import 'dart:io';

import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';

/// MediaStore helpers that avoid copying whole files into app cache.
class MediaAssetChannel {
  MediaAssetChannel._();

  static const _channel = MethodChannel('zen.media/asset');

  /// Reads [MediaStore.MediaColumns.SIZE] for an asset id (Android only).
  static Future<int> getSizeBytes(AssetEntity asset) async {
    if (!Platform.isAndroid) return 0;
    try {
      final size = await _channel.invokeMethod<int>('getSizeBytes', {
        'id': asset.id,
        'type': asset.typeInt,
      });
      return size ?? 0;
    } catch (_) {
      return 0;
    }
  }
}
