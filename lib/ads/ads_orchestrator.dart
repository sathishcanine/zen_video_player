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

  /// How long we keep polling one network for a fill before trying the next.
  static const Duration _rewardedNetworkPollBudget = Duration(seconds: 20);

  /// Delay between attempts while waiting for a rewarded load.
  static const Duration _rewardedPollInterval = Duration(milliseconds: 400);

  static AdConfig _config = AdConfig.defaults();
  static AdConfig get config => _config;

  static final List<AdNetwork> _registry = [
    AdmobAdapter(),
    UnityAdapter(),
    InMobiAdapter(),
  ];

  static bool _booted = false;

  /// Initialize the orchestrator. Loads persisted config, optionally merges
  /// [coldStartUri] before any SDK runs so e.g. `ads=admob` avoids initializing
  /// Unity/InMobi on the same cold start.
  static Future<void> init({Uri? coldStartUri}) async {
    if (_booted) return;
    _booted = true;
    _config = await AdConfig.load();
    if (coldStartUri != null) {
      _config = AdConfig.fromUri(coldStartUri, _config);
      await _config.save();
    }
    debugPrint('[ads] boot config: $_config');
    debugPrint(
      '[ads] active network chain (init/preload/rewarded/banner): '
      '${_orderedNetworks().map((n) => n.name).join(",")}',
    );
    await _initEnabledNetworks();
    _preloadPrimary();
  }

  /// Apply a new config (typically parsed from a deeplink) at runtime.
  /// Newly-enabled networks get initialized; already-enabled ones
  /// keep their state.
  static Future<void> applyConfig(AdConfig newConfig) async {
    _config = newConfig;
    debugPrint('[ads] config updated: $_config');
    debugPrint(
      '[ads] active network chain: '
      '${_orderedNetworks().map((n) => n.name).join(",")}',
    );
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

  /// Networks resolved from [AdConfig.adOrder] only — registry entries not
  /// listed here are never initialized, preloaded, or shown for rewarded/banner.
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
  ///
  /// [onAdOpening] runs when a full-screen ad is about to show (e.g. to
  /// hide a loading overlay). It may be called at most once per successful
  /// presentation.
  static Future<bool> showRewarded({
    required VoidCallback onReward,
    VoidCallback? onAdOpening,
  }) async {
    if (!_config.rewardedEnabled) {
      onReward();
      return false;
    }
    if (!AdThrottle.canRequest(_config.maxRequestsPerHour)) {
      debugPrint('[ads] rewarded fallthrough: hourly cap reached');
      onReward();
      return false;
    }
    final networks = _orderedNetworks();
    if (networks.isEmpty) {
      debugPrint('[ads] rewarded: no networks in config order');
      onReward();
      return false;
    }
    final tried = <String>[];
    for (final n in networks) {
      tried.add(n.name);
      final networkStart = DateTime.now();
      while (DateTime.now().difference(networkStart) < _rewardedNetworkPollBudget) {
        try {
          n.preloadRewarded();
          final shown = await n.showRewarded(
            onReward: onReward,
            onAdOpening: onAdOpening,
          );
          if (shown) return true;
        } catch (e) {
          debugPrint('[ads] ${n.name} rewarded threw: $e');
        }
        await Future<void>.delayed(_rewardedPollInterval);
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
