/// User-created audio playlist (asset IDs from photo_manager).
class AudioPlaylist {
  const AudioPlaylist({
    required this.id,
    required this.name,
    required this.assetIds,
    required this.createdAtMs,
  });

  final String id;
  final String name;
  final List<String> assetIds;
  final int createdAtMs;

  int get trackCount => assetIds.length;

  AudioPlaylist copyWith({
    String? name,
    List<String>? assetIds,
  }) {
    return AudioPlaylist(
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

  factory AudioPlaylist.fromJson(Map<String, dynamic> json) {
    return AudioPlaylist(
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
