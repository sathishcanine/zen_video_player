import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';

import '../models/duplicate_group.dart';
import '../models/duplicate_media_item.dart';
import '../models/duplicate_media_kind.dart';
import 'media_asset_channel.dart';
import 'media_asset_filter.dart';
import 'media_permission_service.dart';

class DuplicateScanProgress {
  const DuplicateScanProgress({
    required this.percent,
    this.scanned = 0,
    this.total = 0,
    this.groupsFound = 0,
    this.currentFileName,
    this.isLoadingLibrary = false,
  });

  /// Overall scan completion, 0–100.
  final int percent;
  final int scanned;
  final int total;
  final int groupsFound;
  final String? currentFileName;
  final bool isLoadingLibrary;
}

/// Scans on-device video or audio for exact duplicate files (same size + name).
class DuplicateFinderService {
  DuplicateFinderService._();

  static const int _pageSize = 200;
  static const int _maxPages = 80;
  static const Duration _fileTimeout = Duration(seconds: 8);
  static const Duration _pathListTimeout = Duration(seconds: 45);

  static const int _loadEnd = 40;
  static const int _indexEnd = 65;
  static const int _checkEnd = 99;

  static Future<List<DuplicateGroup>> scan({
    required DuplicateMediaKind kind,
    required void Function(DuplicateScanProgress progress) onProgress,
    bool Function()? isCancelled,
  }) async {
    var lastPercent = 0;

    Future<void> report(
      int percent, {
      int scanned = 0,
      int total = 0,
      int groupsFound = 0,
      String? currentFileName,
      bool isLoadingLibrary = false,
    }) async {
      final next = percent.clamp(0, 100);
      if (next < lastPercent) return;
      lastPercent = next;
      onProgress(
        DuplicateScanProgress(
          percent: next,
          scanned: scanned,
          total: total,
          groupsFound: groupsFound,
          currentFileName: currentFileName,
          isLoadingLibrary: isLoadingLibrary,
        ),
      );
      await Future<void>.delayed(Duration.zero);
    }

    if (!await MediaPermissionService.ensureMediaAccessFor(kind)) {
      return const [];
    }

    await report(1, isLoadingLibrary: true);

    final assets = await _loadAllAssets(
      kind,
      isCancelled: isCancelled,
      report: report,
    );
    if (isCancelled?.call() == true) return const [];

    final total = assets.length;
    if (total == 0) {
      await report(100);
      return const [];
    }

    await report(_loadEnd);

    final byName = <String, List<AssetEntity>>{};
    for (var i = 0; i < assets.length; i++) {
      if (isCancelled?.call() == true) return const [];
      final asset = assets[i];
      final name = _displayName(asset);
      byName.putIfAbsent(_normalizeName(name), () => []).add(asset);

      if (i % 10 == 0 || i == total - 1) {
        final slice = _loadEnd + 1 + ((_indexEnd - _loadEnd) * (i + 1) ~/ total);
        await report(
          slice,
          scanned: i + 1,
          total: total,
          currentFileName: name,
        );
      }
    }

    final candidates = <AssetEntity>[];
    for (final list in byName.values) {
      if (list.length > 1) candidates.addAll(list);
    }

    if (candidates.isEmpty) {
      await report(100, scanned: total, total: total);
      return const [];
    }

    await report(_indexEnd, scanned: total, total: total);

    final checkTotal = candidates.length;
    final buckets = <String, List<({AssetEntity asset, int bytes})>>{};
    var checked = 0;

    for (final asset in candidates) {
      if (isCancelled?.call() == true) return const [];

      checked++;
      final name = _displayName(asset);
      final slice = _indexEnd +
          1 +
          ((_checkEnd - _indexEnd) * checked ~/ checkTotal);
      await report(
        slice,
        scanned: checked,
        total: checkTotal,
        groupsFound: _duplicateGroupCount(buckets),
        currentFileName: name,
      );

      final bytes = await _readFileSize(asset);
      if (bytes <= 0) continue;

      final key = '$bytes|${_normalizeName(name)}';
      buckets.putIfAbsent(key, () => []).add((asset: asset, bytes: bytes));
    }

    final groups = <DuplicateGroup>[];
    for (final entry in buckets.entries) {
      if (entry.value.length < 2) continue;
      entry.value.sort(
        (a, b) => a.asset.createDateTime.compareTo(b.asset.createDateTime),
      );
      final items = <DuplicateMediaItem>[];
      for (var i = 0; i < entry.value.length; i++) {
        final row = entry.value[i];
        items.add(
          DuplicateMediaItem(
            asset: row.asset,
            displayName: _displayName(row.asset),
            bytes: row.bytes,
            kind: kind,
            isKeeper: i == 0,
          ),
        );
      }
      groups.add(DuplicateGroup(key: entry.key, items: items));
    }

    groups.sort((a, b) => b.duplicateCount.compareTo(a.duplicateCount));

    await report(
      100,
      scanned: checkTotal,
      total: checkTotal,
      groupsFound: groups.length,
    );

    return groups;
  }

  static int _duplicateGroupCount(
    Map<String, List<({AssetEntity asset, int bytes})>> buckets,
  ) {
    var count = 0;
    for (final list in buckets.values) {
      if (list.length >= 2) count++;
    }
    return count;
  }

  static Future<int> _readFileSize(AssetEntity asset) async {
    try {
      final fromStore = await MediaAssetChannel.getSizeBytes(asset);
      if (fromStore > 0) return fromStore;
      final file = await asset.file.timeout(_fileTimeout);
      if (file == null) return 0;
      return await file.length().timeout(const Duration(seconds: 3));
    } catch (_) {
      return 0;
    }
  }

  static Future<List<AssetEntity>> _loadAllAssets(
    DuplicateMediaKind kind, {
    bool Function()? isCancelled,
    required Future<void> Function(
      int percent, {
      int scanned,
      int total,
      String? currentFileName,
      bool isLoadingLibrary,
    }) report,
  }) async {
    final type = kind == DuplicateMediaKind.video
        ? RequestType.video
        : RequestType.audio;

    await report(3, isLoadingLibrary: true);

    List<AssetPathEntity> paths;
    try {
      paths = await PhotoManager.getAssetPathList(
        type: type,
        hasAll: true,
        onlyAll: false,
        filterOption: kMediaAssetFilter,
      ).timeout(_pathListTimeout);
    } on TimeoutException {
      debugPrint('[duplicate] getAssetPathList timed out');
      return const [];
    } catch (e, st) {
      debugPrint('[duplicate] getAssetPathList failed: $e\n$st');
      return const [];
    }

    await report(6, isLoadingLibrary: true);

    final allPath = paths.where((p) => p.isAll).firstOrNull;
    if (allPath == null) return const [];

    await report(8, isLoadingLibrary: true);

    final out = <AssetEntity>[];
    var page = 0;
    while (page < _maxPages) {
      if (isCancelled?.call() == true) return out;

      List<AssetEntity> batch;
      try {
        batch = await allPath
            .getAssetListPaged(page: page, size: _pageSize)
            .timeout(const Duration(seconds: 30));
      } on TimeoutException {
        debugPrint('[duplicate] page $page timed out');
        break;
      } catch (e, st) {
        debugPrint('[duplicate] page $page failed: $e\n$st');
        break;
      }

      if (batch.isEmpty) break;
      out.addAll(batch);

      final loadPercent = 8 + ((page + 1) * (_loadEnd - 8) ~/ _maxPages);
      await report(
        loadPercent.clamp(8, _loadEnd),
        scanned: out.length,
        total: out.length + (batch.length < _pageSize ? 0 : _pageSize),
        isLoadingLibrary: true,
      );

      if (batch.length < _pageSize) break;
      page++;
    }
    return out;
  }

  static String _displayName(AssetEntity asset) {
    final raw = asset.title ?? asset.relativePath ?? 'file';
    return raw.split('/').last;
  }

  static String _normalizeName(String name) {
    return name.trim().toLowerCase();
  }

  static Future<List<String>> deleteItems(List<DuplicateMediaItem> items) async {
    if (items.isEmpty) return const [];
    final ids = items.map((e) => e.asset.id).toList();
    return PhotoManager.editor.deleteWithIds(ids);
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    if (!it.moveNext()) return null;
    return it.current;
  }
}
