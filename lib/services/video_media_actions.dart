import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';
import 'package:zen_video_player/theme/zen_palette.dart';

import '../models/media_folder.dart';
import '../models/video_playlist.dart';
import '../utils/video_navigation.dart';
import '../widgets/add_to_playlist_sheet.dart';
import '../widgets/media_details_dialog.dart';
import '../widgets/media_options_sheet.dart';
import 'asset_playback_resolver.dart';
import 'hidden_folders_service.dart';
import 'local_media_service.dart';
import 'media_share_service.dart';
import 'playlist_service.dart';
import 'video_playback_queue.dart';

/// Handles folder / video / playlist option-menu actions.
class VideoMediaActions {
  VideoMediaActions._();

  static List<MediaOptionAction> folderActions({bool includeHide = true}) {
    return [
      MediaOptionAction.play,
      MediaOptionAction.delete,
      MediaOptionAction.send,
      MediaOptionAction.rename,
      MediaOptionAction.addToPlaylist,
      if (includeHide) MediaOptionAction.hideFromList,
      MediaOptionAction.details,
    ];
  }

  static List<MediaOptionAction> assetActions() => [
        MediaOptionAction.play,
        MediaOptionAction.delete,
        MediaOptionAction.send,
        MediaOptionAction.rename,
        MediaOptionAction.addToPlaylist,
        MediaOptionAction.details,
      ];

  static List<MediaOptionAction> playlistActions() => [
        MediaOptionAction.play,
        MediaOptionAction.delete,
        MediaOptionAction.send,
        MediaOptionAction.rename,
        MediaOptionAction.details,
      ];

  static List<MediaOptionAction> playlistAssetActions() => [
        MediaOptionAction.play,
        MediaOptionAction.removeFromPlaylist,
        MediaOptionAction.send,
        MediaOptionAction.details,
      ];

  static Future<void> handleFolder(
    BuildContext context, {
    required MediaFolder folder,
    required MediaOptionAction action,
    required VoidCallback onLibraryChanged,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final title = folder.displayName;

    switch (action) {
      case MediaOptionAction.play:
        final assets = await LocalMediaService.loadAllVideosInFolder(folder);
        if (!context.mounted) return;
        if (assets.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.noVideosFound)),
          );
          return;
        }
        await _openAsset(
          context,
          assets.first,
          queueAssetIds: assets.map((a) => a.id).toList(),
        );
      case MediaOptionAction.delete:
        final ok = await _confirm(
          context,
          title: l10n.deleteFolderTitle,
          body: l10n.deleteFolderBody(folder.videoCount, title),
          confirm: l10n.delete,
        );
        if (!ok || !context.mounted) return;
        final assets = await LocalMediaService.loadAllVideosInFolder(folder);
        final ids = assets.map((a) => a.id).toList();
        if (ids.isNotEmpty) {
          final deleted = await _deleteAssetIds(ids);
          if (!context.mounted) return;
          if (!deleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.duplicateDeleteFailed)),
            );
            return;
          }
        }
        onLibraryChanged();
      case MediaOptionAction.send:
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.sharePreparing)),
        );
        final shared = await MediaShareService.shareFolder(folder);
        if (!context.mounted) return;
        if (!shared) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.shareFailed)),
          );
        }
      case MediaOptionAction.rename:
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.renameNotSupported)),
        );
      case MediaOptionAction.addToPlaylist:
        final assets = await LocalMediaService.loadAllVideosInFolder(folder);
        if (!context.mounted) return;
        await showAddToPlaylistSheet(
          context,
          assetIds: assets.map((a) => a.id).toList(),
        );
      case MediaOptionAction.hideFromList:
        if (folder.isRecentlyAdded) return;
        final hideOk = await _confirm(
          context,
          title: l10n.hideFolderTitle,
          body: l10n.hideFolderBody(title),
          confirm: l10n.hide,
        );
        if (!hideOk) return;
        await HiddenFoldersService.instance.hide(
          folder.id,
          displayName: folder.displayName,
        );
        onLibraryChanged();
      case MediaOptionAction.details:
        await showFolderDetailsDialog(context, folder: folder);
      case MediaOptionAction.removeFromPlaylist:
        break;
    }
  }

  static Future<void> handleAsset(
    BuildContext context, {
    required AssetEntity asset,
    required MediaOptionAction action,
    VoidCallback? onListChanged,
    List<String>? queueAssetIds,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final name = asset.title ?? asset.relativePath ?? 'Video';

    switch (action) {
      case MediaOptionAction.play:
        await _openAsset(
          context,
          asset,
          queueAssetIds: queueAssetIds,
        );
      case MediaOptionAction.delete:
        final ok = await _confirm(
          context,
          title: l10n.duplicateDeleteTitle,
          body: l10n.duplicateDeleteBody(name),
          confirm: l10n.delete,
        );
        if (!ok || !context.mounted) return;
        final deleted = await _deleteAssetIds([asset.id]);
        if (!context.mounted) return;
        if (!deleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.duplicateDeleteFailed)),
          );
          return;
        }
        onListChanged?.call();
      case MediaOptionAction.send:
        final shared = await MediaShareService.shareAssets([asset]);
        if (!context.mounted) return;
        if (!shared) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.shareFailed)),
          );
        }
      case MediaOptionAction.rename:
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.renameNotSupported)),
        );
      case MediaOptionAction.addToPlaylist:
        await showAddToPlaylistSheet(context, assetIds: [asset.id]);
      case MediaOptionAction.details:
        await showAssetDetailsDialog(context, asset: asset);
      case MediaOptionAction.hideFromList:
      case MediaOptionAction.removeFromPlaylist:
        break;
    }
  }

  static Future<void> handlePlaylist(
    BuildContext context, {
    required VideoPlaylist playlist,
    required MediaOptionAction action,
    required VoidCallback onChanged,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    switch (action) {
      case MediaOptionAction.play:
        if (playlist.assetIds.isEmpty) return;
        final entity = await AssetEntity.fromId(playlist.assetIds.first);
        if (entity == null || !context.mounted) return;
        await _openAsset(
          context,
          entity,
          queueAssetIds: playlist.assetIds,
        );
      case MediaOptionAction.delete:
        final ok = await _confirm(
          context,
          title: l10n.deletePlaylistTitle,
          body: l10n.deletePlaylistBody(playlist.name),
          confirm: l10n.delete,
        );
        if (!ok) return;
        await PlaylistService.delete(playlist.id);
        onChanged();
      case MediaOptionAction.send:
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.sharePreparing)),
        );
        final shared =
            await MediaShareService.shareAssetIds(playlist.assetIds);
        if (!context.mounted) return;
        if (!shared) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.shareFailed)),
          );
        }
      case MediaOptionAction.rename:
        final name = await _promptText(
          context,
          title: l10n.renamePlaylist,
          hint: l10n.playlistNameHint,
          initial: playlist.name,
        );
        if (name == null) return;
        await PlaylistService.rename(playlist.id, name);
        onChanged();
      case MediaOptionAction.details:
        await showPlaylistDetailsDialog(
          context,
          name: playlist.name,
          videoCount: playlist.videoCount,
        );
      case MediaOptionAction.addToPlaylist:
      case MediaOptionAction.hideFromList:
      case MediaOptionAction.removeFromPlaylist:
        break;
    }
  }

  static Future<void> handlePlaylistAsset(
    BuildContext context, {
    required String playlistId,
    required AssetEntity asset,
    required MediaOptionAction action,
    required VoidCallback onChanged,
    List<String>? queueAssetIds,
  }) async {
    switch (action) {
      case MediaOptionAction.play:
        await _openAsset(
          context,
          asset,
          queueAssetIds: queueAssetIds,
        );
      case MediaOptionAction.removeFromPlaylist:
        await PlaylistService.removeAsset(playlistId, asset.id);
        onChanged();
      case MediaOptionAction.send:
        await handleAsset(context, asset: asset, action: MediaOptionAction.send);
      case MediaOptionAction.details:
        await showAssetDetailsDialog(context, asset: asset);
      default:
        break;
    }
  }

  static Future<void> _openAsset(
    BuildContext context,
    AssetEntity asset, {
    List<String>? queueAssetIds,
  }) async {
    if (queueAssetIds != null && queueAssetIds.length > 1) {
      VideoPlaybackQueue.install(queueAssetIds, asset.id);
    } else {
      VideoPlaybackQueue.clear();
    }
    final target = await AssetPlaybackResolver.resolve(asset);
    if (!context.mounted) return;
    if (target == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.noVideosFound)),
      );
      return;
    }
    VideoNavigation.openPlayer(
      context: context,
      videoSource: target.videoSource,
      isLocal: target.isLocal,
      useContentUri: target.useContentUri,
      displayTitle: target.displayName,
      resumeKey: target.assetId,
    );
  }

  /// Returns false when MediaStore delete fails (permissions, OEM, limited access).
  static Future<bool> _deleteAssetIds(List<String> ids) async {
    if (ids.isEmpty) return true;
    try {
      final result = await PhotoManager.editor.deleteWithIds(ids);
      return result.isNotEmpty;
    } catch (e, st) {
      debugPrint('[media] deleteWithIds failed: $e\n$st');
      return false;
    }
  }

  static Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String body,
    required String confirm,
  }) async {
    final zen = Theme.of(context).extension<ZenPalette>();
    final sheetBg = zen?.sheetBackground ?? Theme.of(context).colorScheme.surface;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: sheetBg,
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(ctx)!.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirm),
          ),
        ],
      ),
    );
    return result == true;
  }

  static Future<String?> _promptText(
    BuildContext context, {
    required String title,
    required String hint,
    String? initial,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final zen = Theme.of(context).extension<ZenPalette>();
    final sheetBg = zen?.sheetBackground ?? Theme.of(context).colorScheme.surface;
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: sheetBg,
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}
