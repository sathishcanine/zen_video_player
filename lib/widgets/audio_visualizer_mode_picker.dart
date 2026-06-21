import 'package:flutter/material.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';

import '../services/audio_visualizer_service.dart';

/// Overflow (three-dot) menu with a Visualizer submenu for style selection.
class AudioNowPlayingOverflowMenu extends StatelessWidget {
  const AudioNowPlayingOverflowMenu({
    super.key,
    required this.mode,
    required this.onModeChanged,
    this.iconColor,
  });

  final AudioVisualizerMode mode;
  final ValueChanged<AudioVisualizerMode> onModeChanged;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return MenuAnchor(
      builder: (context, controller, child) {
        return IconButton(
          icon: Icon(Icons.more_vert, color: iconColor),
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
        );
      },
      menuChildren: [
        SubmenuButton(
          menuChildren: [
            _modeItem(
              context,
              value: AudioVisualizerMode.bars,
              icon: Icons.bar_chart_rounded,
              label: l10n.visualizerModeBars,
            ),
            _modeItem(
              context,
              value: AudioVisualizerMode.wave,
              icon: Icons.show_chart_rounded,
              label: l10n.visualizerModeWave,
            ),
            _modeItem(
              context,
              value: AudioVisualizerMode.circle,
              icon: Icons.donut_large_rounded,
              label: l10n.visualizerModeCircle,
            ),
          ],
          child: _menuRow(
            icon: Icons.graphic_eq_rounded,
            label: l10n.visualizer,
            trailing: const Icon(Icons.chevron_right, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _menuRow({
    required IconData icon,
    required String label,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _modeItem(
    BuildContext context, {
    required AudioVisualizerMode value,
    required IconData icon,
    required String label,
  }) {
    final selected = mode == value;
    return MenuItemButton(
      onPressed: () {
        onModeChanged(value);
        MenuController.maybeOf(context)?.close();
      },
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          if (selected) const Icon(Icons.check, size: 20),
        ],
      ),
    );
  }
}
