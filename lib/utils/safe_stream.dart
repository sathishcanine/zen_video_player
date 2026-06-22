import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Cancels an [EventChannel] (or any) subscription without crashing when the
/// native stream was already torn down (common on PiP / visualizer dispose).
Future<void> safeCancelSubscription(
  StreamSubscription<dynamic>? subscription,
) async {
  if (subscription == null) return;
  try {
    await subscription.cancel();
  } on PlatformException catch (e) {
    final detail = '${e.code} ${e.message ?? ''}';
    if (detail.contains('No active stream to cancel')) return;
    debugPrint('[stream] cancel PlatformException: $e');
  } catch (e, st) {
    debugPrint('[stream] cancel failed: $e\n$st');
  }
}
