import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

import 'ad_ids.dart';
import 'ad_network.dart';
import 'ad_throttle.dart';

/// Unity Ads adapter.
///
/// Game IDs and placement IDs come from the Unity Dashboard. Pass
/// overrides via the constructor for staging / per-flavor builds.
///
/// Resilience:
///   - `init()` is retried with exponential backoff up to
///     [_maxInitAttempts] times. A persistent failure leaves the
///     adapter idle (orchestrator falls through to AdMob/InMobi).
///   - Load failures with transient codes (network / INIT_UNKNOWN)
///     trigger a backed-off retry up to [_maxLoadAttempts] times,
///     scoped to a single load chain. Each external preload starts a
///     fresh chain.
///   - Receiving [UnityAdsLoadError.initializeFailed] (or a message that
///     clearly requires re-init) clears [_initialized] so the next preload
///     runs [init] again. Generic **network** load failures do not re-init —
///     we only retry [load] so the retry path does not hit `!_initialized`
///     and return without loading.
///   - A circuit breaker trips after [_maxConsecutiveFailures]
///     consecutive failures and skips Unity entirely for
///     [_circuitCooldown]. This prevents wasting the global request
///     budget (AdThrottle) and quietens log spam when the Game ID is
///     misconfigured or Unity's endpoints are unreachable.
class UnityAdapter implements AdNetwork {
  final String androidGameId;
  final String iosGameId;

  final String rewardedPlacementAndroid;
  final String rewardedPlacementIos;
  final String bannerPlacementAndroid;
  final String bannerPlacementIos;

  final bool testMode;

  /// Game IDs and [testMode] default from [ad_ids] (see [kUseTestAdIds]).
  UnityAdapter({
    String? androidGameId,
    String? iosGameId,
    this.rewardedPlacementAndroid = 'Rewarded_Android',
    this.rewardedPlacementIos = 'Rewarded_iOS',
    this.bannerPlacementAndroid = 'Banner_Android',
    this.bannerPlacementIos = 'Banner_iOS',
    bool? testMode,
  })  : androidGameId = androidGameId ?? unityAndroidGameId,
        iosGameId = iosGameId ?? unityIosGameId,
        testMode = testMode ?? unityAdsTestMode;

  @override
  String get name => 'unity';

  static const int _maxInitAttempts = 3;
  static const int _maxLoadAttempts = 3;
  static const Duration _baseBackoff = Duration(seconds: 2);
  static const int _maxConsecutiveFailures = 6;
  static const Duration _circuitCooldown = Duration(minutes: 5);

  /// Unity sometimes returns `INIT_UNKNOWN` on the *first* load if it races
  /// the native `onComplete` callback. A short pause before the first
  /// `load` and before building [UnityBannerAd] reduces that.
  static const Duration _postInitLoadDelay = Duration(milliseconds: 1200);

  bool _initialized = false;
  bool _initInFlight = false;
  int _initAttempts = 0;

  @override
  bool get isInitialized => _initialized;

  bool _rewardedReady = false;

  // Tracks an in-flight retry chain so external preload triggers
  // don't double-fire. Reset on every terminal outcome.
  bool _rewardedChainActive = false;

  // Circuit breaker state.
  int _consecutiveFailures = 0;
  DateTime? _circuitOpenedAt;

  String get _gameId => Platform.isIOS ? iosGameId : androidGameId;
  String get _rewardedPlacement =>
      Platform.isIOS ? rewardedPlacementIos : rewardedPlacementAndroid;
  String get _bannerPlacement =>
      Platform.isIOS ? bannerPlacementIos : bannerPlacementAndroid;

  bool get _circuitOpen {
    final openedAt = _circuitOpenedAt;
    if (openedAt == null) return false;
    if (DateTime.now().difference(openedAt) >= _circuitCooldown) {
      _circuitOpenedAt = null;
      _consecutiveFailures = 0;
      debugPrint('[unity] circuit breaker reset; will retry Unity Ads.');
      return false;
    }
    return true;
  }

  void _recordSuccess() {
    _consecutiveFailures = 0;
    _circuitOpenedAt = null;
  }

  void _recordFailure() {
    _consecutiveFailures += 1;
    if (_consecutiveFailures >= _maxConsecutiveFailures &&
        _circuitOpenedAt == null) {
      _circuitOpenedAt = DateTime.now();
      debugPrint(
        '[unity] circuit breaker tripped after $_consecutiveFailures '
        'consecutive failures. Skipping Unity for '
        '${_circuitCooldown.inMinutes} min. Verify gameId="$_gameId", '
        'test mode (${testMode ? "ON" : "OFF"}) matches the Unity '
        'dashboard, and that Unity Ads endpoints are not blocked.',
      );
    }
  }

  @override
  Future<void> init() async {
    if (_initialized || _initInFlight) return;
    if (_circuitOpen) return;
    _initInFlight = true;
    try {
      await _initOnce();
    } finally {
      _initInFlight = false;
    }
  }

  Future<void> _initOnce() async {
    final completer = Completer<void>();
    try {
      UnityAds.init(
        gameId: _gameId,
        testMode: testMode,
        onComplete: () {
          // Native may report init callback slightly before
          // `isInitialized` flips; wait so the first load is less likely to
          // get PUBLIC_ERROR_CODE_INIT_UNKNOWN.
          unawaited(_afterInitCallback(completer));
        },
        onFailed: (error, message) {
          _initAttempts += 1;
          _recordFailure();
          debugPrint(
            '[unity] init failed (attempt $_initAttempts/'
            '$_maxInitAttempts): $error $message',
          );
          if (_initAttempts >= _maxInitAttempts) {
            debugPrint(
              '[unity] giving up on init. Verify gameId="$_gameId", '
              'that the device has internet access to Unity Ads '
              'endpoints, and that test mode '
              '(${testMode ? "ON" : "OFF"}) matches the Unity dashboard.',
            );
          } else {
            // Schedule a retry; do not block the current init() future
            // on it so the orchestrator can move on to other networks.
            Future.delayed(_backoff(_initAttempts), () {
              if (!_initialized && !_circuitOpen) {
                _initInFlight = false;
                init();
              }
            });
          }
          if (!completer.isCompleted) completer.complete();
        },
      );
    } catch (e) {
      _recordFailure();
      debugPrint('[unity] init threw: $e');
      if (!completer.isCompleted) completer.complete();
    }
    return completer.future;
  }

  /// Wait for the native layer to report initialized before completing
  /// [init] so [preloadRewarded] / banner do not race the gateway.
  Future<void> _afterInitCallback(Completer<void> completer) async {
    for (var i = 0; i < 30; i++) {
      try {
        if (await UnityAds.isInitialized()) {
          _initialized = true;
          _initAttempts = 0;
          _recordSuccess();
          debugPrint(
            '[unity] init complete (isInitialized=true, poll #${i + 1}) '
            'gameId=$_gameId testMode=$testMode',
          );
          if (!completer.isCompleted) completer.complete();
          return;
        }
      } catch (e) {
        debugPrint('[unity] isInitialized poll: $e');
      }
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
    debugPrint(
      '[unity] isInitialized() still false after 6s; completing init anyway '
      '(if loads fail with "Network error", check VPN/DNS or Unity service)',
    );
    if (!_initialized) {
      _initialized = true;
      _initAttempts = 0;
      _recordSuccess();
    }
    if (!completer.isCompleted) completer.complete();
  }

  @override
  void preloadRewarded() {
    if (_circuitOpen) return;
    if (_rewardedReady || _rewardedChainActive) return;
    _rewardedChainActive = true;
    _loadAttempt(attempt: 1);
  }

  void _loadAttempt({required int attempt}) {
    if (_circuitOpen) {
      _rewardedChainActive = false;
      return;
    }
    if (!_initialized) {
      // Kick off init in the background; once it lands, the next
      // preload tick will start a fresh chain. We end this chain now
      // so it isn't left hanging.
      _rewardedChainActive = false;
      init();
      return;
    }

    void runLoad() {
      if (_circuitOpen) {
        _rewardedChainActive = false;
        return;
      }
      AdThrottle.recordRequest();
      UnityAds.load(
        placementId: _rewardedPlacement,
        onComplete: (_) {
          _rewardedReady = true;
          _recordSuccess();
          _rewardedChainActive = false;
        },
        onFailed: (placement, error, message) {
          _rewardedReady = false;
          _recordFailure();
          debugPrint(
            '[unity] rewarded load failed (attempt $attempt/$_maxLoadAttempts) '
            '$placement: $error $message',
          );

          // Only force a new `UnityAds.init` when the *load* error says the
          // SDK is not initialized. A plain "Network error" / timeout often
          // still has isInitialized==true; re-init then spams a second init
          // and breaks the load retry path (we'd hit `!_initialized` and
          // return before `load()`).
          if (_loadFailureRequiresSdkReinit(error, message)) {
            _initialized = false;
            _initAttempts = 0;
            debugPrint('[unity] load failure requires SDK reinit; will re-init on next attempt');
          }

          if (attempt < _maxLoadAttempts && !_circuitOpen) {
            Future.delayed(_backoff(attempt), () {
              _loadAttempt(attempt: attempt + 1);
            });
          } else {
            if (!_circuitOpen) {
              debugPrint(
                '[unity] giving up on rewarded preload until the next '
                'show attempt.',
              );
            }
            _rewardedChainActive = false;
          }
        },
      );
    }

    if (attempt == 1) {
      Future.delayed(_postInitLoadDelay, runLoad);
    } else {
      runLoad();
    }
  }

  @override
  Future<bool> showRewarded({
    required VoidCallback onReward,
    VoidCallback? onAdOpening,
  }) async {
    if (_circuitOpen) return false;
    if (!_initialized || !_rewardedReady) {
      preloadRewarded();
      return false;
    }
    final completer = Completer<bool>();
    UnityAds.showVideoAd(
      placementId: _rewardedPlacement,
      onComplete: (_) {
        _rewardedReady = false;
        onReward();
        if (!completer.isCompleted) completer.complete(true);
        preloadRewarded();
      },
      onFailed: (_, error, message) {
        _rewardedReady = false;
        debugPrint('[unity] rewarded show failed: $error $message');
        if (!completer.isCompleted) completer.complete(false);
        preloadRewarded();
      },
      onSkipped: (_) {
        _rewardedReady = false;
        if (!completer.isCompleted) completer.complete(true);
        preloadRewarded();
      },
      onStart: (_) => onAdOpening?.call(),
      onClick: (_) {},
    );
    return completer.future;
  }

  @override
  Widget? buildBanner() {
    if (!_initialized || _circuitOpen) return null;
    return _UnityBannerDeferred(
      postInitDelay: _postInitLoadDelay,
      placementId: _bannerPlacement,
      onLoad: (_) => _recordSuccess(),
      onFailed: (placement, error, message) {
        _recordFailure();
        debugPrint('[unity] banner failed: $error $message');
      },
    );
  }

  /// Exponential backoff capped to ~16s; jitter is unnecessary here
  /// because a single device only fans out to one Unity endpoint.
  Duration _backoff(int attempt) {
    final factor = 1 << (attempt - 1).clamp(0, 3);
    return _baseBackoff * factor;
  }

  /// When true, the next [preloadRewarded] should run [init] again. Do **not**
  /// use this for generic connectivity failures: those should retry [load] only
  /// while [isInitialized] stays true, or the retry path hits `!_initialized`
  /// and bails without loading.
  bool _loadFailureRequiresSdkReinit(UnityAdsLoadError error, String message) {
    if (error == UnityAdsLoadError.initializeFailed) return true;
    final m = message.toLowerCase();
    if (m.contains('init_unknown')) return true;
    if (m.contains('not initialized') || m.contains('notinitialized')) {
      return true;
    }
    // Do not match generic "network error" — native often maps real network
    // issues to `INIT_UNKNOWN` in logs while the Flutter [message] is only
    // "Network error occurred", which is not fixed by calling init() again.
    return false;
  }
}

/// Short delay before mounting [UnityBannerAd] so the first request does not
/// race Unity init (`PUBLIC_ERROR_CODE_INIT_UNKNOWN`).
class _UnityBannerDeferred extends StatefulWidget {
  const _UnityBannerDeferred({
    required this.postInitDelay,
    required this.placementId,
    this.onLoad,
    this.onFailed,
  });

  final Duration postInitDelay;
  final String placementId;
  final void Function(String placementId)? onLoad;
  final void Function(
    String placementId,
    UnityAdsBannerError error,
    String message,
  )? onFailed;

  @override
  State<_UnityBannerDeferred> createState() => _UnityBannerDeferredState();
}

class _UnityBannerDeferredState extends State<_UnityBannerDeferred> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.postInitDelay, () {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      height: 50,
      child: _ready
          ? UnityBannerAd(
              placementId: widget.placementId,
              onLoad: widget.onLoad,
              onClick: (_) {},
              onFailed: widget.onFailed,
            )
          : const SizedBox.shrink(),
    );
  }
}
