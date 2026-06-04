import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';
import 'package:zen_video_player/theme/zen_theme.dart';
import '../models/video_playlist.dart';
import '../navigation/library_navigation.dart';
import '../services/playlist_service.dart';
import '../services/video_media_actions.dart';
import '../widgets/media_options_sheet.dart';
import '../widgets/video_asset_tile.dart';

class PlaylistDetailScreen extends StatefulWidget {
  const PlaylistDetailScreen({super.key, required this.playlistId});

  final String playlistId;

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  VideoPlaylist? _playlist;
  List<AssetEntity> _assets = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final playlist = await PlaylistService.byId(widget.playlistId);
    if (playlist == null) {
      if (mounted) Navigator.pop(context);
      return;
    }
    final assets = <AssetEntity>[];
    for (final id in playlist.assetIds) {
      try {
        final entity = await AssetEntity.fromId(id);
        if (entity != null) assets.add(entity);
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() {
      _playlist = playlist;
      _assets = assets;
      _loading = false;
    });
  }

  Future<void> _openMenu(AssetEntity asset) async {
    final action = await showMediaOptionsSheet(
      context,
      actions: VideoMediaActions.playlistAssetActions(),
    );
    if (action == null || !mounted) return;
    await VideoMediaActions.handlePlaylistAsset(
      context,
      playlistId: widget.playlistId,
      asset: asset,
      action: action,
      onChanged: _load,
    );
  }

  String _subtitle(AssetEntity asset) {
    if (asset.width > 0 && asset.height > 0) {
      return '${asset.width}×${asset.height}';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final playlist = _playlist;

    return LibraryRoutePage(
      child: Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => LibraryNavigation.pop(context),
        ),
        title: Text(playlist?.name ?? l10n.pillPlaylist),
      ),
      body: ZenGradientBackground(
        child: SafeArea(
          child: _loading || playlist == null
              ? const Center(child: CircularProgressIndicator())
              : _assets.isEmpty
                  ? Center(
                      child: Text(
                        l10n.noVideosFound,
                        style: const TextStyle(color: ZenTheme.textSecondary),
                      ),
                    )
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _assets.length,
                      onReorder: (oldIndex, newIndex) async {
                        if (newIndex > oldIndex) newIndex--;
                        final ids = playlist.assetIds.toList();
                        final id = ids.removeAt(oldIndex);
                        ids.insert(newIndex, id);
                        await PlaylistService.reorderAssets(
                          widget.playlistId,
                          ids,
                        );
                        await _load();
                      },
                      itemBuilder: (context, index) {
                        final asset = _assets[index];
                        final name =
                            asset.title ?? asset.relativePath ?? 'Video';
                        return VideoAssetTile(
                          key: ValueKey(asset.id),
                          asset: asset,
                          title: name,
                          subtitle: _subtitle(asset),
                          onTap: () => VideoMediaActions.handlePlaylistAsset(
                            context,
                            playlistId: widget.playlistId,
                            asset: asset,
                            action: MediaOptionAction.play,
                            onChanged: _load,
                          ),
                          onMenu: () => _openMenu(asset),
                        );
                      },
                    ),
        ),
      ),
      ),
    );
  }
}
