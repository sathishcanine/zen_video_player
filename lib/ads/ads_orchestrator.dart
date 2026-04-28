import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'ad_config.dart';
import 'ad_network.dart';
import 'ad_throttle.dart';
import 'admob_adapter.dart';
import 'inmobi_adapter.dart';
import 'unity_adapter.dart';

/// Single entry point all UI code should use to request ads.
///
/// Why this exists:
///   - The app talks to an interface; networks can be added/removed
///     without touching UI code.
///   - The fallback chain (primary -> secondary -> tertiary) is driven
///     by [AdConfig] so it's swappable at runtime via deeplink.
///   - Throttling lives here, so every network shares the same
///     hourly cap and inter-ad gap. This is what protects us from
///     the AdMob "ad serving limit" caused by request bursts.
class AdsOrchestrator {
  AdsOrchestrator._();

  static AdConfig _config = AdConfig.defaults();
  static AdConfig get config => _config;

  static final List<AdNetwork> _registry = [
    AdmobAdapter(),
    UnityAdapter(),
    InMobiAdapter(),
  ];

  static bool _booted = false;

  /// Initialize the orchestrator. Loads persisted config and inits
  /// every network listed in the config (in parallel).
  static Future<void> init() async {
    if (_booted) return;
    _booted = true;
    _config = await AdConfig.load();
    debugPrint('[ads] boot config: $_config');
    await _initEnabledNetworks();
    _preloadPrimary();
  }

  /// Apply a new config (typically parsed from a deeplink) at runtime.
  /// Newly-enabled networks get initialized; already-enabled ones
  /// keep their state.
  static Future<void> applyConfig(AdConfig newConfig) async {
    _config = newConfig;
    debugPrint('[ads] config updated: $_config');
    await newConfig.save();
    await _initEnabledNetworks();
    _preloadPrimary();
  }

  static Future<void> _initEnabledNetworks() async {
    final futures = <Future<void>>[];
    for (final n in _orderedNetworks()) {
      if (!n.isInitialized) {
        futures.add(n.init().catchError(
          (e) => debugPrint('[ads] ${n.name} init error: $e'),
        ));
      }
    }
    await Future.wait(futures);
  }

  static void _preloadPrimary() {
    final list = _orderedNetworks();
    if (list.isEmpty) return;
    final primary = list.first;
    if (_config.rewardedEnabled) primary.preloadRewarded();
  }

  /// Networks resolved from the config's order, skipping unknown names.
  static List<AdNetwork> _orderedNetworks() {
    final result = <AdNetwork>[];
    for (final name in _config.adOrder) {
      for (final n in _registry) {
        if (n.name == name) {
          result.add(n);
          break;
        }
      }
    }
    return result;
  }

  /// Try to show a rewarded ad. If no network can serve one, [onReward]
  /// is still called so the user isn't blocked by ad failures.
  static Future<bool> showRewarded({required VoidCallback onReward}) async {
    if (!_config.rewardedEnabled) {
      onReward();
      return false;
    }
    if (!AdThrottle.canRequest(_config.maxRequestsPerHour)) {
      debugPrint('[ads] rewarded fallthrough: hourly cap reached');
      onReward();
      return false;
    }
    final tried = <String>[];
    for (final n in _orderedNetworks()) {
      tried.add(n.name);
      try {
        final shown = await n.showRewarded(onReward: onReward);
        if (shown) return true;
      } catch (e) {
        debugPrint('[ads] ${n.name} rewarded threw: $e');
      }
    }
    debugPrint(
      '[ads] rewarded chain exhausted: tried=$tried — granting reward '
      'anyway so the user is not blocked by ad failures.',
    );
    onReward();
    return false;
  }

  /// Build a banner widget from the first network in the chain that
  /// can produce one. Returns null when banner is disabled or every
  /// network is unavailable (caller should render [SizedBox.shrink]).
  static Widget? buildBanner() {
    if (!_config.bannerEnabled) return null;
    for (final n in _orderedNetworks()) {
      final w = n.buildBanner();
      if (w != null) return w;
    }
    return null;
  }
}
