import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:video_player/video_player.dart';

import 'ad_ids.dart';
import 'ad_throttle.dart';
import 'ads_orchestrator.dart';

/// Native Advanced overlay when the user tapped pause or the video ended.
class VideoPauseNativeAdOverlay extends StatefulWidget {
  const VideoPauseNativeAdOverlay({
    super.key,
    required this.controller,
    this.userPausedForAd = false,
  });

  final VideoPlayerController controller;

  /// Set by player chrome when the user taps the pause control (not buffering).
  final bool userPausedForAd;

  @override
  State<VideoPauseNativeAdOverlay> createState() =>
      _VideoPauseNativeAdOverlayState();
}

class _VideoPauseNativeAdOverlayState extends State<VideoPauseNativeAdOverlay> {
  NativeAd? _ad;
  bool _loaded = false;
  bool _loadFailed = false;
  bool _dismissedThisPause = false;
  bool _wasPlaying = true;

  static const double _adHeight = 300;
  static const double _maxWidth = 340;
  /// Space between dismiss control and [AdWidget] to cut accidental ad clicks.
  static const double _closeToAdGap = 20;
  static const double _closeTapSize = 48;

  @override
  void initState() {
    super.initState();
    _wasPlaying = widget.controller.value.isPlaying;
    widget.controller.addListener(_onVideoUpdate);
    if (!kIsWeb) {
      _loadAd();
    }
  }

  @override
  void didUpdateWidget(VideoPauseNativeAdOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onVideoUpdate);
      widget.controller.addListener(_onVideoUpdate);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onVideoUpdate);
    _ad?.dispose();
    super.dispose();
  }

  void _onVideoUpdate() {
    final playing = widget.controller.value.isPlaying;
    if (playing && !_wasPlaying) {
      if (_dismissedThisPause) {
        setState(() => _dismissedThisPause = false);
      }
    }
    _wasPlaying = playing;
    if (mounted) setState(() {});
  }

  Future<void> _loadAd() async {
    final cfg = AdsOrchestrator.config;
    if (!cfg.bannerEnabled) return;
    if (!AdThrottle.canRequest(cfg.maxRequestsPerHour)) {
      debugPrint('[ads] pause native: hourly cap');
      return;
    }

    await MobileAds.instance.initialize();
    if (!mounted) return;

    AdThrottle.recordRequest();

    final ad = NativeAd(
      adUnitId: adMobPauseNativeUnitId,
      listener: NativeAdListener(
        onAdLoaded: (_) {
          if (!mounted) return;
          setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          debugPrint(
            '[ads] pause native failed: ${err.code} ${err.message}',
          );
          if (mounted) {
            setState(() {
              _ad = null;
              _loadFailed = true;
            });
          }
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: const Color(0xFF1E1E1E),
        cornerRadius: 8,
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          size: 16,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white70,
          size: 13,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white54,
          size: 11,
        ),
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black,
          size: 14,
          backgroundColor: const Color(0xFFB39DDB),
        ),
      ),
    );

    _ad = ad;
    ad.load();
  }

  bool get _videoEnded {
    final v = widget.controller.value;
    if (!v.isInitialized || v.hasError) return false;
    final duration = v.duration;
    if (duration <= Duration.zero) return false;
    if (v.isPlaying || v.isBuffering) return false;
    final remaining = duration - v.position;
    return remaining <= const Duration(milliseconds: 500);
  }

  bool get _eligiblePauseState {
    return widget.userPausedForAd || _videoEnded;
  }

  bool get _visible {
    if (kIsWeb || _loadFailed) return false;
    if (!AdsOrchestrator.config.bannerEnabled) return false;
    if (_dismissedThisPause) return false;
    if (!_loaded || _ad == null) return false;
    final v = widget.controller.value;
    if (!v.isInitialized || v.isPlaying || v.isBuffering || v.hasError) {
      return false;
    }
    if (!_eligiblePauseState) return false;
    return true;
  }

  void _dismiss() {
    setState(() => _dismissedThisPause = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    final ad = _ad!;
    final width = MediaQuery.sizeOf(context).width;
    final cardWidth = width > _maxWidth + 48 ? _maxWidth : width - 48;

    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _dismiss,
        child: ColoredBox(
          color: Colors.black.withValues(alpha: 0.55),
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                _PauseAdDismissButton(
                  onPressed: _dismiss,
                  size: _closeTapSize,
                ),
                const SizedBox(height: _closeToAdGap),
                Material(
                  color: Colors.transparent,
                  elevation: 8,
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: cardWidth,
                    height: _adHeight,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AdWidget(ad: ad),
                    ),
                  ),
                ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dismiss control kept outside the native ad bounds (AdMob accidental-click).
class _PauseAdDismissButton extends StatelessWidget {
  const _PauseAdDismissButton({
    required this.onPressed,
    required this.size,
  });

  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 3,
      shape: const CircleBorder(),
      child: SizedBox(
        width: size,
        height: size,
        child: IconButton(
          icon: const Icon(Icons.close, size: 22),
          color: Colors.black87,
          tooltip: 'Close',
          padding: EdgeInsets.zero,
          constraints: BoxConstraints.tightFor(width: size, height: size),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
