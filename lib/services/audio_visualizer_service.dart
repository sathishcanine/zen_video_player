import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import 'audio_visualizer_channel.dart';
import '../utils/safe_stream.dart';

enum AudioVisualizerMode { bars, wave, circle }

/// Real-time FFT / waveform for the now-playing visualizer (Android).
class AudioVisualizerService extends ChangeNotifier {
  AudioVisualizerService._();

  static final AudioVisualizerService instance = AudioVisualizerService._();

  static const int bandCount = 40;
  static const int wavePointCount = 64;

  AudioVisualizerMode mode = AudioVisualizerMode.bars;

  final List<double> bands = List<double>.filled(bandCount, 0.04);
  final List<double> waveform = List<double>.filled(wavePointCount, 0);

  bool hasRealData = false;
  bool _isPlaying = false;

  StreamSubscription<int?>? _sessionSub;
  StreamSubscription<Map<String, dynamic>>? _captureSub;
  AudioPlayer? _player;

  void setMode(AudioVisualizerMode next) {
    if (mode == next) return;
    mode = next;
    notifyListeners();
  }

  void cycleMode() {
    final values = AudioVisualizerMode.values;
    mode = values[(mode.index + 1) % values.length];
    notifyListeners();
  }

  void bindPlayer(AudioPlayer player, {required bool isPlaying}) {
    _isPlaying = isPlaying;
    if (!identical(_player, player)) {
      unawaited(_restartCapture(player));
    } else if (isPlaying) {
      final sessionId = player.androidAudioSessionId;
      if (sessionId != null && sessionId != 0 && !hasRealData) {
        unawaited(_tryStart(sessionId));
      }
    }
    if (!isPlaying) {
      _decayToIdle();
    }
    notifyListeners();
  }

  void setPlaying(bool playing) {
    _isPlaying = playing;
    if (!playing) {
      _decayToIdle();
    }
    notifyListeners();
  }

  Future<void> unbind() async {
    final sessionSub = _sessionSub;
    final captureSub = _captureSub;
    _sessionSub = null;
    _captureSub = null;
    _player = null;
    hasRealData = false;
    await safeCancelSubscription(sessionSub);
    await safeCancelSubscription(captureSub);
    await AudioVisualizerChannel.stop();
    _decayToIdle();
    notifyListeners();
  }

  Future<void> _restartCapture(AudioPlayer player) async {
    await safeCancelSubscription(_sessionSub);
    _sessionSub = null;
    await safeCancelSubscription(_captureSub);
    _captureSub = null;
    await AudioVisualizerChannel.stop();
    _player = player;
    hasRealData = false;

    _captureSub = AudioVisualizerChannel.events.listen(_onCapture);
    _sessionSub = player.androidAudioSessionIdStream.listen((sessionId) {
      if (sessionId != null && sessionId != 0) {
        unawaited(_tryStart(sessionId));
      }
    });

    final sessionId = player.androidAudioSessionId;
    if (sessionId != null && sessionId != 0) {
      await _tryStart(sessionId);
    }
  }

  Future<void> _tryStart(int sessionId) async {
    final ok = await AudioVisualizerChannel.start(sessionId);
    hasRealData = ok;
    notifyListeners();
  }

  void _onCapture(Map<String, dynamic> event) {
    if (!_isPlaying) return;
    final type = event['type'] as String?;
    final raw = event['data'];
    if (raw is! List) return;

    if (type == 'fft') {
      _applyFft(raw);
      hasRealData = true;
    } else if (type == 'wave') {
      _applyWaveform(raw);
      hasRealData = true;
    }
    notifyListeners();
  }

  void _applyFft(List<dynamic> mags) {
    if (mags.isEmpty) return;
    final n = mags.length;
    for (var i = 0; i < bandCount; i++) {
      final t = i / bandCount;
      // Log-spaced bins — more resolution in bass.
      final start = (math.pow(n, t) as double).floor().clamp(0, n - 1);
      final end = (math.pow(n, (i + 1) / bandCount) as double)
          .ceil()
          .clamp(start + 1, n);
      var sum = 0.0;
      for (var j = start; j < end; j++) {
        sum += (mags[j] as num).toDouble();
      }
      final avg = sum / (end - start);
      final norm = (avg / 128).clamp(0.0, 1.0);
      final target = 0.04 + norm * 0.96;
      bands[i] += (target - bands[i]) * 0.45;
    }
  }

  void _applyWaveform(List<dynamic> samples) {
    if (samples.isEmpty) return;
    final step = samples.length / wavePointCount;
    for (var i = 0; i < wavePointCount; i++) {
      final idx = (i * step).floor().clamp(0, samples.length - 1);
      final v = (samples[idx] as num).toDouble() / 128.0;
      waveform[i] += (v - waveform[i]) * 0.35;
    }
  }

  void _decayToIdle() {
    for (var i = 0; i < bandCount; i++) {
      bands[i] += (0.04 - bands[i]) * 0.2;
    }
    for (var i = 0; i < wavePointCount; i++) {
      waveform[i] += (0 - waveform[i]) * 0.2;
    }
  }
}
