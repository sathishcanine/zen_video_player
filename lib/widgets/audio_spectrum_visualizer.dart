import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../services/audio_equalizer_spec.dart';

/// Animated bar spectrum driven by EQ band gains (ZenEqualizer spec).
class AudioSpectrumVisualizer extends StatefulWidget {
  const AudioSpectrumVisualizer({
    super.key,
    required this.gains,
    required this.isPlaying,
    this.barCount = 40,
    this.referenceBandCount = 10,
  });

  final List<double> gains;
  final bool isPlaying;
  final int barCount;
  final int referenceBandCount;

  @override
  State<AudioSpectrumVisualizer> createState() =>
      _AudioSpectrumVisualizerState();
}

class _SpectrumBar {
  _SpectrumBar({
    required this.phase,
    required this.speed,
    required this.bandIndex,
  });

  double height = 0.05;
  double target = 0.04;
  double phase;
  double speed;
  int bandIndex;
}

class _AudioSpectrumVisualizerState extends State<AudioSpectrumVisualizer>
    with SingleTickerProviderStateMixin {
  late final List<_SpectrumBar> _bars;
  Ticker? _ticker;

  @override
  void initState() {
    super.initState();
    final rng = math.Random(42);
    _bars = List.generate(widget.barCount, (i) {
      return _SpectrumBar(
        phase: rng.nextDouble() * math.pi * 2,
        speed: 0.02 + rng.nextDouble() * 0.03,
        bandIndex: (i / widget.barCount * widget.referenceBandCount).floor(),
      );
    });
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  void _onTick(Duration _) {
    if (!mounted) return;
    setState(() {});
  }

  double _gainForBar(int bandIndex) {
    if (widget.gains.isEmpty) return 0;
    final idx = bandIndex.clamp(0, widget.gains.length - 1);
    return widget.gains[idx];
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SpectrumPainter(
        bars: _bars,
        gains: widget.gains,
        isPlaying: widget.isPlaying,
        gainForBar: _gainForBar,
      ),
      child: const SizedBox(height: 90, width: double.infinity),
    );
  }
}

class _SpectrumPainter extends CustomPainter {
  _SpectrumPainter({
    required this.bars,
    required this.gains,
    required this.isPlaying,
    required this.gainForBar,
  });

  final List<_SpectrumBar> bars;
  final List<double> gains;
  final bool isPlaying;
  final double Function(int bandIndex) gainForBar;

  static const _dbRange = AudioEqualizerSpec.dbRange;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final barW = size.width / bars.length;
    for (var i = 0; i < bars.length; i++) {
      final bar = bars[i];
      final gain = gainForBar(bar.bandIndex);
      final base = (gain + _dbRange) / (_dbRange * 2);

      if (isPlaying) {
        bar.phase += bar.speed;
        final wave = math.sin(bar.phase) * 0.5 + 0.5;
        final wave2 = math.sin(bar.phase * 1.7 + 1) * 0.3 + 0.3;
        bar.target = math.max(0.04, base * 0.5 + wave * 0.3 + wave2 * 0.2);
      } else {
        bar.target = 0.04;
      }
      bar.height += (bar.target - bar.height) * 0.12;

      final x = i * barW + 1;
      final bh = bar.height * size.height * 0.92;
      final y = size.height - bh;
      final color = AudioEqualizerSpec.bandColorForIndex(
        bar.bandIndex,
        AudioEqualizerSpec.referenceFrequenciesHz.length,
      );

      final grad = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.87),
          color.withValues(alpha: 0.2),
        ],
      );

      final rrect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y, barW - 2, bh),
        topLeft: Radius.circular(math.min(3, barW / 2 - 0.5)),
        topRight: Radius.circular(math.min(3, barW / 2 - 0.5)),
      );
      canvas.drawRRect(
        rrect,
        Paint()..shader = grad.createShader(rrect.outerRect),
      );

      if (isPlaying && bar.height > 0.1) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y - 3, barW - 2, 2),
            const Radius.circular(1),
          ),
          Paint()..color = color,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SpectrumPainter oldDelegate) {
    return oldDelegate.isPlaying != isPlaying ||
        oldDelegate.gains != gains;
  }
}
