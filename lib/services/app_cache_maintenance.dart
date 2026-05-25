import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keeps app storage healthy without asking users to open system settings.
///
/// - Every cold start: [PhotoManager.clearFileCache] (photo_manager docs).
/// - Once per user on build [storageRepairBuild]: extra sweep of stale `pm_*`
///   exports left by older versions that called [AssetEntity.file] heavily.
class AppCacheMaintenance {
  AppCacheMaintenance._();

  /// First build that ships the storage-leak fix; upgraders get [_deepPurge] once.
  static const int storageRepairBuild = 20;

  static const _repairPrefsKey = 'zen_storage_repair_build';

  /// Call from [main] before [runApp]. No UI, no user action.
  static Future<void> runOnColdStart() async {
    if (kIsWeb) return;

    try {
      await PhotoManager.clearFileCache();
    } catch (e, st) {
      debugPrint('[cache] clearFileCache failed: $e\n$st');
    }

    try {
      final info = await PackageInfo.fromPlatform();
      final currentBuild = int.tryParse(info.buildNumber) ?? 0;
      if (currentBuild < storageRepairBuild) return;

      final prefs = await SharedPreferences.getInstance();
      final lastRepair = prefs.getInt(_repairPrefsKey) ?? 0;
      if (lastRepair >= storageRepairBuild) return;

      final freed = await _deepPurgePmExports();
      await prefs.setInt(_repairPrefsKey, currentBuild);
      debugPrint('[cache] storage repair done (freed ~$freed bytes of pm_* exports)');
    } catch (e, st) {
      debugPrint('[cache] storage repair failed: $e\n$st');
    }
  }

  static Future<int> _deepPurgePmExports() async {
    var freed = 0;
    try {
      await PhotoManager.clearFileCache();
    } catch (_) {}

    final dirs = <Directory>[];
    try {
      final tmp = await getTemporaryDirectory();
      dirs.add(tmp);
    } catch (_) {}
    try {
      final cache = await getApplicationCacheDirectory();
      dirs.add(cache);
    } catch (_) {}

    for (final dir in dirs) {
      freed += await _deletePmFilesIn(dir);
    }
    return freed;
  }

  static Future<int> _deletePmFilesIn(Directory dir) async {
    var freed = 0;
    if (!dir.existsSync()) return 0;
    await for (final entity in dir.list(recursive: false, followLinks: false)) {
      if (entity is! File) continue;
      final name = entity.uri.pathSegments.last;
      if (!name.startsWith('pm_')) continue;
      try {
        final len = await entity.length();
        await entity.delete();
        freed += len;
      } catch (_) {}
    }
    return freed;
  }
}
