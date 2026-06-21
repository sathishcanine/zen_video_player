import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'media_asset_filter.dart';
import 'media_permission_service.dart';

/// A video folder hidden from the library grid via "Hide from list".
class HiddenFolderEntry {
  const HiddenFolderEntry({
    required this.id,
    required this.displayName,
  });

  final String id;
  final String displayName;
}

/// Folder IDs hidden from the video library list.
class HiddenFoldersService extends ChangeNotifier {
  HiddenFoldersService._();

  static final HiddenFoldersService instance = HiddenFoldersService._();

  static const _idsKey = 'hidden_video_folder_ids_v1';
  static const _namesKey = 'hidden_video_folder_names_v1';

  Future<Set<String>> loadHiddenIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_idsKey) ?? []).toSet();
  }

  Future<List<HiddenFolderEntry>> loadHiddenEntries() async {
    final ids = await loadHiddenIds();
    if (ids.isEmpty) return const [];

    final names = await _loadNameMap();
    final entries = <HiddenFolderEntry>[];
    for (final id in ids) {
      final name = names[id] ?? await _resolveDisplayName(id);
      entries.add(HiddenFolderEntry(id: id, displayName: name));
    }
    entries.sort(
      (a, b) => a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
    );
    return entries;
  }

  Future<void> hide(String folderId, {String? displayName}) async {
    if (folderId == '__recent__') return;
    final prefs = await SharedPreferences.getInstance();
    final hidden = await loadHiddenIds();
    hidden.add(folderId);
    await prefs.setStringList(_idsKey, hidden.toList());

    if (displayName != null && displayName.isNotEmpty) {
      final names = await _loadNameMap();
      names[folderId] = displayName;
      await _saveNameMap(names);
    }

    notifyListeners();
  }

  Future<void> unhide(String folderId) async {
    final prefs = await SharedPreferences.getInstance();
    final hidden = await loadHiddenIds();
    if (!hidden.remove(folderId)) return;
    await prefs.setStringList(_idsKey, hidden.toList());

    final names = await _loadNameMap();
    names.remove(folderId);
    await _saveNameMap(names);

    notifyListeners();
  }

  Future<void> unhideAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_idsKey);
    await prefs.remove(_namesKey);
    notifyListeners();
  }

  Future<Map<String, String>> _loadNameMap() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_namesKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      return decoded.map(
        (key, value) => MapEntry('$key', '$value'),
      );
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveNameMap(Map<String, String> names) async {
    final prefs = await SharedPreferences.getInstance();
    if (names.isEmpty) {
      await prefs.remove(_namesKey);
      return;
    }
    await prefs.setString(_namesKey, jsonEncode(names));
  }

  Future<String> _resolveDisplayName(String folderId) async {
    if (!await MediaPermissionService.hasMediaAccess()) {
      return folderId;
    }
    try {
      final paths = await PhotoManager.getAssetPathList(
        type: RequestType.video,
        hasAll: true,
        onlyAll: false,
        filterOption: kMediaAssetFilter,
      );
      for (final path in paths) {
        if (path.id == folderId) return path.name;
      }
    } catch (e, st) {
      debugPrint('[hidden_folders] resolve name failed: $e\n$st');
    }
    return folderId;
  }
}
