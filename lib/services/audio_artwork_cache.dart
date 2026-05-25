import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';

import 'audio_metadata_channel.dart';

/// Loads embedded album art from audio files (photo_manager cannot thumbnail audio).
class AudioArtworkCache {
  AudioArtworkCache._();

  static final AudioArtworkCache instance = AudioArtworkCache._();

  final Map<String, Uint8List?> _bytes = {};
  final Map<String, Future<Uint8List?>> _inflight = {};

  Future<Uint8List?> load(AssetEntity asset) {
    final id = asset.id;
    if (_bytes.containsKey(id)) {
      return Future.value(_bytes[id]);
    }
    return _inflight.putIfAbsent(id, () => _load(asset));
  }

  Future<Uint8List?> _load(AssetEntity asset) async {
    try {
      final bytes = await AudioMetadataChannel.getArtworkForAsset(asset);
      if (bytes != null && bytes.isNotEmpty) {
        _bytes[asset.id] = bytes;
        return bytes;
      }
    } catch (e, st) {
      debugPrint('[audio] artwork load failed: $e\n$st');
    }
    _bytes[asset.id] = null;
    return null;
  }

  void clear() => _bytes.clear();
}
