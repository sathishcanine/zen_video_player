import 'package:flutter/material.dart';

import '../theme/zen_theme.dart';
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

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: ZenTheme.textPrimary,
        ),
        children: [
          TextSpan(text: first, style: const TextStyle(color: ZenTheme.accentBlue)),
          TextSpan(text: rest),
        ],
      ),
    );
  }
}
