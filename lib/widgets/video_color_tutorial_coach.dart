import 'package:flutter/material.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';

/// Short coach card shown above the color menu on first visit.
class VideoColorTutorialCoach extends StatelessWidget {
  const VideoColorTutorialCoach({
    super.key,
    required this.onDismiss,
    required this.landscape,
  });

  final VoidCallback onDismiss;
  final bool landscape;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primary = Theme.of(context).colorScheme.primary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return Material(
      color: const Color(0xFF1E1E1E),
      elevation: 10,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          landscape ? 18 : 16,
          landscape ? 14 : 16,
          landscape ? 18 : 16,
          landscape ? 12 : 14,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.format_paint,
                  color: primary,
                  size: landscape ? 22 : 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.colorTutorialTitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: landscape ? 16 : 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: landscape ? 8 : 10),
            Text(
              l10n.colorTutorialBody,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.82),
                fontSize: landscape ? 13 : 14,
                height: 1.35,
              ),
            ),
            SizedBox(height: landscape ? 12 : 14),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: onDismiss,
                style: FilledButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: onPrimary,
                  padding: EdgeInsets.symmetric(
                    horizontal: landscape ? 22 : 26,
                    vertical: landscape ? 8 : 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  l10n.gotIt,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
