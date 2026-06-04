import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

/// Play Store rating prompts: after rewarded download, and on day 2+ on home.
class PlayStoreRatingService {
  PlayStoreRatingService._();

  static const _downloadPendingKey = 'play_store_rating_pending_v1';
  static const _homePendingKey = 'play_store_rating_home_pending_v1';
  static const _firstUseDayKey = 'play_store_rating_first_use_day_v1';
  static const _ratedKey = 'play_store_rating_rated_v1';
  static const _legacyCompletedKey = 'play_store_rating_completed_v1';
  static const _snoozeUntilKey = 'play_store_rating_snooze_until_v1';

  /// Call when a post-ad download was started successfully.
  static Future<void> markDownloadStarted() async {
    if (!_isEligiblePlatform) return;
    final prefs = await SharedPreferences.getInstance();
    if (_hasRated(prefs)) return;
    await prefs.setBool(_downloadPendingKey, true);
  }

  /// Records the first calendar day of use; schedules the home prompt from day 2.
  static Future<void> recordCalendarDay() async {
    if (!_isEligiblePlatform) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_hasRated(prefs)) return;
      if (_isSnoozed(prefs)) return;

      final today = _dayKey(DateTime.now());
      final firstRaw = prefs.getString(_firstUseDayKey);
      if (firstRaw == null) {
        await prefs.setString(_firstUseDayKey, today);
        return;
      }

      final firstDay = _parseDayKey(firstRaw);
      if (firstDay == null) {
        await prefs.setString(_firstUseDayKey, today);
        return;
      }

      if (today == _dayKey(firstDay)) return;

      await prefs.setBool(_homePendingKey, true);
    } catch (_) {
      // Never crash cold start for existing users on corrupt prefs.
    }
  }

  static Future<bool> shouldPromptOnResume() async {
    if (!_isEligiblePlatform) return false;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_hasRated(prefs)) return false;
      if (_isSnoozed(prefs)) return false;
      return prefs.getBool(_downloadPendingKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> shouldPromptOnHomeScreen() async {
    if (!_isEligiblePlatform) return false;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_hasRated(prefs)) return false;
      if (_isSnoozed(prefs)) return false;
      return prefs.getBool(_homePendingKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> clearHomePending() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_homePendingKey, false);
    } catch (_) {}
  }

  /// Defers all prompts until snooze expires (e.g. user tapped Maybe).
  static Future<void> snooze({
    Duration duration = const Duration(days: 1),
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        _snoozeUntilKey,
        DateTime.now().add(duration).millisecondsSinceEpoch,
      );
      await prefs.setBool(_homePendingKey, false);
    } catch (_) {}
  }

  /// User chose Rate now — never show again.
  static Future<void> markRated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_ratedKey, true);
      await prefs.remove(_legacyCompletedKey);
      await prefs.remove(_downloadPendingKey);
      await prefs.remove(_homePendingKey);
      await prefs.remove(_snoozeUntilKey);
    } catch (_) {}
  }

  static bool _hasRated(SharedPreferences prefs) {
    if (prefs.getBool(_ratedKey) ?? false) return true;
    return prefs.getBool(_legacyCompletedKey) ?? false;
  }

  static bool _isSnoozed(SharedPreferences prefs) {
    final snoozeUntil = prefs.getInt(_snoozeUntilKey);
    if (snoozeUntil == null) return false;
    return DateTime.now().millisecondsSinceEpoch < snoozeUntil;
  }

  static String _dayKey(DateTime dt) {
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '${dt.year}-$m-$d';
  }

  static DateTime? _parseDayKey(String raw) {
    final parts = raw.split('-');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    if (m < 1 || m > 12 || d < 1 || d > 31) return null;
    return DateTime(y, m, d);
  }

  static bool get _isEligiblePlatform {
    if (kIsWeb) return false;
    return Platform.isAndroid;
  }
}
