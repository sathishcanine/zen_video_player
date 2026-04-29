import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import 'telemetry.dart';

/// Analytics + Crashlytics for [VideoPlayerScreen] failures and lifecycle.
class VideoPlayerTelemetry {
  VideoPlayerTelemetry._();

  static Future<void> screenOpened({
    required bool isLocal,
    required bool allowNetworkDownload,
    required String videoSource,
  }) {
    final ctx = _sourceContext(videoSource, isLocal);
    return Telemetry.logEvent(
      'video_player_open',
      {
        'is_local': isLocal ? 1 : 0,
        'allow_download': allowNetworkDownload ? 1 : 0,
        ...ctx.analyticsParams,
      },
    );
  }

  static Future<void> initStarted({
    required bool isLocal,
    required String videoSource,
  }) {
    final ctx = _sourceContext(videoSource, isLocal);
    return Telemetry.logEvent(
      'video_player_init_started',
      {
        'is_local': isLocal ? 1 : 0,
        ...ctx.analyticsParams,
      },
    );
  }

  static Future<void> initSucceeded({
    required bool isLocal,
    required String videoSource,
    required Duration elapsed,
  }) {
    final ctx = _sourceContext(videoSource, isLocal);
    return Telemetry.logEvent(
      'video_player_init_succeeded',
      {
        'is_local': isLocal ? 1 : 0,
        'elapsed_ms': elapsed.inMilliseconds,
        ...ctx.analyticsParams,
      },
    );
  }

  static Future<void> initFailed({
    required bool isLocal,
    required String videoSource,
    required Object error,
    StackTrace? stackTrace,
    required Duration elapsed,
  }) async {
    final ctx = _sourceContext(videoSource, isLocal);
    final human = _humanMessage(error);
    final type = _errorType(error);

    await Telemetry.logEvent(
      'video_player_init_failed',
      {
        'is_local': isLocal ? 1 : 0,
        'error_type': type,
        'elapsed_ms': elapsed.inMilliseconds,
        ...ctx.analyticsParams,
        'message': human,
      },
    );

    await Telemetry.recordNonFatal(
      error,
      stackTrace,
      reason: 'VideoPlayerScreen.initialize failed',
      context: {
        'stage': 'initialize',
        'error_type': type,
        'human_message': human,
        'elapsed_ms': '${elapsed.inMilliseconds}',
        'is_local': '$isLocal',
        ...ctx.crashlyticsStrings,
      },
    );
  }

  static Future<void> playbackError({
    required bool isLocal,
    required String videoSource,
    required String errorDescription,
  }) async {
    final ctx = _sourceContext(videoSource, isLocal);

    await Telemetry.logEvent(
      'video_player_playback_error',
      {
        'is_local': isLocal ? 1 : 0,
        ...ctx.analyticsParams,
        'message': errorDescription,
      },
    );

    await Telemetry.recordNonFatal(
      Exception(errorDescription),
      StackTrace.current,
      reason: 'VideoPlayerScreen playback error',
      context: {
        'stage': 'playback',
        'is_local': '$isLocal',
        'error_description': errorDescription,
        ...ctx.crashlyticsStrings,
      },
    );
  }

  static Future<void> downloadFailed({
    required String videoSource,
    required Object error,
    StackTrace? stackTrace,
  }) async {
    final ctx = _sourceContext(videoSource, false);

    await Telemetry.logEvent(
      'video_player_download_failed',
      {
        ...ctx.analyticsParams,
        'message': error.toString(),
      },
    );

    await Telemetry.recordNonFatal(
      error,
      stackTrace,
      reason: 'VideoPlayerScreen.download failed',
      context: {
        'stage': 'download',
        ...ctx.crashlyticsStrings,
      },
    );
  }

  static String _humanMessage(Object e) {
    if (e is TimeoutException) {
      return e.message ?? e.toString();
    }
    if (e is PlatformException) {
      final m = e.message;
      if (m != null && m.isNotEmpty) return m;
      return 'Player error (${e.code}).';
    }
    return e.toString();
  }

  static String _errorType(Object e) {
    if (e is TimeoutException) return 'TimeoutException';
    if (e is PlatformException) return 'PlatformException';
    if (e is SocketException) return 'SocketException';
    if (e is FileSystemException) return 'FileSystemException';
    return e.runtimeType.toString();
  }
}

class _SourceContext {
  _SourceContext({
    required this.analyticsParams,
    required this.crashlyticsStrings,
  });

  final Map<String, Object?> analyticsParams;
  final Map<String, String> crashlyticsStrings;
}

_SourceContext _sourceContext(String videoSource, bool isLocal) {
  if (isLocal) {
    final name = videoSource.split(Platform.pathSeparator).last;
    return _SourceContext(
      analyticsParams: {
        'source_kind': 'file',
        'file_name': name,
      },
      crashlyticsStrings: {
        'video_source_kind': 'file',
        'video_file_name': name,
        'video_path_length': '${videoSource.length}',
      },
    );
  }
  try {
    final uri = Uri.parse(videoSource);
    return _SourceContext(
      analyticsParams: {
        'source_kind': 'network',
        'uri_scheme': uri.scheme,
        'uri_host': uri.host,
        'path_len': uri.path.length,
      },
      crashlyticsStrings: {
        'video_source_kind': 'network',
        'video_uri': videoSource,
        'uri_scheme': uri.scheme,
        'uri_host': uri.host,
        'uri_path': uri.path,
        'uri_query_len': '${uri.query.length}',
      },
    );
  } catch (_) {
    return _SourceContext(
      analyticsParams: {'source_kind': 'network_invalid_uri'},
      crashlyticsStrings: {
        'video_source_kind': 'network',
        'video_uri': videoSource,
      },
    );
  }
}
