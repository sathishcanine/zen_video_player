import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';

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

  /// Reads tags from [asset] without [AssetEntity.file] (avoids pm_* cache copies).
  static Future<AudioFileMetadata?> getMetadataForAsset(AssetEntity asset) async {
    if (!Platform.isAndroid) return null;
    final source = await _resolveMediaSource(asset);
    if (source == null) return null;
    return getMetadataFromSource(source);
  }

  /// Reads embedded art from [asset] without exporting the whole file to cache.
  static Future<Uint8List?> getArtworkForAsset(AssetEntity asset) async {
    if (!Platform.isAndroid) return null;
    final source = await _resolveMediaSource(asset);
    if (source == null) return null;
    return getArtworkFromSource(source);
  }

  static Future<String?> _resolveMediaSource(AssetEntity asset) async {
    final url = await asset.getMediaUrl();
    if (url != null && url.isNotEmpty) return url;
    final file = await asset.file;
    return file?.path;
  }

  static Future<Uint8List?> getArtworkFromSource(String source) async {
    if (!Platform.isAndroid) return null;
    try {
      final args = source.startsWith('content://')
          ? <String, String>{'uri': source}
          : <String, String>{'path': source};
      final bytes = await _channel.invokeMethod<Uint8List>('getArtwork', args);
      if (bytes != null && bytes.isNotEmpty) return bytes;
    } catch (e, st) {
      debugPrint('[audio] getArtwork failed: $e\n$st');
    }
    return null;
  }

  static Future<AudioFileMetadata?> getMetadataFromSource(String source) async {
    if (!Platform.isAndroid) return null;
    try {
      final args = source.startsWith('content://')
          ? <String, String>{'uri': source}
          : <String, String>{'path': source};
      final map = await _channel.invokeMapMethod<String, dynamic>(
        'getMetadata',
        args,
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
