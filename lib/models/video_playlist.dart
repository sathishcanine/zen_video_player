/// User-created video playlist (asset IDs from photo_manager).
class VideoPlaylist {
  const VideoPlaylist({
    required this.id,
    required this.name,
    required this.assetIds,
    required this.createdAtMs,
  });

  final String id;
  final String name;
  final List<String> assetIds;
  final int createdAtMs;

  int get videoCount => assetIds.length;

  VideoPlaylist copyWith({
    String? name,
    List<String>? assetIds,
  }) {
    return VideoPlaylist(
      id: id,
      name: name ?? this.name,
      assetIds: assetIds ?? this.assetIds,
      createdAtMs: createdAtMs,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'assetIds': assetIds,
        'createdAtMs': createdAtMs,
      };

  factory VideoPlaylist.fromJson(Map<String, dynamic> json) {
    return VideoPlaylist(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Playlist',
      assetIds: (json['assetIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      createdAtMs: json['createdAtMs'] as int? ?? 0,
    );
  }
}
