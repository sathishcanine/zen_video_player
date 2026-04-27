import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

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
///   - Receiving INIT_UNKNOWN at load time forces a full re-init,
///     because Unity can land in that state after a connectivity
///     blip even though `onComplete` had previously fired.
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

  /// Unity dashboard supports a separate interstitial placement; we
  /// keep platform-specific defaults so the adapter stays symmetric
  /// even though the current app flow primarily uses rewarded.
  final String interstitialPlacementAndroid;
  final String interstitialPlacementIos;

  final bool testMode;

  UnityAdapter({
    this.androidGameId = '6100151',
    this.iosGameId = '6100150',
    this.rewardedPlacementAndroid = 'Rewarded_Android',
    this.rewardedPlacementIos = 'Rewarded_iOS',
    this.bannerPlacementAndroid = 'Banner_Android',
    this.bannerPlacementIos = 'Banner_iOS',
    this.interstitialPlacementAndroid = 'Interstitial_Android',
    this.interstitialPlacementIos = 'Interstitial_iOS',
    this.testMode = true,
  });

  @override
  String get name => 'unity';

  static const int _maxInitAttempts = 3;
  static const int _maxLoadAttempts = 3;
  static const Duration _baseBackoff = Duration(seconds: 2);
  static const int _maxConsecutiveFailures = 6;
  static const Duration _circuitCooldown = Duration(minutes: 5);

  bool _initialized = false;
  bool _initInFlight = false;
  int _initAttempts = 0;

  @override
  bool get isInitialized => _initialized;

  bool _interstitialReady = false;
  bool _rewardedReady = false;

  // Tracks an in-flight retry chain so external preload triggers
  // don't double-fire. Reset on every terminal outcome.
  bool _interstitialChainActive = false;
  bool _rewardedChainActive = false;

  // Circuit breaker state.
  int _consecutiveFailures = 0;
  DateTime? _circuitOpenedAt;

  String get _gameId => Platform.isIOS ? iosGameId : androidGameId;
  String get _rewardedPlacement =>
      Platform.isIOS ? rewardedPlacementIos : rewardedPlacementAndroid;
  String get _bannerPlacement =>
      Platform.isIOS ? bannerPlacementIos : bannerPlacementAndroid;
  String get _interstitialPlacement => Platform.isIOS
      ? interstitialPlacementIos
      : interstitialPlacementAndroid;

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
          _initialized = true;
          _initAttempts = 0;
          _recordSuccess();
          if (!completer.isCompleted) completer.complete();
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

  @override
  void preloadInterstitial() {
    if (_circuitOpen) return;
    if (_interstitialReady || _interstitialChainActive) return;
    _interstitialChainActive = true;
    _loadAttempt(isRewarded: false, attempt: 1);
  }

  @override
  void preloadRewarded() {
    if (_circuitOpen) return;
    if (_rewardedReady || _rewardedChainActive) return;
    _rewardedChainActive = true;
    _loadAttempt(isRewarded: true, attempt: 1);
  }

  void _loadAttempt({required bool isRewarded, required int attempt}) {
    if (_circuitOpen) {
      _endChain(isRewarded: isRewarded);
      return;
    }
    if (!_initialized) {
      // Kick off init in the background; once it lands, the next
      // preload tick will start a fresh chain. We end this chain now
      // so it isn't left hanging.
      _endChain(isRewarded: isRewarded);
      init();
      return;
    }

    final placementId =
        isRewarded ? _rewardedPlacement : _interstitialPlacement;
    AdThrottle.recordRequest();
    UnityAds.load(
      placementId: placementId,
      onComplete: (_) {
        if (isRewarded) {
          _rewardedReady = true;
        } else {
          _interstitialReady = true;
        }
        _recordSuccess();
        _endChain(isRewarded: isRewarded);
      },
      onFailed: (placement, error, message) {
        if (isRewarded) {
          _rewardedReady = false;
        } else {
          _interstitialReady = false;
        }
        _recordFailure();
        debugPrint(
          '[unity] ${isRewarded ? "rewarded" : "interstitial"} load '
          'failed (attempt $attempt/$_maxLoadAttempts) '
          '$placement: $error $message',
        );

        // INIT_UNKNOWN at load time means the SDK is in a degraded
        // state (often a post-init network blip). Force a full
        // re-init before the next attempt.
        if (_isInitUnknown(error, message)) {
          _initialized = false;
          _initAttempts = 0;
        }

        if (attempt < _maxLoadAttempts && !_circuitOpen) {
          Future.delayed(_backoff(attempt), () {
            _loadAttempt(isRewarded: isRewarded, attempt: attempt + 1);
          });
        } else {
          if (!_circuitOpen) {
            debugPrint(
              '[unity] giving up on '
              '${isRewarded ? "rewarded" : "interstitial"} preload '
              'until the next show attempt.',
            );
          }
          _endChain(isRewarded: isRewarded);
        }
      },
    );
  }

  void _endChain({required bool isRewarded}) {
    if (isRewarded) {
      _rewardedChainActive = false;
    } else {
      _interstitialChainActive = false;
    }
  }

  @override
  Future<bool> showInterstitial() async {
    if (_circuitOpen) return false;
    if (!_initialized || !_interstitialReady) {
      preloadInterstitial();
      return false;
    }
    final completer = Completer<bool>();
    UnityAds.showVideoAd(
      placementId: _interstitialPlacement,
      onComplete: (_) {
        _interstitialReady = false;
        if (!completer.isCompleted) completer.complete(true);
        preloadInterstitial();
      },
      onFailed: (_, error, message) {
        _interstitialReady = false;
        debugPrint('[unity] interstitial show failed: $error $message');
        if (!completer.isCompleted) completer.complete(false);
        preloadInterstitial();
      },
      onSkipped: (_) {
        _interstitialReady = false;
        if (!completer.isCompleted) completer.complete(true);
        preloadInterstitial();
      },
      onStart: (_) {},
      onClick: (_) {},
    );
    return completer.future;
  }

  @override
  Future<bool> showRewarded({required VoidCallback onReward}) async {
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
      onStart: (_) {},
      onClick: (_) {},
    );
    return completer.future;
  }

  @override
  Widget? buildBanner() {
    if (!_initialized || _circuitOpen) return null;
    return SizedBox(
      width: 320,
      height: 50,
      child: UnityBannerAd(
        placementId: _bannerPlacement,
        onLoad: (_) => _recordSuccess(),
        onClick: (_) {},
        onFailed: (placement, error, message) {
          _recordFailure();
          debugPrint('[unity] banner failed: $error $message');
        },
      ),
    );
  }

  /// Exponential backoff capped to ~16s; jitter is unnecessary here
  /// because a single device only fans out to one Unity endpoint.
  Duration _backoff(int attempt) {
    final factor = 1 << (attempt - 1).clamp(0, 3);
    return _baseBackoff * factor;
  }

  bool _isInitUnknown(UnityAdsLoadError error, String message) {
    if (error == UnityAdsLoadError.initializeFailed) return true;
    final m = message.toLowerCase();
    return m.contains('init_unknown') ||
        m.contains('initialize') ||
        m.contains('network error');
  }
}
