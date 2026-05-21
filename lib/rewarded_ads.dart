import 'package:flutter/material.dart';

import 'ads/ads_orchestrator.dart';
import 'ads/rewarded_loading_overlay.dart';
import 'download_service.dart';
import 'utils/video_navigation.dart';

/// Backwards-compat facade. The real logic lives in [AdsOrchestrator];
/// this class is kept only so existing screens don't need to change
/// their imports/calls.
class AdManager {
  /// Prevents overlapping rewarded flows (e.g. double-tap Play before an
  /// ad finishes loading), which would waste inventory or race overlays.
  static bool _rewardedFlowActive = false;

  /// Initializes the ad orchestrator (all configured networks).
  static Future<void> initialize() => AdsOrchestrator.init();

  /// Shows a rewarded ad through the configured network chain.
  /// If no network can serve, the user still proceeds — we never
  /// block playback because of an ad failure.
  ///
  /// Shows a dim full-screen circular loader until an ad opens or the
  /// chain gives up. Ignores extra taps while a flow is already running.
  static Future<void> showRewarded(
    BuildContext context, {
    required String url,
    bool download = false,
    bool isLocal = false,
    bool allowNetworkDownloadInPlayer = true,
  }) async {
    if (_rewardedFlowActive) return;
    _rewardedFlowActive = true;

    OverlayEntry? entry;
    var loaderRemoved = false;

    void removeLoader() {
      if (loaderRemoved) return;
      loaderRemoved = true;
      entry?.remove();
    }

    try {
      final overlay =
          Navigator.maybeOf(context, rootNavigator: true)?.overlay;

      if (overlay != null) {
        entry = OverlayEntry(
          builder: (_) => const RewardedLoadingOverlay(),
        );
        overlay.insert(entry);
      }

      await AdsOrchestrator.showRewarded(
        onReward: () {
          // Reward fires from ad SDK callbacks mid teardown; defer until the
          // next frame so Navigator/context lookups see a consistent tree.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            startVideo(
              context,
              url,
              download,
              isLocal,
              allowNetworkDownloadInPlayer,
            );
          });
        },
        onAdOpening: overlay != null ? removeLoader : null,
      );
    } finally {
      removeLoader();
      _rewardedFlowActive = false;
    }
  }

  /// Start video or download. Pulled out of the old AdManager to
  /// stay structurally identical to the previous public API.
  static Future<void> startVideo(
    BuildContext context,
    String url,
    bool download,
    bool isLocal,
    bool allowNetworkDownloadInPlayer,
  ) async {
    if (download) {
      if (!context.mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            isLocal
                ? "Saving to Downloads..."
                : "Opening system download manager...",
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.blueGrey,
        ),
      );
      try {
        final outcome = await DownloadService.downloadFile(
          url,
          isLocal: isLocal,
        );
        if (!context.mounted) return;
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              outcome.handedOffToSystem
                  ? "Started. Check your notifications or folder."
                  : " Saved to: ${outcome.localPath}",
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!context.mounted) return;
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text("Download failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Do not use [context] to resolve Navigator — after a fullscreen ad,
      // the overlay subtree can be torn down while callbacks still hold the old
      // BuildContext (StatefulElement.state null crashes).
      if (!context.mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        VideoNavigation.openPlayer(
          videoSource: url,
          isLocal: isLocal,
          allowNetworkDownload: allowNetworkDownloadInPlayer,
        );
      });
    }
  }
}
