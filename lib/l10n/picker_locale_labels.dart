import 'package:flutter/material.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';

/// Display name for each language in the home-screen picker.
String pickerLabelForLocale(Locale locale, AppLocalizations l10n) {
  switch (locale.languageCode) {
    case 'en':
      return l10n.languageEnglish;
    case 'es':
      return l10n.languageSpanishPicker;
    case 'ar':
      return l10n.languageArabicPicker;
    case 'fr':
      return l10n.languageFrenchPicker;
    case 'bn':
      return l10n.languageBengaliPicker;
    case 'pt':
      return l10n.languagePortuguesePicker;
    case 'ru':
      return l10n.languageRussianPicker;
    case 'ur':
      return l10n.languageUrduPicker;
    case 'zh':
      return l10n.languageMandarinPicker;
    case 'ta':
      return l10n.languageTamilPicker;
    case 'hi':
      return l10n.languageHindiPicker;
    case 'te':
      return l10n.languageTeluguPicker;
    default:
      return locale.languageCode;
  }
}
