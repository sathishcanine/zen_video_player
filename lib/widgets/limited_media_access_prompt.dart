import 'package:flutter/material.dart';

import '../theme/zen_palette.dart';

/// Empty-state prompt when the user granted partial (limited) media access.
class LimitedMediaAccessPrompt extends StatelessWidget {
  const LimitedMediaAccessPrompt({
    super.key,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onGrantFullAccess,
    this.settingsLabel,
    this.onOpenSettings,
    this.extraActions = const [],
  });

  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback onGrantFullAccess;
  final String? settingsLabel;
  final VoidCallback? onOpenSettings;
  final List<Widget> extraActions;

  @override
  Widget build(BuildContext context) {
    final zen = context.zen;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_shared_outlined,
              size: 56,
              color: zen.textSecondary.withValues(alpha: 0.85),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: zen.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.45,
                color: zen.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onGrantFullAccess,
                child: Text(primaryLabel),
              ),
            ),
            if (onOpenSettings != null && settingsLabel != null) ...[
              const SizedBox(height: 10),
              TextButton(
                onPressed: onOpenSettings,
                child: Text(settingsLabel!),
              ),
            ],
            ...extraActions,
          ],
        ),
      ),
    );
  }
}
