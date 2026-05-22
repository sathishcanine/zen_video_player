import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_ids.dart';
import 'ad_network.dart';
import 'ad_throttle.dart';

/// Google AdMob adapter.
///
/// Soft circuit breaker:
///   When an AdMob account is under "ad serving limit", every load
///   returns ERROR_CODE_NO_FILL (3). Hammering the network unit on
///   every request wastes the global hourly budget that the orchestrator
///   shares across all adapters and slows the fallback to Unity/InMobi.
///   After [_maxConsecutiveNoFills] consecutive failures (no-fill or
///   otherwise) for the rewarded slot, AdMob rewarded is skipped for
///   [_circuitCooldown].
class AdmobAdapter implements AdNetwork {
  final String rewardedUnitId;
  final String bannerUnitId;

  /// Defaults come from [ad_ids] (`kUseTestAdIds` / Google sample units).
  AdmobAdapter({
    String? rewardedUnitId,
    String? bannerUnitId,
  })  : rewardedUnitId = rewardedUnitId ?? adMobRewardedUnitId,
        bannerUnitId = bannerUnitId ?? adMobBannerUnitId;

  @override
  String get name => 'admob';

  static const int _maxConsecutiveNoFills = 5;
  static const Duration _circuitCooldown = Duration(minutes: 3);
  static const int _adMobErrorNoFill = 3;

  bool _initialized = false;
  @override
  bool get isInitialized => _initialized;

  RewardedAd? _rewarded;
  bool _rewardedLoading = false;
  int _rewardedFailures = 0;
  DateTime? _rewardedBreakerOpenedAt;

  bool _circuitOpen(DateTime? openedAt, void Function() reset) {
    if (openedAt == null) return false;
    if (DateTime.now().difference(openedAt) >= _circuitCooldown) {
      reset();
      return false;
    }
    return true;
  }

  @override
  Future<void> init() async {
    if (_initialized) return;
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
    } catch (e) {
      debugPrint('[admob] init failed: $e');
    }
  }

  @override
  void preloadRewarded() {
    if (!_initialized || _rewarded != null || _rewardedLoading) return;
    if (_circuitOpen(_rewardedBreakerOpenedAt, () {
      _rewardedBreakerOpenedAt = null;
      _rewardedFailures = 0;
      debugPrint('[admob] rewarded circuit reset');
    })) {
      return;
    }
    _rewardedLoading = true;
    AdThrottle.recordRequest();
    RewardedAd.load(
      adUnitId: rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewarded = ad;
          _rewardedLoading = false;
          _rewardedFailures = 0;
          _rewardedBreakerOpenedAt = null;
        },
        onAdFailedToLoad: (err) {
          _rewarded = null;
          _rewardedLoading = false;
          _rewardedFailures += 1;
          debugPrint(
            '[admob] rewarded failed (#$_rewardedFailures): '
            '${err.code} ${err.message}',
          );
          if (_rewardedFailures >= _maxConsecutiveNoFills &&
              _rewardedBreakerOpenedAt == null) {
            _rewardedBreakerOpenedAt = DateTime.now();
            debugPrint(
              '[admob] rewarded circuit tripped after '
              '$_rewardedFailures consecutive failures. Skipping for '
              '${_circuitCooldown.inMinutes} min. '
              '${err.code == _adMobErrorNoFill ? "(ERROR_CODE_NO_FILL — typically AdMob ad serving limit on this account)" : ""}',
            );
          }
        },
      ),
    );
  }

  @override
  Future<bool> showRewarded({
    required VoidCallback onReward,
    VoidCallback? onAdOpening,
  }) async {
    final ad = _rewarded;
    if (ad == null) {
      preloadRewarded();
      return false;
    }
    bool earned = false;
    final completer = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => onAdOpening?.call(),
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        _rewarded = null;
        if (earned) onReward();
        if (!completer.isCompleted) completer.complete(true);
        preloadRewarded();
      },
      onAdFailedToShowFullScreenContent: (a, _) {
        a.dispose();
        _rewarded = null;
        if (!completer.isCompleted) completer.complete(false);
        preloadRewarded();
      },
    );
    ad.show(onUserEarnedReward: (_, __) {
      earned = true;
    });
    return completer.future;
  }

  @override
  Widget? buildBanner() => buildBannerWithUnitId(bannerUnitId);

  /// Banner with an explicit AdMob unit (e.g. full vs limited home placement).
  Widget? buildBannerWithUnitId(String unitId) {
    if (!_initialized) return null;
    return _AdmobBanner(key: ValueKey<String>(unitId), unitId: unitId);
  }
}

class _AdmobBanner extends StatefulWidget {
  final String unitId;
  const _AdmobBanner({super.key, required this.unitId});

  @override
  State<_AdmobBanner> createState() => _AdmobBannerState();
}

class _AdmobBannerState extends State<_AdmobBanner> {
  BannerAd? _ad;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  @override
  void didUpdateWidget(covariant _AdmobBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.unitId != widget.unitId) {
      _ad?.dispose();
      _ad = null;
      _failed = false;
      _loadBanner();
    }
  }

  void _loadBanner() {
    AdThrottle.recordRequest();
    _ad = BannerAd(
      size: AdSize.banner,
      adUnitId: widget.unitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() {});
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          if (mounted) setState(() => _failed = true);
          debugPrint('[admob] banner failed: ${err.code} ${err.message}');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (_failed || ad == null) return const SizedBox.shrink();
    return SizedBox(
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}
