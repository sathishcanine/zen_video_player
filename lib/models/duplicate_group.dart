import 'duplicate_media_item.dart';

/// Files that share the same size and file name (exact duplicates).
class DuplicateGroup {
  const DuplicateGroup({
    required this.key,
    required this.items,
  });

  final String key;
  final List<DuplicateMediaItem> items;

  DuplicateMediaItem get keeper =>
      items.firstWhere((i) => i.isKeeper, orElse: () => items.first);

  List<DuplicateMediaItem> get deletable =>
      items.where((i) => !i.isKeeper).toList(growable: false);

  int get duplicateCount => items.length;
}
