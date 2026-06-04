import 'package:flutter/material.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';
import 'package:zen_video_player/theme/zen_palette.dart';

import '../models/duplicate_media_kind.dart';
import '../navigation/library_navigation.dart';
import '../screens/duplicate_scan_screen.dart';
import '../services/media_permission_service.dart';

/// UPlayer-style chooser: scan duplicate audio or video.
Future<void> showDuplicateChooseDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final zen = context.zen;

  final kind = await showDialog<DuplicateMediaKind>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: zen.sheetBackground,
      title: Text(
        l10n.duplicateChooseTitle,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: zen.textPrimary,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              l10n.tabAudio,
              style: TextStyle(color: zen.textPrimary),
            ),
            onTap: () => Navigator.pop(ctx, DuplicateMediaKind.audio),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              l10n.tabVideo,
              style: TextStyle(color: zen.textPrimary),
            ),
            onTap: () => Navigator.pop(ctx, DuplicateMediaKind.video),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(l10n.duplicateChooseCancel),
        ),
      ],
    ),
  );

  if (kind == null || !context.mounted) return;

  if (!await MediaPermissionService.ensureMediaAccessFor(kind)) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.permissionRequired)),
    );
    return;
  }

  if (!context.mounted) return;
  LibraryNavigation.push(context, DuplicateScanScreen(kind: kind));
}
