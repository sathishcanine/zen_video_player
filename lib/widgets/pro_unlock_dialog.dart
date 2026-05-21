import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';
import 'package:zen_video_player/theme/zen_palette.dart';

import '../ads/pro_unlock_rewarded.dart';
import '../ads/rewarded_loading_overlay.dart';
import '../services/pro_features_service.dart';

export '../services/pro_features_service.dart' show ProFeature;

/// Returns true if the user may proceed (already unlocked or watched ad).
Future<bool> requestProFeatureAccess(
  BuildContext context, {
  required ProFeature feature,
  required VoidCallback onUnlocked,
}) async {
  if (ProFeaturesService.instance.isUnlocked(feature)) {
    onUnlocked();
    return true;
  }

  final watch = await showProUnlockDialog(context, feature: feature);
  if (watch != true || !context.mounted) return false;

  OverlayEntry? loader;
  var loaderRemoved = false;
  void removeLoader() {
    if (loaderRemoved) return;
    loaderRemoved = true;
    loader?.remove();
  }

  final overlay = Navigator.maybeOf(context, rootNavigator: true)?.overlay;
  if (overlay != null) {
    loader = OverlayEntry(builder: (_) => const RewardedLoadingOverlay());
    overlay.insert(loader);
  }

  var earned = false;
  try {
    earned = await ProUnlockRewarded.show(
      onAdOpening: removeLoader,
      onReward: () async {
        await ProFeaturesService.instance.unlock(feature);
      },
    );
  } finally {
    removeLoader();
  }

  if (!context.mounted) return false;

  final l10n = AppLocalizations.of(context)!;
  if (earned) {
    onUnlocked();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.proUnlockSuccess(_featureName(l10n, feature))),
      ),
    );
    return true;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(l10n.proUnlockAdFailed)),
  );
  return false;
}

/// Catchy Pro gate — watch one ad to unlock a single feature.
Future<bool?> showProUnlockDialog(
  BuildContext context, {
  required ProFeature feature,
}) {
  final l10n = AppLocalizations.of(context)!;
  final zen = context.zen;
  final theme = Theme.of(context);
  final primary = theme.colorScheme.primary;
  final featureName = _featureName(l10n, feature);
  final featureIcon = _featureIcon(feature);

  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return Dialog(
        backgroundColor: zen.sheetBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primary,
                      primary.withValues(alpha: 0.65),
                      const Color(0xFF1A1A2E),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.workspace_premium,
                            size: 18,
                            color: Colors.black87,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.proBadge,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              letterSpacing: 1.2,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.proUnlockTitleFeature(featureName),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.proUnlockBodyFeature(featureName),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: zen.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: primary.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(featureIcon, size: 28, color: primary),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              featureName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: zen.textPrimary,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.lock_outline,
                            color: zen.textSecondary.withValues(alpha: 0.6),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () => Navigator.pop(ctx, true),
                      icon: const Icon(Icons.play_circle_outline),
                      label: Text(l10n.proUnlockWatchAd),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(l10n.proUnlockNotNow),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

String _featureName(AppLocalizations l10n, ProFeature feature) {
  switch (feature) {
    case ProFeature.darkTheme:
      return l10n.settingsDarkTheme;
    case ProFeature.primaryColor:
      return l10n.settingsPrimaryColor;
    case ProFeature.findDuplicate:
      return l10n.settingsFindDuplicate;
  }
}

IconData _featureIcon(ProFeature feature) {
  switch (feature) {
    case ProFeature.darkTheme:
      return Icons.dark_mode_outlined;
    case ProFeature.primaryColor:
      return Icons.format_paint_outlined;
    case ProFeature.findDuplicate:
      return Icons.copy_all_outlined;
  }
}
