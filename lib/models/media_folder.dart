import 'package:photo_manager/photo_manager.dart';

/// A browsable album or virtual "recently added" collection.
class MediaFolder {
  const MediaFolder({
    required this.id,
    required this.displayName,
    required this.videoCount,
    this.assetPath,
    this.totalBytes,
    this.isRecentlyAdded = false,
    this.isNew = false,
  });

  final String id;
  final String displayName;
  final int videoCount;
  final int? totalBytes;
  final AssetPathEntity? assetPath;
  final bool isRecentlyAdded;
  final bool isNew;

  String formatBytes() {
    final bytes = totalBytes;
    if (bytes == null || bytes <= 0) return '';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var value = bytes.toDouble();
    var unit = 0;
    while (value >= 1024 && unit < units.length - 1) {
      value /= 1024;
      unit++;
    }
    final digits = unit >= 2 ? 1 : 0;
    return '${value.toStringAsFixed(digits)} ${units[unit]}';
  }
}
