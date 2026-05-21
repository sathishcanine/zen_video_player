import 'package:flutter/material.dart';

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
    final primary = Theme.of(context).colorScheme.primary;
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: primary.withValues(alpha: 0.12),
          border: Border.all(color: primary.withValues(alpha: 0.45)),
        ),
        child: Icon(
          Icons.translate_rounded,
          color: primary,
          size: 20,
        ),
      ),
    );
  }
}
