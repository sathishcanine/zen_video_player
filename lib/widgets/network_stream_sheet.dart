import 'package:flutter/material.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';

import '../theme/zen_palette.dart';

typedef UrlSubmitCallback = void Function(String url);

/// Bottom sheet for playing a remote video URL (legacy home flow).
Future<void> showNetworkStreamSheet(
  BuildContext context, {
  required UrlSubmitCallback onSubmit,
}) {
  final l10n = AppLocalizations.of(context)!;
  final controller = TextEditingController();

  final zen = context.zen;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: zen.sheetBackground,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      final sheetZen = ctx.zen;
      final primary = Theme.of(ctx).colorScheme.primary;
      return Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 20 + MediaQuery.viewInsetsOf(ctx).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.playFromUrl,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: sheetZen.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              style: TextStyle(color: sheetZen.textPrimary),
              decoration: InputDecoration(
                hintText: l10n.pasteVideoUrl,
                hintStyle: TextStyle(color: sheetZen.textSecondary),
                filled: true,
                fillColor: sheetZen.surfaceCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.url,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                final url = controller.text.trim();
                if (url.isEmpty) return;
                Navigator.pop(ctx);
                onSubmit(url);
              },
              style: FilledButton.styleFrom(
                backgroundColor: primary,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(l10n.playVideo),
            ),
          ],
        ),
      );
    },
  );
}
