import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zen_video_player/app_update/force_update_screen.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';
import 'package:zen_video_player/services/play_store_rating_service.dart';
import 'package:zen_video_player/theme/zen_palette.dart';
import 'package:url_launcher/url_launcher.dart';

enum PlayStoreRatingDialogResult { rated, maybe }

/// Play Store rating prompt (not an in-app star rating).
Future<PlayStoreRatingDialogResult?> showPlayStoreRatingDialog(
  BuildContext context,
) {
  return showDialog<PlayStoreRatingDialogResult>(
    context: context,
    barrierDismissible: true,
    useRootNavigator: true,
    builder: (ctx) => const _PlayStoreRatingDialog(),
  );
}

class _PlayStoreRatingDialog extends StatefulWidget {
  const _PlayStoreRatingDialog();

  @override
  State<_PlayStoreRatingDialog> createState() => _PlayStoreRatingDialogState();
}

class _PlayStoreRatingDialogState extends State<_PlayStoreRatingDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  Future<void> _openPlayStore() async {
    final navigator = Navigator.of(context);
    await PlayStoreRatingService.markRated();
    final uri = Uri.parse(kZenVideoPlayerPlayStoreUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    if (!mounted) return;
    navigator.pop(PlayStoreRatingDialogResult.rated);
  }

  void _maybe() {
    unawaited(PlayStoreRatingService.snooze());
    Navigator.of(context).pop(PlayStoreRatingDialogResult.maybe);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final zen = context.zen;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Dialog(
      backgroundColor: zen.sheetBackground,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _shimmer,
              builder: (context, child) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 26),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFFB300),
                        primary,
                        const Color(0xFF1A1A2E),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [
                        0.0,
                        0.45 + (_shimmer.value * 0.08),
                        1.0,
                      ],
                    ),
                  ),
                  child: child,
                );
              },
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withValues(alpha: 0.45),
                          blurRadius: 28,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l10n.playStoreRatingTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3,
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
                    l10n.playStoreRatingBody,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.45,
                      color: zen.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _maybe,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(l10n.playStoreRatingMaybe),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _openPlayStore,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(l10n.playStoreRatingRateNow),
                        ),
                      ),
                    ],
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
