import 'package:flutter/material.dart';

import 'ads/ads_orchestrator.dart';
import 'download_service.dart';
import 'video_player_screen.dart';

/// Backwards-compat facade. The real logic lives in [AdsOrchestrator];
/// this class is kept only so existing screens don't need to change
/// their imports/calls.
class AdManager {
  /// Initializes the ad orchestrator (all configured networks).
  static Future<void> initialize() => AdsOrchestrator.init();

  /// Shows a rewarded ad through the configured network chain.
  /// If no network can serve, the user still proceeds — we never
  /// block playback because of an ad failure.
  static void showRewarded(
    BuildContext context, {
    required String url,
    bool download = false,
    bool isLocal = false,
    bool allowNetworkDownloadInPlayer = true,
  }) {
    AdsOrchestrator.showRewarded(
      onReward: () {
        startVideo(
          context,
          url,
          download,
          isLocal,
          allowNetworkDownloadInPlayer,
        );
      },
    );
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
        const SnackBar(
          content: Text("Started...Keep the App opened"),
          duration: Duration(days: 1),
          backgroundColor: Colors.blueGrey,
        ),
      );
      try {
        final savedPath = await DownloadService.downloadFile(
          url,
          isLocal: isLocal,
        );
        if (!context.mounted) return;
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text("Video saved to: $savedPath"),
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoPlayerScreen(
            videoSource: url,
            isLocal: isLocal,
            allowNetworkDownload: allowNetworkDownloadInPlayer,
          ),
        ),
      );
    }
  }
}
