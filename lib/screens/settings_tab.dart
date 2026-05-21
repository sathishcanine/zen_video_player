import 'package:flutter/material.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';

import '../services/app_settings_service.dart';
import '../utils/video_navigation.dart';
import '../widgets/duplicate_choose_dialog.dart';
import '../widgets/network_stream_sheet.dart';
import '../widgets/primary_color_picker_sheet.dart';
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
      listenable: AppSettingsService.instance,
      builder: (context, _) {
        final settings = AppSettingsService.instance;
        final primary = settings.primaryColor;

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
                    onTap: () => showDuplicateChooseDialog(context),
                  ),
                  const _SectionDivider(),
                  _SectionLabel(text: l10n.settingsAppearance),
                  SwitchListTile(
                    secondary: const Icon(Icons.dark_mode_outlined),
                    title: Text(
                      l10n.settingsDarkTheme,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      l10n.settingsDarkThemeSubtitle,
                      style: subtitleStyle,
                    ),
                    value: settings.isDarkTheme,
                    onChanged: (v) =>
                        AppSettingsService.instance.setDarkTheme(v),
                  ),
                  ListTile(
                    leading: const Icon(Icons.format_paint_outlined),
                    title: Text(
                      l10n.settingsPrimaryColor,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      l10n.settingsPrimaryColorSubtitle,
                      style: subtitleStyle,
                    ),
                    trailing: Container(
                      width: 28,
                      height: 28,
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
                    onTap: () => showPrimaryColorPickerSheet(context),
                  ),
                ],
              ),
            ),
          ],
        );
      },
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
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

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
      onTap: onTap,
    );
  }
}
