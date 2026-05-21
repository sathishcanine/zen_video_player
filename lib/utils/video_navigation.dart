import 'package:flutter/material.dart';

import '../app_navigator.dart';
import '../video_player_screen.dart';
import '../video_preview_screen.dart';

/// Route names for fullscreen video flows (above [LibraryShellScreen]).
abstract final class VideoRoutes {
  static const String player = '/video/player';
  static const String preview = '/video/preview';
}

/// Opens video screens on the app root navigator (no bottom nav / banner ad).
abstract final class VideoNavigation {
  static NavigatorState? _rootNav(BuildContext? context) {
    final fromKey = rootNavigatorKey.currentState;
    if (fromKey != null) return fromKey;
    if (context != null && context.mounted) {
      return Navigator.of(context, rootNavigator: true);
    }
    return null;
  }

  static Future<T?> openPlayer<T>({
    BuildContext? context,
    required String videoSource,
    required bool isLocal,
    bool useContentUri = false,
    bool allowNetworkDownload = true,
  }) {
    final nav = _rootNav(context);
    if (nav == null) return Future.value();
    return nav.push<T>(
      MaterialPageRoute<T>(
        settings: const RouteSettings(name: VideoRoutes.player),
        builder: (_) => VideoPlayerScreen(
          videoSource: videoSource,
          isLocal: isLocal,
          useContentUri: useContentUri,
          allowNetworkDownload: allowNetworkDownload,
        ),
      ),
    );
  }

  static Future<T?> openPreview<T>({
    BuildContext? context,
    required String videoSource,
    bool isLocal = false,
    bool openedViaDeeplink = false,
  }) {
    final nav = _rootNav(context);
    if (nav == null) return Future.value();
    return nav.push<T>(
      MaterialPageRoute<T>(
        settings: const RouteSettings(name: VideoRoutes.preview),
        builder: (_) => VideoPreviewScreen(
          videoSource: videoSource,
          isLocal: isLocal,
          openedViaDeeplink: openedViaDeeplink,
        ),
      ),
    );
  }
}
