import 'package:flutter/material.dart';

import '../screens/audio_now_playing_screen.dart';

/// Route names for the library shell navigator.
abstract final class AudioRoutes {
  static const String nowPlaying = 'audio_now_playing';

  static bool isNowPlaying(Route<dynamic>? route) {
    return route?.settings.name == nowPlaying;
  }

  static Route<void> nowPlayingRoute() {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: nowPlaying),
      builder: (_) => const AudioNowPlayingScreen(),
    );
  }
}
