import 'package:shared_preferences/shared_preferences.dart';

/// Persists the last audio library sub-section (Album / Songs / …).
class AudioLibraryPrefs {
  AudioLibraryPrefs._();

  static const _sectionKey = 'audio_library_section_v1';

  static Future<int> loadSectionIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getInt(_sectionKey) ?? 0).clamp(0, 4);
  }

  static Future<void> saveSectionIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sectionKey, index.clamp(0, 4));
  }
}
