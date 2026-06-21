import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';

import '../analytics/telemetry.dart';
import '../models/media_folder.dart';
import 'hidden_folders_service.dart';
import 'media_asset_filter.dart';
import 'media_permission_service.dart';
import 'new_media_tracker.dart';

/// Loads on-device video albums via [photo_manager].
class LocalMediaService {
  LocalMediaService._();

  static const _recentDays = 14;

  static Future<List<MediaFolder>> loadVideoFolders() async {
    if (!await MediaPermissionService.hasMediaAccess()) {
      return const [];
    }

    final paths = await PhotoManager.getAssetPathList(
      type: RequestType.video,
      hasAll: true,
      onlyAll: false,
      filterOption: kMediaAssetFilter,
    );

    final hidden = await HiddenFoldersService.instance.loadHiddenIds();
    final folders = <MediaFolder>[];
    final folderCounts = <String, int>{};

    try {
      final recent = await _buildRecentlyAdded(paths);
      if (recent != null) folders.add(recent);
    } catch (e, st) {
      debugPrint('[media] recently added failed: $e\n$st');
      await Telemetry.recordNonFatal(e, st, reason: 'buildRecentlyAdded');
    }

    for (final path in paths) {
      if (path.isAll) continue;
      if (hidden.contains(path.id)) continue;
      try {
        final count = await path.assetCountAsync;
        if (count == 0) continue;
        folderCounts[path.id] = count;

        final isNew = await NewMediaTracker.isFolderNew(
          folderId: path.id,
          videoCount: count,
        );

        folders.add(
          MediaFolder(
            id: path.id,
            displayName: path.name,
            videoCount: count,
            assetPath: path,
            isNew: isNew,
          ),
        );
      } catch (e, st) {
        debugPrint('[media] album ${path.id} skipped: $e\n$st');
        await Telemetry.recordNonFatal(
          e,
          st,
          reason: 'albumCount',
          context: {'albumId': path.id},
        );
      }
    }

    folders.sort(
      (a, b) => b.videoCount.compareTo(a.videoCount),
    );

    // First scan after install: snapshot counts — nothing is "new" yet.
    await NewMediaTracker.establishFolderBaseline(folderCounts);

    return folders;
  }

  static Future<MediaFolder?> _buildRecentlyAdded(
    List<AssetPathEntity> paths,
  ) async {
    final cutoff = DateTime.now().subtract(const Duration(days: _recentDays));
    final recentAssets = <AssetEntity>[];

    for (final path in paths) {
      if (path.isAll) continue;
      try {
        final page = await path.getAssetListPaged(page: 0, size: 80);
        for (final asset in page) {
          if (asset.createDateTime.isAfter(cutoff)) {
            recentAssets.add(asset);
          }
        }
      } catch (e, st) {
        debugPrint('[media] recent page ${path.id} skipped: $e\n$st');
        await Telemetry.recordNonFatal(
          e,
          st,
          reason: 'recentAlbumPage',
          context: {'albumId': path.id},
        );
      }
      if (recentAssets.length >= 120) break;
    }

    if (recentAssets.isEmpty) return null;

    return MediaFolder(
      id: '__recent__',
      displayName: '',
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
      filterOption: kMediaAssetFilter,
    );
    final cutoff = DateTime.now().subtract(const Duration(days: _recentDays));
    final out = <AssetEntity>[];

    for (final path in paths) {
      if (path.isAll) continue;
      final page = await path.getAssetListPaged(page: 0, size: 100);
      for (final asset in page) {
        if (asset.createDateTime.isAfter(cutoff)) out.add(asset);
      }
    }

    out.sort((a, b) => b.createDateTime.compareTo(a.createDateTime));
    return out;
  }
}
