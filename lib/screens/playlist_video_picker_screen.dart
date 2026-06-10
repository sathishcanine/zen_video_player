import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';
import 'package:zen_video_player/theme/zen_palette.dart';
import 'package:zen_video_player/theme/zen_theme.dart';

import '../models/media_folder.dart';
import '../navigation/library_navigation.dart';
import '../services/local_media_service.dart';

/// Opens the device video picker and returns the selected asset IDs
/// (excluding [existingIds]), or null if dismissed.
Future<List<String>?> pickVideosForPlaylist(
  BuildContext context, {
  required Set<String> existingIds,
}) {
  return LibraryNavigation.push<List<String>>(
    context,
    PlaylistVideoPickerScreen(existingIds: existingIds),
  );
}

/// Multi-select picker: browse device folders and choose videos to add.
class PlaylistVideoPickerScreen extends StatefulWidget {
  const PlaylistVideoPickerScreen({super.key, required this.existingIds});

  final Set<String> existingIds;

  @override
  State<PlaylistVideoPickerScreen> createState() =>
      _PlaylistVideoPickerScreenState();
}

class _PlaylistVideoPickerScreenState extends State<PlaylistVideoPickerScreen> {
  List<MediaFolder> _folders = [];
  MediaFolder? _openFolder;
  List<AssetEntity> _videos = [];
  bool _loading = true;
  final Set<String> _selected = <String>{};

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    final folders = await LocalMediaService.loadVideoFolders();
    if (!mounted) return;
    setState(() {
      _folders = folders;
      _loading = false;
    });
  }

  Future<void> _openFolderAssets(MediaFolder folder) async {
    setState(() {
      _openFolder = folder;
      _videos = [];
      _loading = true;
    });
    final videos = await LocalMediaService.loadAllVideosInFolder(folder);
    if (!mounted || _openFolder?.id != folder.id) return;
    setState(() {
      _videos = videos;
      _loading = false;
    });
  }

  void _handleBack() {
    if (_openFolder != null) {
      setState(() {
        _openFolder = null;
        _videos = [];
        _loading = false;
      });
      return;
    }
    LibraryNavigation.pop(context);
  }

  void _toggle(AssetEntity asset) {
    setState(() {
      if (!_selected.remove(asset.id)) {
        _selected.add(asset.id);
      }
    });
  }

  void _confirm() {
    LibraryNavigation.pop(context, _selected.toList());
  }

  String _folderName(MediaFolder folder, AppLocalizations l10n) {
    if (folder.isRecentlyAdded) return l10n.folderRecentlyAdded;
    return folder.displayName;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final zen = context.zen;
    final openFolder = _openFolder;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: BackButton(onPressed: _handleBack),
          title: Text(
            openFolder == null
                ? l10n.playlistAddVideos
                : _folderName(openFolder, l10n),
          ),
        ),
        body: ZenGradientBackground(
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : openFolder == null
                          ? _buildFolderList(l10n, zen)
                          : _buildVideoList(l10n, zen),
                ),
                if (_selected.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _confirm,
                        icon: const Icon(Icons.playlist_add),
                        label: Text(l10n.playlistAddCount(_selected.length)),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFolderList(AppLocalizations l10n, ZenPalette zen) {
    if (_folders.isEmpty) {
      return Center(
        child: Text(
          l10n.noVideosFound,
          style: TextStyle(color: zen.textSecondary),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _folders.length,
      itemBuilder: (context, index) {
        final folder = _folders[index];
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: zen.surfaceCard,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              folder.isRecentlyAdded
                  ? Icons.schedule_rounded
                  : Icons.folder_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: Text(
            _folderName(folder, l10n),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: zen.textPrimary,
            ),
          ),
          subtitle: Text(
            l10n.playlistVideoCount(folder.videoCount),
            style: TextStyle(color: zen.textSecondary, fontSize: 13),
          ),
          trailing: Icon(Icons.chevron_right, color: zen.textSecondary),
          onTap: () => _openFolderAssets(folder),
        );
      },
    );
  }

  Widget _buildVideoList(AppLocalizations l10n, ZenPalette zen) {
    if (_videos.isEmpty) {
      return Center(
        child: Text(
          l10n.noVideosFound,
          style: TextStyle(color: zen.textSecondary),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        final asset = _videos[index];
        final alreadyAdded = widget.existingIds.contains(asset.id);
        return _PickerVideoTile(
          key: ValueKey(asset.id),
          asset: asset,
          selected: _selected.contains(asset.id),
          alreadyAdded: alreadyAdded,
          alreadyAddedLabel: l10n.playlistAlreadyAdded,
          onTap: alreadyAdded ? null : () => _toggle(asset),
        );
      },
    );
  }
}

class _PickerVideoTile extends StatelessWidget {
  const _PickerVideoTile({
    super.key,
    required this.asset,
    required this.selected,
    required this.alreadyAdded,
    required this.alreadyAddedLabel,
    required this.onTap,
  });

  final AssetEntity asset;
  final bool selected;
  final bool alreadyAdded;
  final String alreadyAddedLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final zen = context.zen;
    final primary = Theme.of(context).colorScheme.primary;
    final title = asset.title ?? asset.relativePath ?? 'Video';

    return Opacity(
      opacity: alreadyAdded ? 0.45 : 1,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: _Thumbnail(asset: asset),
        title: Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: zen.textPrimary,
          ),
        ),
        subtitle: alreadyAdded
            ? Text(
                alreadyAddedLabel,
                style: TextStyle(color: zen.textSecondary, fontSize: 13),
              )
            : null,
        trailing: alreadyAdded
            ? Icon(Icons.check_circle, color: zen.textSecondary)
            : selected
                ? Icon(Icons.check_circle, color: primary)
                : Icon(Icons.radio_button_unchecked, color: zen.textSecondary),
        selected: selected,
        selectedTileColor: primary.withValues(alpha: 0.12),
        onTap: onTap,
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.asset});

  final AssetEntity asset;

  @override
  Widget build(BuildContext context) {
    final zen = context.zen;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: 72,
        height: 48,
        child: FutureBuilder<Uint8List?>(
          future: asset.thumbnailDataWithSize(const ThumbnailSize(200, 120)),
          builder: (context, snapshot) {
            final data = snapshot.data;
            return Stack(
              fit: StackFit.expand,
              children: [
                if (data != null)
                  Image.memory(data, fit: BoxFit.cover)
                else
                  ColoredBox(
                    color: zen.surfaceCard,
                    child: Icon(
                      Icons.videocam_outlined,
                      color: zen.textSecondary,
                    ),
                  ),
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      _formatDuration(asset.duration),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
