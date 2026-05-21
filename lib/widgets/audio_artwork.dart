import 'package:flutter/material.dart';

import '../theme/zen_theme.dart';

/// Placeholder artwork for audio — [photo_manager] cannot thumbnail audio files.
class AudioArtwork extends StatelessWidget {
  const AudioArtwork({super.key, this.large = false});

  final bool large;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: large ? double.infinity : 48,
      height: large ? double.infinity : 48,
      color: ZenTheme.surfaceElevated,
      alignment: Alignment.center,
      child: Icon(
        Icons.music_note,
        size: large ? 56 : 28,
        color: ZenTheme.textSecondary,
      ),
    );
  }
}
