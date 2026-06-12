import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One-time "what's new" prompts for users who **update** the app.
///
/// Fresh installs have no stored version, so announcements stay hidden.
class FeatureAnnouncementService {
  FeatureAnnouncementService._();

  static const _lastRecordedVersionKey = 'app_last_recorded_version_code_v1';
  static const _equalizerAnnouncePendingKey =
      'feature_announce_equalizer_v1_pending';

  /// First build that ships the audio equalizer (must match pubspec `+N`).
  static const int equalizerFeatureVersionCode = 27;

  /// Call once per cold start before the library home is shown.
  static Future<void> recordVersionOnColdStart() async {
    if (kIsWeb) return;
    try {
      final info = await PackageInfo.fromPlatform();
      final current = int.tryParse(info.buildNumber) ?? 0;
      if (current <= 0) return;

      final prefs = await SharedPreferences.getInstance();
      final last = prefs.getInt(_lastRecordedVersionKey);

      if (last != null &&
          last < current &&
          current >= equalizerFeatureVersionCode &&
          last < equalizerFeatureVersionCode) {
        await prefs.setBool(_equalizerAnnouncePendingKey, true);
      }

      await prefs.setInt(_lastRecordedVersionKey, current);
    } catch (e, st) {
      debugPrint('[feature_announce] recordVersion failed: $e\n$st');
    }
  }

  static Future<bool> shouldShowEqualizerAnnounce() async {
    if (kIsWeb) return false;
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_equalizerAnnouncePendingKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> markEqualizerAnnounceShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_equalizerAnnouncePendingKey, false);
    } catch (_) {}
  }
}
