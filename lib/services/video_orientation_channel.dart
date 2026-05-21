import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Android Activity sensor orientation for video playback.
class VideoOrientationChannel {
  VideoOrientationChannel._();

  static const MethodChannel _channel = MethodChannel('zen.video/orientation');

  /// Unlocks the Activity for sensor rotation (call when [VideoPlayerScreen] opens).
  static Future<void> enterPlayerMode() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('enterPlayer');
    } catch (e, st) {
      debugPrint('[video] enterPlayer orientation failed: $e\n$st');
    }
  }

  /// Restores orientation saved before [enterPlayerMode].
  static Future<void> exitPlayerMode() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('exitPlayer');
    } catch (e, st) {
      debugPrint('[video] exitPlayer orientation failed: $e\n$st');
    }
  }

  /// Portrait ↔ landscape when auto-rotate is off or the Activity stayed locked.
  static Future<void> toggleOrientation() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('toggleOrientation');
    } catch (e, st) {
      debugPrint('[video] toggleOrientation failed: $e\n$st');
    }
  }
}
