import 'package:flutter/material.dart';

import 'package:zen_video_player/l10n/app_localizations.dart';

class ZenBrandTitle extends StatelessWidget {
  const ZenBrandTitle({super.key, this.fontSize = 20});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final name = AppLocalizations.of(context)!.appName;
    if (name.isEmpty) return const SizedBox.shrink();
    final first = name.substring(0, 1);
    final rest = name.length > 1 ? name.substring(1) : '';

    final onSurface = Theme.of(context).colorScheme.onSurface;
    final accent = Theme.of(context).colorScheme.primary;

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
        children: [
          TextSpan(text: first, style: TextStyle(color: accent)),
          TextSpan(text: rest),
        ],
      ),
    );
  }
}
