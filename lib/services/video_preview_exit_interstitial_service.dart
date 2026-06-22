import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zen_video_player/ads/ad_ids.dart';
import 'package:zen_video_player/ads/ad_throttle.dart';
import 'package:zen_video_player/ads/interstitial_loading_overlay.dart';
import 'package:zen_video_player/app_navigator.dart';

/// Interstitial when leaving [VideoPreviewScreen] back to home.
///
/// Pops to home first, shows a loader, requests a fill, then presents the ad
/// or dismisses safely when no fill is available (1× per calendar day).
class VideoPreviewExitInterstitialService {
  VideoPreviewExitInterstitialService._();

  static final VideoPreviewExitInterstitialService instance =
      VideoPreviewExitInterstitialService._();

  static const String _lastShownDayKey =
      'video_preview_exit_interstitial_day_v1';
  static const Duration _loadTimeout = Duration(seconds: 5);

  bool _flowActive = false;
  bool _adsReady = false;

  Future<void> _ensureAdsReady() async {
    if (_adsReady || kIsWeb) return;
    try {
      await MobileAds.instance.initialize();
      _adsReady = true;
    } catch (e) {
      debugPrint('[preview_exit_ad] MobileAds init failed: $e');
    }
  }

  String _dayKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  Future<bool> _shownToday() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_lastShownDayKey) == _dayKey(DateTime.now());
    } catch (_) {
      return true;
    }
  }

  Future<void> _markShownToday() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastShownDayKey, _dayKey(DateTime.now()));
    } catch (_) {}
  }

  bool get _platformSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Call after the preview route has been popped and home is visible.
  Future<bool> tryShowAfterLanding() async {
    if (!_platformSupported || _flowActive) return false;
    if (await _shownToday()) {
      debugPrint('[preview_exit_ad] skip: already shown today');
      return false;
    }

    _flowActive = true;
    OverlayEntry? entry;
    var loaderRemoved = false;

    void removeLoader() {
      if (loaderRemoved) return;
      loaderRemoved = true;
      try {
        entry?.remove();
      } catch (e) {
        debugPrint('[preview_exit_ad] loader remove: $e');
      }
      entry = null;
    }

    try {
      final overlay = rootNavigatorKey.currentState?.overlay;
      if (overlay != null) {
        entry = OverlayEntry(
          builder: (_) => const InterstitialLoadingOverlay(),
        );
        overlay.insert(entry!);
      }

      final ad = await _requestInterstitial();
      removeLoader();
      if (ad == null) {
        debugPrint('[preview_exit_ad] skip: no fill');
        return false;
      }

      final shown = await _present(ad);
      if (shown) {
        await _markShownToday();
      }
      return shown;
    } catch (e, st) {
      debugPrint('[preview_exit_ad] tryShow failed: $e\n$st');
      removeLoader();
      return false;
    } finally {
      _flowActive = false;
      if (!loaderRemoved) removeLoader();
    }
  }

  Future<InterstitialAd?> _requestInterstitial() async {
    await _ensureAdsReady();
    if (!_adsReady) return null;
    if (!AdThrottle.canRequest(60)) return null;

    final completer = Completer<InterstitialAd?>();
    AdThrottle.recordRequest();

    InterstitialAd.load(
      adUnitId: adMobVideoPreviewExitInterstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          if (!completer.isCompleted) completer.complete(ad);
        },
        onAdFailedToLoad: (err) {
          debugPrint(
            '[preview_exit_ad] load failed: ${err.code} ${err.message}',
          );
          if (!completer.isCompleted) completer.complete(null);
        },
      ),
    );

    return completer.future.timeout(
      _loadTimeout,
      onTimeout: () {
        debugPrint('[preview_exit_ad] load timed out');
        return null;
      },
    );
  }

  Future<bool> _present(InterstitialAd ad) async {
    final completer = Completer<bool>();
    var markedShown = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        markedShown = true;
      },
      onAdDismissedFullScreenContent: (dismissed) {
        dismissed.dispose();
        if (!completer.isCompleted) completer.complete(markedShown);
      },
      onAdFailedToShowFullScreenContent: (failed, err) {
        failed.dispose();
        debugPrint(
          '[preview_exit_ad] show failed: ${err.code} ${err.message}',
        );
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    try {
      ad.show();
    } catch (e) {
      debugPrint('[preview_exit_ad] show threw: $e');
      ad.dispose();
      return false;
    }

    return completer.future.timeout(
      const Duration(seconds: 120),
      onTimeout: () {
        debugPrint('[preview_exit_ad] show timed out');
        return markedShown;
      },
    );
  }
}
