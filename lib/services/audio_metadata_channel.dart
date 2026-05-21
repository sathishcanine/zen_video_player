import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AudioFileMetadata {
  const AudioFileMetadata({
    required this.album,
    required this.artist,
    required this.title,
    required this.hasArtwork,
  });

  final String album;
  final String artist;
  final String title;
  final bool hasArtwork;
}

/// Native audio metadata (Android [MediaMetadataRetriever]).
class AudioMetadataChannel {
  AudioMetadataChannel._();

  static const MethodChannel _channel = MethodChannel('zen.audio/metadata');

  static Future<Uint8List?> getArtwork(String path) async {
    if (!Platform.isAndroid) return null;
    try {
      final bytes = await _channel.invokeMethod<Uint8List>(
        'getArtwork',
        <String, String>{'path': path},
      );
      if (bytes != null && bytes.isNotEmpty) return bytes;
    } catch (e, st) {
      debugPrint('[audio] getArtwork failed: $e\n$st');
    }
    return null;
  }

  static Future<AudioFileMetadata?> getMetadata(String path) async {
    if (!Platform.isAndroid) return null;
    try {
      final map = await _channel.invokeMapMethod<String, dynamic>(
        'getMetadata',
        <String, String>{'path': path},
      );
      if (map == null) return null;
      return AudioFileMetadata(
        album: map['album'] as String? ?? '',
        artist: map['artist'] as String? ?? '',
        title: map['title'] as String? ?? '',
        hasArtwork: map['hasArtwork'] as bool? ?? false,
      );
    } catch (e, st) {
      debugPrint('[audio] getMetadata failed: $e\n$st');
    }
    return null;
  }
}
