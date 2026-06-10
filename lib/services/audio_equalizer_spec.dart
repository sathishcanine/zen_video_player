import 'dart:math' as math;
import 'dart:ui';

import 'package:just_audio/just_audio.dart';

import 'audio_equalizer_service.dart';

/// Reference 10-band EQ from ZenEqualizer design spec (±12 dB).
abstract final class AudioEqualizerSpec {
  static const double dbRange = 12;

  /// Reference center frequencies (Hz) for preset curves.
  static const List<int> referenceFrequenciesHz = [
    60,
    170,
    310,
    600,
    1000,
    3000,
    6000,
    12000,
    14000,
    16000,
  ];

  static const Color subColor = Color(0xFFA855F7);
  static const Color bassColor = Color(0xFF3B82F6);
  static const Color midColor = Color(0xFF22D3EE);
  static const Color highColor = Color(0xFF10B981);
  static const Color airColor = Color(0xFFF59E0B);

  static const Map<EqualizerPreset, List<double>> presetCurves = {
    EqualizerPreset.normal: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    EqualizerPreset.bass: [6, 5, 4, 2, 0, 0, 0, 0, 0, 0],
    EqualizerPreset.bassTreble: [5, 4, 2, 0, 0, 0, 2, 4, 5, 6],
    EqualizerPreset.treble: [0, 0, 0, 0, 0, 2, 4, 5, 6, 6],
    EqualizerPreset.vocal: [-2, -2, 0, 2, 4, 4, 3, 1, 0, 0],
    EqualizerPreset.rock: [4, 3, 2, 0, -1, 0, 2, 3, 4, 4],
    EqualizerPreset.pop: [0, 1, 3, 4, 3, 1, 0, 0, 1, 2],
    EqualizerPreset.jazz: [2, 1, 0, 2, -1, -1, 0, 1, 2, 3],
    EqualizerPreset.classical: [3, 2, 1, 0, 0, 0, 1, 2, 3, 4],
    EqualizerPreset.hipHop: [5, 4, 3, 1, 0, -1, 0, 1, 2, 3],
    EqualizerPreset.electronic: [4, 3, 0, -2, -1, 0, 3, 4, 5, 5],
    EqualizerPreset.nightMode: [-2, -1, 0, 1, 2, 2, 1, 0, -1, -2],
  };

  static double snapDb(double db) => (db * 2).round() / 2;

  /// just_audio's Android equalizer "decibels" are actually millibels / 1000
  /// (i.e. 1 unit == 10 real dB; a ±15 dB device reports min/max as ±1.5).
  /// Convert between real dB (UI) and just_audio's native gain unit.
  static double dbToNative(double db) => db / 10.0;

  static double nativeToDb(double native) => native * 10.0;

  static Color bandColorForHz(int hz) {
    if (hz <= 80) return subColor;
    if (hz <= 400) return bassColor;
    if (hz <= 4000) return midColor;
    if (hz <= 13000) return highColor;
    return airColor;
  }

  static Color bandColorForIndex(int index, int bandCount) {
    if (bandCount == referenceFrequenciesHz.length) {
      return bandColorForType(_bandTypeForIndex(index));
    }
    final t = bandCount <= 1 ? 0.0 : index / (bandCount - 1);
    final refIndex = (t * (referenceFrequenciesHz.length - 1)).round();
    return bandColorForType(_bandTypeForIndex(refIndex));
  }

  static Color bandColorForType(String type) {
    switch (type) {
      case 'sub':
        return subColor;
      case 'bass':
        return bassColor;
      case 'mid':
        return midColor;
      case 'high':
        return highColor;
      case 'air':
        return airColor;
      default:
        return midColor;
    }
  }

  static String frequencyLabel(int hz) {
    for (final ref in referenceFrequenciesHz) {
      if ((hz - ref).abs() <= ref * 0.15) {
        return _referenceLabel(ref);
      }
    }
    if (hz >= 1000) {
      final k = hz / 1000;
      return k == k.roundToDouble() ? '${k.round()}k' : '${k.toStringAsFixed(1)}k';
    }
    return '$hz';
  }

  static String _referenceLabel(int hz) {
    if (hz >= 1000) return '${hz ~/ 1000}k';
    return '${hz}Hz';
  }

  static String _bandTypeForIndex(int index) {
    const types = [
      'sub',
      'bass',
      'bass',
      'mid',
      'mid',
      'mid',
      'high',
      'high',
      'air',
      'air',
    ];
    return types[index.clamp(0, types.length - 1)];
  }

  static List<double> mapCurveToBands(
    List<double> curve,
    List<AndroidEqualizerBand> bands,
  ) {
    if (bands.isEmpty) return const [];
    return [
      for (final band in bands)
        _gainAtFrequency(curve, band.centerFrequency),
    ];
  }

  static double _gainAtFrequency(List<double> curve, double hz) {
    const freqs = referenceFrequenciesHz;
    if (hz <= freqs.first) return curve.first;
    if (hz >= freqs.last) return curve.last;

    final logHz = math.log(hz);
    for (var i = 0; i < freqs.length - 1; i++) {
      final lo = freqs[i];
      final hi = freqs[i + 1];
      if (hz >= lo && hz <= hi) {
        final t = (logHz - math.log(lo)) / (math.log(hi) - math.log(lo));
        return curve[i] * (1 - t) + curve[i + 1] * t;
      }
    }
    return curve.last;
  }
}
