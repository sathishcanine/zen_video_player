import 'package:flutter/material.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';
import 'package:zen_video_player/l10n/picker_locale_labels.dart';

import '../services/locale_service.dart';
import '../theme/zen_theme.dart';

Future<void> showLanguagePickerSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  final current = LocaleService.instance.locale;

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: ZenTheme.gradientMid,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  l10n.chooseLanguage,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: ZenTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              for (final locale in LocaleService.primaryPickerLocales)
                _LanguageTile(
                  label: pickerLabelForLocale(locale, l10n),
                  selected: LocaleService.isSelected(locale, current),
                  onTap: () => _selectLocale(ctx, locale),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: Text(
                  l10n.moreLanguages,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                    color: ZenTheme.textSecondary.withValues(alpha: 0.9),
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(ctx).height * 0.28,
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final locale in LocaleService.morePickerLocales)
                      _LanguageTile(
                        label: pickerLabelForLocale(locale, l10n),
                        selected: LocaleService.isSelected(locale, current),
                        onTap: () => _selectLocale(ctx, locale),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _selectLocale(BuildContext context, Locale locale) async {
  await LocaleService.instance.setLocale(locale);
  if (context.mounted) Navigator.pop(context);
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      leading: Icon(
        selected ? Icons.check_circle : Icons.circle_outlined,
        size: 22,
        color: selected ? ZenTheme.accentBlue : ZenTheme.textSecondary,
      ),
      title: Text(
        label,
        style: const TextStyle(
          color: ZenTheme.textPrimary,
          fontSize: 15,
        ),
      ),
      onTap: onTap,
    );
  }
}
