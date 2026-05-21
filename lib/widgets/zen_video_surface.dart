import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:zen_video_player/video/video_color_filter.dart';

/// Video layer that resizes when the device rotates.
///
/// Chewie's built-in [AspectRatio] can keep a portrait box after the system
/// UI has already gone landscape; [FittedBox] tracks [LayoutBuilder] bounds.
class ZenVideoSurface extends StatelessWidget {
  const ZenVideoSurface({
    super.key,
    required this.controller,
    this.colorFilter = VideoColorFilterSettings.standard,
  });

  final VideoPlayerController controller;
  final VideoColorFilterSettings colorFilter;

  @override
  Widget build(BuildContext context) {
    final value = controller.value;
    final w = value.size.width;
    final h = value.size.height;
    if (!value.isInitialized || w <= 0 || h <= 0) {
      return const ColoredBox(color: Colors.black);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.center,
          child: SizedBox(
            width: w,
            height: h,
            child: _filteredPlayer(),
          ),
        );
      },
    );
  }

  Widget _filteredPlayer() {
    Widget child = VideoPlayer(controller);
    for (final filter in colorFilter.buildColorFilters()) {
      child = ColorFiltered(colorFilter: filter, child: child);
    }
    return child;
  }
}
