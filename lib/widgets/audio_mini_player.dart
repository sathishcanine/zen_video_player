import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';

import '../navigation/audio_routes.dart';
import '../navigation/library_navigation.dart';
import '../services/audio_player_service.dart';
import '../theme/zen_palette.dart';
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

        final zen = context.zen;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Material(
          color: isDark ? const Color(0xFF1A1A22) : zen.surfaceCard,
          child: InkWell(
            onTap: () {
              unawaited(
                LibraryNavigation.pushRoute(
                  context,
                  AudioRoutes.nowPlayingRoute(),
                ),
              );
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
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: zen.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: zen.textSecondary,
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
