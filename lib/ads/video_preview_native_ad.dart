import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_ids.dart';
import 'ad_throttle.dart';
import 'ads_orchestrator.dart';

/// AdMob Native Advanced (medium template) for the video preview screen.
///
/// Respects [AdsOrchestrator.config.bannerEnabled] and the same hourly
/// request cap as banners.
class VideoPreviewNativeAd extends StatefulWidget {
  const VideoPreviewNativeAd({super.key});

  @override
  State<VideoPreviewNativeAd> createState() => _VideoPreviewNativeAdState();
}

class _VideoPreviewNativeAdState extends State<VideoPreviewNativeAd> {
  NativeAd? _ad;
  bool _loaded = false;
  bool _failed = false;

  static const double _adHeight = 320;

  @override
  void initState() {
    super.initState();
    _startLoad();
  }

  Future<void> _startLoad() async {
    final cfg = AdsOrchestrator.config;
    if (!cfg.bannerEnabled) return;
    if (!AdThrottle.canRequest(cfg.maxRequestsPerHour)) {
      debugPrint('[ads] video preview native: hourly cap');
      return;
    }

    await MobileAds.instance.initialize();
    if (!mounted) return;

    AdThrottle.recordRequest();

    final ad = NativeAd(
      adUnitId: adMobNativeAdvancedUnitId,
      listener: NativeAdListener(
        onAdLoaded: (_) {
          if (!mounted) return;
          setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          debugPrint(
            '[ads] video preview native failed: ${err.code} ${err.message}',
          );
          if (mounted) {
            setState(() {
              _ad = null;
              _failed = true;
            });
          }
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: const Color(0xFF302b63),
        cornerRadius: 12,
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          size: 16,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white70,
          size: 14,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white54,
          size: 12,
        ),
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          size: 14,
          backgroundColor: Colors.deepPurple,
        ),
      ),
    );

    _ad = ad;
    ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) return const SizedBox.shrink();

    final ad = _ad;
    if (!_loaded || ad == null) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      height: _adHeight,
      child: AdWidget(ad: ad),
    );
  }
}
