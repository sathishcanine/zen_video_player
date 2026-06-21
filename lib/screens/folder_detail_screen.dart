import 'package:flutter/material.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';
import 'package:photo_manager/photo_manager.dart';
import '../models/media_folder.dart';
import '../navigation/library_navigation.dart';
import '../services/local_media_service.dart';
import '../services/new_media_tracker.dart';
import '../services/video_media_actions.dart';
import '../widgets/media_options_sheet.dart';
import '../widgets/video_asset_tile.dart';
import '../theme/zen_theme.dart';

class FolderDetailScreen extends StatefulWidget {
  const FolderDetailScreen({super.key, required this.folder});

  final MediaFolder folder;

  @override
  State<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends State<FolderDetailScreen> {
  List<AssetEntity> _assets = [];
  final Map<String, bool> _newByAssetId = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final assets = await LocalMediaService.loadAllVideosInFolder(widget.folder);
    final newFlags = <String, bool>{};
    if (!widget.folder.isRecentlyAdded) {
      final newIds = await NewMediaTracker.newAssetIdsInFolder(
        folderId: widget.folder.id,
        assets: assets,
      );
      for (final id in newIds) {
        newFlags[id] = true;
      }
      await NewMediaTracker.acknowledgeFolder(widget.folder.id, assets);
    }
    if (!mounted) return;
    setState(() {
      _assets = assets;
      _newByAssetId
        ..clear()
        ..addAll(newFlags);
      _loading = false;
    });
  }

  String _title(AppLocalizations l10n) {
    if (widget.folder.isRecentlyAdded) {
      return l10n.folderRecentlyAdded;
    }
    return widget.folder.displayName;
  }

  Future<void> _openMenu(AssetEntity asset) async {
    final action = await showMediaOptionsSheet(
      context,
      actions: VideoMediaActions.assetActions(),
    );
    if (action == null || !mounted) return;
    await VideoMediaActions.handleAsset(
      context,
      asset: asset,
      action: action,
      onListChanged: _load,
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

    return LibraryRoutePage(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: BackButton(
            onPressed: () => LibraryNavigation.pop(context),
          ),
          title: Text(l10n.videosInFolder(_title(l10n))),
        ),
        body: ZenGradientBackground(
          child: SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _assets.isEmpty
                    ? Center(
                        child: Text(
                          l10n.noVideosFound,
                          style:
                              const TextStyle(color: ZenTheme.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _assets.length,
                        itemBuilder: (context, index) {
                          final asset = _assets[index];
                          final name = asset.title ??
                              asset.relativePath ??
                              'Video ${index + 1}';
                          return VideoAssetTile(
                            asset: asset,
                            title: name,
                            subtitle: _subtitle(asset),
                            isNew: _newByAssetId[asset.id] ?? false,
                            onTap: () => VideoMediaActions.handleAsset(
                              context,
                              asset: asset,
                              action: MediaOptionAction.play,
                              queueAssetIds:
                                  _assets.map((a) => a.id).toList(),
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
