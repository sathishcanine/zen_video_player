import 'package:flutter/material.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';
import 'package:zen_video_player/theme/zen_palette.dart';
import 'package:zen_video_player/theme/zen_theme.dart';

import '../models/video_playlist.dart';
import '../navigation/library_navigation.dart';
import '../services/playlist_service.dart';
import '../services/video_media_actions.dart';
import '../widgets/media_options_sheet.dart';
import 'playlist_detail_screen.dart';

/// User playlists (UPlayer-style list).
class PlaylistListScreen extends StatefulWidget {
  const PlaylistListScreen({super.key});

  @override
  State<PlaylistListScreen> createState() => _PlaylistListScreenState();
}

class _PlaylistListScreenState extends State<PlaylistListScreen> {
  List<VideoPlaylist> _playlists = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await PlaylistService.loadAll();
    if (!mounted) return;
    setState(() {
      _playlists = list;
      _loading = false;
    });
  }

  Future<void> _createPlaylist() async {
    final l10n = AppLocalizations.of(context)!;
    final zen = context.zen;
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: zen.sheetBackground,
        title: Text(
          l10n.createPlaylist,
          style: TextStyle(color: zen.textPrimary),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.playlistNameHint),
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
    if (name == null || !mounted) {
      controller.dispose();
      return;
    }
    await PlaylistService.create(name);
    controller.dispose();
    if (!mounted) return;
    await _load();
  }

  Future<void> _openMenu(VideoPlaylist playlist) async {
    final action = await showMediaOptionsSheet(
      context,
      actions: VideoMediaActions.playlistActions(),
    );
    if (action == null || !mounted) return;
    await VideoMediaActions.handlePlaylist(
      context,
      playlist: playlist,
      action: action,
      onChanged: () {
        if (action == MediaOptionAction.delete) {
          Navigator.pop(context);
        } else {
          _load();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final zen = context.zen;

    return LibraryRoutePage(
      child: Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => LibraryNavigation.pop(context),
        ),
        title: Text(l10n.pillPlaylist),
      ),
      body: ZenGradientBackground(
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ListTile(
                      leading: Icon(Icons.add, color: zen.textPrimary),
                      title: Text(
                        l10n.createPlaylist,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: zen.textPrimary,
                        ),
                      ),
                      onTap: _createPlaylist,
                    ),
                    Expanded(
                      child: _playlists.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  l10n.playlistEmpty,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: zen.textSecondary),
                                ),
                              ),
                            )
                          : ReorderableListView.builder(
                              padding: const EdgeInsets.only(bottom: 16),
                              itemCount: _playlists.length,
                              onReorder: (oldIndex, newIndex) async {
                                if (newIndex > oldIndex) newIndex--;
                                final list = List<VideoPlaylist>.from(_playlists);
                                final item = list.removeAt(oldIndex);
                                list.insert(newIndex, item);
                                setState(() => _playlists = list);
                                await PlaylistService.reorder(list);
                              },
                              itemBuilder: (context, index) {
                                final p = _playlists[index];
                                return ListTile(
                                  key: ValueKey(p.id),
                                  leading: ReorderableDragStartListener(
                                    index: index,
                                    child: Icon(
                                      Icons.drag_handle,
                                      color: zen.textSecondary,
                                    ),
                                  ),
                                  title: Text(
                                    p.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: zen.textPrimary,
                                    ),
                                  ),
                                  subtitle: Text(
                                    l10n.playlistVideoCount(p.videoCount),
                                    style: TextStyle(
                                      color: zen.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.more_vert,
                                      color: zen.textSecondary,
                                    ),
                                    onPressed: () => _openMenu(p),
                                  ),
                                  onTap: () async {
                                    await LibraryNavigation.push<void>(
                                      context,
                                      PlaylistDetailScreen(
                                        playlistId: p.id,
                                      ),
                                    );
                                    await _load();
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
        ),
      ),
      ),
    );
  }
}
