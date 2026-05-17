import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

/// Android system Picture-in-Picture via `MainActivity` [MethodChannel].
class VideoPipHelper {
  static const MethodChannel _channel = MethodChannel('zen.video/pip');

  static bool get _android => !kIsWeb && Platform.isAndroid;

  static Map<String, dynamic> _args(
    double width,
    double height,
    Rect? sourceRectPhysical,
  ) {
    final w = width.round().clamp(1, 100000);
    final h = height.round().clamp(1, 100000);
    final map = <String, dynamic>{
      'width': w,
      'height': h,
    };
    final r = sourceRectPhysical;
    if (r != null) {
      map['srcLeft'] = r.left.round().clamp(0, 1 << 30);
      map['srcTop'] = r.top.round().clamp(0, 1 << 30);
      map['srcRight'] = r.right.round().clamp(0, 1 << 30);
      map['srcBottom'] = r.bottom.round().clamp(0, 1 << 30);
    }
    return map;
  }

  /// Requests PiP with an aspect ratio matching the video frame (width × height).
  /// [sourceRectPhysical] is in **device pixels** (window coordinates), for a
  /// YouTube-style shrink animation when set.
  /// Returns whether the native call reported success (still OS-dependent).
  static Future<bool> enterPictureInPicture(
    double width,
    double height, {
    Rect? sourceRectPhysical,
  }) async {
    if (!_android) return false;
    if (width <= 0 || height <= 0) return false;
    try {
      final ok = await _channel.invokeMethod<bool>(
        'enter',
        _args(width, height, sourceRectPhysical),
      );
      return ok ?? false;
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Tells [MainActivity] the user may enter PiP when leaving the app while the
  /// video is playing. Must run **before** backgrounding: Android rejects
  /// [enterPictureInPictureMode] once the activity is already paused; API 31+
  /// uses [setPictureInPictureParams] with auto-enter instead.
  static Future<void> prepareAutoEnterWhilePlaying(
    double width,
    double height, {
    Rect? sourceRectPhysical,
  }) async {
    if (!_android) return;
    if (width <= 0 || height <= 0) return;
    try {
      await _channel.invokeMethod<void>(
        'prepare',
        _args(width, height, sourceRectPhysical),
      );
    } on PlatformException {
      // ignore
    } catch (_) {
      // ignore
    }
  }

  /// Clears PiP-on-leave / auto-enter so leaving the app does not enter PiP
  /// (e.g. video paused or screen disposed).
  static Future<void> clearPipEligibility() async {
    if (!_android) return;
    try {
      await _channel.invokeMethod<void>('clear');
    } on PlatformException {
      // ignore
    } catch (_) {
      // ignore
    }
  }
}
