import 'package:flutter/foundation.dart';

import 'audio_metadata_channel.dart';
import 'package:photo_manager/photo_manager.dart';

import '../analytics/telemetry.dart';
import '../models/audio_track.dart';
import '../models/media_folder.dart';
import 'media_asset_filter.dart';
import 'media_permission_service.dart';

/// Loads on-device audio via [photo_manager].
class LocalAudioService {
  LocalAudioService._();

  static const PermissionRequestOption _audioRequestOption =
      PermissionRequestOption(
    androidPermission: AndroidPermission(
      type: RequestType.audio,
      mediaLocation: false,
    ),
  );

  static Future<List<AudioTrack>> loadTracks() async {
    if (!await MediaPermissionService.hasAudioAccess()) {
      return const [];
    }

    final paths = await PhotoManager.getAssetPathList(
      type: RequestType.audio,
      hasAll: true,
      onlyAll: false,
      filterOption: kMediaAssetFilter,
    );

    final tracks = <AudioTrack>[];
    const pageSize = 200;

    // Page per album — avoid `isAll` (OEM SQL: `ORDER BY LIMIT` when option null).
    for (final path in paths) {
      if (path.isAll) continue;
      try {
        var page = 0;
        while (page <= 50) {
          final batch = await path.getAssetListPaged(page: page, size: pageSize);
          if (batch.isEmpty) break;
          for (final asset in batch) {
            tracks.add(_trackFromAsset(asset));
          }
          if (batch.length < pageSize) break;
          page++;
        }
      } catch (e, st) {
        debugPrint('[audio] album ${path.id} skipped: $e\n$st');
        await Telemetry.recordNonFatal(
          e,
          st,
          reason: 'loadTracksAlbum',
          context: {'albumId': path.id},
        );
      }
    }

    tracks.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return tracks;
  }

  static AudioTrack _trackFromAsset(AssetEntity asset) {
    final title = _clean(asset.title ?? asset.relativePath ?? 'Track');
    final folder = _folderFromPath(asset.relativePath);
    final albumName = folder.isNotEmpty ? folder : title;
    return AudioTrack(
      asset: asset,
      title: title,
      artist: folder,
      albumName: albumName,
      albumKey: albumName.toLowerCase(),
      folderName: folder,
    );
  }

  static String _clean(String raw) {
    final name = raw.split('/').last;
    final dot = name.lastIndexOf('.');
    return dot > 0 ? name.substring(0, dot) : name;
  }

  static String _folderFromPath(String? path) {
    if (path == null || !path.contains('/')) return '';
    final parts = path.split('/');
    if (parts.length < 2) return '';
    return parts[parts.length - 2];
  }

  static List<AudioAlbum> groupAlbums(List<AudioTrack> tracks) {
    final map = <String, List<AudioTrack>>{};
    for (final t in tracks) {
      map.putIfAbsent(t.albumKey, () => []).add(t);
    }

    final albums = map.entries.map((e) {
      final list = e.value;
      final first = list.first;
      return AudioAlbum(
        id: e.key,
        title: first.albumName,
        artist: first.artist,
        trackCount: list.length,
        tracks: list,
        coverAsset: first.asset,
      );
    }).toList();

    albums.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return albums;
  }

  /// Resolves embedded tags + cover art per album (like system music apps).
  static Future<List<AudioAlbum>> groupAlbumsEnriched(List<AudioTrack> tracks) async {
    final basic = groupAlbums(tracks);
    final enriched = <AudioAlbum>[];
    for (final album in basic) {
      enriched.add(await _enrichAlbum(album));
    }
    return enriched;
  }

  static Future<AudioAlbum> _enrichAlbum(AudioAlbum album) async {
    var title = album.title;
    var artist = album.artist;
    AssetEntity? cover = album.coverAsset;

    for (final track in album.tracks.take(12)) {
      try {
        final info = await AudioMetadataChannel.getMetadataForAsset(track.asset);
        if (info != null) {
          if (info.album.isNotEmpty) title = info.album;
          if (info.artist.isNotEmpty) artist = info.artist;
          if (info.hasArtwork) {
            cover = track.asset;
            break;
          }
        }
      } catch (e) {
        debugPrint('[audio] metadata read failed: $e');
      }
    }

    return AudioAlbum(
      id: album.id,
      title: title,
      artist: artist,
      trackCount: album.trackCount,
      tracks: album.tracks,
      coverAsset: cover,
    );
  }

  static List<AudioArtist> groupArtists(List<AudioTrack> tracks) {
    final map = <String, List<AudioTrack>>{};
    for (final t in tracks) {
      map.putIfAbsent(t.artist, () => []).add(t);
    }

    final artists = map.entries
        .map(
          (e) => AudioArtist(
            name: e.key,
            trackCount: e.value.length,
            tracks: e.value,
          ),
        )
        .toList();
    artists.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return artists;
  }

  static Future<List<MediaFolder>> loadAudioFolders() async {
    if (!await MediaPermissionService.hasAudioAccess()) {
      return const [];
    }

    try {
      final paths = await PhotoManager.getAssetPathList(
        type: RequestType.audio,
        hasAll: true,
        onlyAll: false,
        filterOption: kMediaAssetFilter,
      );

      final folders = <MediaFolder>[];
      for (final path in paths) {
        if (path.isAll) continue;
        final count = await path.assetCountAsync;
        if (count == 0) continue;
        folders.add(
          MediaFolder(
            id: path.id,
            displayName: path.name,
            videoCount: count,
            assetPath: path,
          ),
        );
      }
      folders.sort((a, b) => b.videoCount.compareTo(a.videoCount));
      return folders;
    } catch (e, st) {
      debugPrint('[audio] folder load failed: $e\n$st');
      return const [];
    }
  }

  static Future<List<AudioTrack>> loadTracksInFolder(MediaFolder folder) async {
    final path = folder.assetPath;
    if (path == null) return const [];
    try {
      final assets = await path.getAssetListPaged(page: 0, size: 300);
      return assets.map(_trackFromAsset).toList();
    } catch (e, st) {
      debugPrint('[audio] folder tracks failed: $e\n$st');
      await Telemetry.recordNonFatal(e, st, reason: 'loadTracksInFolder');
      return const [];
    }
  }

  static Future<void> requestAudioAccess() async {
    await PhotoManager.requestPermissionExtend(requestOption: _audioRequestOption);
  }
}

