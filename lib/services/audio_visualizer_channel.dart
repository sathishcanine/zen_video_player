import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Native Android Visualizer → Flutter event stream.
class AudioVisualizerChannel {
  AudioVisualizerChannel._();

  static const _method = MethodChannel('zen.audio/visualizer');
  static const _events = EventChannel('zen.audio/visualizer_stream');

  static Stream<Map<String, dynamic>>? _broadcast;

  static Stream<Map<String, dynamic>> get events {
    if (!Platform.isAndroid) return const Stream.empty();
    return _broadcast ??= _events
        .receiveBroadcastStream()
        .map((e) => Map<String, dynamic>.from(e as Map));
  }

  static Future<bool> start(int sessionId) async {
    if (!Platform.isAndroid || sessionId == 0) return false;
    try {
      final ok = await _method.invokeMethod<bool>('start', {
        'sessionId': sessionId,
      });
      return ok ?? false;
    } catch (e, st) {
      debugPrint('[audio_visualizer] start failed: $e\n$st');
      return false;
    }
  }

  static Future<void> stop() async {
    if (!Platform.isAndroid) return;
    try {
      await _method.invokeMethod<void>('stop');
    } catch (e, st) {
      debugPrint('[audio_visualizer] stop failed: $e\n$st');
    }
  }
}
