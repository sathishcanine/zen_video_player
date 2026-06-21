import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';

import '../services/video_continue_watching_service.dart';
import '../theme/zen_palette.dart';
import '../utils/video_navigation.dart';

/// UPlayer-style resume card at the top of the video library.
class VideoContinueWatchingCard extends StatelessWidget {
  const VideoContinueWatchingCard({
    super.key,
    required this.entry,
    required this.onDismiss,
    this.onOpened,
  });

  final VideoContinueEntry entry;
  final VoidCallback onDismiss;
  final VoidCallback? onOpened;

  String _formatTime(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (h > 0) return '$h:$m:$s';
    return '$m:$s';
  }

  void _resume(BuildContext context) {
    VideoNavigation.openPlayer(
      context: context,
      videoSource: entry.videoSource,
      isLocal: entry.isLocal,
      useContentUri: entry.useContentUri,
      allowNetworkDownload: entry.allowNetworkDownload,
      displayTitle: entry.displayTitle,
      resumeKey: entry.assetId,
    ).then((_) => onOpened?.call());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final zen = context.zen;
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Material(
        color: zen.surfaceCard,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _resume(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                _Thumbnail(
                  assetId: entry.assetId,
                  positionLabel: _formatTime(entry.position),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.continueWatching,
                        style: TextStyle(
                          color: primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.displayTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: zen.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 22),
                  tooltip: l10n.notNow,
                  onPressed: onDismiss,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.assetId,
    required this.positionLabel,
  });

  final String? assetId;
  final String positionLabel;

  @override
  Widget build(BuildContext context) {
    final zen = context.zen;
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 72,
        height: 48,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (assetId != null)
              FutureBuilder<Uint8List?>(
                future: _loadThumb(assetId!),
                builder: (context, snapshot) {
                  final data = snapshot.data;
                  if (data != null) {
                    return Image.memory(data, fit: BoxFit.cover);
                  }
                  return ColoredBox(
                    color: zen.surfaceElevated,
                    child: Icon(Icons.videocam, color: zen.textSecondary),
                  );
                },
              )
            else
              ColoredBox(
                color: zen.surfaceElevated,
                child: Icon(Icons.videocam, color: zen.textSecondary),
              ),
            Positioned(
              left: 4,
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  positionLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<Uint8List?> _loadThumb(String id) async {
    try {
      final asset = await AssetEntity.fromId(id);
      if (asset == null) return null;
      return asset.thumbnailDataWithSize(const ThumbnailSize(200, 120));
    } catch (_) {
      return null;
    }
  }
}
