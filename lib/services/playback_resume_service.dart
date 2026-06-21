import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persists last playback position per video key.
class PlaybackResumeService {
  PlaybackResumeService._();

  static const _videoKey = 'playback_resume_video_v1';
  static const _minSaveMs = 5000;
  static const _minResumeMs = 3000;

  static Future<void> saveVideoPosition(String sourceKey, Duration position) {
    return _save(_videoKey, sourceKey, position);
  }

  static Future<Duration?> loadVideoPosition(String sourceKey) {
    return _load(_videoKey, sourceKey);
  }

  static String videoKeyForSource(String source, {String? assetId}) {
    if (assetId != null && assetId.isNotEmpty) return 'asset:$assetId';
    return source;
  }

  static Future<void> _save(
    String prefsKey,
    String id,
    Duration position,
  ) async {
    if (position.inMilliseconds < _minSaveMs) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(prefsKey);
    final map = raw == null
        ? <String, dynamic>{}
        : Map<String, dynamic>.from(jsonDecode(raw) as Map);
    map[id] = position.inMilliseconds;
    await prefs.setString(prefsKey, jsonEncode(map));
  }

  static Future<Duration?> _load(String prefsKey, String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(prefsKey);
    if (raw == null) return null;
    final map = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    final ms = map[id];
    if (ms is! num || ms < _minResumeMs) return null;
    return Duration(milliseconds: ms.round());
  }
}
