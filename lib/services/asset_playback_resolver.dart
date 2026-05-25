import 'dart:io';

import 'package:photo_manager/photo_manager.dart';

/// How to open a gallery [AssetEntity] in [VideoPlayerScreen] without copying
/// the whole file into app cache (see photo_manager cache docs).
class AssetPlaybackTarget {
  const AssetPlaybackTarget({
    required this.videoSource,
    required this.isLocal,
    this.useContentUri = false,
  });

  final String videoSource;
  final bool isLocal;
  final bool useContentUri;
}

class AssetPlaybackResolver {
  AssetPlaybackResolver._();

  /// Prefer Android `content://` URIs; fall back to a file path only when needed.
  static Future<AssetPlaybackTarget?> resolve(AssetEntity asset) async {
    if (Platform.isAndroid) {
      final url = await asset.getMediaUrl();
      if (url != null && url.isNotEmpty) {
        return AssetPlaybackTarget(
          videoSource: url,
          isLocal: true,
          useContentUri: url.startsWith('content://'),
        );
      }
    } else if (Platform.isIOS || Platform.isMacOS) {
      final url = await asset.getMediaUrl();
      if (url != null && url.isNotEmpty) {
        return AssetPlaybackTarget(
          videoSource: url,
          isLocal: true,
          useContentUri: false,
        );
      }
    }

    final file = await asset.file;
    if (file == null) return null;
    return AssetPlaybackTarget(
      videoSource: file.path,
      isLocal: true,
    );
  }
}
