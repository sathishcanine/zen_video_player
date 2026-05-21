import 'package:shared_preferences/shared_preferences.dart';

/// First-time color-filter coach shown after the gesture tutorial.
class VideoPlayerColorTutorialService {
  VideoPlayerColorTutorialService._();

  static const String prefsKey = 'video_player_color_tutorial_v1';

  static Future<bool> wasSeen() async {
    try {
      final p = await SharedPreferences.getInstance();
      return p.getBool(prefsKey) == true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> markSeen() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(prefsKey, true);
    } catch (_) {}
  }
}
