import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_ids.dart';
import 'ad_network.dart';
import 'ad_throttle.dart';

/// Google AdMob adapter.
///
/// Rewarded waterfall (single network):
///   1. Standard rewarded ad
///   2. Rewarded interstitial when rewarded fails to fill
///
/// Soft circuit breaker on the rewarded slot:
///   When an AdMob account is under "ad serving limit", every load
///   returns ERROR_CODE_NO_FILL (3). After [_maxConsecutiveNoFills]
///   consecutive failures, rewarded is skipped for [_circuitCooldown]
///   and the adapter tries rewarded interstitial instead.
class AdmobAdapter implements AdNetwork {
  final String rewardedUnitId;
  final String rewardedInterstitialUnitId;
  final String bannerUnitId;

  /// Defaults come from [ad_ids] (`kUseTestAdIds` / Google sample units).
  AdmobAdapter({
    String? rewardedUnitId,
    String? rewardedInterstitialUnitId,
    String? bannerUnitId,
  })  : rewardedUnitId = rewardedUnitId ?? adMobRewardedUnitId,
        rewardedInterstitialUnitId =
            rewardedInterstitialUnitId ?? adMobRewardedInterstitialUnitId,
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

  RewardedInterstitialAd? _rewardedInterstitial;
  bool _rewardedInterstitialLoading = false;
  int _rewardedInterstitialFailures = 0;
  DateTime? _rewardedInterstitialBreakerOpenedAt;

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

  bool get _rewardedCircuitOpen => _circuitOpen(_rewardedBreakerOpenedAt, () {
        _rewardedBreakerOpenedAt = null;
        _rewardedFailures = 0;
        debugPrint('[admob] rewarded circuit reset');
      });

  bool get _rewardedInterstitialCircuitOpen =>
      _circuitOpen(_rewardedInterstitialBreakerOpenedAt, () {
        _rewardedInterstitialBreakerOpenedAt = null;
        _rewardedInterstitialFailures = 0;
        debugPrint('[admob] rewarded interstitial circuit reset');
      });

  /// True once rewarded has failed or its circuit is open — interstitial may load.
  bool get _shouldTryRewardedInterstitial =>
      _rewarded == null &&
      !_rewardedLoading &&
      (_rewardedFailures > 0 || _rewardedCircuitOpen);

  @override
  void preloadRewarded() {
    if (!_initialized) return;

    if (_rewarded == null &&
        !_rewardedLoading &&
        !_rewardedCircuitOpen) {
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
            _preloadRewardedInterstitial();
          },
        ),
      );
    }

    if (_shouldTryRewardedInterstitial) {
      _preloadRewardedInterstitial();
    }
  }

  void _preloadRewardedInterstitial() {
    if (!_initialized ||
        _rewardedInterstitial != null ||
        _rewardedInterstitialLoading ||
        _rewardedInterstitialCircuitOpen) {
      return;
    }
    _rewardedInterstitialLoading = true;
    AdThrottle.recordRequest();
    RewardedInterstitialAd.load(
      adUnitId: rewardedInterstitialUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedInterstitial = ad;
          _rewardedInterstitialLoading = false;
          _rewardedInterstitialFailures = 0;
          _rewardedInterstitialBreakerOpenedAt = null;
          debugPrint('[admob] rewarded interstitial loaded');
        },
        onAdFailedToLoad: (err) {
          _rewardedInterstitial = null;
          _rewardedInterstitialLoading = false;
          _rewardedInterstitialFailures += 1;
          debugPrint(
            '[admob] rewarded interstitial failed '
            '(#$_rewardedInterstitialFailures): ${err.code} ${err.message}',
          );
          if (_rewardedInterstitialFailures >= _maxConsecutiveNoFills &&
              _rewardedInterstitialBreakerOpenedAt == null) {
            _rewardedInterstitialBreakerOpenedAt = DateTime.now();
            debugPrint(
              '[admob] rewarded interstitial circuit tripped after '
              '$_rewardedInterstitialFailures consecutive failures. '
              'Skipping for ${_circuitCooldown.inMinutes} min.',
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
    final rewarded = _rewarded;
    if (rewarded != null) {
      return _showLoadedRewarded(rewarded, onReward, onAdOpening);
    }

    final interstitial = _rewardedInterstitial;
    if (interstitial != null) {
      debugPrint('[admob] showing rewarded interstitial fallback');
      return _showLoadedRewardedInterstitial(
        interstitial,
        onReward,
        onAdOpening,
      );
    }

    preloadRewarded();
    return false;
  }

  Future<bool> _showLoadedRewarded(
    RewardedAd ad,
    VoidCallback onReward,
    VoidCallback? onAdOpening,
  ) async {
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
        _preloadRewardedInterstitial();
        preloadRewarded();
      },
    );
    ad.show(onUserEarnedReward: (_, __) {
      earned = true;
    });
    return completer.future;
  }

  Future<bool> _showLoadedRewardedInterstitial(
    RewardedInterstitialAd ad,
    VoidCallback onReward,
    VoidCallback? onAdOpening,
  ) async {
    bool earned = false;
    final completer = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => onAdOpening?.call(),
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        _rewardedInterstitial = null;
        if (earned) onReward();
        if (!completer.isCompleted) completer.complete(true);
        preloadRewarded();
      },
      onAdFailedToShowFullScreenContent: (a, _) {
        a.dispose();
        _rewardedInterstitial = null;
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

  /// Banner with an explicit AdMob unit.
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
