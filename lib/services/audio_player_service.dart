import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../models/audio_track.dart';

/// Global audio queue + playback (mini-player and now-playing UI).
class AudioPlayerService extends ChangeNotifier {
  AudioPlayerService._() {
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
      if (s.processingState == ProcessingState.completed && _queue.isNotEmpty) {
        unawaited(skipNext());
      }
      notifyListeners();
    });
  }

  static final AudioPlayerService instance = AudioPlayerService._();

  final AudioPlayer _player = AudioPlayer();
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
    _queue = List<AudioTrack>.from(tracks);
    _index = startIndex.clamp(0, _queue.length - 1);
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
      final file = await track.asset.file;
      if (file == null) return;
      await _player.setFilePath(file.path);
      _duration = Duration(seconds: track.asset.duration);
      await _player.play();
      notifyListeners();
    } catch (e, st) {
      debugPrint('[audio] play failed: $e\n$st');
    }
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
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
    await _player.stop();
    _queue = [];
    _index = 0;
    _position = Duration.zero;
    _duration = Duration.zero;
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> jumpTo(int index) async {
    if (index < 0 || index >= _queue.length) return;
    _index = index;
    await _playCurrent();
  }

  @override
  void dispose() {
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
