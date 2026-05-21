import 'package:photo_manager/photo_manager.dart';

import 'duplicate_media_kind.dart';

/// One library file participating in a duplicate group.
class DuplicateMediaItem {
  const DuplicateMediaItem({
    required this.asset,
    required this.displayName,
    required this.bytes,
    required this.kind,
    required this.isKeeper,
  });

  final AssetEntity asset;
  final String displayName;
  final int bytes;
  final DuplicateMediaKind kind;
  final bool isKeeper;
}
