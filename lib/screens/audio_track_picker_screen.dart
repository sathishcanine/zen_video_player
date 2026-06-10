import 'package:flutter/material.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';
import 'package:zen_video_player/theme/zen_palette.dart';
import 'package:zen_video_player/theme/zen_theme.dart';

import '../models/audio_track.dart';
import '../navigation/library_navigation.dart';
import '../services/audio_player_service.dart';
import '../services/local_audio_service.dart';
import '../widgets/audio_artwork.dart';

/// Opens the device track picker and returns the selected asset IDs
/// (excluding [existingIds]), or null if dismissed.
Future<List<String>?> pickTracksForAudioPlaylist(
  BuildContext context, {
  required Set<String> existingIds,
}) {
  return LibraryNavigation.push<List<String>>(
    context,
    AudioTrackPickerScreen(existingIds: existingIds),
  );
}

/// Multi-select picker over all on-device audio tracks.
class AudioTrackPickerScreen extends StatefulWidget {
  const AudioTrackPickerScreen({super.key, required this.existingIds});

  final Set<String> existingIds;

  @override
  State<AudioTrackPickerScreen> createState() => _AudioTrackPickerScreenState();
}

class _AudioTrackPickerScreenState extends State<AudioTrackPickerScreen> {
  List<AudioTrack> _tracks = [];
  bool _loading = true;
  final Set<String> _selected = <String>{};

  @override
  void initState() {
    super.initState();
    _loadTracks();
  }

  Future<void> _loadTracks() async {
    final tracks = await LocalAudioService.loadTracks();
    if (!mounted) return;
    setState(() {
      _tracks = tracks;
      _loading = false;
    });
  }

  void _toggle(AudioTrack track) {
    setState(() {
      if (!_selected.remove(track.asset.id)) {
        _selected.add(track.asset.id);
      }
    });
  }

  void _confirm() {
    LibraryNavigation.pop(context, _selected.toList());
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
          title: Text(l10n.playlistAddSongs),
        ),
        body: ZenGradientBackground(
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _tracks.isEmpty
                          ? Center(
                              child: Text(
                                l10n.noAudioFound,
                                style: TextStyle(color: zen.textSecondary),
                              ),
                            )
                          : _buildTrackList(l10n, zen),
                ),
                if (_selected.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _confirm,
                        icon: const Icon(Icons.playlist_add),
                        label: Text(
                          l10n.playlistAddSongCount(_selected.length),
                        ),
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

  Widget _buildTrackList(AppLocalizations l10n, ZenPalette zen) {
    final primary = Theme.of(context).colorScheme.primary;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _tracks.length,
      itemBuilder: (context, index) {
        final track = _tracks[index];
        final id = track.asset.id;
        final alreadyAdded = widget.existingIds.contains(id);
        final selected = _selected.contains(id);
        final artist =
            track.artist.isEmpty ? l10n.unknownArtist : track.artist;

        return Opacity(
          opacity: alreadyAdded ? 0.45 : 1,
          child: ListTile(
            key: ValueKey(id),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            leading: AudioArtwork(asset: track.asset),
            title: Text(
              track.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: zen.textPrimary,
              ),
            ),
            subtitle: Text(
              alreadyAdded ? l10n.playlistAlreadyAdded : artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: zen.textSecondary, fontSize: 13),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatDuration(Duration(seconds: track.asset.duration)),
                  style: TextStyle(color: zen.textSecondary, fontSize: 13),
                ),
                const SizedBox(width: 10),
                alreadyAdded
                    ? Icon(Icons.check_circle, color: zen.textSecondary)
                    : selected
                        ? Icon(Icons.check_circle, color: primary)
                        : Icon(
                            Icons.radio_button_unchecked,
                            color: zen.textSecondary,
                          ),
              ],
            ),
            selected: selected,
            selectedTileColor: primary.withValues(alpha: 0.12),
            onTap: alreadyAdded ? null : () => _toggle(track),
          ),
        );
      },
    );
  }
}
