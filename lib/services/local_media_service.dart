import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/media_folder.dart';
import 'hidden_folders_service.dart';
import 'media_permission_service.dart';

/// Loads on-device video albums via [photo_manager].
class LocalMediaService {
  LocalMediaService._();

  static const _seenAlbumsKey = 'seen_album_ids_v1';
  static const _recentDays = 14;

  static Future<List<MediaFolder>> loadVideoFolders() async {
    if (!await MediaPermissionService.hasMediaAccess()) {
      return const [];
    }

    final paths = await PhotoManager.getAssetPathList(
      type: RequestType.video,
      hasAll: true,
      onlyAll: false,
    );

    final seen = await _loadSeenAlbumIds();
    final hidden = await HiddenFoldersService.loadHiddenIds();
    final folders = <MediaFolder>[];

    final recent = await _buildRecentlyAdded(paths);
    if (recent != null) folders.add(recent);

    for (final path in paths) {
      if (path.isAll) continue;
      if (hidden.contains(path.id)) continue;
      final count = await path.assetCountAsync;
      if (count == 0) continue;
      folders.add(
        MediaFolder(
          id: path.id,
          displayName: path.name,
          videoCount: count,
          assetPath: path,
          isNew: !seen.contains(path.id),
        ),
      );
    }

    folders.sort(
      (a, b) => b.videoCount.compareTo(a.videoCount),
    );

    await _markAlbumsSeen(paths.map((p) => p.id).toList());
    return folders;
  }

  static Future<MediaFolder?> _buildRecentlyAdded(
    List<AssetPathEntity> paths,
  ) async {
    final cutoff = DateTime.now().subtract(const Duration(days: _recentDays));
    final recentAssets = <AssetEntity>[];

    for (final path in paths) {
      final page = await path.getAssetListPaged(page: 0, size: 80);
      for (final asset in page) {
        if (asset.createDateTime.isAfter(cutoff)) {
          recentAssets.add(asset);
        }
      }
      if (recentAssets.length >= 120) break;
    }

    if (recentAssets.isEmpty) return null;

    return MediaFolder(
      id: '__recent__',
      displayName: '', // filled by UI with localized label
      videoCount: recentAssets.length,
      isRecentlyAdded: true,
      assetPath: paths.firstWhere(
        (p) => p.isAll,
        orElse: () => paths.first,
      ),
    );
  }

  static Future<List<AssetEntity>> loadVideosInFolder(
    MediaFolder folder, {
    int page = 0,
    int size = 60,
  }) async {
    if (folder.isRecentlyAdded) {
      return _loadRecentAssets();
    }
    final path = folder.assetPath;
    if (path == null) return const [];
    return path.getAssetListPaged(page: page, size: size);
  }

  /// Loads every video in a folder (paged) for share/delete actions.
  static Future<List<AssetEntity>> loadAllVideosInFolder(
    MediaFolder folder, {
    int pageSize = 200,
    int maxPages = 80,
  }) async {
    if (folder.isRecentlyAdded) {
      return _loadRecentAssets();
    }
    final path = folder.assetPath;
    if (path == null) return const [];

    final out = <AssetEntity>[];
    var page = 0;
    while (page < maxPages) {
      final batch = await path.getAssetListPaged(page: page, size: pageSize);
      if (batch.isEmpty) break;
      out.addAll(batch);
      if (batch.length < pageSize) break;
      page++;
    }
    return out;
  }

  static Future<List<AssetEntity>> _loadRecentAssets() async {
    final paths = await PhotoManager.getAssetPathList(
      type: RequestType.video,
      hasAll: true,
    );
    final cutoff = DateTime.now().subtract(const Duration(days: _recentDays));
    final out = <AssetEntity>[];

    for (final path in paths) {
      final page = await path.getAssetListPaged(page: 0, size: 100);
      for (final asset in page) {
        if (asset.createDateTime.isAfter(cutoff)) out.add(asset);
      }
    }

    out.sort((a, b) => b.createDateTime.compareTo(a.createDateTime));
    return out;
  }

  static Future<void> fillFolderSizes(List<MediaFolder> folders) async {
    for (var i = 0; i < folders.length; i++) {
      final folder = folders[i];
      if (folder.isRecentlyAdded || folder.assetPath == null) continue;
      try {
        final assets = await folder.assetPath!
            .getAssetListRange(start: 0, end: 40);
        var total = 0;
        for (final asset in assets) {
          final file = await asset.file;
          if (file != null) total += await file.length();
        }
        if (total > 0 && assets.isNotEmpty) {
          final scale = folder.videoCount / assets.length;
          folders[i] = MediaFolder(
            id: folder.id,
            displayName: folder.displayName,
            videoCount: folder.videoCount,
            assetPath: folder.assetPath,
            totalBytes: (total * scale).round(),
            isRecentlyAdded: folder.isRecentlyAdded,
            isNew: folder.isNew,
          );
        }
      } catch (e, st) {
        debugPrint('[media] size estimate failed for ${folder.id}: $e\n$st');
      }
    }
  }

  static Future<Set<String>> _loadSeenAlbumIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_seenAlbumsKey) ?? []).toSet();
  }

  static Future<void> _markAlbumsSeen(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    final merged = {...await _loadSeenAlbumIds(), ...ids}.toList();
    await prefs.setStringList(_seenAlbumsKey, merged);
  }
}
