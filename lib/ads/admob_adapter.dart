import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_network.dart';
import 'ad_throttle.dart';

/// Google AdMob adapter.
///
/// Soft circuit breaker:
///   When an AdMob account is under "ad serving limit", every load
///   returns ERROR_CODE_NO_FILL (3). Hammering the network unit on
///   every video play wastes the global hourly request budget that
///   the orchestrator shares across all adapters and slows the
///   fallback to Unity/InMobi. After [_maxConsecutiveNoFills]
///   consecutive failures (no-fill or otherwise) for the same ad
///   type, AdMob is skipped for [_circuitCooldown] for that ad type
///   only — banner does not punish interstitial and vice versa.
class AdmobAdapter implements AdNetwork {
  final String interstitialUnitId;
  final String rewardedUnitId;
  final String bannerUnitId;

  AdmobAdapter({
    this.interstitialUnitId = 'ca-app-pub-4789468551786381/4193593813',
    this.rewardedUnitId = 'ca-app-pub-8723888126390754/7234751166',
    this.bannerUnitId = 'ca-app-pub-8723888126390754/7532332319',
  });

  @override
  String get name => 'admob';

  static const int _maxConsecutiveNoFills = 5;
  static const Duration _circuitCooldown = Duration(minutes: 3);
  static const int _adMobErrorNoFill = 3;

  bool _initialized = false;
  @override
  bool get isInitialized => _initialized;

  InterstitialAd? _interstitial;
  bool _interstitialLoading = false;
  int _interstitialFailures = 0;
  DateTime? _interstitialBreakerOpenedAt;

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
  void preloadInterstitial() {
    if (!_initialized || _interstitial != null || _interstitialLoading) return;
    if (_circuitOpen(_interstitialBreakerOpenedAt, () {
      _interstitialBreakerOpenedAt = null;
      _interstitialFailures = 0;
      debugPrint('[admob] interstitial circuit reset');
    })) {
      return;
    }
    _interstitialLoading = true;
    AdThrottle.recordRequest();
    InterstitialAd.load(
      adUnitId: interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          _interstitialLoading = false;
          _interstitialFailures = 0;
          _interstitialBreakerOpenedAt = null;
        },
        onAdFailedToLoad: (err) {
          _interstitial = null;
          _interstitialLoading = false;
          _interstitialFailures += 1;
          debugPrint(
            '[admob] interstitial failed (#$_interstitialFailures): '
            '${err.code} ${err.message}',
          );
          if (_interstitialFailures >= _maxConsecutiveNoFills &&
              _interstitialBreakerOpenedAt == null) {
            _interstitialBreakerOpenedAt = DateTime.now();
            debugPrint(
              '[admob] interstitial circuit tripped after '
              '$_interstitialFailures consecutive failures. Skipping for '
              '${_circuitCooldown.inMinutes} min. '
              '${err.code == _adMobErrorNoFill ? "(ERROR_CODE_NO_FILL — typically AdMob ad serving limit on this account)" : ""}',
            );
          }
        },
      ),
    );
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
  Future<bool> showInterstitial() async {
    final ad = _interstitial;
    if (ad == null) {
      preloadInterstitial();
      return false;
    }
    final completer = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        _interstitial = null;
        if (!completer.isCompleted) completer.complete(true);
        preloadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (a, _) {
        a.dispose();
        _interstitial = null;
        if (!completer.isCompleted) completer.complete(false);
        preloadInterstitial();
      },
    );
    ad.show();
    return completer.future;
  }

  @override
  Future<bool> showRewarded({required VoidCallback onReward}) async {
    final ad = _rewarded;
    if (ad == null) {
      preloadRewarded();
      return false;
    }
    bool earned = false;
    final completer = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
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
  Widget? buildBanner() {
    if (!_initialized) return null;
    return _AdmobBanner(unitId: bannerUnitId);
  }
}

class _AdmobBanner extends StatefulWidget {
  final String unitId;
  const _AdmobBanner({required this.unitId});

  @override
  State<_AdmobBanner> createState() => _AdmobBannerState();
}

class _AdmobBannerState extends State<_AdmobBanner> {
  BannerAd? _ad;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    AdThrottle.recordRequest();
    _ad = BannerAd(
      size: AdSize.banner,
      adUnitId: widget.unitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() {}),
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
