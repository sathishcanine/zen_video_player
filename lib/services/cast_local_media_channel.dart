import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/services.dart';

/// Android helper to turn `content://` media into a readable file path for Cast.
class CastLocalMediaChannel {
  CastLocalMediaChannel._();

  static const _channel = MethodChannel('zen.cast/local');

  static Future<String?> resolveReadablePath(String uri) async {
    if (kIsWeb || !Platform.isAndroid) return null;
    if (uri.isEmpty) return null;
    try {
      final path = await _channel.invokeMethod<String>(
        'resolveReadablePath',
        <String, String>{'uri': uri},
      );
      if (path == null || path.isEmpty) return null;
      final file = File(path);
      if (!await file.exists()) return null;
      return path;
    } catch (e, st) {
      debugPrint('[cast] resolveReadablePath failed: $e\n$st');
      return null;
    }
  }
}
