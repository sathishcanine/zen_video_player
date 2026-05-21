import 'package:shared_preferences/shared_preferences.dart';

/// Folder IDs hidden from the video library list.
class HiddenFoldersService {
  HiddenFoldersService._();

  static const _key = 'hidden_video_folder_ids_v1';

  static Future<Set<String>> loadHiddenIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? []).toSet();
  }

  static Future<void> hide(String folderId) async {
    if (folderId == '__recent__') return;
    final prefs = await SharedPreferences.getInstance();
    final hidden = await loadHiddenIds();
    hidden.add(folderId);
    await prefs.setStringList(_key, hidden.toList());
  }

  static Future<void> unhide(String folderId) async {
    final prefs = await SharedPreferences.getInstance();
    final hidden = await loadHiddenIds();
    hidden.remove(folderId);
    await prefs.setStringList(_key, hidden.toList());
  }
}
