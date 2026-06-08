import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';

import '../services/audio_equalizer_service.dart';
import '../services/audio_player_service.dart';
import '../theme/zen_palette.dart';
import '../theme/zen_theme.dart';

Future<void> showAudioEqualizerSheet(BuildContext context) async {
  final eq = AudioEqualizerService.instance;
  await eq.ensureLoaded();
  if (AudioPlayerService.instance.hasActiveTrack) {
    await eq.reapplyAfterPlayback();
  }
  if (!context.mounted) return;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _AudioEqualizerSheet(),
  );
}

class _AudioEqualizerSheet extends StatefulWidget {
  const _AudioEqualizerSheet();

  @override
  State<_AudioEqualizerSheet> createState() => _AudioEqualizerSheetState();
}

class _AudioEqualizerSheetState extends State<_AudioEqualizerSheet> {
  final _eq = AudioEqualizerService.instance;

  @override
  void initState() {
    super.initState();
    _eq.addListener(_onEqChanged);
    _eq.ensureLoaded();
  }

  @override
  void dispose() {
    _eq.removeListener(_onEqChanged);
    super.dispose();
  }

  void _onEqChanged() {
    if (mounted) setState(() {});
  }

  String _presetLabel(AppLocalizations l10n, EqualizerPreset p) {
    switch (p) {
      case EqualizerPreset.normal:
        return l10n.eqPresetNormal;
      case EqualizerPreset.rock:
        return l10n.eqPresetRock;
      case EqualizerPreset.pop:
        return l10n.eqPresetPop;
      case EqualizerPreset.jazz:
        return l10n.eqPresetJazz;
      case EqualizerPreset.classical:
        return l10n.eqPresetClassical;
      case EqualizerPreset.bass:
        return l10n.eqPresetBass;
      case EqualizerPreset.treble:
        return l10n.eqPresetTreble;
      case EqualizerPreset.vocal:
        return l10n.eqPresetVocal;
      case EqualizerPreset.electronic:
        return l10n.eqPresetElectronic;
      case EqualizerPreset.custom:
        return l10n.eqPresetCustom;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final zen = context.zen;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: zen.sheetBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: zen.textSecondary.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                child: Row(
                  children: [
                    Icon(Icons.graphic_eq, color: zen.textPrimary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.equalizerTitle,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: zen.textPrimary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _eq.reset(),
                      child: Text(l10n.eqReset),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      color: zen.textSecondary,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              if (!_eq.isSupported)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    l10n.eqUnsupported,
                    style: TextStyle(color: zen.textSecondary, fontSize: 13),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      l10n.eqEnabled,
                      style: TextStyle(
                        color: zen.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Switch.adaptive(
                      value: _eq.enabled,
                      activeTrackColor: ZenTheme.accentBlue.withValues(alpha: 0.5),
                      activeThumbColor: ZenTheme.accentBlue,
                      onChanged: _eq.isSupported ? _eq.setEnabled : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    for (final p in EqualizerPreset.values)
                      if (p != EqualizerPreset.custom)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(_presetLabel(l10n, p)),
                            selected: _eq.preset == p,
                            onSelected: _eq.isSupported
                                ? (_) => _eq.applyPreset(p)
                                : null,
                            selectedColor:
                                ZenTheme.accentBlue.withValues(alpha: 0.35),
                            labelStyle: TextStyle(
                              color: _eq.preset == p
                                  ? Colors.white
                                  : zen.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            backgroundColor: zen.surfaceElevated,
                            side: BorderSide.none,
                          ),
                        ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Row(
                  children: [
                    Icon(Icons.speaker, size: 18, color: zen.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      l10n.eqBassBoost,
                      style: TextStyle(
                        color: zen.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: _eq.bassBoost,
                        min: 0,
                        max: 1,
                        activeColor: ZenTheme.accentBlue,
                        inactiveColor: zen.surfaceElevated,
                        onChanged:
                            _eq.isSupported ? _eq.setBassBoost : null,
                      ),
                    ),
                    Text(
                      '${(_eq.bassBoost * 100).round()}%',
                      style: TextStyle(
                        color: zen.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: !_eq.isSupported
                    ? Center(
                        child: Icon(
                          Icons.graphic_eq,
                          size: 72,
                          color: zen.textSecondary.withValues(alpha: 0.25),
                        ),
                      )
                    : FutureBuilder<AndroidEqualizerParameters>(
                        future: _eq.equalizer.parameters,
                        builder: (context, snapshot) {
                          final params = snapshot.data;
                          if (params == null) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return ListView(
                            controller: scrollController,
                            padding: EdgeInsets.fromLTRB(12, 8, 12, bottom + 16),
                            children: [
                              SizedBox(
                                height: 220,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    for (var i = 0; i < params.bands.length; i++)
                                      Expanded(
                                        child: _EqBandSlider(
                                          band: params.bands[i],
                                          min: params.minDecibels,
                                          max: params.maxDecibels,
                                          enabled: _eq.enabled,
                                          onChanged: (g) =>
                                              _eq.setBandGain(i, g),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EqBandSlider extends StatelessWidget {
  const _EqBandSlider({
    required this.band,
    required this.min,
    required this.max,
    required this.enabled,
    required this.onChanged,
  });

  final AndroidEqualizerBand band;
  final double min;
  final double max;
  final bool enabled;
  final ValueChanged<double> onChanged;

  String _freqLabel(int hz) {
    if (hz >= 1000) return '${(hz / 1000).toStringAsFixed(1)}k';
    return '$hz';
  }

  @override
  Widget build(BuildContext context) {
    final zen = context.zen;
    return StreamBuilder<double>(
      stream: band.gainStream,
      initialData: band.gain,
      builder: (context, snapshot) {
        final gain = snapshot.data ?? band.gain;
        final norm = max > min ? (gain - min) / (max - min) : 0.5;
        return Column(
          children: [
            Text(
              gain >= 0 ? '+${gain.toStringAsFixed(0)}' : gain.toStringAsFixed(0),
              style: TextStyle(
                fontSize: 10,
                color: enabled ? ZenTheme.accentBlue : zen.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    onVerticalDragUpdate: enabled
                        ? (d) {
                            final h = constraints.maxHeight;
                            if (h <= 0) return;
                            final delta = -d.delta.dy / h * (max - min);
                            onChanged((gain + delta).clamp(min, max));
                          }
                        : null,
                    onTapDown: enabled
                        ? (d) {
                            final h = constraints.maxHeight;
                            if (h <= 0) return;
                            final y = d.localPosition.dy.clamp(0.0, h);
                            final value = max - (y / h) * (max - min);
                            onChanged(value.clamp(min, max));
                          }
                        : null,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: zen.surfaceElevated,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          FractionallySizedBox(
                            heightFactor: norm.clamp(0.05, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    ZenTheme.accentBlue,
                                    ZenTheme.accentBlue.withValues(alpha: 0.5),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: norm.clamp(0.0, 1.0) *
                                    constraints.maxHeight -
                                6,
                            child: Container(
                              width: 18,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _freqLabel(band.centerFrequency.round()),
              style: TextStyle(
                fontSize: 10,
                color: zen.textSecondary,
              ),
            ),
          ],
        );
      },
    );
  }
}
