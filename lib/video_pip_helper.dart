import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

/// Android system Picture-in-Picture via `MainActivity` [MethodChannel].
class VideoPipHelper {
  VideoPipHelper._();

  static const MethodChannel _channel = MethodChannel('zen.video/pip');
  static const EventChannel _eventChannel = EventChannel('zen.video/pip_events');
  static const EventChannel _controlChannel =
      EventChannel('zen.video/pip_controls');

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
  static Stream<bool>? _pipModeBroadcast;
  static Stream<bool> get pipModeChanges {
    if (!_android) return const Stream<bool>.empty();
    return _pipModeBroadcast ??= _eventChannel
        .receiveBroadcastStream()
        .map((event) => event == true)
        .handleError((_) {});
  }

  /// Fires when the user taps play/pause on the system PiP overlay.
  static Stream<void>? _pipControlBroadcast;
  static Stream<void> get pipPlayPauseToggles {
    if (!_android) return const Stream<void>.empty();
    return _pipControlBroadcast ??= _controlChannel
        .receiveBroadcastStream()
        .map((_) {})
        .handleError((_) {});
  }

  static Map<String, dynamic>? _args(
    VideoPlayerValue value, {
    Rect? sourceRectPhysical,
  }) {
    if (!value.isInitialized) return null;
    final (w, h) = displaySizeForPip(value);
    final (aspectNum, aspectDen) = standardAspectRational(value);
    final map = <String, dynamic>{
      'width': w.round().clamp(1, 100000),
      'height': h.round().clamp(1, 100000),
      'aspectNum': aspectNum.clamp(1, 239),
      'aspectDen': aspectDen.clamp(1, 239),
      'isPlaying': value.isPlaying,
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
    try {
      final args = _args(value, sourceRectPhysical: sourceRectPhysical);
      if (args == null) return false;
      final ok = await _channel.invokeMethod<bool>('enter', args);
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
    try {
      final args = _args(value);
      if (args == null) return;
      await _channel.invokeMethod<void>('prepare', args);
    } on PlatformException {
      // ignore
    } catch (_) {
      // ignore
    }
  }

  /// Updates the PiP overlay play/pause icon to match playback state.
  static Future<void> updatePipPlaybackAction(bool isPlaying) async {
    if (!_android) return;
    try {
      await _channel.invokeMethod<void>(
        'updateActions',
        <String, dynamic>{'isPlaying': isPlaying},
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
