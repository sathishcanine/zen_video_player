import 'package:flutter/material.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';
import 'package:zen_video_player/theme/zen_palette.dart';

/// UPlayer-style vertical option list (Play, Delete, Send, …).
enum MediaOptionAction {
  play,
  delete,
  send,
  rename,
  addToPlaylist,
  hideFromList,
  details,
  removeFromPlaylist,
}

Future<MediaOptionAction?> showMediaOptionsSheet(
  BuildContext context, {
  required List<MediaOptionAction> actions,
}) {
  final l10n = AppLocalizations.of(context)!;
  final zen = context.zen;

  return showModalBottomSheet<MediaOptionAction>(
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
            for (var i = 0; i < actions.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  color: zen.textSecondary.withValues(alpha: 0.2),
                ),
              ListTile(
                title: Text(
                  _label(l10n, actions[i]),
                  style: TextStyle(
                    color: zen.textPrimary,
                    fontSize: 16,
                  ),
                ),
                onTap: () => Navigator.pop(ctx, actions[i]),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

String _label(AppLocalizations l10n, MediaOptionAction action) {
  switch (action) {
    case MediaOptionAction.play:
      return l10n.optionPlay;
    case MediaOptionAction.delete:
      return l10n.optionDelete;
    case MediaOptionAction.send:
      return l10n.optionSend;
    case MediaOptionAction.rename:
      return l10n.optionRename;
    case MediaOptionAction.addToPlaylist:
      return l10n.optionAddToPlaylist;
    case MediaOptionAction.hideFromList:
      return l10n.optionHideFromList;
    case MediaOptionAction.details:
      return l10n.optionDetails;
    case MediaOptionAction.removeFromPlaylist:
      return l10n.optionRemoveFromPlaylist;
  }
}
