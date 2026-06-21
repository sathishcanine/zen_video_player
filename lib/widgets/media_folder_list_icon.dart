import 'package:flutter/material.dart';

import '../theme/zen_palette.dart';

/// Standard folder icon for every media album row (Camera, Download, etc.).
class MediaFolderListIcon extends StatelessWidget {
  const MediaFolderListIcon({
    super.key,
    this.size = 24,
    this.muted = false,
  });

  final double size;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final color = muted
        ? context.zen.textSecondary.withValues(alpha: 0.7)
        : context.zen.textSecondary;
    return Icon(Icons.folder_outlined, color: color, size: size);
  }
}
