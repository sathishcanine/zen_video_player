import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_plus/share_plus.dart';

import '../models/media_folder.dart';
import 'local_media_service.dart';

/// Shares local video files via the system share sheet.
class MediaShareService {
  MediaShareService._();

  static Future<bool> shareAssets(List<AssetEntity> assets) async {
    if (assets.isEmpty) return false;
    final files = <XFile>[];
    for (final asset in assets) {
      try {
        final file = await asset.file;
        if (file != null && await file.exists()) {
          files.add(XFile(file.path));
        }
      } catch (e, st) {
        debugPrint('[share] skip asset ${asset.id}: $e\n$st');
      }
    }
    if (files.isEmpty) return false;
    await SharePlus.instance.share(
      ShareParams(
        files: files,
        subject: files.length == 1
            ? files.first.name
            : '${files.length} videos',
      ),
    );
    return true;
  }

  static Future<bool> shareFolder(MediaFolder folder) async {
    final assets = await LocalMediaService.loadAllVideosInFolder(folder);
    return shareAssets(assets);
  }

  static Future<bool> shareAssetIds(List<String> ids) async {
    final assets = <AssetEntity>[];
    for (final id in ids) {
      try {
        final entity = await AssetEntity.fromId(id);
        if (entity != null) assets.add(entity);
      } catch (_) {}
    }
    return shareAssets(assets);
  }
}
