// Firebase is wired for Android only (`android/app/google-services.json`).
// iOS builds skip Firebase initialization until you add an iOS app and run
// `flutterfire configure`.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Firebase is not configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'Firebase is Android-only in this project; Telemetry.init() will no-op on iOS.',
        );
      default:
        throw UnsupportedError(
          'Firebase is not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBh0RUwCxJZvf42_0CHlZIYIvvZS9BeE3Y',
    appId: '1:730292757522:android:df207a5ea01bd13fd3e4cb',
    messagingSenderId: '730292757522',
    projectId: 'zen-video-player',
    storageBucket: 'zen-video-player.firebasestorage.app',
  );
}
