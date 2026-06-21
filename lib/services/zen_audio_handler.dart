import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import '../models/audio_track.dart';
import 'audio_artwork_cache.dart';
import 'audio_equalizer_service.dart';

/// Bridges [just_audio] to system media controls (notification, lock screen).
class ZenAudioHandler extends BaseAudioHandler with SeekHandler {
  ZenAudioHandler() {
    player = AudioPlayer(audioPipeline: _eq.pipeline);
    unawaited(_configureSession());
    unawaited(_eq.ensureLoaded());
    player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  final _eq = AudioEqualizerService.instance;
  late final AudioPlayer player;

  Future<void> Function()? onSkipNext;
  Future<void> Function()? onSkipPrevious;
  Future<void> Function()? onStop;
  bool Function()? hasQueue;

  int _queueIndex = 0;

  void bindTransport({
    required Future<void> Function() skipNext,
    required Future<void> Function() skipPrevious,
    required Future<void> Function() stop,
    required bool Function() hasQueue,
  }) {
    onSkipNext = skipNext;
    onSkipPrevious = skipPrevious;
    onStop = stop;
    this.hasQueue = hasQueue;
  }

  void setQueueIndex(int index) => _queueIndex = index;

  Future<void> _configureSession() async {
    if (kIsWeb) return;
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (e, st) {
      debugPrint('[audio] session config failed: $e\n$st');
    }
  }

  Future<void> updateNowPlaying(AudioTrack track) async {
    final duration = Duration(seconds: track.asset.duration);
    mediaItem.add(
      MediaItem(
        id: track.asset.id,
        title: track.title,
        artist: track.artist,
        album: track.albumName,
        duration: duration,
        artUri: await _artworkUri(track),
      ),
    );
  }

  void syncTrackQueue(List<AudioTrack> tracks) {
    queue.add(tracks.map(_toMediaItem).toList());
  }

  void clearNowPlaying() {
    mediaItem.add(null);
    queue.add([]);
  }

  MediaItem _toMediaItem(AudioTrack track) {
    return MediaItem(
      id: track.asset.id,
      title: track.title,
      artist: track.artist,
      album: track.albumName,
      duration: Duration(seconds: track.asset.duration),
    );
  }

  Future<Uri?> _artworkUri(AudioTrack track) async {
    if (kIsWeb || !Platform.isAndroid) return null;
    try {
      final bytes = await AudioArtworkCache.instance.load(track.asset);
      if (bytes == null || bytes.isEmpty) return null;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/zen_art_${track.asset.id}.jpg');
      if (!await file.exists()) {
        await file.writeAsBytes(bytes, flush: true);
      }
      return file.uri;
    } catch (e, st) {
      debugPrint('[audio] notification artwork failed: $e\n$st');
      return null;
    }
  }

  @override
  Future<void> play() => player.play();

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> stop() async {
    await player.stop();
    clearNowPlaying();
    await onStop?.call();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => player.seek(position);

  @override
  Future<void> skipToNext() async {
    await onSkipNext?.call();
  }

  @override
  Future<void> skipToPrevious() async {
    await onSkipPrevious?.call();
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    final playing = player.playing;
    final showQueue = hasQueue?.call() ?? false;
    return PlaybackState(
      controls: [
        if (showQueue) MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        if (showQueue) MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: showQueue ? const [0, 1, 3] : const [0, 1],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[player.processingState]!,
      playing: playing,
      updatePosition: event.updatePosition,
      bufferedPosition: event.bufferedPosition,
      speed: player.speed,
      queueIndex: showQueue ? _queueIndex : null,
    );
  }
}
