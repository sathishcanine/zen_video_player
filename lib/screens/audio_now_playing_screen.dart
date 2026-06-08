import 'package:flutter/material.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';

import '../navigation/library_navigation.dart';
import '../services/audio_player_service.dart';
import '../theme/zen_theme.dart';
import '../widgets/cast_device_picker_sheet.dart';
import '../widgets/audio_artwork.dart';
import '../widgets/audio_equalizer_sheet.dart';
import '../widgets/audio_queue_sheet.dart';

class AudioNowPlayingScreen extends StatelessWidget {
  const AudioNowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return LibraryRoutePage(
      child: Scaffold(
      backgroundColor: const Color(0xFF121218),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => LibraryNavigation.pop(context),
        ),
        title: ListenableBuilder(
          listenable: AudioPlayerService.instance,
          builder: (_, __) {
            final track = AudioPlayerService.instance.currentTrack;
            return Text(
              track?.albumName ?? l10n.tabAudio,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cast_outlined),
            onPressed: () => showCastDevicePicker(context),
          ),
          IconButton(
            icon: const Icon(Icons.graphic_eq),
            tooltip: l10n.equalizerTitle,
            onPressed: () => showAudioEqualizerSheet(context),
          ),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: ListenableBuilder(
        listenable: AudioPlayerService.instance,
        builder: (context, _) {
          final service = AudioPlayerService.instance;
          final track = service.currentTrack;
          if (track == null) {
            return Center(child: Text(l10n.noAudioFound));
          }

          final artist =
              track.artist.isEmpty ? l10n.unknownArtist : track.artist;
          final pos = service.position;
          final dur = service.duration.inMilliseconds > 0
              ? service.duration
              : Duration(seconds: track.asset.duration);
          final progress = dur.inMilliseconds > 0
              ? pos.inMilliseconds / dur.inMilliseconds
              : 0.0;

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        var width = constraints.maxWidth;
                        var height = width / 0.85;
                        if (height > constraints.maxHeight) {
                          height = constraints.maxHeight;
                          width = height * 0.85;
                        }
                        return SizedBox(
                          width: width,
                          height: height,
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: AudioArtwork(large: true, asset: track.asset),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Icon(
                                  Icons.favorite_border,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  size: 28,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: ZenTheme.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            artist,
                            style: const TextStyle(
                              color: ZenTheme.textSecondary,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${service.currentIndex + 1}/${service.queue.length}',
                            style: const TextStyle(
                              color: ZenTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.queue_music),
                      onPressed: () => showAudioQueueSheet(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      formatDuration(pos),
                      style: const TextStyle(
                        color: ZenTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: progress.clamp(0.0, 1.0),
                        activeColor: ZenTheme.accentBlue,
                        inactiveColor: ZenTheme.surfaceElevated,
                        onChanged: (v) {
                          final ms = (dur.inMilliseconds * v).round();
                          service.seek(Duration(milliseconds: ms));
                        },
                      ),
                    ),
                    Text(
                      formatDuration(dur),
                      style: const TextStyle(
                        color: ZenTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.repeat,
                        color: service.repeat
                            ? ZenTheme.accentBlue
                            : ZenTheme.textSecondary,
                      ),
                      onPressed: service.toggleRepeat,
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_previous, size: 36),
                      onPressed: () => service.skipPrevious(),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        color: ZenTheme.accentBlue,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        iconSize: 42,
                        icon: Icon(
                          service.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                        ),
                        onPressed: () => service.togglePlayPause(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next, size: 36),
                      onPressed: () => service.skipNext(),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.shuffle,
                        color: service.shuffle
                            ? ZenTheme.accentBlue
                            : ZenTheme.textSecondary,
                      ),
                      onPressed: service.toggleShuffle,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      ),
    );
  }
}
