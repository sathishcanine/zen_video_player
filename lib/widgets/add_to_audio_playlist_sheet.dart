import 'package:flutter/material.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';
import 'package:zen_video_player/theme/zen_palette.dart';

import '../services/audio_playlist_service.dart';

/// Picker to add one or more audio asset IDs to a playlist.
Future<void> showAddToAudioPlaylistSheet(
  BuildContext context, {
  required List<String> assetIds,
}) async {
  if (assetIds.isEmpty) return;
  final l10n = AppLocalizations.of(context)!;
  final zen = context.zen;

  final playlists = await AudioPlaylistService.loadAll();
  if (!context.mounted) return;

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: zen.sheetBackground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.optionAddToPlaylist,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: zen.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: l10n.createPlaylist,
                    onPressed: () async {
                      final name = await _promptName(ctx);
                      if (name == null) return;
                      final created = await AudioPlaylistService.create(name);
                      await AudioPlaylistService.addAssets(
                        created.id,
                        assetIds,
                      );
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.addedToPlaylist(created.name)),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            if (playlists.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.playlistEmpty,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: zen.textSecondary),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: playlists.length,
                  itemBuilder: (_, i) {
                    final p = playlists[i];
                    return ListTile(
                      title: Text(
                        p.name,
                        style: TextStyle(color: zen.textPrimary),
                      ),
                      subtitle: Text(
                        l10n.songCount(p.trackCount),
                        style: TextStyle(color: zen.textSecondary),
                      ),
                      onTap: () async {
                        await AudioPlaylistService.addAssets(p.id, assetIds);
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.addedToPlaylist(p.name)),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

Future<String?> _promptName(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final zen = context.zen;
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: zen.sheetBackground,
      title: Text(
        l10n.createPlaylist,
        style: TextStyle(color: zen.textPrimary),
      ),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(hintText: l10n.playlistNameHint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, controller.text),
          child: Text(l10n.save),
        ),
      ],
    ),
  );
}
