import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ad_ids.dart';
import 'ad_network.dart';
import 'ad_throttle.dart';

/// InMobi adapter.
///
/// InMobi has no official Flutter SDK, so this adapter speaks to a
/// native bridge over the [_channelName] method channel. The bridges
/// live in:
///   - android: `android/app/src/main/kotlin/.../InMobiBridge.kt`
///   - ios:     `ios/Runner/InMobiBridge.swift`
///
/// Replace the default account / placement IDs with values from your
/// InMobi Monetization dashboard before shipping. Note that InMobi
/// (like Unity) does NOT publish universal test IDs — every placement
/// is bound to a specific account and ad format.
///
/// Resilience:
///   - A circuit breaker trips after [_maxConsecutiveFailures]
///     consecutive failures and skips InMobi for [_circuitCooldown].
///     This avoids burning the global hourly request budget on a
///     placement the auction server keeps rejecting (typical when the
///     account/placement IDs are stale or the device GAID isn't
///     registered as a test device).
///   - Chain-active guards prevent overlapping preloads.
class InMobiAdapter implements AdNetwork {
  static const String _channelName = 'zen.ads/inmobi';

  final MethodChannel _channel;

  final String accountId;

  final String rewardedPlacementId;
  final String bannerPlacementId;

  /// Account / placement IDs default from [ad_ids] (see [kUseTestAdIds]).
  InMobiAdapter({
    String? accountId,
    String? rewardedPlacementId,
    String? bannerPlacementId,
  })  : accountId = accountId ?? inMobiAccountId,
        rewardedPlacementId = rewardedPlacementId ?? inMobiRewardedPlacementId,
        bannerPlacementId = bannerPlacementId ?? inMobiBannerPlacementId,
        _channel = const MethodChannel(_channelName);

  @override
  String get name => 'inmobi';

  static const int _maxConsecutiveFailures = 4;
  static const Duration _circuitCooldown = Duration(minutes: 5);

  bool _initialized = false;
  @override
  bool get isInitialized => _initialized;

  bool _rewardedReady = false;
  bool _rewardedLoadInFlight = false;

  int _consecutiveFailures = 0;
  DateTime? _circuitOpenedAt;

  bool get _circuitOpen {
    final openedAt = _circuitOpenedAt;
    if (openedAt == null) return false;
    if (DateTime.now().difference(openedAt) >= _circuitCooldown) {
      _circuitOpenedAt = null;
      _consecutiveFailures = 0;
      debugPrint('[inmobi] circuit breaker reset; will retry InMobi.');
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
        '[inmobi] circuit breaker tripped after $_consecutiveFailures '
        'consecutive failures. Skipping InMobi for '
        '${_circuitCooldown.inMinutes} min. Verify accountId='
        '"$accountId", that the rewarded placement '
        '"$rewardedPlacementId" is configured as a Rewarded ad in the '
        'InMobi dashboard, and that this device\'s GAID is registered '
        'as a Test Device.',
      );
    }
  }

  @override
  Future<void> init() async {
    if (_initialized) return;
    if (_circuitOpen) return;
    try {
      final ok = await _channel.invokeMethod<bool>('init', {
        'accountId': accountId,
      });
      _initialized = ok ?? false;
      if (_initialized) {
        _recordSuccess();
      } else {
        _recordFailure();
      }
    } on MissingPluginException {
      // Native side not wired yet; degrade gracefully.
      _initialized = false;
    } catch (e) {
      debugPrint('[inmobi] init failed: $e');
      _initialized = false;
      _recordFailure();
    }
  }

  @override
  void preloadRewarded() {
    if (_circuitOpen) return;
    if (!_initialized || _rewardedReady) return;
    if (_rewardedLoadInFlight) return;
    _rewardedLoadInFlight = true;
    AdThrottle.recordRequest();
    _channel.invokeMethod('loadRewarded', {
      'placementId': rewardedPlacementId,
    }).then((value) {
      final ok = value == true;
      _rewardedReady = ok;
      if (ok) {
        _recordSuccess();
      } else {
        _recordFailure();
      }
    }).catchError((e) {
      _rewardedReady = false;
      debugPrint('[inmobi] rewarded load failed: $e');
      _recordFailure();
    }).whenComplete(() {
      _rewardedLoadInFlight = false;
    });
  }

  @override
  Future<bool> showRewarded({required VoidCallback onReward}) async {
    if (_circuitOpen) return false;
    if (!_rewardedReady) {
      preloadRewarded();
      return false;
    }
    try {
      final result = await _channel.invokeMethod<Map>('showRewarded');
      _rewardedReady = false;
      preloadRewarded();
      if (result == null) return false;
      if (result['rewarded'] == true) onReward();
      return result['shown'] == true;
    } catch (e) {
      _rewardedReady = false;
      debugPrint('[inmobi] rewarded show failed: $e');
      _recordFailure();
      return false;
    }
  }

  @override
  Widget? buildBanner() {
    // Native banner would require an AndroidView/UiKitView wired to
    // the platform side. Returning null until that's implemented so
    // the orchestrator falls through to the next network.
    return null;
  }
}
