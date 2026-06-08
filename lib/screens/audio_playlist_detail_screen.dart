import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';
import 'package:zen_video_player/theme/zen_theme.dart';

import '../models/audio_playlist.dart';
import '../models/audio_track.dart';
import '../navigation/library_navigation.dart';
import '../services/audio_media_actions.dart';
import '../services/audio_player_service.dart';
import '../services/audio_playlist_service.dart';
import '../services/local_audio_service.dart';
import '../utils/audio_playback_launcher.dart';
import '../widgets/audio_artwork.dart';
import '../widgets/media_options_sheet.dart';

class AudioPlaylistDetailScreen extends StatefulWidget {
  const AudioPlaylistDetailScreen({super.key, required this.playlistId});

  final String playlistId;

  @override
  State<AudioPlaylistDetailScreen> createState() =>
      _AudioPlaylistDetailScreenState();
}

class _AudioPlaylistDetailScreenState extends State<AudioPlaylistDetailScreen> {
  AudioPlaylist? _playlist;
  List<AudioTrack> _tracks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final playlist = await AudioPlaylistService.byId(widget.playlistId);
    if (playlist == null) {
      if (mounted) Navigator.pop(context);
      return;
    }
    final tracks = <AudioTrack>[];
    for (final id in playlist.assetIds) {
      try {
        final entity = await AssetEntity.fromId(id);
        if (entity != null) {
          tracks.add(LocalAudioService.trackFromAsset(entity));
        }
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() {
      _playlist = playlist;
      _tracks = tracks;
      _loading = false;
    });
  }

  Future<void> _openMenu(AudioTrack track) async {
    final action = await showMediaOptionsSheet(
      context,
      actions: AudioMediaActions.playlistTrackActions(),
    );
    if (action == null || !mounted) return;
    await AudioMediaActions.handlePlaylistTrack(
      context,
      playlistId: widget.playlistId,
      track: track,
      action: action,
      onChanged: _load,
      queue: _tracks,
    );
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
                : _tracks.isEmpty
                    ? Center(
                        child: Text(
                          l10n.noAudioFound,
                          style: const TextStyle(color: ZenTheme.textSecondary),
                        ),
                      )
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _tracks.length,
                        onReorder: (oldIndex, newIndex) async {
                          if (newIndex > oldIndex) newIndex--;
                          final ids = playlist.assetIds.toList();
                          final id = ids.removeAt(oldIndex);
                          ids.insert(newIndex, id);
                          await AudioPlaylistService.reorderAssets(
                            widget.playlistId,
                            ids,
                          );
                          await _load();
                        },
                        itemBuilder: (context, index) {
                          final track = _tracks[index];
                          final artist = track.artist.isEmpty
                              ? l10n.unknownArtist
                              : track.artist;
                          return ListTile(
                            key: ValueKey(track.asset.id),
                            leading: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ReorderableDragStartListener(
                                  index: index,
                                  child: const Icon(
                                    Icons.drag_handle,
                                    color: ZenTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                AudioArtwork(asset: track.asset),
                              ],
                            ),
                            title: Text(
                              track.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  formatDuration(
                                    Duration(seconds: track.asset.duration),
                                  ),
                                  style: const TextStyle(
                                    color: ZenTheme.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.more_vert, size: 20),
                                  onPressed: () => _openMenu(track),
                                ),
                              ],
                            ),
                            onTap: () => launchAudioPlayback(
                              context,
                              _tracks,
                              startIndex: index,
                            ),
                          );
                        },
                      ),
          ),
        ),
      ),
    );
  }
}
