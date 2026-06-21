import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_settings_service.dart';

/// Last in-progress video for the library "Continue watching" card.
class VideoContinueEntry {
  const VideoContinueEntry({
    required this.storageKey,
    required this.videoSource,
    required this.displayTitle,
    required this.positionMs,
    required this.durationMs,
    this.isLocal = false,
    this.useContentUri = false,
    this.allowNetworkDownload = true,
    this.assetId,
  });

  final String storageKey;
  final String videoSource;
  final String displayTitle;
  final int positionMs;
  final int durationMs;
  final bool isLocal;
  final bool useContentUri;
  final bool allowNetworkDownload;
  final String? assetId;

  Duration get position => Duration(milliseconds: positionMs);
  Duration get duration => Duration(milliseconds: durationMs);

  Map<String, dynamic> toJson() => {
        'storageKey': storageKey,
        'videoSource': videoSource,
        'displayTitle': displayTitle,
        'positionMs': positionMs,
        'durationMs': durationMs,
        'isLocal': isLocal,
        'useContentUri': useContentUri,
        'allowNetworkDownload': allowNetworkDownload,
        if (assetId != null) 'assetId': assetId,
      };

  factory VideoContinueEntry.fromJson(Map<String, dynamic> j) {
    return VideoContinueEntry(
      storageKey: j['storageKey'] as String,
      videoSource: j['videoSource'] as String,
      displayTitle: j['displayTitle'] as String? ?? 'Video',
      positionMs: (j['positionMs'] as num?)?.toInt() ?? 0,
      durationMs: (j['durationMs'] as num?)?.toInt() ?? 0,
      isLocal: j['isLocal'] as bool? ?? false,
      useContentUri: j['useContentUri'] as bool? ?? false,
      allowNetworkDownload: j['allowNetworkDownload'] as bool? ?? true,
      assetId: j['assetId'] as String?,
    );
  }
}

/// Persists and broadcasts the last video for the continue-watching card.
class VideoContinueWatchingService extends ChangeNotifier {
  VideoContinueWatchingService._();

  static final VideoContinueWatchingService instance =
      VideoContinueWatchingService._();

  static const _entryKey = 'video_continue_watching_v1';
  static const _dismissedKey = 'video_continue_dismissed_key_v1';
  static const _minPositionMs = 5000;
  static const _minRemainingMs = 30000;
  static const _minResumeMs = 3000;

  VideoContinueEntry? _visible;

  VideoContinueEntry? get visibleEntry {
    if (!AppSettingsService.instance.resumeVideo) return null;
    return _visible;
  }

  Future<void> refresh() async {
    if (!AppSettingsService.instance.resumeVideo) {
      if (_visible != null) {
        _visible = null;
        notifyListeners();
      }
      return;
    }
    _visible = await _readVisibleFromPrefs();
    notifyListeners();
  }

  Future<void> updateFromPlayback({
    required String storageKey,
    required String videoSource,
    required String displayTitle,
    required Duration position,
    required Duration duration,
    bool isLocal = false,
    bool useContentUri = false,
    bool allowNetworkDownload = true,
    String? assetId,
  }) async {
    if (!AppSettingsService.instance.resumeVideo) return;

    if (position.inMilliseconds < _minPositionMs) return;
    if (duration.inMilliseconds > 0) {
      final remaining = duration - position;
      if (remaining.inMilliseconds < _minRemainingMs) {
        await clear();
        return;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final dismissed = prefs.getString(_dismissedKey);
    final entry = VideoContinueEntry(
      storageKey: storageKey,
      videoSource: videoSource,
      displayTitle: displayTitle,
      positionMs: position.inMilliseconds,
      durationMs: duration.inMilliseconds,
      isLocal: isLocal,
      useContentUri: useContentUri,
      allowNetworkDownload: allowNetworkDownload,
      assetId: assetId,
    );
    if (dismissed == storageKey) {
      _visible = null;
    } else {
      _visible = entry;
    }
    notifyListeners();

    await prefs.setString(_entryKey, jsonEncode(entry.toJson()));

    if (dismissed != null && dismissed != storageKey) {
      await prefs.remove(_dismissedKey);
    }
  }

  Future<void> dismiss(String storageKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dismissedKey, storageKey);
    if (_visible?.storageKey == storageKey) {
      _visible = null;
      notifyListeners();
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_entryKey);
    if (_visible != null) {
      _visible = null;
      notifyListeners();
    }
  }

  static Future<VideoContinueEntry?> _readVisibleFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_entryKey);
    if (raw == null) return null;

    try {
      final entry = VideoContinueEntry.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
      if (entry.positionMs < _minResumeMs) return null;

      final dismissed = prefs.getString(_dismissedKey);
      if (dismissed == entry.storageKey) return null;

      if (entry.durationMs > 0) {
        final remaining = entry.durationMs - entry.positionMs;
        if (remaining < _minRemainingMs) {
          await prefs.remove(_entryKey);
          return null;
        }
      }
      return entry;
    } catch (_) {
      return null;
    }
  }
}
