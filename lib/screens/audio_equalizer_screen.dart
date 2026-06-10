import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';

import '../services/audio_equalizer_service.dart';
import '../services/audio_equalizer_spec.dart';
import '../services/audio_player_service.dart';
import '../theme/zen_palette.dart';

const _eqBackground = Color(0xFF0A1020);
const _eqCard = Color(0xFF080E1A);
const _eqCardBorder = Color(0xFF1A2540);
const _eqBorder = Color(0xFF1E293B);
const _eqLabelMuted = Color(0xFF334155);
const _eqCyan = AudioEqualizerSpec.midColor;
const _eqBlue = AudioEqualizerSpec.bassColor;
const _eqPurple = AudioEqualizerSpec.subColor;
const _eqOrange = AudioEqualizerSpec.airColor;
const _eqTextMuted = Color(0xFF64748B);

const _presetOrder = <EqualizerPreset>[
  EqualizerPreset.normal,
  EqualizerPreset.bass,
  EqualizerPreset.bassTreble,
  EqualizerPreset.treble,
  EqualizerPreset.vocal,
  EqualizerPreset.rock,
  EqualizerPreset.pop,
  EqualizerPreset.jazz,
  EqualizerPreset.classical,
  EqualizerPreset.hipHop,
  EqualizerPreset.electronic,
  EqualizerPreset.nightMode,
  EqualizerPreset.custom,
];

Future<void> openAudioEqualizer(BuildContext context) async {
  final eq = AudioEqualizerService.instance;
  await eq.ensureLoaded();
  if (AudioPlayerService.instance.hasActiveTrack) {
    await eq.reapplyAfterPlayback();
  }
  if (!context.mounted) return;
  await Navigator.of(context).push<void>(
    MaterialPageRoute(builder: (_) => const AudioEqualizerScreen()),
  );
}

class AudioEqualizerScreen extends StatefulWidget {
  const AudioEqualizerScreen({super.key});

  @override
  State<AudioEqualizerScreen> createState() => _AudioEqualizerScreenState();
}

class _AudioEqualizerScreenState extends State<AudioEqualizerScreen> {
  final _eq = AudioEqualizerService.instance;
  final _audio = AudioPlayerService.instance;
  final _scrollController = ScrollController();
  bool _faderDragging = false;
  late bool _lastIsPlaying = _audio.isPlaying;
  late bool _lastHasTrack = _audio.hasActiveTrack;

  @override
  void initState() {
    super.initState();
    _eq.addListener(_onEqChanged);
    _audio.addListener(_onAudioChanged);
    _eq.ensureLoaded();
  }

  @override
  void dispose() {
    _eq.removeListener(_onEqChanged);
    _audio.removeListener(_onAudioChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _onEqChanged() {
    if (mounted) setState(() {});
  }

  /// [AudioPlayerService] notifies on every position tick; only rebuild the
  /// EQ screen when the play state actually changes.
  void _onAudioChanged() {
    final isPlaying = _audio.isPlaying;
    final hasTrack = _audio.hasActiveTrack;
    if (isPlaying == _lastIsPlaying && hasTrack == _lastHasTrack) return;
    _lastIsPlaying = isPlaying;
    _lastHasTrack = hasTrack;
    if (mounted) setState(() {});
  }

  void _setFaderDragging(bool dragging) {
    if (_faderDragging == dragging) return;
    setState(() => _faderDragging = dragging);
  }

  String _presetLabel(AppLocalizations l10n, EqualizerPreset p) {
    switch (p) {
      case EqualizerPreset.normal:
        return l10n.eqPresetNormal;
      case EqualizerPreset.bass:
        return l10n.eqPresetBass;
      case EqualizerPreset.bassTreble:
        return l10n.eqPresetBassTreble;
      case EqualizerPreset.treble:
        return l10n.eqPresetTreble;
      case EqualizerPreset.vocal:
        return l10n.eqPresetVocal;
      case EqualizerPreset.rock:
        return l10n.eqPresetRock;
      case EqualizerPreset.pop:
        return l10n.eqPresetPop;
      case EqualizerPreset.jazz:
        return l10n.eqPresetJazz;
      case EqualizerPreset.classical:
        return l10n.eqPresetClassical;
      case EqualizerPreset.hipHop:
        return l10n.eqPresetHipHop;
      case EqualizerPreset.electronic:
        return l10n.eqPresetElectronic;
      case EqualizerPreset.nightMode:
        return l10n.eqPresetNightMode;
      case EqualizerPreset.custom:
        return l10n.eqPresetCustom;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF060B12),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0F172A), _eqBackground],
                    transform: GradientRotation(2.79),
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _eqBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.7),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: !_eq.isSupported
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: _UnsupportedBody(l10n: l10n),
                      )
                    : FutureBuilder<AndroidEqualizerParameters>(
                        future: _eq.equalizer.parameters,
                        builder: (context, snapshot) {
                          final params = snapshot.data;
                          if (params == null) {
                            return const SizedBox(
                              height: 320,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: _eqCyan,
                                ),
                              ),
                            );
                          }
                          final eqOn = _eq.enabled;
                          final isPlaying =
                              _audio.isPlaying && _audio.hasActiveTrack;
                          return ListView(
                            controller: _scrollController,
                            physics: _faderDragging
                                ? const NeverScrollableScrollPhysics()
                                : const ClampingScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(
                              14,
                              8,
                              14,
                              bottom + 16,
                            ),
                            children: [
                              _Header(
                                l10n: l10n,
                                enabled: eqOn,
                                isPlaying: isPlaying,
                                onBack: () => Navigator.pop(context),
                                onToggle: _eq.setEnabled,
                                onPlayPause: _audio.hasActiveTrack
                                    ? _audio.togglePlayPause
                                    : null,
                              ),
                              const SizedBox(height: 10),
                              _EqDisabledWrap(
                                enabled: eqOn,
                                dimOpacity: 0.3,
                                child: _EqCurveCard(
                                  bands: params.bands,
                                  enabled: eqOn,
                                ),
                              ),
                              _EqDisabledWrap(
                                enabled: eqOn,
                                dimOpacity: 0.15,
                                child: const Padding(
                                  padding: EdgeInsets.fromLTRB(4, 3, 4, 0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _DbHorizLabel('+12'),
                                      _DbHorizLabel('+6'),
                                      _DbHorizLabel('0'),
                                      _DbHorizLabel('-6'),
                                      _DbHorizLabel('-12'),
                                    ],
                                  ),
                                ),
                              ),
                              _EqDisabledWrap(
                                enabled: eqOn,
                                child: _EqBandPanel(
                                  bands: params.bands,
                                  // Device range in real dB, capped to the
                                  // ±12 dB scale the UI displays.
                                  minDb: AudioEqualizerSpec.nativeToDb(
                                    params.minDecibels,
                                  ).clamp(-AudioEqualizerSpec.dbRange, 0.0),
                                  maxDb: AudioEqualizerSpec.nativeToDb(
                                    params.maxDecibels,
                                  ).clamp(0.0, AudioEqualizerSpec.dbRange),
                                  enabled: eqOn,
                                  onBandChanged: _eq.setBandGain,
                                  onDragStateChanged: _setFaderDragging,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _EqDisabledWrap(
                                enabled: eqOn,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.eqPresets,
                                      style: const TextStyle(
                                        color: _eqLabelMuted,
                                        fontSize: 8,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    const SizedBox(height: 7),
                                    Wrap(
                                      spacing: 5,
                                      runSpacing: 5,
                                      children: [
                                        for (final p in _presetOrder)
                                          _PresetChip(
                                            label: _presetLabel(l10n, p),
                                            selected: _eq.preset == p,
                                            onTap: () => _eq.applyPreset(p),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    _BassBoostCard(
                                      label: l10n.eqBassBoost,
                                      value: _eq.bassBoost,
                                      onChanged: _eq.setBassBoost,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _FeatureToggle(
                                            label: l10n.eq3dSurround,
                                            active: _eq.surround3d,
                                            color: _eqPurple,
                                            onTap: () => _eq.setSurround3d(
                                              !_eq.surround3d,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _FeatureToggle(
                                            label: l10n.eqLoudness,
                                            active: _eq.loudness,
                                            color: _eqOrange,
                                            onTap: () =>
                                                _eq.setLoudness(!_eq.loudness),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: _eq.reset,
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: _eqTextMuted,
                                        backgroundColor: _eqCard,
                                        side: const BorderSide(
                                          color: _eqBorder,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 13,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Text(l10n.eqReset),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 2,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: eqOn
                                            ? const LinearGradient(
                                                colors: [
                                                  _eqCyan,
                                                  _eqBlue,
                                                ],
                                              )
                                            : null,
                                        color: eqOn ? null : _eqBorder,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: eqOn
                                            ? [
                                                BoxShadow(
                                                  color: _eqCyan.withValues(
                                                    alpha: 0.27,
                                                  ),
                                                  blurRadius: 20,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          onTap: () => Navigator.pop(context),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 13,
                                            ),
                                            child: Center(
                                              child: Text(
                                                eqOn
                                                    ? l10n.eqApplied
                                                    : l10n.eqOff,
                                                style: TextStyle(
                                                  color: eqOn
                                                      ? Colors.white
                                                      : _eqTextMuted,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UnsupportedBody extends StatelessWidget {
  const _UnsupportedBody({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final zen = context.zen;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.graphic_eq,
            size: 64,
            color: zen.textSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.equalizerTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.eqUnsupported,
            textAlign: TextAlign.center,
            style: TextStyle(color: zen.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _EqDisabledWrap extends StatelessWidget {
  const _EqDisabledWrap({
    required this.enabled,
    required this.child,
    this.dimOpacity = 0.35,
  });

  final bool enabled;
  final Widget child;
  final double dimOpacity;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: enabled ? 1 : dimOpacity,
      child: IgnorePointer(ignoring: !enabled, child: child),
    );
  }
}

class _DbHorizLabel extends StatelessWidget {
  const _DbHorizLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: _eqTextMuted,
        fontSize: 7.5,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.l10n,
    required this.enabled,
    required this.isPlaying,
    required this.onBack,
    required this.onToggle,
    this.onPlayPause,
  });

  final AppLocalizations l10n;
  final bool enabled;
  final bool isPlaying;
  final VoidCallback onBack;
  final ValueChanged<bool> onToggle;
  final Future<void> Function()? onPlayPause;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(2, 2, 4, 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _eqBorder)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            color: const Color(0xFF94A3B8),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: onBack,
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Text(
              l10n.equalizerTitle,
              style: const TextStyle(
                color: Color(0xFFF1F5F9),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (onPlayPause != null) ...[
            _PlayPauseButton(
              isPlaying: isPlaying,
              onTap: onPlayPause!,
            ),
            const SizedBox(width: 10),
          ],
          GestureDetector(
            onTap: () => onToggle(!enabled),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: enabled
                    ? const LinearGradient(colors: [_eqCyan, _eqBlue])
                    : null,
                color: enabled ? null : _eqBorder,
                boxShadow: enabled
                    ? [
                        BoxShadow(
                          color: _eqCyan.withValues(alpha: 0.33),
                          blurRadius: 14,
                        ),
                      ]
                    : null,
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment:
                    enabled ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 18,
                  height: 18,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: enabled ? Colors.white : const Color(0xFF475569),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({
    required this.isPlaying,
    required this.onTap,
  });

  final bool isPlaying;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPlaying
          ? _eqCyan.withValues(alpha: 0.15)
          : Colors.white.withValues(alpha: 0.05),
      shape: CircleBorder(
        side: BorderSide(
          color: isPlaying ? const Color(0x5522D3EE) : _eqBorder,
        ),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            size: 16,
            color: isPlaying ? _eqCyan : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}

class _EqCurveCard extends StatefulWidget {
  const _EqCurveCard({
    required this.bands,
    required this.enabled,
  });

  final List<AndroidEqualizerBand> bands;
  final bool enabled;

  @override
  State<_EqCurveCard> createState() => _EqCurveCardState();
}

class _EqCurveCardState extends State<_EqCurveCard> {
  final List<double> _gains = [];
  final List<StreamSubscription<double>?> _subs = [];

  @override
  void initState() {
    super.initState();
    _bindBands();
  }

  @override
  void didUpdateWidget(covariant _EqCurveCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bands != widget.bands) {
      _disposeSubs();
      _bindBands();
    }
  }

  void _bindBands() {
    _gains
      ..clear()
      ..addAll([for (final b in widget.bands) b.gain]);
    _subs
      ..clear()
      ..addAll(
        List.generate(widget.bands.length, (i) {
          return widget.bands[i].gainStream.listen((g) {
            if (!mounted) return;
            setState(() => _gains[i] = g);
          });
        }),
      );
  }

  void _disposeSubs() {
    for (final s in _subs) {
      s?.cancel();
    }
    _subs.clear();
  }

  @override
  void dispose() {
    _disposeSubs();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nativeGains = _gains.isEmpty
        ? [for (final b in widget.bands) b.gain]
        : _gains;
    // Painter works in real dB on the ±12 scale.
    final gains = [
      for (final g in nativeGains) AudioEqualizerSpec.nativeToDb(g),
    ];
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: _eqCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _eqCardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        painter: _EqCurvePainter(
          gains: gains,
          enabled: widget.enabled,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _EqCurvePainter extends CustomPainter {
  _EqCurvePainter({
    required this.gains,
    required this.enabled,
  });

  final List<double> gains;
  final bool enabled;

  double _yForDb(double db, double h) =>
      h / 2 - (db / AudioEqualizerSpec.dbRange) * (h / 2) * 0.85;

  @override
  void paint(Canvas canvas, Size size) {
    if (gains.isEmpty) return;

    for (final db in [-6, 0, 6]) {
      final y = _yForDb(db.toDouble(), size.height);
      final paint = Paint()
        ..color = db == 0
            ? const Color(0xFF334155)
            : const Color(0xFF1E293B)
        ..strokeWidth = db == 0 ? 1 : 0.5;
      if (db != 0) {
        _drawDashedLine(canvas, Offset(0, y), Offset(size.width, y), paint);
      } else {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      }
    }

    final points = <Offset>[];
    for (var i = 0; i < gains.length; i++) {
      final x = gains.length == 1
          ? size.width / 2
          : i / (gains.length - 1) * size.width;
      final y = _yForDb(gains[i], size.height);
      points.add(Offset(x, y));
    }

    final fillPath = Path()..moveTo(points.first.dx, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath
      ..lineTo(points.last.dx, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _eqCyan.withValues(alpha: enabled ? 0.4 : 0.12),
          _eqCyan.withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = enabled ? _eqCyan : Colors.white38
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final midX = (prev.dx + curr.dx) / 2;
      linePath.cubicTo(midX, prev.dy, midX, curr.dy, curr.dx, curr.dy);
    }
    canvas.drawPath(linePath, linePaint);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dash = 3.0;
    const gap = 3.0;
    final total = (end - start).distance;
    if (total <= 0) return;
    final dir = (end - start) / total;
    var drawn = 0.0;
    while (drawn < total) {
      final segEnd = drawn + dash;
      canvas.drawLine(
        start + dir * drawn,
        start + dir * segEnd.clamp(0, total),
        paint,
      );
      drawn += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _EqCurvePainter oldDelegate) {
    return oldDelegate.gains != gains || oldDelegate.enabled != enabled;
  }
}

class _EqBandPanel extends StatelessWidget {
  const _EqBandPanel({
    required this.bands,
    required this.minDb,
    required this.maxDb,
    required this.enabled,
    required this.onBandChanged,
    required this.onDragStateChanged,
  });

  final List<AndroidEqualizerBand> bands;
  final double minDb;
  final double maxDb;
  final bool enabled;
  final void Function(int index, double gain) onBandChanged;
  final ValueChanged<bool> onDragStateChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: SizedBox(
        height: 150,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < bands.length; i++)
              Expanded(
                child: _EqBandSlider(
                  band: bands[i],
                  bandIndex: i,
                  bandCount: bands.length,
                  min: minDb,
                  max: maxDb,
                  enabled: enabled,
                  onChanged: (g) => onBandChanged(i, g),
                  onDragStateChanged: onDragStateChanged,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EqBandSlider extends StatefulWidget {
  const _EqBandSlider({
    required this.band,
    required this.bandIndex,
    required this.bandCount,
    required this.min,
    required this.max,
    required this.enabled,
    required this.onChanged,
    required this.onDragStateChanged,
  });

  final AndroidEqualizerBand band;
  final int bandIndex;
  final int bandCount;
  final double min;
  final double max;
  final bool enabled;
  final ValueChanged<double> onChanged;
  final ValueChanged<bool> onDragStateChanged;

  @override
  State<_EqBandSlider> createState() => _EqBandSliderState();
}

/// Wins the gesture arena immediately on touch-down so ancestor scrollables
/// (the EQ screen's ListView) can never steal vertical drags from the fader.
class _EagerVerticalDragRecognizer extends VerticalDragGestureRecognizer {
  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }
}

class _EqBandSliderState extends State<_EqBandSlider> {
  bool _dragging = false;
  DateTime? _lastTapTime;
  Offset? _lastTapPos;

  AndroidEqualizerBand get band => widget.band;
  bool get enabled => widget.enabled;

  Color get _thumbColor => AudioEqualizerSpec.bandColorForIndex(
        widget.bandIndex,
        widget.bandCount,
      );

  double _dbToPercent(double db) =>
      ((AudioEqualizerSpec.dbRange - db) / (AudioEqualizerSpec.dbRange * 2)) *
      100;

  double _percentToDb(double pct) =>
      AudioEqualizerSpec.dbRange -
      (pct / 100) * AudioEqualizerSpec.dbRange * 2;

  void _setFromDy(double dy, double trackH) {
    if (trackH <= 0 || !enabled) return;
    final pct = (dy / trackH * 100).clamp(0.0, 100.0);
    widget.onChanged(
      AudioEqualizerSpec.snapDb(
        _percentToDb(pct).clamp(widget.min, widget.max),
      ),
    );
  }

  void _endDrag() {
    if (!_dragging) return;
    _dragging = false;
    widget.onDragStateChanged(false);
  }

  void _handleDown(DragDownDetails details, double trackH) {
    final now = DateTime.now();
    final pos = details.localPosition;
    final isDoubleTap = _lastTapTime != null &&
        _lastTapPos != null &&
        now.difference(_lastTapTime!) < const Duration(milliseconds: 300) &&
        (pos - _lastTapPos!).distance < 14;
    if (isDoubleTap) {
      widget.onChanged(0);
      _lastTapTime = null;
      _lastTapPos = null;
    } else {
      _lastTapTime = now;
      _lastTapPos = pos;
      _setFromDy(pos.dy, trackH);
    }
    _dragging = true;
    widget.onDragStateChanged(true);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
      stream: band.gainStream,
      initialData: band.gain,
      builder: (context, snapshot) {
        // Stream values are in just_audio's native unit; UI works in real dB.
        final gain =
            AudioEqualizerSpec.nativeToDb(snapshot.data ?? band.gain);
        final thumbPct = _dbToPercent(gain).clamp(0.0, 100.0);
        final snapped = AudioEqualizerSpec.snapDb(gain);
        final snappedText = snapped.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
        final display = gain > 0 ? '+$snappedText' : snappedText;
        final valueColor = gain == 0
            ? _eqLabelMuted
            : gain > 0
                ? _eqCyan
                : _eqOrange;

        return Column(
          children: [
            Text(
              display,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final trackH = constraints.maxHeight;

                  return RawGestureDetector(
                    behavior: HitTestBehavior.opaque,
                    gestures: enabled
                        ? <Type, GestureRecognizerFactory>{
                            _EagerVerticalDragRecognizer:
                                GestureRecognizerFactoryWithHandlers<
                                    _EagerVerticalDragRecognizer>(
                              () => _EagerVerticalDragRecognizer(),
                              (recognizer) {
                                recognizer.onDown =
                                    (d) => _handleDown(d, trackH);
                                recognizer.onUpdate = (d) =>
                                    _setFromDy(d.localPosition.dy, trackH);
                                recognizer.onEnd = (_) => _endDrag();
                                recognizer.onCancel = _endDrag;
                              },
                            ),
                          }
                        : const <Type, GestureRecognizerFactory>{},
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 4,
                          height: trackH,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFF0F172A),
                                Color(0xFF1E293B),
                                Color(0xFF0F172A),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 12,
                          right: 12,
                          top: gain >= 0
                              ? thumbPct / 100 * trackH
                              : trackH / 2,
                          bottom: gain < 0
                              ? (100 - thumbPct) / 100 * trackH
                              : trackH / 2,
                          child: Container(
                            width: 4,
                            color: _thumbColor.withValues(alpha: 0.7),
                          ),
                        ),
                        Positioned(
                          top: (thumbPct / 100 * trackH - 10)
                              .clamp(0.0, trackH - 20),
                          child: Container(
                            width: 22,
                            height: 20,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  _thumbColor.withValues(alpha: 0.8),
                                  _thumbColor.withValues(alpha: 0.4),
                                ],
                              ),
                              border: Border.all(
                                color: _thumbColor,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _thumbColor.withValues(alpha: 0.33),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 14,
                                height: 1.5,
                                decoration: BoxDecoration(
                                  color: _thumbColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AudioEqualizerSpec.frequencyLabel(band.centerFrequency.round()),
              style: const TextStyle(
                fontSize: 7,
                color: _eqLabelMuted,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0x1F22D3EE) : const Color(0xFF0A0F1A),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? _eqCyan : _eqBorder,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? _eqCyan : const Color(0xFF475569),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _BassBoostCard extends StatelessWidget {
  const _BassBoostCard({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        color: _eqCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _eqCardBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              Text(
                '${(value * 100).round()}%',
                style: const TextStyle(
                  color: _eqBlue,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: SliderComponentShape.noOverlay,
              activeTrackColor: _eqBlue,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
              thumbColor: _eqBlue,
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 1,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureToggle extends StatelessWidget {
  const _FeatureToggle({
    required this.label,
    required this.active,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? color.withValues(alpha: 0.09) : _eqCard,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active ? color.withValues(alpha: 0.53) : _eqBorder,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? color : _eqLabelMuted,
                ),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: active ? color : _eqLabelMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
