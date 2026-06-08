import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/audio_playlist.dart';

/// Persists user audio playlists locally.
class AudioPlaylistService {
  AudioPlaylistService._();

  static const _storageKey = 'audio_playlists_v1';
  static final _random = Random();

  static String _newId() =>
      '${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(1 << 32)}';

  static Future<List<AudioPlaylist>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return <AudioPlaylist>[];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => AudioPlaylist.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return <AudioPlaylist>[];
    }
  }

  static Future<void> _saveAll(List<AudioPlaylist> playlists) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(playlists.map((p) => p.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  static Future<AudioPlaylist> create(String name) async {
    final trimmed = name.trim();
    final playlists = List<AudioPlaylist>.from(await loadAll());
    final playlist = AudioPlaylist(
      id: _newId(),
      name: trimmed.isEmpty ? 'Playlist' : trimmed,
      assetIds: const [],
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
    );
    playlists.insert(0, playlist);
    await _saveAll(playlists);
    return playlist;
  }

  static Future<void> rename(String id, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final playlists = List<AudioPlaylist>.from(await loadAll());
    final i = playlists.indexWhere((p) => p.id == id);
    if (i < 0) return;
    playlists[i] = playlists[i].copyWith(name: trimmed);
    await _saveAll(playlists);
  }

  static Future<void> delete(String id) async {
    final playlists = List<AudioPlaylist>.from(await loadAll());
    playlists.removeWhere((p) => p.id == id);
    await _saveAll(playlists);
  }

  static Future<void> reorder(List<AudioPlaylist> ordered) async {
    await _saveAll(ordered);
  }

  static Future<void> reorderAssets(String playlistId, List<String> ids) async {
    final playlists = List<AudioPlaylist>.from(await loadAll());
    final i = playlists.indexWhere((p) => p.id == playlistId);
    if (i < 0) return;
    playlists[i] = playlists[i].copyWith(assetIds: ids);
    await _saveAll(playlists);
  }

  static Future<void> addAssets(String playlistId, List<String> assetIds) async {
    if (assetIds.isEmpty) return;
    final playlists = List<AudioPlaylist>.from(await loadAll());
    final i = playlists.indexWhere((p) => p.id == playlistId);
    if (i < 0) return;
    final merged = <String>[...playlists[i].assetIds];
    for (final id in assetIds) {
      if (!merged.contains(id)) merged.add(id);
    }
    playlists[i] = playlists[i].copyWith(assetIds: merged);
    await _saveAll(playlists);
  }

  static Future<void> removeAsset(String playlistId, String assetId) async {
    final playlists = List<AudioPlaylist>.from(await loadAll());
    final i = playlists.indexWhere((p) => p.id == playlistId);
    if (i < 0) return;
    final ids = playlists[i].assetIds.where((id) => id != assetId).toList();
    playlists[i] = playlists[i].copyWith(assetIds: ids);
    await _saveAll(playlists);
  }

  static Future<AudioPlaylist?> byId(String id) async {
    final playlists = await loadAll();
    for (final p in playlists) {
      if (p.id == id) return p;
    }
    return null;
  }
}
