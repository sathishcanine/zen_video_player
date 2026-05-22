import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists and broadcasts the user-selected app locale.
class LocaleService extends ChangeNotifier {
  LocaleService._();

  static final LocaleService instance = LocaleService._();

  static const _localeKey = 'app_locale_code';
  static const tutorialSeenKey = 'language_tutorial_seen_v1';

  /// Shown at the top of the language picker (always visible).
  static const List<Locale> primaryPickerLocales = [
    Locale('en'),
    Locale('ta'),
    Locale('hi'),
    Locale('te'),
    Locale('fr'),
    Locale('bn'),
  ];

  /// Shown in a scrollable section below the primary list.
  static const List<Locale> morePickerLocales = [
    Locale('es'),
    Locale('ar'),
    Locale('pt'),
    Locale('ru'),
    Locale('ur'),
    Locale('zh'),
  ];

  /// All selectable languages (primary + more).
  static List<Locale> get pickerLocales => [
        ...primaryPickerLocales,
        ...morePickerLocales,
      ];

  Locale? _locale;

  Locale? get locale => _locale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey);
    if (code == null) {
      _locale = null;
      return;
    }
    _locale = Locale(code);
  }

  Future<void> setLocale(Locale locale) async {
    if (!pickerLocales.any((l) => l.languageCode == locale.languageCode)) {
      return;
    }
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    notifyListeners();
  }

  static Future<bool> wasLanguageTutorialSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(tutorialSeenKey) ?? false;
  }

  static Future<void> markLanguageTutorialSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(tutorialSeenKey, true);
  }

  static String languageCodeFor(Locale locale) => locale.languageCode;

  static bool isSelected(Locale a, Locale? b) =>
      b != null && a.languageCode == b.languageCode;
}
