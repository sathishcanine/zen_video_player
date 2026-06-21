import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

/// Android system Picture-in-Picture via `MainActivity` [MethodChannel].
class VideoPipHelper {
  VideoPipHelper._();

  static const MethodChannel _channel = MethodChannel('zen.video/pip');
  static const EventChannel _eventChannel = EventChannel('zen.video/pip_events');

  static bool get _android => !kIsWeb && Platform.isAndroid;

  /// Width × height in **display** orientation (accounts for rotation metadata).
  static (double width, double height) displaySizeForPip(VideoPlayerValue value) {
    final rawW = value.size.width;
    final rawH = value.size.height;
    if (rawW <= 0 || rawH <= 0) return (16, 9);
    final rot = value.rotationCorrection % 360;
    if (rot == 90 || rot == 270) {
      return (rawH, rawW);
    }
    return (rawW, rawH);
  }

  /// Display aspect ratio (width ÷ height) after rotation correction.
  static double displayAspectRatio(VideoPlayerValue value) {
    final (w, h) = displaySizeForPip(value);
    if (w <= 0 || h <= 0) return 16 / 9;
    return w / h;
  }

  /// Snaps to standard PiP ratios (YouTube / Hotstar style wide rectangle).
  static (int numerator, int denominator) standardAspectRational(
    VideoPlayerValue value,
  ) {
    final ar = displayAspectRatio(value);
    if (ar >= 1.15) return (16, 9);
    if (ar <= 0.87) return (9, 16);
    if (ar >= 1.0) return (4, 3);
    return (3, 4);
  }

  /// Emits `true` when the activity enters PiP, `false` when it exits.
  static Stream<bool> get pipModeChanges {
    if (!_android) return const Stream<bool>.empty();
    return _eventChannel.receiveBroadcastStream().map((event) => event == true);
  }

  static Map<String, dynamic> _args(
    double width,
    double height, {
    required int aspectNum,
    required int aspectDen,
    Rect? sourceRectPhysical,
  }) {
    final w = width.round().clamp(1, 100000);
    final h = height.round().clamp(1, 100000);
    final map = <String, dynamic>{
      'width': w,
      'height': h,
      'aspectNum': aspectNum.clamp(1, 239),
      'aspectDen': aspectDen.clamp(1, 239),
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
  /// [sourceRectPhysical] is optional; omit for the most reliable shape on OEMs.
  static Future<bool> enterPictureInPicture(
    VideoPlayerValue value, {
    Rect? sourceRectPhysical,
  }) async {
    if (!_android) return false;
    final (w, h) = displaySizeForPip(value);
    if (w <= 0 || h <= 0) return false;
    final (aspectNum, aspectDen) = standardAspectRational(value);
    try {
      final ok = await _channel.invokeMethod<bool>(
        'enter',
        _args(
          w,
          h,
          aspectNum: aspectNum,
          aspectDen: aspectDen,
          sourceRectPhysical: sourceRectPhysical,
        ),
      );
      return ok ?? false;
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Arms auto-enter PiP while the video plays (Android home / recents).
  static Future<void> prepareAutoEnterWhilePlaying(VideoPlayerValue value) async {
    if (!_android) return;
    final (w, h) = displaySizeForPip(value);
    if (w <= 0 || h <= 0) return;
    final (aspectNum, aspectDen) = standardAspectRational(value);
    try {
      await _channel.invokeMethod<void>(
        'prepare',
        _args(w, h, aspectNum: aspectNum, aspectDen: aspectDen),
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
