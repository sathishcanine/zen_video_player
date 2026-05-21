import 'package:flutter/material.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';

import '../navigation/audio_routes.dart';
import '../navigation/library_shell_scope.dart';
import '../services/audio_player_service.dart';
import '../theme/zen_theme.dart';
import 'audio_artwork.dart';
import 'audio_queue_sheet.dart';

class AudioMiniPlayer extends StatelessWidget {
  const AudioMiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AudioPlayerService.instance,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context)!;
        final service = AudioPlayerService.instance;
        final track = service.currentTrack;
        if (track == null) return const SizedBox.shrink();

        final artist =
            track.artist.isEmpty ? l10n.unknownArtist : track.artist;

        return Material(
          color: const Color(0xFF1A1A22),
          child: InkWell(
            onTap: () {
              final route = AudioRoutes.nowPlayingRoute();
              final shellNav = LibraryShellScope.navigatorOf(context);
              if (shellNav != null) {
                shellNav.push(route);
              } else {
                Navigator.push<void>(context, route);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, size: 22),
                    onPressed: () => service.stopAndClear(),
                  ),
                  AudioArtwork(asset: track.asset),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          track.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: ZenTheme.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: ZenTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      service.isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                    onPressed: () => service.togglePlayPause(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.queue_music),
                    onPressed: () => showAudioQueueSheet(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
