import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preset equalizer curves (5 reference bands, interpolated per device).
enum EqualizerPreset {
  normal,
  rock,
  pop,
  jazz,
  classical,
  bass,
  treble,
  vocal,
  electronic,
  custom,
}

/// Manages Android system equalizer + loudness enhancer for [AudioPlayerService].
class AudioEqualizerService extends ChangeNotifier {
  AudioEqualizerService._();

  static final AudioEqualizerService instance = AudioEqualizerService._();

  static const _prefsKey = 'audio_equalizer_v1';

  final AndroidEqualizer equalizer = AndroidEqualizer();
  final AndroidLoudnessEnhancer loudnessEnhancer = AndroidLoudnessEnhancer();

  AudioPipeline get pipeline => AudioPipeline(
        androidAudioEffects: [loudnessEnhancer, equalizer],
      );

  bool get isSupported => !kIsWeb && Platform.isAndroid;

  bool _enabled = false;
  bool _loaded = false;
  EqualizerPreset _preset = EqualizerPreset.normal;
  double _bassBoost = 0;
  List<double> _customGains = const [];

  bool get enabled => _enabled;
  EqualizerPreset get preset => _preset;
  double get bassBoost => _bassBoost;

  static const Map<EqualizerPreset, List<double>> _presetCurves = {
    EqualizerPreset.normal: [0, 0, 0, 0, 0],
    EqualizerPreset.rock: [4, 2, -1, 2, 4],
    EqualizerPreset.pop: [-1, 2, 4, 2, -1],
    EqualizerPreset.jazz: [3, 2, 0, 2, 3],
    EqualizerPreset.classical: [3, 2, -1, 2, 3],
    EqualizerPreset.bass: [6, 4, 1, 0, 0],
    EqualizerPreset.treble: [0, 0, 1, 4, 6],
    EqualizerPreset.vocal: [-2, -1, 3, 4, 2],
    EqualizerPreset.electronic: [4, 3, 0, 3, 5],
  };

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    _loaded = true;
    if (!isSupported) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return;
      final j = jsonDecode(raw) as Map<String, dynamic>;
      _enabled = j['enabled'] as bool? ?? false;
      _bassBoost = (j['bassBoost'] as num?)?.toDouble() ?? 0;
      final presetName = j['preset'] as String? ?? 'normal';
      _preset = EqualizerPreset.values.firstWhere(
        (p) => p.name == presetName,
        orElse: () => EqualizerPreset.normal,
      );
      final gains = (j['customGains'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList();
      if (gains != null) _customGains = gains;

      await _applyToDevice(restoreOnly: true);
    } catch (e, st) {
      debugPrint('[eq] load failed: $e\n$st');
    }
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    if (!isSupported) {
      notifyListeners();
      return;
    }
    await equalizer.setEnabled(value);
    await loudnessEnhancer.setEnabled(value && _bassBoost > 0);
    await _persist();
    notifyListeners();
  }

  Future<void> applyPreset(EqualizerPreset preset) async {
    _preset = preset;
    if (!isSupported) {
      notifyListeners();
      return;
    }
    final params = await equalizer.parameters;
    final curve = _presetCurves[preset] ?? _presetCurves[EqualizerPreset.normal]!;
    final gains = _interpolateCurve(curve, params.bands.length);
    for (var i = 0; i < params.bands.length; i++) {
      await params.bands[i].setGain(gains[i]);
    }
    _customGains = gains;
    if (!_enabled) {
      await setEnabled(true);
    } else {
      await _persist();
      notifyListeners();
    }
  }

  Future<void> setBandGain(int index, double gain) async {
    if (!isSupported) return;
    final params = await equalizer.parameters;
    if (index < 0 || index >= params.bands.length) return;
    await params.bands[index].setGain(gain);
    _preset = EqualizerPreset.custom;
    _customGains = [for (final b in params.bands) b.gain];
    await _persist();
    notifyListeners();
  }

  Future<void> setBassBoost(double value) async {
    _bassBoost = value.clamp(0.0, 1.0);
    if (!isSupported) {
      notifyListeners();
      return;
    }
    final targetGain = _bassBoost * 0.8;
    await loudnessEnhancer.setTargetGain(targetGain);
    await loudnessEnhancer.setEnabled(_enabled && _bassBoost > 0.01);
    await _persist();
    notifyListeners();
  }

  Future<void> reset() async {
    _bassBoost = 0;
    await applyPreset(EqualizerPreset.normal);
    await setBassBoost(0);
  }

  /// Re-attach gains after a new audio session starts (e.g. new track).
  Future<void> reapplyAfterPlayback() async {
    if (!isSupported) return;
    try {
      await _applyToDevice(restoreOnly: true);
      notifyListeners();
    } catch (e, st) {
      debugPrint('[eq] reapply failed: $e\n$st');
    }
  }

  Future<void> _applyToDevice({bool restoreOnly = false}) async {
    if (!isSupported) return;
    await equalizer.setEnabled(_enabled);
    if (_customGains.isNotEmpty && _preset == EqualizerPreset.custom) {
      final params = await equalizer.parameters;
      for (var i = 0; i < params.bands.length && i < _customGains.length; i++) {
        await params.bands[i].setGain(_customGains[i]);
      }
    } else if (_preset != EqualizerPreset.custom) {
      final params = await equalizer.parameters;
      final curve = _presetCurves[_preset] ?? _presetCurves[EqualizerPreset.normal]!;
      final gains = _interpolateCurve(curve, params.bands.length);
      for (var i = 0; i < params.bands.length; i++) {
        await params.bands[i].setGain(gains[i]);
      }
      _customGains = gains;
    }
    await loudnessEnhancer.setTargetGain(_bassBoost * 0.8);
    await loudnessEnhancer.setEnabled(_enabled && _bassBoost > 0.01);
    if (!restoreOnly) notifyListeners();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefsKey,
        jsonEncode({
          'enabled': _enabled,
          'preset': _preset.name,
          'bassBoost': _bassBoost,
          'customGains': _customGains,
        }),
      );
    } catch (_) {}
  }

  List<double> _interpolateCurve(List<double> curve, int bandCount) {
    if (bandCount <= 0) return const [];
    if (bandCount == curve.length) return List<double>.from(curve);
    final result = <double>[];
    for (var i = 0; i < bandCount; i++) {
      final t = bandCount == 1 ? 0.0 : i / (bandCount - 1);
      final srcIdx = t * (curve.length - 1);
      final lo = srcIdx.floor().clamp(0, curve.length - 1);
      final hi = srcIdx.ceil().clamp(0, curve.length - 1);
      final frac = srcIdx - lo;
      result.add(curve[lo] * (1 - frac) + curve[hi] * frac);
    }
    return result;
  }
}
