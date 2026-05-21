import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';

import '../theme/zen_theme.dart';

/// "Why the app needs permission" dialog (Not now flow). OK only dismisses.
Future<void> showPermissionRationaleDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      final linkRecognizer = TapGestureRecognizer()
        ..onTap = () => launchUrl(
              Uri.parse(l10n.permissionWhySupportUrl),
              mode: LaunchMode.externalApplication,
            );

      return AlertDialog(
        backgroundColor: const Color(0xFF383838),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        title: Text(
          l10n.permissionWhyTitle,
          style: const TextStyle(
            color: ZenTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.permissionWhyBody1(l10n.appNameFull),
                style: _bodyStyle,
              ),
              const SizedBox(height: 12),
              Text(l10n.permissionWhyBody2, style: _bodyStyle),
              const SizedBox(height: 12),
              Text(
                l10n.permissionWhyPrivacy(l10n.appNameFull),
                style: _bodyStyle,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.permissionWhyMoreInfo,
                style: _bodyStyle.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text.rich(
                TextSpan(
                  text: l10n.permissionWhySupportUrl,
                  style: _bodyStyle.copyWith(
                    color: const Color(0xFF64B5F6),
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: linkRecognizer,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              linkRecognizer.dispose();
              Navigator.pop(ctx);
            },
            child: Text(
              l10n.ok,
              style: const TextStyle(
                color: ZenTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    },
  );
}

const _bodyStyle = TextStyle(
  color: ZenTheme.textPrimary,
  fontSize: 14,
  height: 1.45,
);
