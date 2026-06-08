import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';
import 'package:zen_video_player/theme/zen_palette.dart';

import '../models/audio_playlist.dart';
import '../models/audio_track.dart';
import '../models/media_folder.dart';
import '../utils/audio_playback_launcher.dart';
import '../widgets/add_to_audio_playlist_sheet.dart';
import '../widgets/media_details_dialog.dart';
import '../widgets/media_options_sheet.dart';
import 'audio_playlist_service.dart';
import 'local_audio_service.dart';
import 'media_share_service.dart';

/// Handles audio track / album / folder / playlist option-menu actions.
class AudioMediaActions {
  AudioMediaActions._();

  static List<MediaOptionAction> trackActions() => [
        MediaOptionAction.play,
        MediaOptionAction.addToPlaylist,
        MediaOptionAction.send,
        MediaOptionAction.delete,
        MediaOptionAction.details,
      ];

  static List<MediaOptionAction> albumActions() => [
        MediaOptionAction.play,
        MediaOptionAction.addToPlaylist,
        MediaOptionAction.send,
        MediaOptionAction.details,
      ];

  static List<MediaOptionAction> folderActions() => [
        MediaOptionAction.play,
        MediaOptionAction.addToPlaylist,
        MediaOptionAction.send,
        MediaOptionAction.details,
      ];

  static List<MediaOptionAction> playlistActions() => [
        MediaOptionAction.play,
        MediaOptionAction.delete,
        MediaOptionAction.send,
        MediaOptionAction.rename,
        MediaOptionAction.details,
      ];

  static List<MediaOptionAction> playlistTrackActions() => [
        MediaOptionAction.play,
        MediaOptionAction.removeFromPlaylist,
        MediaOptionAction.send,
        MediaOptionAction.details,
      ];

  static Future<void> openTrackMenu(
    BuildContext context, {
    required AudioTrack track,
    List<AudioTrack>? queue,
    VoidCallback? onListChanged,
  }) async {
    final action = await showMediaOptionsSheet(
      context,
      actions: trackActions(),
    );
    if (action == null || !context.mounted) return;
    await handleTrack(
      context,
      track: track,
      queue: queue,
      action: action,
      onListChanged: onListChanged,
    );
  }

  static Future<void> openAlbumMenu(
    BuildContext context, {
    required AudioAlbum album,
  }) async {
    final action = await showMediaOptionsSheet(
      context,
      actions: albumActions(),
    );
    if (action == null || !context.mounted) return;
    await handleAlbum(context, album: album, action: action);
  }

  static Future<void> openFolderMenu(
    BuildContext context, {
    required MediaFolder folder,
  }) async {
    final action = await showMediaOptionsSheet(
      context,
      actions: folderActions(),
    );
    if (action == null || !context.mounted) return;
    await handleFolder(context, folder: folder, action: action);
  }

  static Future<void> handleTrack(
    BuildContext context, {
    required AudioTrack track,
    List<AudioTrack>? queue,
    required MediaOptionAction action,
    VoidCallback? onListChanged,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final name = track.title;

    switch (action) {
      case MediaOptionAction.play:
        final list = queue ?? [track];
        final idx = list.indexWhere((t) => t.asset.id == track.asset.id);
        await launchAudioPlayback(
          context,
          list,
          startIndex: idx >= 0 ? idx : 0,
        );
      case MediaOptionAction.addToPlaylist:
        await showAddToAudioPlaylistSheet(
          context,
          assetIds: [track.asset.id],
        );
      case MediaOptionAction.send:
        final shared = await MediaShareService.shareAssets([track.asset]);
        if (!context.mounted) return;
        if (!shared) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.shareFailed)),
          );
        }
      case MediaOptionAction.delete:
        final ok = await _confirm(
          context,
          title: l10n.duplicateDeleteTitle,
          body: l10n.duplicateDeleteBody(name),
          confirm: l10n.delete,
        );
        if (!ok || !context.mounted) return;
        final deleted = await _deleteAssetIds([track.asset.id]);
        if (!context.mounted) return;
        if (!deleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.duplicateDeleteFailed)),
          );
          return;
        }
        onListChanged?.call();
      case MediaOptionAction.details:
        await showAssetDetailsDialog(context, asset: track.asset);
      case MediaOptionAction.rename:
      case MediaOptionAction.hideFromList:
      case MediaOptionAction.removeFromPlaylist:
        break;
    }
  }

  static Future<void> handleAlbum(
    BuildContext context, {
    required AudioAlbum album,
    required MediaOptionAction action,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    switch (action) {
      case MediaOptionAction.play:
        if (album.tracks.isEmpty) return;
        await launchAudioPlayback(context, album.tracks);
      case MediaOptionAction.addToPlaylist:
        await showAddToAudioPlaylistSheet(
          context,
          assetIds: album.tracks.map((t) => t.asset.id).toList(),
        );
      case MediaOptionAction.send:
        final shared = await MediaShareService.shareAssets(
          album.tracks.map((t) => t.asset).toList(),
        );
        if (!context.mounted) return;
        if (!shared) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.shareFailed)),
          );
        }
      case MediaOptionAction.details:
        await showAudioAlbumDetailsDialog(
          context,
          title: album.title,
          artist: album.artist,
          trackCount: album.trackCount,
        );
      default:
        break;
    }
  }

  static Future<void> handleFolder(
    BuildContext context, {
    required MediaFolder folder,
    required MediaOptionAction action,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    switch (action) {
      case MediaOptionAction.play:
        final tracks = await LocalAudioService.loadTracksInFolder(folder);
        if (!context.mounted) return;
        if (tracks.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.noAudioFound)),
          );
          return;
        }
        await launchAudioPlayback(context, tracks);
      case MediaOptionAction.addToPlaylist:
        final tracks = await LocalAudioService.loadTracksInFolder(folder);
        if (!context.mounted) return;
        await showAddToAudioPlaylistSheet(
          context,
          assetIds: tracks.map((t) => t.asset.id).toList(),
        );
      case MediaOptionAction.send:
        final tracks = await LocalAudioService.loadTracksInFolder(folder);
        if (!context.mounted) return;
        final shared = await MediaShareService.shareAssets(
          tracks.map((t) => t.asset).toList(),
        );
        if (!context.mounted) return;
        if (!shared) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.shareFailed)),
          );
        }
      case MediaOptionAction.details:
        await showFolderDetailsDialog(context, folder: folder);
      default:
        break;
    }
  }

  static Future<void> handlePlaylist(
    BuildContext context, {
    required AudioPlaylist playlist,
    required MediaOptionAction action,
    required VoidCallback onChanged,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    switch (action) {
      case MediaOptionAction.play:
        if (playlist.assetIds.isEmpty) return;
        final tracks = await _tracksFromIds(playlist.assetIds);
        if (!context.mounted || tracks.isEmpty) return;
        await launchAudioPlayback(context, tracks);
      case MediaOptionAction.delete:
        final ok = await _confirm(
          context,
          title: l10n.deletePlaylistTitle,
          body: l10n.deletePlaylistBody(playlist.name),
          confirm: l10n.delete,
        );
        if (!ok) return;
        await AudioPlaylistService.delete(playlist.id);
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
        await AudioPlaylistService.rename(playlist.id, name);
        onChanged();
      case MediaOptionAction.details:
        await showAudioPlaylistDetailsDialog(
          context,
          name: playlist.name,
          trackCount: playlist.trackCount,
        );
      default:
        break;
    }
  }

  static Future<void> handlePlaylistTrack(
    BuildContext context, {
    required String playlistId,
    required AudioTrack track,
    required MediaOptionAction action,
    required VoidCallback onChanged,
    List<AudioTrack>? queue,
  }) async {
    switch (action) {
      case MediaOptionAction.play:
        final list = queue ?? [track];
        final idx = list.indexWhere((t) => t.asset.id == track.asset.id);
        await launchAudioPlayback(
          context,
          list,
          startIndex: idx >= 0 ? idx : 0,
        );
      case MediaOptionAction.removeFromPlaylist:
        await AudioPlaylistService.removeAsset(playlistId, track.asset.id);
        onChanged();
      case MediaOptionAction.send:
        await handleTrack(context, track: track, action: MediaOptionAction.send);
      case MediaOptionAction.details:
        await showAssetDetailsDialog(context, asset: track.asset);
      default:
        break;
    }
  }

  static Future<List<AudioTrack>> _tracksFromIds(List<String> ids) async {
    final tracks = <AudioTrack>[];
    for (final id in ids) {
      try {
        final entity = await AssetEntity.fromId(id);
        if (entity != null) {
          tracks.add(LocalAudioService.trackFromAsset(entity));
        }
      } catch (_) {}
    }
    return tracks;
  }

  static Future<bool> _deleteAssetIds(List<String> ids) async {
    if (ids.isEmpty) return true;
    try {
      final result = await PhotoManager.editor.deleteWithIds(ids);
      return result.isNotEmpty;
    } catch (e, st) {
      debugPrint('[audio] deleteWithIds failed: $e\n$st');
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
