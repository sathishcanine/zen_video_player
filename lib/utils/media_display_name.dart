import 'package:path/path.dart' as p;
import 'package:photo_manager/photo_manager.dart';

/// Human-readable media file names for player chrome and lists.
abstract final class MediaDisplayName {
  static String forVideoAsset(AssetEntity asset) {
    final title = asset.title?.trim();
    if (title != null && title.isNotEmpty) return title;
    final rel = asset.relativePath?.trim();
    if (rel != null && rel.isNotEmpty) return p.basename(rel);
    return 'Video';
  }

  /// Returns `movie.mp4` style name — never a raw `content://` URI.
  static String forVideoSource({
    required String source,
    String? displayTitle,
    bool isLocal = false,
  }) {
    final explicit = displayTitle?.trim();
    if (explicit != null && explicit.isNotEmpty) return explicit;

    if (source.startsWith('http://') || source.startsWith('https://')) {
      try {
        final uri = Uri.parse(source);
        final seg = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
        if (seg.isNotEmpty) return Uri.decodeComponent(seg);
      } catch (_) {}
    }

    if (source.startsWith('content://')) {
      try {
        final uri = Uri.parse(source);
        if (uri.pathSegments.isNotEmpty) {
          final last = Uri.decodeComponent(uri.pathSegments.last);
          if (last.isNotEmpty) return last;
        }
      } catch (_) {}
      return 'Video';
    }

    if (source.startsWith('file://')) {
      try {
        return p.basename(Uri.parse(source).path);
      } catch (_) {}
    }

    if (isLocal || !source.contains('://')) {
      try {
        return p.basename(source);
      } catch (_) {}
    }

    return 'Video';
  }
}
