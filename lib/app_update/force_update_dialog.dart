import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zen_video_player/theme/zen_palette.dart';

import 'force_update_remote_config.dart';
import 'force_update_screen.dart';

/// Shows a non-dismissible update dialog on the library home when Remote Config
/// requires a newer [versionCode].
Future<void> showForceUpdateDialogIfNeeded(BuildContext context) async {
  final gate = await ForceUpdateRemoteConfig.evaluate();
  if (gate == null || !context.mounted) return;
  await showForceUpdateDialog(context, gate: gate);
}

Future<void> showForceUpdateDialog(
  BuildContext context, {
  required ForceUpdateGate gate,
}) {
  final zen = context.zen;
  final theme = Theme.of(context);
  final primary = theme.colorScheme.primary;

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (ctx) {
      return PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: zen.sheetBackground,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
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
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.14),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withValues(alpha: 0.45),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.system_update_rounded,
                          size: 44,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Update required',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'A newer Zen Video Player is available',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.88),
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
                        'This update includes important fixes and improvements. '
                        'Please install the latest version from Google Play to '
                        'keep using the app.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.45,
                          color: zen.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: zen.surfaceCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 18,
                              color: zen.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Installed build ${gate.currentVersionCode} · '
                                'Required ${gate.requiredVersionCode}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: zen.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      FilledButton.icon(
                        onPressed: () => _openPlayStore(ctx),
                        icon: const Icon(Icons.shop_rounded),
                        label: const Text('Update on Google Play'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'If the update button does not work, uninstall the old '
                        'app and install again from the store.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: zen.textSecondary.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<void> _openPlayStore(BuildContext context) async {
  final uri = Uri.parse(kZenVideoPlayerPlayStoreUrl);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
