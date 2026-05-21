import 'package:photo_manager/photo_manager.dart';

/// A single audio file from the device library.
class AudioTrack {
  const AudioTrack({
    required this.asset,
    required this.title,
    required this.artist,
    required this.albumName,
    required this.albumKey,
    required this.folderName,
  });

  final AssetEntity asset;
  final String title;
  final String artist;
  final String albumName;
  final String albumKey;
  final String folderName;
}

/// Album grouping for the Audio > Album grid.
class AudioAlbum {
  const AudioAlbum({
    required this.id,
    required this.title,
    required this.artist,
    required this.trackCount,
    required this.tracks,
    this.coverAsset,
  });

  final String id;
  final String title;
  final String artist;
  final int trackCount;
  final List<AudioTrack> tracks;
  final AssetEntity? coverAsset;
}

/// Artist grouping for the Audio > Artist list.
class AudioArtist {
  const AudioArtist({
    required this.name,
    required this.trackCount,
    required this.tracks,
  });

  final String name;
  final int trackCount;
  final List<AudioTrack> tracks;
}
