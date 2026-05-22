import 'package:flutter/material.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';

import '../services/media_permission_service.dart';
import '../theme/zen_theme.dart';

class MediaAccessScreen extends StatefulWidget {
  const MediaAccessScreen({
    super.key,
    required this.onComplete,
  });

  final VoidCallback onComplete;

  @override
  State<MediaAccessScreen> createState() => _MediaAccessScreenState();
}

class _MediaAccessScreenState extends State<MediaAccessScreen> {
  bool _busy = false;

  Future<void> _allow() async {
    if (_busy) return;
    setState(() => _busy = true);
    final granted = await MediaPermissionService.requestMediaAccess();
    if (!mounted) return;
    setState(() => _busy = false);
    if (granted) {
      widget.onComplete();
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.allFilesAccessRequired),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: ZenTheme.onboardingGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 2),
                _Logo(),
                const SizedBox(height: 36),
                Text(
                  l10n.accessYourMedia,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: ZenTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.mediaAccessDescription(l10n.appNameFull),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    color: ZenTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                _FeatureRow(
                  icon: Icons.play_circle_outline,
                  label: l10n.featurePlayLocal,
                ),
                const SizedBox(height: 16),
                _FeatureRow(
                  icon: Icons.manage_search_outlined,
                  label: l10n.featureBrowseFiles,
                ),
                const SizedBox(height: 16),
                _FeatureRow(
                  icon: Icons.folder_special_outlined,
                  label: l10n.featureLockPrivate,
                ),
                const Spacer(flex: 3),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _busy ? null : _allow,
                    style: FilledButton.styleFrom(
                      backgroundColor: ZenTheme.accent,
                      disabledBackgroundColor:
                          ZenTheme.accent.withValues(alpha: .5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: _busy
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            l10n.allowAccess,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: ZenTheme.gradientMid.withValues(alpha: .55),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Image.asset(
          'android/app/src/main/res/mipmap-hdpi/ic_launcher.png',
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: ZenTheme.textPrimary, size: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: ZenTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
