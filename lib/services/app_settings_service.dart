import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User preferences: theme mode and accent color.
class AppSettingsService extends ChangeNotifier {
  AppSettingsService._();

  static final AppSettingsService instance = AppSettingsService._();

  static const _darkThemeKey = 'settings_dark_theme';
  static const _primaryColorKey = 'settings_primary_color';

  /// Preset accent colors (UPlayer-style pink included).
  static const List<Color> primaryColorPresets = <Color>[
    Color(0xFFE91E63), // pink / magenta
    Color(0xFF673AB7), // deep purple (default)
    Color(0xFF7E57C2),
    Color(0xFF2196F3),
    Color(0xFF00BCD4),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFFF44336),
  ];

  bool _isDarkTheme = true;
  Color _primaryColor = primaryColorPresets[1];

  bool get isDarkTheme => _isDarkTheme;
  Color get primaryColor => _primaryColor;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkTheme = prefs.getBool(_darkThemeKey) ?? true;
    final stored = prefs.getInt(_primaryColorKey);
    if (stored != null) {
      _primaryColor = Color(stored);
    }
  }

  Future<void> setDarkTheme(bool value) async {
    if (_isDarkTheme == value) return;
    _isDarkTheme = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkThemeKey, value);
    notifyListeners();
  }

  Future<void> setPrimaryColor(Color color) async {
    if (_primaryColor.toARGB32() == color.toARGB32()) return;
    _primaryColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_primaryColorKey, color.toARGB32());
    notifyListeners();
  }
}
