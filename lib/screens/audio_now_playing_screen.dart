import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';

import '../navigation/library_navigation.dart';
import '../services/audio_equalizer_service.dart';
import '../services/audio_equalizer_spec.dart';
import '../services/audio_player_service.dart';
import '../services/audio_visualizer_service.dart';
import '../services/app_settings_service.dart';
import '../theme/zen_palette.dart';
import '../widgets/audio_spectrum_visualizer.dart';
import '../widgets/audio_visualizer_mode_picker.dart';
import '../widgets/cast_device_picker_sheet.dart';
import '../widgets/audio_artwork.dart';
import 'audio_equalizer_screen.dart';
import '../widgets/audio_queue_sheet.dart';
import '../widgets/sleep_timer_sheet.dart';

class AudioNowPlayingScreen extends StatelessWidget {
  const AudioNowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final zen = context.zen;
    final isDark = AppSettingsService.instance.isDarkTheme;
    final onPlayer = isDark ? Colors.white : Colors.white;
    final onPlayerMuted = isDark
        ? Colors.white.withValues(alpha: 0.65)
        : Colors.white.withValues(alpha: 0.75);
    final playerBg = isDark ? const Color(0xFF121218) : const Color(0xFF1A1A24);

    return LibraryRoutePage(
      child: Scaffold(
        backgroundColor: playerBg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: onPlayer,
          iconTheme: IconThemeData(color: onPlayer),
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
              icon: const Icon(Icons.timer_outlined),
              tooltip: l10n.sleepTimerTitle,
              onPressed: () => showSleepTimerSheet(context),
            ),
            IconButton(
              icon: const Icon(Icons.cast_outlined),
              onPressed: () => showCastDevicePicker(context),
            ),
            IconButton(
              icon: const Icon(Icons.graphic_eq),
              tooltip: l10n.equalizerTitle,
              onPressed: () => openAudioEqualizer(context),
            ),
            ListenableBuilder(
              listenable: AudioVisualizerService.instance,
              builder: (_, __) {
                final viz = AudioVisualizerService.instance;
                return AudioNowPlayingOverflowMenu(
                  mode: viz.mode,
                  onModeChanged: viz.setMode,
                  iconColor: onPlayer,
                );
              },
            ),
          ],
        ),
        body: ListenableBuilder(
          listenable: Listenable.merge([
            AudioPlayerService.instance,
            AudioEqualizerService.instance,
            AudioVisualizerService.instance,
          ]),
          builder: (context, _) {
            final service = AudioPlayerService.instance;
            final eq = AudioEqualizerService.instance;
            final viz = AudioVisualizerService.instance;
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
            final gains = eq.isSupported
                ? List<double>.generate(
                    10,
                    (i) => AudioEqualizerSpec.presetCurves[eq.preset]?[i] ?? 0,
                  )
                : const <double>[];

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final size = math.min(
                            constraints.maxWidth,
                            constraints.maxHeight,
                          );
                          return SizedBox(
                            width: size,
                            height: size,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                AudioSpectrumVisualizer(
                                  gains: gains,
                                  isPlaying: service.isPlaying,
                                  bands: viz.bands,
                                  waveform: viz.waveform,
                                  mode: viz.mode,
                                  useRealData: viz.hasRealData,
                                  surroundArtwork: true,
                                  height: size,
                                  barCount: 48,
                                ),
                                ClipOval(
                                  child: SizedBox(
                                    width: size * 0.64,
                                    height: size * 0.64,
                                    child: AudioArtwork(
                                      large: true,
                                      asset: track.asset,
                                    ),
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
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: onPlayer,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              artist,
                              style: TextStyle(
                                color: onPlayerMuted,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${service.currentIndex + 1}/${service.queue.length}',
                              style: TextStyle(
                                color: onPlayerMuted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.queue_music, color: onPlayer),
                        onPressed: () => showAudioQueueSheet(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        formatDuration(pos),
                        style: TextStyle(color: onPlayerMuted, fontSize: 12),
                      ),
                      Expanded(
                        child: Slider(
                          value: progress.clamp(0.0, 1.0),
                          activeColor: zen.tabIndicator,
                          inactiveColor: onPlayerMuted.withValues(alpha: 0.35),
                          onChanged: (v) {
                            final ms = (dur.inMilliseconds * v).round();
                            service.seek(Duration(milliseconds: ms));
                          },
                        ),
                      ),
                      Text(
                        formatDuration(dur),
                        style: TextStyle(color: onPlayerMuted, fontSize: 12),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.repeat,
                          color: service.repeat ? zen.tabIndicator : onPlayerMuted,
                        ),
                        onPressed: service.toggleRepeat,
                      ),
                      IconButton(
                        icon: Icon(Icons.skip_previous, size: 36, color: onPlayer),
                        onPressed: () => service.skipPrevious(),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: zen.tabIndicator,
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
                        icon: Icon(Icons.skip_next, size: 36, color: onPlayer),
                        onPressed: () => service.skipNext(),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.shuffle,
                          color:
                              service.shuffle ? zen.tabIndicator : onPlayerMuted,
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
