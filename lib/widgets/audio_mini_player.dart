import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';

import '../navigation/audio_routes.dart';
import '../navigation/library_navigation.dart';
import '../services/audio_player_service.dart';
import '../theme/zen_palette.dart';
import 'audio_artwork.dart';
import 'audio_queue_sheet.dart';

/// Bottom bar shown only while audio is playing in the background.
class AudioMiniPlayer extends StatelessWidget {
  const AudioMiniPlayer({super.key});

  void _openNowPlaying(BuildContext context) {
    unawaited(
      LibraryNavigation.pushRoute(
        context,
        AudioRoutes.nowPlayingRoute(),
      ),
    );
  }

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
        final primary = Theme.of(context).colorScheme.primary;

        return Material(
          elevation: 6,
          color: isDark ? const Color(0xFF1A1A22) : zen.surfaceCard,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 6, 4, 6),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, size: 22),
                    tooltip: l10n.notNow,
                    onPressed: () => service.stopAndClear(),
                  ),
                  GestureDetector(
                    onTap: () => _openNowPlaying(context),
                    behavior: HitTestBehavior.opaque,
                    child: AudioArtwork(asset: track.asset),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _openNowPlaying(context),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.music_note,
                                size: 14,
                                color: primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                l10n.backgroundPlayingAudio,
                                style: TextStyle(
                                  color: primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
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
                  ),
                  Material(
                    color: primary.withValues(alpha: 0.15),
                    shape: const CircleBorder(),
                    child: IconButton(
                      iconSize: 28,
                      icon: Icon(
                        service.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: primary,
                      ),
                      tooltip: service.isPlaying ? 'Pause' : 'Play',
                      onPressed: () => service.togglePlayPause(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.queue_music),
                    tooltip: l10n.tabAudio,
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
