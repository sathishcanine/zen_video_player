import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Play listing for Zen Video Player.
const String kZenVideoPlayerPlayStoreUrl =
    'https://play.google.com/store/apps/details?id=com.player.zen_video_player';

/// Full-screen gate when a deeplink declares [latest_version] higher than
/// this build’s version code.
class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({
    super.key,
    required this.requiredVersionCode,
    required this.currentVersionCode,
  });

  final int requiredVersionCode;
  final int currentVersionCode;

  Future<void> _openStore() async {
    final uri = Uri.parse(kZenVideoPlayerPlayStoreUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Icon(Icons.system_update, size: 72, color: Colors.blue.shade300),
                const SizedBox(height: 24),
                Text(
                  'Update required',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  'A newer version of Zen Video Player is required to continue '
                  '(installed: $currentVersionCode, required: $requiredVersionCode). '
                  'Install the update from Google Play.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'If not working, Try uninstall the old one and install again',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _openStore,
                  icon: const Icon(Icons.shop),
                  label: const Text('Update on Google Play'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
