import 'package:flutter/material.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';
import 'package:zen_video_player/services/audio_equalizer_service.dart';
import 'package:zen_video_player/services/audio_equalizer_spec.dart';
import 'package:zen_video_player/theme/zen_palette.dart';
import 'package:zen_video_player/widgets/audio_spectrum_visualizer.dart';

Future<void> showEqualizerFeatureAnnounceDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    useRootNavigator: true,
    builder: (ctx) => const _EqualizerFeatureAnnounceDialog(),
  );
}

class _EqualizerFeatureAnnounceDialog extends StatelessWidget {
  const _EqualizerFeatureAnnounceDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final zen = context.zen;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final gains = AudioEqualizerSpec.presetCurves[EqualizerPreset.vocal] ??
        AudioEqualizerSpec.presetCurves[EqualizerPreset.normal]!;

    return Dialog(
      backgroundColor: zen.sheetBackground,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF5C6BC0),
                    primary,
                    const Color(0xFF1A1A2E),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                    child: const Icon(
                      Icons.graphic_eq_rounded,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.equalizerFeatureAnnounceTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.equalizerFeatureAnnounceHeadline,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 72,
                    child: AudioSpectrumVisualizer(
                      gains: gains,
                      isPlaying: true,
                      barCount: 32,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.equalizerFeatureAnnounceBody,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.45,
                      color: zen.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 22),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(l10n.equalizerFeatureAnnounceCta),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
