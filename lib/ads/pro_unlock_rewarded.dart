import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_ids.dart';
import 'ad_throttle.dart';
import 'ads_orchestrator.dart';

/// Rewarded ad for unlocking Pro settings (dedicated AdMob unit).
class ProUnlockRewarded {
  ProUnlockRewarded._();

  static const Duration _loadTimeout = Duration(seconds: 25);

  /// Shows the pro-unlock rewarded ad. Returns true only if the user earned
  /// the reward. Does not grant unlock on load/show failure.
  static Future<bool> show({
    required VoidCallback onReward,
    VoidCallback? onAdOpening,
  }) async {
    if (kIsWeb) return false;
    if (!AdsOrchestrator.config.rewardedEnabled) return false;
    if (!AdThrottle.canRequest(AdsOrchestrator.config.maxRequestsPerHour)) {
      debugPrint('[ads] pro unlock rewarded: hourly cap');
      return false;
    }

    await MobileAds.instance.initialize();
    AdThrottle.recordRequest();

    final ad = await _load();
    if (ad == null) return false;

    var earned = false;
    final completer = Completer<bool>();

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => onAdOpening?.call(),
      onAdDismissedFullScreenContent: (dismissed) {
        dismissed.dispose();
        if (earned) onReward();
        if (!completer.isCompleted) completer.complete(earned);
      },
      onAdFailedToShowFullScreenContent: (failed, err) {
        failed.dispose();
        debugPrint('[ads] pro unlock show failed: ${err.message}');
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    ad.show(onUserEarnedReward: (_, __) {
      earned = true;
    });

    return completer.future;
  }

  static Future<RewardedAd?> _load() async {
    final completer = Completer<RewardedAd?>();

    RewardedAd.load(
      adUnitId: adMobProUnlockRewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: completer.complete,
        onAdFailedToLoad: (err) {
          debugPrint(
            '[ads] pro unlock load failed: ${err.code} ${err.message}',
          );
          completer.complete(null);
        },
      ),
    );

    try {
      return await completer.future.timeout(_loadTimeout);
    } on TimeoutException {
      debugPrint('[ads] pro unlock load timed out');
      return null;
    }
  }
}
