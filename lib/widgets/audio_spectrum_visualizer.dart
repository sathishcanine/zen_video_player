import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../services/audio_equalizer_spec.dart';
import '../services/audio_visualizer_service.dart';

/// Real-time audio visualizer: bars, wave, or circular spectrum.
class AudioSpectrumVisualizer extends StatefulWidget {
  const AudioSpectrumVisualizer({
    super.key,
    this.gains = const [],
    required this.isPlaying,
    this.bands,
    this.waveform,
    this.mode = AudioVisualizerMode.bars,
    this.useRealData = false,
    this.onModeTap,
    this.barCount = 40,
    this.referenceBandCount = 10,
    this.height = 90,
    this.surroundArtwork = false,
  });

  final List<double> gains;
  final bool isPlaying;
  final List<double>? bands;
  final List<double>? waveform;
  final AudioVisualizerMode mode;
  final bool useRealData;
  final VoidCallback? onModeTap;
  final int barCount;
  final int referenceBandCount;
  final double height;
  final bool surroundArtwork;

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
  double _beatPhase = 0;

  @override
  void initState() {
    super.initState();
    final rng = math.Random(42);
    _bars = List.generate(widget.barCount, (i) {
      return _SpectrumBar(
        phase: rng.nextDouble() * math.pi * 2,
        speed: 0.03 + rng.nextDouble() * 0.04,
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
    if (widget.isPlaying && !widget.useRealData) {
      _beatPhase += 0.11;
    }
    setState(() {});
  }

  double _gainForBar(int bandIndex) {
    if (widget.gains.isEmpty) return 0;
    final idx = bandIndex.clamp(0, widget.gains.length - 1);
    return widget.gains[idx];
  }

  double _simulatedBand(int index) {
    final gain = _gainForBar(
      (index / widget.barCount * widget.referenceBandCount).floor(),
    );
    final base = (gain + AudioEqualizerSpec.dbRange) /
        (AudioEqualizerSpec.dbRange * 2);
    final bar = _bars[index];
    bar.phase += bar.speed;
    final bassBoost = index < widget.barCount * 0.25 ? 1.25 : 1.0;
    final beat = math.sin(_beatPhase) * 0.5 + 0.5;
    final beat2 = math.sin(_beatPhase * 2.3 + 0.5) * 0.35 + 0.35;
    final wave = math.sin(bar.phase) * 0.5 + 0.5;
    return math.max(
      0.04,
      (base * 0.35 + wave * 0.25 + beat * 0.22 + beat2 * 0.18) * bassBoost,
    );
  }

  List<double> _resolvedBands() {
    if (widget.useRealData && widget.bands != null && widget.bands!.isNotEmpty) {
      return widget.bands!;
    }
    return List.generate(widget.barCount, _simulatedBand);
  }

  List<double> _resolvedWaveform() {
    if (widget.useRealData &&
        widget.waveform != null &&
        widget.waveform!.isNotEmpty) {
      return widget.waveform!;
    }
    final pts = widget.barCount;
    return List.generate(pts, (i) {
      final t = i / pts * math.pi * 4 + _beatPhase * 2;
      return math.sin(t) * 0.35 + math.sin(t * 2.1 + 1) * 0.2;
    });
  }

  @override
  Widget build(BuildContext context) {
    final child = CustomPaint(
      painter: _ReactivePainter(
        mode: widget.mode,
        bands: _resolvedBands(),
        waveform: _resolvedWaveform(),
        isPlaying: widget.isPlaying,
        barCount: widget.barCount,
        referenceBandCount: widget.referenceBandCount,
        bars: _bars,
        gainForBar: _gainForBar,
        surroundArtwork: widget.surroundArtwork,
      ),
      child: SizedBox(
        height: widget.height,
        width: widget.surroundArtwork ? widget.height : double.infinity,
      ),
    );

    if (widget.onModeTap == null) return child;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onModeTap,
      child: child,
    );
  }
}

class _ReactivePainter extends CustomPainter {
  _ReactivePainter({
    required this.mode,
    required this.bands,
    required this.waveform,
    required this.isPlaying,
    required this.barCount,
    required this.referenceBandCount,
    required this.bars,
    required this.gainForBar,
    this.surroundArtwork = false,
  });

  final AudioVisualizerMode mode;
  final List<double> bands;
  final List<double> waveform;
  final bool isPlaying;
  final int barCount;
  final int referenceBandCount;
  final List<_SpectrumBar> bars;
  final double Function(int bandIndex) gainForBar;
  final bool surroundArtwork;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    if (surroundArtwork) {
      switch (mode) {
        case AudioVisualizerMode.bars:
          _paintRadialBars(canvas, size);
        case AudioVisualizerMode.wave:
          _paintRadialWave(canvas, size);
        case AudioVisualizerMode.circle:
          _paintRadialCircle(canvas, size);
      }
      return;
    }
    switch (mode) {
      case AudioVisualizerMode.bars:
        _paintBars(canvas, size);
      case AudioVisualizerMode.wave:
        _paintWave(canvas, size);
      case AudioVisualizerMode.circle:
        _paintCircle(canvas, size);
    }
  }

  void _paintBars(Canvas canvas, Size size) {
    final count = math.min(bands.length, barCount);
    final barW = size.width / count;
    for (var i = 0; i < count; i++) {
      final target = isPlaying ? bands[i].clamp(0.04, 1.0) : 0.04;
      final bar = bars[i % bars.length];
      bar.height += (target - bar.height) * 0.28;

      final x = i * barW + 1;
      final bh = bar.height * size.height * 0.92;
      final y = size.height - bh;
      final bandIndex =
          (i / count * referenceBandCount).floor().clamp(0, referenceBandCount - 1);
      final color = AudioEqualizerSpec.bandColorForIndex(
        bandIndex,
        AudioEqualizerSpec.referenceFrequenciesHz.length,
      );

      final rrect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y, barW - 2, bh),
        topLeft: Radius.circular(math.min(3, barW / 2 - 0.5)),
        topRight: Radius.circular(math.min(3, barW / 2 - 0.5)),
      );
      canvas.drawRRect(
        rrect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: 0.9),
              color.withValues(alpha: 0.18),
            ],
          ).createShader(rrect.outerRect),
      );
    }
  }

  void _paintWave(Canvas canvas, Size size) {
    final pts = waveform;
    if (pts.isEmpty) return;
    final path = Path();
    final midY = size.height * 0.5;
    final amp = size.height * 0.42 * (isPlaying ? 1.0 : 0.15);
    for (var i = 0; i < pts.length; i++) {
      final x = i / (pts.length - 1) * size.width;
      final y = midY - pts[i].clamp(-1.0, 1.0) * amp;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final waveRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: [
          AudioEqualizerSpec.bassColor.withValues(alpha: 0.95),
          AudioEqualizerSpec.midColor.withValues(alpha: 0.95),
          AudioEqualizerSpec.highColor.withValues(alpha: 0.95),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(waveRect);
    canvas.drawPath(path, paint);

    final fill = Path()
      ..addPath(path, Offset.zero)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AudioEqualizerSpec.midColor.withValues(alpha: 0.35),
            const Color(0x00000000),
          ],
        ).createShader(Rect.fromLTWH(0, midY, size.width, size.height - midY)),
    );
  }

  void _paintCircle(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.55);
    final maxR = math.min(size.width, size.height) * 0.42;
    final minR = maxR * 0.55;
    final count = math.min(bands.length, barCount);
    for (var i = 0; i < count; i++) {
      final angle = (i / count) * math.pi * 2 - math.pi / 2;
      final level = isPlaying ? bands[i].clamp(0.04, 1.0) : 0.04;
      final outer = minR + (maxR - minR) * level;
      final inner = minR * 0.92;
      final bandIndex =
          (i / count * referenceBandCount).floor().clamp(0, referenceBandCount - 1);
      final color = AudioEqualizerSpec.bandColorForIndex(
        bandIndex,
        AudioEqualizerSpec.referenceFrequenciesHz.length,
      );

      final ox = center.dx + math.cos(angle) * outer;
      final oy = center.dy + math.sin(angle) * outer;
      final ix = center.dx + math.cos(angle) * inner;
      final iy = center.dy + math.sin(angle) * inner;

      canvas.drawLine(
        Offset(ix, iy),
        Offset(ox, oy),
        Paint()
          ..strokeWidth = math.max(2.0, size.width / count * 0.55)
          ..strokeCap = StrokeCap.round
          ..color = color.withValues(alpha: 0.85),
      );
    }

    canvas.drawCircle(
      center,
      minR * 0.88,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0x44FFFFFF),
    );
  }

  void _paintRadialBars(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final innerR = size.width * 0.34;
    final maxLen = size.width * 0.13;
    final count = math.min(bands.length, barCount);
    for (var i = 0; i < count; i++) {
      final angle = (i / count) * math.pi * 2 - math.pi / 2;
      final target = isPlaying ? bands[i].clamp(0.04, 1.0) : 0.04;
      final bar = bars[i % bars.length];
      bar.height += (target - bar.height) * 0.28;
      final outerR = innerR + bar.height * maxLen;
      final bandIndex = (i / count * referenceBandCount)
          .floor()
          .clamp(0, referenceBandCount - 1);
      final color = AudioEqualizerSpec.bandColorForIndex(
        bandIndex,
        AudioEqualizerSpec.referenceFrequenciesHz.length,
      );
      final inner = Offset(
        center.dx + math.cos(angle) * innerR,
        center.dy + math.sin(angle) * innerR,
      );
      final outer = Offset(
        center.dx + math.cos(angle) * outerR,
        center.dy + math.sin(angle) * outerR,
      );
      canvas.drawLine(
        inner,
        outer,
        Paint()
          ..strokeWidth = math.max(2.5, size.width / count * 0.42)
          ..strokeCap = StrokeCap.round
          ..color = color.withValues(alpha: 0.9),
      );
    }
  }

  void _paintRadialWave(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final baseR = size.width * 0.36;
    final amp = size.width * 0.1 * (isPlaying ? 1.0 : 0.2);
    final pts = waveform;
    if (pts.isEmpty) return;

    final path = Path();
    for (var i = 0; i <= pts.length; i++) {
      final sample = pts[i % pts.length].clamp(-1.0, 1.0);
      final angle = (i / pts.length) * math.pi * 2 - math.pi / 2;
      final r = baseR + sample * amp;
      final point = Offset(
        center.dx + math.cos(angle) * r,
        center.dy + math.sin(angle) * r,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round
        ..color = AudioEqualizerSpec.midColor.withValues(alpha: 0.9),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = AudioEqualizerSpec.bassColor.withValues(alpha: 0.55),
    );
  }

  void _paintRadialCircle(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final innerR = size.width * 0.34;
    final maxLen = size.width * 0.12;
    final count = math.min(bands.length, barCount);
    for (var i = 0; i < count; i++) {
      final angle = (i / count) * math.pi * 2 - math.pi / 2;
      final level = isPlaying ? bands[i].clamp(0.04, 1.0) : 0.04;
      final outerR = innerR + level * maxLen;
      final bandIndex = (i / count * referenceBandCount)
          .floor()
          .clamp(0, referenceBandCount - 1);
      final color = AudioEqualizerSpec.bandColorForIndex(
        bandIndex,
        AudioEqualizerSpec.referenceFrequenciesHz.length,
      );
      canvas.drawLine(
        Offset(
          center.dx + math.cos(angle) * innerR,
          center.dy + math.sin(angle) * innerR,
        ),
        Offset(
          center.dx + math.cos(angle) * outerR,
          center.dy + math.sin(angle) * outerR,
        ),
        Paint()
          ..strokeWidth = math.max(2.0, size.width / count * 0.38)
          ..strokeCap = StrokeCap.round
          ..color = color.withValues(alpha: 0.85),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ReactivePainter oldDelegate) {
    return oldDelegate.mode != mode ||
        oldDelegate.isPlaying != isPlaying ||
        oldDelegate.bands != bands ||
        oldDelegate.waveform != waveform ||
        oldDelegate.surroundArtwork != surroundArtwork;
  }
}
