import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/audio_track.dart';
import 'asset_playback_resolver.dart';
import 'audio_equalizer_service.dart';
import 'audio_visualizer_service.dart';
import 'sleep_timer_service.dart';
import 'zen_audio_handler.dart';

/// Global audio queue + playback (mini-player and now-playing UI).
class AudioPlayerService extends ChangeNotifier {
  AudioPlayerService._(this._handler) {
    unawaited(_eq.ensureLoaded());
    _handler.bindTransport(
      skipNext: skipNext,
      skipPrevious: skipPrevious,
      stop: _onSystemStop,
      resumePlay: _resumePlayback,
      hasQueue: () => _queue.isNotEmpty,
    );
    _positionSub = _player.positionStream.listen((p) {
      _position = p;
      notifyListeners();
    });
    _durationSub = _player.durationStream.listen((d) {
      if (d != null) {
        _duration = d;
        notifyListeners();
      }
    });
    _stateSub = _player.playerStateStream.listen((s) {
      _isPlaying = s.playing;
      AudioVisualizerService.instance.setPlaying(s.playing);
      if (s.playing) {
        AudioVisualizerService.instance.bindPlayer(_player, isPlaying: true);
      }
      if (s.processingState == ProcessingState.completed && _queue.isNotEmpty) {
        unawaited(SleepTimerService.instance.onMediaCompleted());
        unawaited(skipNext());
      }
      notifyListeners();
    });
    SleepTimerService.instance.addOnExpireListener(_onSleepTimerExpired);
  }

  static AudioPlayerService? _instance;

  static AudioPlayerService get instance {
    final i = _instance;
    if (i == null) {
      throw StateError(
        'Call AudioPlayerService.init() before accessing instance.',
      );
    }
    return i;
  }

  /// Registers background playback + system media controls.
  static Future<void> init() async {
    if (_instance != null) return;

    if (kIsWeb) {
      _instance = AudioPlayerService._(ZenAudioHandler());
      return;
    }

    final handler = ZenAudioHandler();
    await AudioService.init(
      builder: () => handler,
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.player.zen_video_player.audio',
        androidNotificationChannelName: 'Audio playback',
        androidStopForegroundOnPause: false,
        androidNotificationClickStartsActivity: true,
        androidResumeOnClick: true,
      ),
    );
    _instance = AudioPlayerService._(handler);
  }

  final ZenAudioHandler _handler;
  final _eq = AudioEqualizerService.instance;

  AudioPlayer get _player => _handler.player;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<PlayerState>? _stateSub;

  List<AudioTrack> _queue = [];
  int _index = 0;
  bool _shuffle = false;
  bool _repeat = false;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  List<AudioTrack> get queue => List.unmodifiable(_queue);
  int get currentIndex => _index;
  bool get isPlaying => _isPlaying;
  bool get shuffle => _shuffle;
  bool get repeat => _repeat;
  Duration get position => _position;
  Duration get duration => _duration;

  AudioTrack? get currentTrack =>
      _queue.isEmpty || _index < 0 || _index >= _queue.length
          ? null
          : _queue[_index];

  bool get hasActiveTrack => currentTrack != null;

  Future<void> playQueue(
    List<AudioTrack> tracks, {
    int startIndex = 0,
  }) async {
    if (tracks.isEmpty) return;
    if (!kIsWeb && Platform.isAndroid) {
      await Permission.notification.request();
    }
    _queue = List<AudioTrack>.from(tracks);
    _index = startIndex.clamp(0, _queue.length - 1);
    _handler.syncTrackQueue(_queue);
    _handler.setQueueIndex(_index);
    await _playCurrent();
  }

  Future<void> playTrack(AudioTrack track, {List<AudioTrack>? queue}) async {
    final list = queue ?? [track];
    final idx = list.indexOf(track);
    await playQueue(list, startIndex: idx >= 0 ? idx : 0);
  }

  Future<void> _playCurrent() async {
    final track = currentTrack;
    if (track == null) return;
    try {
      final target = await AssetPlaybackResolver.resolve(track.asset);
      if (target == null) return;
      final source = target.videoSource;
      if (target.useContentUri || source.startsWith('content://')) {
        await _player.setAudioSource(AudioSource.uri(Uri.parse(source)));
      } else if (source.startsWith('file://')) {
        await _player.setAudioSource(AudioSource.uri(Uri.parse(source)));
      } else {
        await _player.setFilePath(source);
      }
      _duration = Duration(seconds: track.asset.duration);
      _handler.setQueueIndex(_index);
      unawaited(_handler.updateNowPlaying(track));
      await _player.play();
      AudioVisualizerService.instance.bindPlayer(_player, isPlaying: true);
      unawaited(_eq.reapplyAfterPlayback());
      notifyListeners();
    } catch (e, st) {
      debugPrint('[audio] play failed: $e\n$st');
    }
  }

  void _onSleepTimerExpired() {
    unawaited(stopAndClear());
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
      return;
    }
    await _resumePlayback();
  }

  /// Reloads the current track after [AudioPlayer.stop] (notification stop).
  Future<void> _resumePlayback() async {
    if (currentTrack == null) return;
    final state = _player.processingState;
    if (state == ProcessingState.idle || state == ProcessingState.completed) {
      await _playCurrent();
    } else {
      await _player.play();
    }
  }

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> skipNext() async {
    if (_queue.isEmpty) return;
    if (_shuffle) {
      _index = Random().nextInt(_queue.length);
    } else if (_index < _queue.length - 1) {
      _index++;
    } else if (_repeat) {
      _index = 0;
    } else {
      return;
    }
    _handler.setQueueIndex(_index);
    await _playCurrent();
  }

  Future<void> skipPrevious() async {
    if (_queue.isEmpty) return;
    if (_position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }
    if (_index > 0) {
      _index--;
    } else if (_repeat) {
      _index = _queue.length - 1;
    } else {
      await seek(Duration.zero);
      return;
    }
    _handler.setQueueIndex(_index);
    await _playCurrent();
  }

  void toggleShuffle() {
    _shuffle = !_shuffle;
    notifyListeners();
  }

  void toggleRepeat() {
    _repeat = !_repeat;
    notifyListeners();
  }

  Future<void> playShuffled(List<AudioTrack> tracks) async {
    if (tracks.isEmpty) return;
    final shuffled = List<AudioTrack>.from(tracks)..shuffle(Random());
    _shuffle = true;
    await playQueue(shuffled);
  }

  Future<void> stopAndClear() async {
    unawaited(AudioVisualizerService.instance.unbind());
    _queue = [];
    _index = 0;
    _position = Duration.zero;
    _duration = Duration.zero;
    _isPlaying = false;
    await _handler.stopAndDismissSession();
    notifyListeners();
  }

  /// Notification stop — stop playback but keep queue so play can resume.
  Future<void> _onSystemStop() async {
    unawaited(AudioVisualizerService.instance.unbind());
    _position = Duration.zero;
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> jumpTo(int index) async {
    if (index < 0 || index >= _queue.length) return;
    _index = index;
    _handler.setQueueIndex(_index);
    await _playCurrent();
  }

  @override
  void dispose() {
    SleepTimerService.instance.removeOnExpireListener(_onSleepTimerExpired);
    _positionSub?.cancel();
    _durationSub?.cancel();
    _stateSub?.cancel();
    _player.dispose();
    super.dispose();
  }
}

String formatDuration(Duration d) {
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$m:$s';
}
