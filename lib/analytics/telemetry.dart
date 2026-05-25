import 'dart:async';
import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../app_update/force_update_remote_config.dart';
import '../firebase_options.dart';

/// Firebase Analytics + Crashlytics bootstrap and safe no-op fallbacks.
class Telemetry {
  Telemetry._();

  static FirebaseAnalytics? _analytics;
  static FirebaseCrashlytics? _crashlytics;

  static bool get isFirebaseReady => _crashlytics != null;

  static Future<void> init() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _analytics = FirebaseAnalytics.instance;
      _crashlytics = FirebaseCrashlytics.instance;

      await _crashlytics!.setCrashlyticsCollectionEnabled(!kDebugMode);

      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        _crashlytics?.recordFlutterFatalError(details);
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        _crashlytics?.recordError(error, stack, fatal: true);
        return true;
      };

      unawaited(ForceUpdateRemoteConfig.prefetch());
    } catch (e, st) {
      debugPrint('Telemetry: Firebase init failed — add native config and run '
          'flutterfire configure. ($e)\n$st');
      _analytics = null;
      _crashlytics = null;
    }
  }

  static Future<void> logEvent(
    String name,
    Map<String, Object?> parameters,
  ) async {
    final a = _analytics;
    if (a == null) return;
    try {
      await a.logEvent(
        name: name,
        parameters: _analyticsParams(parameters),
      );
    } catch (e, st) {
      debugPrint('Telemetry: logEvent failed: $e\n$st');
    }
  }

  /// Non-fatal issue (e.g. video init failure). Prefer for user-visible errors.
  static Future<void> recordNonFatal(
    Object exception,
    StackTrace? stackTrace, {
    String? reason,
    Map<String, String>? context,
  }) async {
    final c = _crashlytics;
    if (c == null) return;
    try {
      final info = <Object>[
        if (reason != null) 'reason: $reason',
        ...?context?.entries.map((e) => '${e.key}=${e.value}'),
      ];
      await c.recordError(
        exception,
        stackTrace,
        reason: reason,
        information: info,
        fatal: false,
      );
    } catch (e, st) {
      debugPrint('Telemetry: recordNonFatal failed: $e\n$st');
    }
  }

  static void recordZoneError(Object error, StackTrace stack) {
    final c = _crashlytics;
    if (c != null) {
      unawaited(c.recordError(error, stack, fatal: true));
    } else {
      debugPrint('Telemetry: zone error (Firebase off): $error\n$stack');
    }
  }

  /// GA4 allows string or num; truncate strings to stay within limits.
  static Map<String, Object> _analyticsParams(Map<String, Object?> raw) {
    const maxLen = 99;
    final out = <String, Object>{};
    var count = 0;
    for (final e in raw.entries) {
      if (count >= 24) break;
      final v = e.value;
      if (v == null) continue;
      if (v is num) {
        out[e.key] = v;
      } else {
        final s = v.toString();
        out[e.key] =
            s.length > maxLen ? '${s.substring(0, maxLen - 3)}...' : s;
      }
      count++;
    }
    return out;
  }
}
