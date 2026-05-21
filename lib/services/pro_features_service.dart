import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pro settings that each require their own rewarded ad unlock.
enum ProFeature {
  darkTheme,
  primaryColor,
  findDuplicate,
}

/// Tracks per-feature Pro unlock state (one ad per feature).
class ProFeaturesService extends ChangeNotifier {
  ProFeaturesService._();

  static final ProFeaturesService instance = ProFeaturesService._();

  static const _legacyUnlockedKey = 'pro_features_unlocked_v1';
  static const _keyDark = 'pro_unlock_dark_theme_v1';
  static const _keyColor = 'pro_unlock_primary_color_v1';
  static const _keyDuplicate = 'pro_unlock_find_duplicate_v1';

  final Set<ProFeature> _unlocked = {};

  bool isUnlocked(ProFeature feature) => _unlocked.contains(feature);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    // Migrate old single unlock → all three (existing users keep access).
    if (prefs.getBool(_legacyUnlockedKey) == true) {
      _unlocked.addAll(ProFeature.values);
      await prefs.setBool(_keyDark, true);
      await prefs.setBool(_keyColor, true);
      await prefs.setBool(_keyDuplicate, true);
      await prefs.remove(_legacyUnlockedKey);
      return;
    }

    if (prefs.getBool(_keyDark) == true) {
      _unlocked.add(ProFeature.darkTheme);
    }
    if (prefs.getBool(_keyColor) == true) {
      _unlocked.add(ProFeature.primaryColor);
    }
    if (prefs.getBool(_keyDuplicate) == true) {
      _unlocked.add(ProFeature.findDuplicate);
    }
  }

  Future<void> unlock(ProFeature feature) async {
    if (_unlocked.contains(feature)) return;
    _unlocked.add(feature);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFor(feature), true);
    notifyListeners();
  }

  static String _keyFor(ProFeature feature) {
    switch (feature) {
      case ProFeature.darkTheme:
        return _keyDark;
      case ProFeature.primaryColor:
        return _keyColor;
      case ProFeature.findDuplicate:
        return _keyDuplicate;
    }
  }
}
