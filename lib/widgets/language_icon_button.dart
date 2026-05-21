import 'package:flutter/material.dart';

import '../theme/zen_theme.dart';

/// Language control shown left of search on the home screen.
class LanguageIconButton extends StatelessWidget {
  const LanguageIconButton({
    super.key,
    required this.onPressed,
    this.tooltip,
  });

  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              ZenTheme.accentBlue.withValues(alpha: 0.35),
              ZenTheme.gradientMid.withValues(alpha: 0.5),
            ],
          ),
          border: Border.all(
            color: ZenTheme.accentBlue.withValues(alpha: 0.5),
          ),
        ),
        child: const Icon(
          Icons.translate_rounded,
          color: ZenTheme.textPrimary,
          size: 20,
        ),
      ),
    );
  }
}
