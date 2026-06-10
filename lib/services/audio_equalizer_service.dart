import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'audio_equalizer_spec.dart';

/// Preset equalizer curves (10 reference bands, mapped per device).
enum EqualizerPreset {
  normal,
  bass,
  bassTreble,
  treble,
  vocal,
  rock,
  pop,
  jazz,
  classical,
  hipHop,
  electronic,
  nightMode,
  custom,
}

/// Manages Android system equalizer + loudness enhancer for [AudioPlayerService].
class AudioEqualizerService extends ChangeNotifier {
  AudioEqualizerService._();

  static final AudioEqualizerService instance = AudioEqualizerService._();

  // v2: custom gains are stored in real dB (old data used mixed units).
  static const _prefsKey = 'audio_equalizer_v2';

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
  bool _loudness = false;
  bool _surround3d = false;
  /// Saved curve from manual fader adjustments (preserved across preset switches).
  List<double> _userCustomGains = const [];

  bool get enabled => _enabled;
  EqualizerPreset get preset => _preset;
  bool get hasUserCustomCurve => _userCustomGains.isNotEmpty;
  double get bassBoost => _bassBoost;
  bool get loudness => _loudness;
  bool get surround3d => _surround3d;

  static const Map<EqualizerPreset, List<double>> _presetCurves =
      AudioEqualizerSpec.presetCurves;

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
      _loudness = j['loudness'] as bool? ?? false;
      _surround3d = j['surround3d'] as bool? ?? false;
      final presetName = j['preset'] as String? ?? 'normal';
      _preset = EqualizerPreset.values.firstWhere(
        (p) => p.name == presetName,
        orElse: () => EqualizerPreset.normal,
      );
      final gains = (j['customGains'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList();
      if (gains != null) _userCustomGains = gains;

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
    await _syncLoudnessEnhancer();
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
    final gains = _gainsForPreset(preset, params.bands);
    for (var i = 0; i < params.bands.length; i++) {
      await _setBandNative(params, i, gains[i]);
    }
    if (!_enabled) {
      await setEnabled(true);
    } else {
      await _persist();
      notifyListeners();
    }
  }

  List<double> _gainsForPreset(
    EqualizerPreset preset,
    List<AndroidEqualizerBand> bands,
  ) {
    if (preset == EqualizerPreset.custom) {
      if (_userCustomGains.length == bands.length) {
        return List<double>.from(_userCustomGains);
      }
      // No saved curve yet — keep live band values so the user can tweak them.
      return [for (final b in bands) AudioEqualizerSpec.nativeToDb(b.gain)];
    }
    final curve =
        _presetCurves[preset] ?? _presetCurves[EqualizerPreset.normal]!;
    return AudioEqualizerSpec.mapCurveToBands(curve, bands);
  }

  /// Writes a real-dB gain to a band, converting to just_audio's native unit
  /// and clamping to the device-supported range.
  Future<void> _setBandNative(
    AndroidEqualizerParameters params,
    int index,
    double db,
  ) async {
    final native = AudioEqualizerSpec.dbToNative(db)
        .clamp(params.minDecibels, params.maxDecibels);
    await params.bands[index].setGain(native);
  }

  /// [gain] is in real dB (UI scale, typically ±12).
  ///
  /// Called on every drag-move event, so this path must stay cheap: skip
  /// duplicate values, debounce the prefs write, and only rebuild listeners
  /// when the preset chip actually changes (band UI updates via gainStream).
  Future<void> setBandGain(int index, double gain) async {
    if (!isSupported) return;
    final params = await equalizer.parameters;
    if (index < 0 || index >= params.bands.length) return;
    final band = params.bands[index];
    final native = AudioEqualizerSpec.dbToNative(AudioEqualizerSpec.snapDb(gain))
        .clamp(params.minDecibels, params.maxDecibels);
    final presetChanged = _preset != EqualizerPreset.custom;
    if (band.gain == native && !presetChanged) return;
    await band.setGain(native);
    _preset = EqualizerPreset.custom;
    _userCustomGains = [
      for (final b in params.bands) AudioEqualizerSpec.nativeToDb(b.gain),
    ];
    _schedulePersist();
    if (presetChanged) notifyListeners();
  }

  Timer? _persistDebounce;

  void _schedulePersist() {
    _persistDebounce?.cancel();
    _persistDebounce = Timer(const Duration(milliseconds: 500), _persist);
  }

  Future<void> setBassBoost(double value) async {
    _bassBoost = value.clamp(0.0, 1.0);
    if (!isSupported) {
      notifyListeners();
      return;
    }
    await _syncLoudnessEnhancer();
    await _persist();
    notifyListeners();
  }

  Future<void> setLoudness(bool value) async {
    _loudness = value;
    if (!isSupported) {
      notifyListeners();
      return;
    }
    await _syncLoudnessEnhancer();
    await _persist();
    notifyListeners();
  }

  Future<void> setSurround3d(bool value) async {
    _surround3d = value;
    await _persist();
    notifyListeners();
  }

  Future<void> reset() async {
    _bassBoost = 0;
    _loudness = false;
    _surround3d = false;
    await applyPreset(EqualizerPreset.normal);
    await setBassBoost(0);
    await setLoudness(false);
    await setSurround3d(false);
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
    final params = await equalizer.parameters;
    final gains = _gainsForPreset(_preset, params.bands);
    for (var i = 0; i < params.bands.length; i++) {
      await _setBandNative(params, i, gains[i]);
    }
    await _syncLoudnessEnhancer();
    if (!restoreOnly) notifyListeners();
  }

  Future<void> _syncLoudnessEnhancer() async {
    if (!isSupported) return;
    final bassGain = _bassBoost * 0.8;
    final loudnessGain = _loudness ? 0.45 : 0.0;
    final targetGain = math.max(bassGain, loudnessGain);
    await loudnessEnhancer.setTargetGain(targetGain);
    await loudnessEnhancer.setEnabled(_enabled && targetGain > 0.01);
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
          'loudness': _loudness,
          'surround3d': _surround3d,
          'customGains': _userCustomGains,
        }),
      );
    } catch (_) {}
  }

}
