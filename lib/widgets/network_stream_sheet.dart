import 'package:flutter/material.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';

import '../theme/zen_theme.dart';

typedef UrlSubmitCallback = void Function(String url);

/// Bottom sheet for playing a remote video URL (legacy home flow).
Future<void> showNetworkStreamSheet(
  BuildContext context, {
  required UrlSubmitCallback onSubmit,
}) {
  final l10n = AppLocalizations.of(context)!;
  final controller = TextEditingController();

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: ZenTheme.gradientMid,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
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
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ZenTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              style: const TextStyle(color: ZenTheme.textPrimary),
              decoration: InputDecoration(
                hintText: l10n.pasteVideoUrl,
                hintStyle: const TextStyle(color: ZenTheme.textSecondary),
                filled: true,
                fillColor: ZenTheme.surface,
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
                backgroundColor: ZenTheme.accent,
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
