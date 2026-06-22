import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zen_video_player/ads/ad_ids.dart';
import 'package:zen_video_player/ads/ad_throttle.dart';
import 'package:zen_video_player/ads/interstitial_loading_overlay.dart';
import 'package:zen_video_player/services/active_session_tracker.dart';

/// Video-exit interstitial for engaged users (8 min session, back from player).
///
/// Show-rate policy:
/// - **Shown today** → no more requests until tomorrow.
/// - **Not shown yet** → preload again at 7 min when needed (no cached fill).
/// - Exit never fires a new load — only presents a preloaded ad.
class VideoExitInterstitialService {
  VideoExitInterstitialService._();

  static final VideoExitInterstitialService instance =
      VideoExitInterstitialService._();

  static const String _lastShownDayKey = 'video_exit_interstitial_day_v1';
  static const Duration _inFlightWait = Duration(seconds: 4);
  /// Gap after a failed preload before trying again (same day, not yet shown).
  static const Duration _preloadRetryCooldown = Duration(minutes: 5);

  InterstitialAd? _ad;
  bool _loading = false;
  bool _flowActive = false;
  bool _adsReady = false;
  DateTime? _lastFailedPreloadAt;

  Future<void> _ensureAdsReady() async {
    if (_adsReady || kIsWeb) return;
    try {
      await MobileAds.instance.initialize();
      _adsReady = true;
    } catch (e) {
      debugPrint('[video_exit_ad] MobileAds init failed: $e');
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
    _ad?.dispose();
    _ad = null;
    _lastFailedPreloadAt = null;
  }

  bool get _platformSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Preload at 7 min session if not shown today and no fill is cached yet.
  void preloadIfNearEligible() {
    if (!_platformSupported) return;
    if (!ActiveSessionTracker.instance.meetsPreloadThreshold) return;
    unawaited(_preloadIfNeeded());
  }

  Future<void> _preloadIfNeeded() async {
    if (await _shownToday()) return;
    if (_ad != null || _loading) return;

    final lastFail = _lastFailedPreloadAt;
    if (lastFail != null &&
        DateTime.now().difference(lastFail) < _preloadRetryCooldown) {
      return;
    }

    await _ensureAdsReady();
    if (!_adsReady) return;
    if (!AdThrottle.canRequest(60)) return;

    _loading = true;
    AdThrottle.recordRequest();
    InterstitialAd.load(
      adUnitId: adMobVideoExitInterstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad?.dispose();
          _ad = ad;
          _loading = false;
          _lastFailedPreloadAt = null;
          debugPrint('[video_exit_ad] preloaded');
        },
        onAdFailedToLoad: (err) {
          _loading = false;
          _lastFailedPreloadAt = DateTime.now();
          debugPrint(
            '[video_exit_ad] preload failed (retry after 7 min + cooldown): '
            '${err.code} ${err.message}',
          );
        },
      ),
    );
  }

  /// Cached fill only — never starts a new network request on exit.
  Future<InterstitialAd?> _takePreloadedAd() async {
    final cached = _ad;
    if (cached != null) {
      _ad = null;
      return cached;
    }
    if (!_loading) return null;

    final deadline = DateTime.now().add(_inFlightWait);
    while (_loading && DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      final ready = _ad;
      if (ready != null) {
        _ad = null;
        return ready;
      }
    }
    return null;
  }

  /// Returns `true` if an interstitial was shown.
  Future<bool> tryShowBeforeExit(BuildContext context) async {
    if (!_platformSupported || _flowActive) return false;
    if (!ActiveSessionTracker.instance.meetsVideoExitAdThreshold) {
      debugPrint('[video_exit_ad] skip: session under 8 min');
      return false;
    }
    if (await _shownToday()) {
      debugPrint('[video_exit_ad] skip: already shown today');
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
        debugPrint('[video_exit_ad] loader remove: $e');
      }
      entry = null;
    }

    try {
      if (!context.mounted) return false;

      final overlay =
          Navigator.maybeOf(context, rootNavigator: true)?.overlay;
      if (overlay != null) {
        entry = OverlayEntry(
          builder: (_) => const InterstitialLoadingOverlay(),
        );
        overlay.insert(entry!);
      }

      final ad = await _takePreloadedAd();
      if (ad == null) {
        debugPrint('[video_exit_ad] skip: no preloaded fill');
        removeLoader();
        return false;
      }

      removeLoader();
      final shown = await _present(ad);
      if (shown) {
        await _markShownToday();
      }
      return shown;
    } catch (e, st) {
      debugPrint('[video_exit_ad] tryShow failed: $e\n$st');
      removeLoader();
      return false;
    } finally {
      _flowActive = false;
      if (!loaderRemoved) removeLoader();
    }
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
          '[video_exit_ad] show failed: ${err.code} ${err.message}',
        );
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    try {
      ad.show();
    } catch (e) {
      debugPrint('[video_exit_ad] show threw: $e');
      ad.dispose();
      return false;
    }

    return completer.future.timeout(
      const Duration(seconds: 120),
      onTimeout: () {
        debugPrint('[video_exit_ad] show timed out');
        return markedShown;
      },
    );
  }

  void dispose() {
    _ad?.dispose();
    _ad = null;
  }
}
