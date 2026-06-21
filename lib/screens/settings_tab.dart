import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';

import '../services/app_settings_service.dart';
import '../services/pro_features_service.dart';
import '../utils/video_navigation.dart';
import '../widgets/duplicate_choose_dialog.dart';
import '../widgets/network_stream_sheet.dart';
import '../widgets/primary_color_picker_sheet.dart';
import '../widgets/pro_unlock_dialog.dart';
import '../widgets/zen_brand_title.dart';

/// Settings tab (network stream, appearance, utilities).
class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final subtitleStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
      fontSize: 13,
    );

    return ListenableBuilder(
      listenable: Listenable.merge([
        AppSettingsService.instance,
        ProFeaturesService.instance,
      ]),
      builder: (context, _) {
        final settings = AppSettingsService.instance;
        final primary = settings.primaryColor;
        final pro = ProFeaturesService.instance;
        final duplicateUnlocked = pro.isUnlocked(ProFeature.findDuplicate);
        final darkUnlocked = pro.isUnlocked(ProFeature.darkTheme);
        final colorUnlocked = pro.isUnlocked(ProFeature.primaryColor);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
              child: Row(
                children: const [
                  ZenBrandTitle(),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                children: [
                  _SettingsTile(
                    icon: Icons.link,
                    title: l10n.settingsNetworkStream,
                    subtitle: l10n.settingsNetworkStreamSubtitle,
                    onTap: () => showNetworkStreamSheet(
                      context,
                      onSubmit: (url) => VideoNavigation.openPreview(
                        context: context,
                        videoSource: url,
                      ),
                    ),
                  ),
                  _SettingsTile(
                    icon: Icons.copy_all_outlined,
                    title: l10n.settingsFindDuplicate,
                    subtitle: l10n.settingsFindDuplicateSubtitle,
                    trailing:
                        duplicateUnlocked ? null : const _ProLockChip(),
                    onTap: () => requestProFeatureAccess(
                      context,
                      feature: ProFeature.findDuplicate,
                      onUnlocked: () => showDuplicateChooseDialog(context),
                    ),
                  ),
                  const _SectionDivider(),
                  _SectionLabel(text: l10n.settingsPlayback),
                  SwitchListTile(
                    secondary: const Icon(Icons.movie_outlined),
                    title: Text(
                      l10n.settingsResumeVideo,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      l10n.settingsResumeVideoSubtitle,
                      style: subtitleStyle,
                    ),
                    value: settings.resumeVideo,
                    onChanged: settings.setResumeVideo,
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.screen_lock_portrait_outlined),
                    title: Text(
                      l10n.settingsKeepScreenOnVideo,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      l10n.settingsKeepScreenOnVideoSubtitle,
                      style: subtitleStyle,
                    ),
                    value: settings.keepScreenOnVideo,
                    onChanged: settings.setKeepScreenOnVideo,
                  ),
                  const _SectionDivider(),
                  _SectionLabel(text: l10n.settingsAppearance),
                  SwitchListTile(
                    secondary: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.dark_mode_outlined),
                        if (!darkUnlocked)
                          const Positioned(
                            right: -4,
                            top: -4,
                            child: Icon(
                              Icons.workspace_premium,
                              size: 12,
                              color: Colors.amber,
                            ),
                          ),
                      ],
                    ),
                    title: Text(
                      l10n.settingsDarkTheme,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      l10n.settingsDarkThemeSubtitle,
                      style: subtitleStyle,
                    ),
                    value: settings.isDarkTheme,
                    onChanged: (v) => requestProFeatureAccess(
                      context,
                      feature: ProFeature.darkTheme,
                      onUnlocked: () =>
                          AppSettingsService.instance.setDarkTheme(v),
                    ),
                  ),
                  ListTile(
                    leading: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.format_paint_outlined),
                        if (!colorUnlocked)
                          const Positioned(
                            right: -4,
                            top: -4,
                            child: Icon(
                              Icons.workspace_premium,
                              size: 12,
                              color: Colors.amber,
                            ),
                          ),
                      ],
                    ),
                    title: Text(
                      l10n.settingsPrimaryColor,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      l10n.settingsPrimaryColorSubtitle,
                      style: subtitleStyle,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!colorUnlocked) const _ProLockChip(),
                        Container(
                          width: 28,
                          height: 28,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    onTap: () => requestProFeatureAccess(
                      context,
                      feature: ProFeature.primaryColor,
                      onUnlocked: () => showPrimaryColorPickerSheet(context),
                    ),
                  ),
                  _AppVersionTile(subtitleStyle: subtitleStyle),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AppVersionTile extends StatelessWidget {
  const _AppVersionTile({required this.subtitleStyle});

  final TextStyle? subtitleStyle;

  static final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<PackageInfo>(
      future: _packageInfo,
      builder: (context, snapshot) {
        final info = snapshot.data;
        final version = info?.version ?? '—';
        final build = info?.buildNumber ?? '—';
        return ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text(
            l10n.settingsVersion,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text('$version ($build)', style: subtitleStyle),
        );
      },
    );
  }
}

class _ProLockChip extends StatelessWidget {
  const _ProLockChip();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
      ),
      child: Text(
        l10n.proBadge,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Colors.amber,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Divider(
        height: 1,
        color: Theme.of(context).dividerColor,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final subtitleStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
          fontSize: 13,
        );

    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: subtitleStyle),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
