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
    // Do not use `.pipe(playbackState)` — it uses [Subject.addStream], which
    // races with [BaseAudioHandler.stop] and causes fatal "Bad state" crashes.
    player.playbackEventStream.listen((event) {
      if (_suppressPlaybackEvents) return;
      _safePlaybackStateAdd(_transformEvent(event));
    });
  }

  final _eq = AudioEqualizerService.instance;
  late final AudioPlayer player;

  Future<void> Function()? onSkipNext;
  Future<void> Function()? onSkipPrevious;
  Future<void> Function()? onStop;
  Future<void> Function()? onResumePlay;
  bool Function()? hasQueue;

  int _queueIndex = 0;
  bool _suppressPlaybackEvents = false;
  bool _stopInProgress = false;

  void bindTransport({
    required Future<void> Function() skipNext,
    required Future<void> Function() skipPrevious,
    required Future<void> Function() stop,
    required Future<void> Function() resumePlay,
    required bool Function() hasQueue,
  }) {
    onSkipNext = skipNext;
    onSkipPrevious = skipPrevious;
    onStop = stop;
    onResumePlay = resumePlay;
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
    await _safeMediaItemAdd(
      MediaItem(
        id: track.asset.id,
        title: track.title,
        artist: track.artist,
        album: track.albumName,
        duration: Duration(seconds: track.asset.duration),
        artUri: await _artworkUri(track),
      ),
    );
  }

  void syncTrackQueue(List<AudioTrack> tracks) {
    _safeQueueAdd(tracks.map(_toMediaItem).toList());
  }

  void clearNowPlaying() {
    _safeMediaItemAdd(null);
    _safeQueueAdd(const <MediaItem>[]);
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
  Future<void> play() async {
    if (onResumePlay != null) {
      await onResumePlay!();
      return;
    }
    await player.play();
  }

  @override
  Future<void> pause() => player.pause();

  /// Notification / lock-screen stop — keeps the current track queued for resume.
  @override
  Future<void> stop() async {
    await _runStopSession(() async {
      await player.stop();
      await onStop?.call();
      await _setIdlePlaybackState();
    });
  }

  /// Full dismiss (mini-player close) — tears down the media session.
  Future<void> stopAndDismissSession() async {
    await _runStopSession(() async {
      await player.stop();
      clearNowPlaying();
      await _setIdlePlaybackState();
    });
  }

  Future<void> _runStopSession(Future<void> Function() action) async {
    if (_stopInProgress) return;
    _stopInProgress = true;
    _suppressPlaybackEvents = true;
    try {
      await action();
      // Let any in-flight just_audio events drain before resuming updates.
      await Future<void>.delayed(Duration.zero);
    } catch (e, st) {
      debugPrint('[audio] stop session failed: $e\n$st');
    } finally {
      _suppressPlaybackEvents = false;
      _stopInProgress = false;
    }
  }

  Future<void> _setIdlePlaybackState() async {
    final current = playbackState.hasValue ? playbackState.value : null;
    _safePlaybackStateAdd(
      (current ?? PlaybackState()).copyWith(
        processingState: AudioProcessingState.idle,
        playing: false,
      ),
    );
  }

  void _safePlaybackStateAdd(PlaybackState state) {
    try {
      playbackState.add(state);
    } catch (e, st) {
      debugPrint('[audio] playbackState.add failed: $e\n$st');
    }
  }

  Future<void> _safeMediaItemAdd(MediaItem? item) async {
    try {
      mediaItem.add(item);
    } catch (e, st) {
      debugPrint('[audio] mediaItem.add failed: $e\n$st');
    }
  }

  void _safeQueueAdd(List<MediaItem> items) {
    try {
      queue.add(items);
    } catch (e, st) {
      debugPrint('[audio] queue.add failed: $e\n$st');
    }
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
