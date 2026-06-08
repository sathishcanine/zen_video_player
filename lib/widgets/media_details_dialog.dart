import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';
import 'package:zen_video_player/theme/zen_palette.dart';
import 'package:zen_video_player/utils/format_bytes.dart';

import '../models/media_folder.dart';

Future<void> showFolderDetailsDialog(
  BuildContext context, {
  required MediaFolder folder,
}) {
  final l10n = AppLocalizations.of(context)!;
  final rows = <_DetailRow>[
    _DetailRow(l10n.detailsName, folder.displayName),
    _DetailRow(l10n.detailsCount, l10n.videoCount(folder.videoCount)),
  ];
  final size = folder.formatBytes();
  if (size.isNotEmpty) {
    rows.add(_DetailRow(l10n.detailsSize, size));
  }
  if (folder.id.isNotEmpty) {
    rows.add(_DetailRow(l10n.detailsPath, folder.id));
  }
  return _show(context, l10n.detailsTitle, rows);
}

Future<void> showAssetDetailsDialog(
  BuildContext context, {
  required AssetEntity asset,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final name = asset.title ?? asset.relativePath ?? asset.id;
  final rows = <_DetailRow>[
    _DetailRow(l10n.detailsName, name),
    _DetailRow(
      l10n.detailsDuration,
      _formatDuration(asset.duration),
    ),
    _DetailRow(
      l10n.detailsResolution,
      '${asset.width}×${asset.height}',
    ),
    _DetailRow(
      l10n.detailsDate,
      asset.createDateTime.toLocal().toString().split('.').first,
    ),
  ];

  try {
    final file = await asset.file;
    if (file != null) {
      final len = await file.length();
      rows.insert(2, _DetailRow(l10n.detailsSize, formatBytes(len)));
      rows.add(_DetailRow(l10n.detailsPath, file.path));
    }
  } catch (_) {}

  if (!context.mounted) return;
  await _show(context, l10n.detailsTitle, rows);
}

Future<void> showPlaylistDetailsDialog(
  BuildContext context, {
  required String name,
  required int videoCount,
}) {
  final l10n = AppLocalizations.of(context)!;
  return _show(
    context,
    l10n.detailsTitle,
    [
      _DetailRow(l10n.detailsName, name),
      _DetailRow(l10n.detailsCount, l10n.playlistVideoCount(videoCount)),
    ],
  );
}

Future<void> showAudioPlaylistDetailsDialog(
  BuildContext context, {
  required String name,
  required int trackCount,
}) {
  final l10n = AppLocalizations.of(context)!;
  return _show(
    context,
    l10n.detailsTitle,
    [
      _DetailRow(l10n.detailsName, name),
      _DetailRow(l10n.detailsCount, l10n.songCount(trackCount)),
    ],
  );
}

Future<void> showAudioAlbumDetailsDialog(
  BuildContext context, {
  required String title,
  required String artist,
  required int trackCount,
}) {
  final l10n = AppLocalizations.of(context)!;
  return _show(
    context,
    l10n.detailsTitle,
    [
      _DetailRow(l10n.detailsName, title),
      if (artist.isNotEmpty) _DetailRow(l10n.audioSubArtist, artist),
      _DetailRow(l10n.detailsCount, l10n.songCount(trackCount)),
    ],
  );
}

Future<void> _show(
  BuildContext context,
  String title,
  List<_DetailRow> rows,
) {
  final zen = context.zen;
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: zen.sheetBackground,
      title: Text(
        title,
        style: TextStyle(color: zen.textPrimary),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: rows
              .map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.label,
                        style: TextStyle(
                          fontSize: 12,
                          color: zen.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        r.value,
                        style: TextStyle(
                          fontSize: 15,
                          color: zen.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(AppLocalizations.of(ctx)!.ok),
        ),
      ],
    ),
  );
}

class _DetailRow {
  const _DetailRow(this.label, this.value);
  final String label;
  final String value;
}

String _formatDuration(int seconds) {
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  final s = seconds % 60;
  if (h > 0) {
    return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}
