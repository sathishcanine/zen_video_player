import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight "new content" tracking — only folder counts + newest file
/// timestamp per folder (a few bytes per album, no asset-id lists).
class NewMediaTracker extends ChangeNotifier {
  NewMediaTracker._();

  static final NewMediaTracker instance = NewMediaTracker._();

  static const _baselineKey = 'video_folder_baseline_v2';

  /// Whether [folderId] has more videos than when the user last acknowledged it.
  static Future<bool> isFolderNew({
    required String folderId,
    required int videoCount,
  }) async {
    final baseline = await _loadBaseline();
    if (!baseline.isEstablished) return false;

    final entry = baseline.folders[folderId];
    if (entry == null) return videoCount > 0;
    return videoCount > entry.count;
  }

  /// First library scan after install — remember current state, no NEW badges.
  static Future<void> establishFolderBaseline(
    Map<String, int> folderCounts,
  ) async {
    final baseline = await _loadBaseline();
    if (baseline.isEstablished) return;

    final folders = <String, _FolderEntry>{};
    for (final e in folderCounts.entries) {
      folders[e.key] = _FolderEntry(count: e.value);
    }
    await _saveBaseline(_Baseline(isEstablished: true, folders: folders));
  }

  /// Call when the user opens a folder — clears NEW for that album.
  static Future<void> acknowledgeFolder(
    String folderId,
    List<AssetEntity> assets,
  ) async {
    final baseline = await _loadBaseline();
    final newestMs = _maxCreateMs(assets);
    final entry = _FolderEntry(
      count: assets.length,
      newestMs: newestMs,
    );
    baseline.folders[folderId] = entry;
    await _saveBaseline(baseline);
    instance.notifyListeners();
  }

  /// IDs of files that are new since the last time this folder was opened.
  static Future<Set<String>> newAssetIdsInFolder({
    required String folderId,
    required List<AssetEntity> assets,
  }) async {
    final baseline = await _loadBaseline();
    if (!baseline.isEstablished || assets.isEmpty) return {};

    final entry = baseline.folders[folderId];
    if (entry == null) return {};

    final ids = <String>{};

    // Count grew — tag the newest N files (works even when file timestamps are stale).
    final delta = assets.length - entry.count;
    if (delta > 0) {
      final sorted = List<AssetEntity>.from(assets)
        ..sort((a, b) => b.createDateTime.compareTo(a.createDateTime));
      ids.addAll(sorted.take(delta).map((a) => a.id));
    }

    // Also pick up anything newer than the last acknowledged max timestamp.
    final newestMs = entry.newestMs;
    if (newestMs != null) {
      for (final a in assets) {
        if (a.createDateTime.millisecondsSinceEpoch > newestMs) {
          ids.add(a.id);
        }
      }
    }

    return ids;
  }

  /// File-level NEW inside a folder (only after baseline exists for that folder).
  static Future<bool> isAssetNew({
    required String folderId,
    required DateTime createDateTime,
  }) async {
    final baseline = await _loadBaseline();
    if (!baseline.isEstablished) return false;

    final entry = baseline.folders[folderId];
    if (entry == null || entry.newestMs == null) return false;

    return createDateTime.millisecondsSinceEpoch > entry.newestMs!;
  }

  static int? _maxCreateMs(List<AssetEntity> assets) {
    if (assets.isEmpty) return null;
    var max = assets.first.createDateTime.millisecondsSinceEpoch;
    for (final a in assets.skip(1)) {
      final ms = a.createDateTime.millisecondsSinceEpoch;
      if (ms > max) max = ms;
    }
    return max;
  }

  static Future<_Baseline> _loadBaseline() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_baselineKey);
    if (raw == null) return _Baseline.empty();

    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      if (j['v'] != 2) return _Baseline.empty();

      final established = j['ready'] as bool? ?? false;
      final foldersRaw = j['folders'] as Map<String, dynamic>? ?? {};
      final folders = <String, _FolderEntry>{};

      for (final e in foldersRaw.entries) {
        final m = e.value as Map<String, dynamic>;
        folders[e.key] = _FolderEntry(
          count: (m['c'] as num?)?.toInt() ?? 0,
          newestMs: (m['t'] as num?)?.toInt(),
        );
      }
      return _Baseline(isEstablished: established, folders: folders);
    } catch (_) {
      return _Baseline.empty();
    }
  }

  static Future<void> _saveBaseline(_Baseline baseline) async {
    final prefs = await SharedPreferences.getInstance();
    final folders = <String, dynamic>{};
    for (final e in baseline.folders.entries) {
      final entry = <String, dynamic>{'c': e.value.count};
      if (e.value.newestMs != null) entry['t'] = e.value.newestMs;
      folders[e.key] = entry;
    }
    await prefs.setString(
      _baselineKey,
      jsonEncode({
        'v': 2,
        'ready': baseline.isEstablished,
        'folders': folders,
      }),
    );
  }
}

class _Baseline {
  _Baseline({required this.isEstablished, required this.folders});

  factory _Baseline.empty() =>
      _Baseline(isEstablished: false, folders: {});

  final bool isEstablished;
  final Map<String, _FolderEntry> folders;
}

class _FolderEntry {
  const _FolderEntry({required this.count, this.newestMs});

  final int count;
  final int? newestMs;
}
