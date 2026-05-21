import 'package:flutter/material.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';

import '../services/locale_service.dart';
import '../theme/zen_theme.dart';

Future<void> showLanguagePickerSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  final current = LocaleService.instance.locale;

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: ZenTheme.gradientMid,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      final options = [
        (Locale('en'), l10n.languageEnglish),
        (Locale('ta'), l10n.languageTamilPicker),
        (Locale('hi'), l10n.languageHindiPicker),
        (Locale('te'), l10n.languageTeluguPicker),
      ];

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.chooseLanguage,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ZenTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ...options.map(
                (e) => ListTile(
                  leading: Icon(
                    LocaleService.isSelected(e.$1, current)
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: LocaleService.isSelected(e.$1, current)
                        ? ZenTheme.accentBlue
                        : ZenTheme.textSecondary,
                  ),
                  title: Text(
                    e.$2,
                    style: const TextStyle(color: ZenTheme.textPrimary),
                  ),
                  onTap: () async {
                    await LocaleService.instance.setLocale(e.$1);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
