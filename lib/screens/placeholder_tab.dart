import 'package:flutter/material.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';

import '../theme/zen_theme.dart';

/// Placeholder until Audio / Settings specs are provided.
class PlaceholderTab extends StatelessWidget {
  const PlaceholderTab({super.key, required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hourglass_empty,
              size: 48,
              color: ZenTheme.textSecondary.withValues(alpha: .6),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.comingSoon,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ZenTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: const TextStyle(color: ZenTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
