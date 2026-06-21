import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';
import 'package:zen_video_player/theme/zen_palette.dart';
import 'package:zen_video_player/theme/zen_theme.dart';

/// Video row with thumbnail and duration badge (UPlayer-style).
class VideoAssetTile extends StatelessWidget {
  const VideoAssetTile({
    super.key,
    required this.asset,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.onMenu,
    this.isNew = false,
  });

  final AssetEntity asset;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback? onMenu;
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    final zen = context.zen;
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: _Thumbnail(asset: asset),
      title: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: zen.textPrimary,
              ),
            ),
          ),
          if (isNew) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: ZenTheme.badgeNew,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _isToday(asset.createDateTime)
                    ? l10n.badgeToday
                    : l10n.badgeNew,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: zen.textSecondary, fontSize: 13),
      ),
      trailing: onMenu == null
          ? null
          : IconButton(
              icon: Icon(Icons.more_vert, color: zen.textSecondary),
              onPressed: onMenu,
            ),
      onTap: onTap,
    );
  }

  static bool _isToday(DateTime created) {
    final now = DateTime.now();
    return created.year == now.year &&
        created.month == now.month &&
        created.day == now.day;
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.asset});

  final AssetEntity asset;

  @override
  Widget build(BuildContext context) {
    final zen = context.zen;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: 72,
        height: 48,
        child: FutureBuilder<Uint8List?>(
          future: asset.thumbnailDataWithSize(const ThumbnailSize(200, 120)),
          builder: (context, snapshot) {
            final data = snapshot.data;
            return Stack(
              fit: StackFit.expand,
              children: [
                if (data != null)
                  Image.memory(data, fit: BoxFit.cover)
                else
                  ColoredBox(
                    color: zen.surfaceCard,
                    child: Icon(
                      Icons.videocam_outlined,
                      color: zen.textSecondary,
                    ),
                  ),
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      _formatDuration(asset.duration),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
