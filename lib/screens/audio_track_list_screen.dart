import 'package:flutter/material.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';

import '../models/audio_track.dart';
import '../navigation/library_navigation.dart';
import '../services/audio_media_actions.dart';
import '../services/audio_player_service.dart';
import '../theme/zen_theme.dart';
import '../utils/audio_playback_launcher.dart';
import '../widgets/audio_artwork.dart';

class AudioTrackListScreen extends StatelessWidget {
  const AudioTrackListScreen({
    super.key,
    required this.title,
    required this.tracks,
  });

  final String title;
  final List<AudioTrack> tracks;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return LibraryRoutePage(
      child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => LibraryNavigation.pop(context),
        ),
        title: Text(title),
      ),
      body: ZenGradientBackground(
        child: tracks.isEmpty
            ? Center(child: Text(l10n.noAudioFound))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: tracks.length,
                itemBuilder: (context, index) {
                  final track = tracks[index];
                  final artist = track.artist.isEmpty
                      ? l10n.unknownArtist
                      : track.artist;
                  return ListTile(
                    leading: AudioArtwork(asset: track.asset),
                    title: Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '$artist | ${track.albumName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: ZenTheme.textSecondary),
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
                          onPressed: () => AudioMediaActions.openTrackMenu(
                            context,
                            track: track,
                            queue: tracks,
                          ),
                        ),
                      ],
                    ),
                    onTap: () => launchAudioPlayback(
                      context,
                      tracks,
                      startIndex: index,
                    ),
                  );
                },
              ),
      ),
      ),
    );
  }
}
