import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:zen_video_player/ads/ad_ids.dart';
import 'package:zen_video_player/ads/ad_throttle.dart';
import 'package:zen_video_player/ads/interstitial_loading_overlay.dart';
import 'package:zen_video_player/app_navigator.dart';

import 'exit_interstitial_gate.dart';

/// Interstitial when leaving the player after **network** playback (back → home).
///
/// No session-length gate; may show on every eligible back. Mutually exclusive
/// with the 8-minute local-player exit interstitial via [ExitInterstitialGate].
class NetworkVideoExitInterstitialService {
  NetworkVideoExitInterstitialService._();

  static final NetworkVideoExitInterstitialService instance =
      NetworkVideoExitInterstitialService._();

  static const Duration _loadTimeout = Duration(seconds: 5);

  bool _adsReady = false;

  Future<void> _ensureAdsReady() async {
    if (_adsReady || kIsWeb) return;
    try {
      await MobileAds.instance.initialize();
      _adsReady = true;
    } catch (e) {
      debugPrint('[network_exit_ad] MobileAds init failed: $e');
    }
  }

  bool get _platformSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Call after the player route has been popped and home is visible.
  Future<bool> tryShowAfterLanding() async {
    if (!_platformSupported) return false;
    if (!ExitInterstitialGate.tryAcquire()) {
      debugPrint('[network_exit_ad] skip: another exit ad is active');
      return false;
    }

    OverlayEntry? entry;
    var loaderRemoved = false;

    void removeLoader() {
      if (loaderRemoved) return;
      loaderRemoved = true;
      try {
        entry?.remove();
      } catch (e) {
        debugPrint('[network_exit_ad] loader remove: $e');
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
        debugPrint('[network_exit_ad] skip: no fill');
        return false;
      }

      return await _present(ad);
    } catch (e, st) {
      debugPrint('[network_exit_ad] tryShow failed: $e\n$st');
      removeLoader();
      return false;
    } finally {
      if (!loaderRemoved) removeLoader();
      ExitInterstitialGate.release();
    }
  }

  Future<InterstitialAd?> _requestInterstitial() async {
    await _ensureAdsReady();
    if (!_adsReady) return null;
    if (!AdThrottle.canRequest(60)) return null;

    final completer = Completer<InterstitialAd?>();
    AdThrottle.recordRequest();

    InterstitialAd.load(
      adUnitId: adMobNetworkVideoExitInterstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          if (!completer.isCompleted) completer.complete(ad);
        },
        onAdFailedToLoad: (err) {
          debugPrint(
            '[network_exit_ad] load failed: ${err.code} ${err.message}',
          );
          if (!completer.isCompleted) completer.complete(null);
        },
      ),
    );

    return completer.future.timeout(
      _loadTimeout,
      onTimeout: () {
        debugPrint('[network_exit_ad] load timed out');
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
          '[network_exit_ad] show failed: ${err.code} ${err.message}',
        );
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    try {
      ad.show();
    } catch (e) {
      debugPrint('[network_exit_ad] show threw: $e');
      ad.dispose();
      return false;
    }

    return completer.future.timeout(
      const Duration(seconds: 120),
      onTimeout: () {
        debugPrint('[network_exit_ad] show timed out');
        return markedShown;
      },
    );
  }
}
