import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:zen_video_player/video/video_color_filter.dart';

/// Video layer that resizes when the device rotates.
///
/// Sizes the video using the **display** aspect ratio (decoder size plus
/// [VideoPlayerValue.rotationCorrection]), so portrait phone videos are not
/// stretched to the screen shape.
class ZenVideoSurface extends StatelessWidget {
  const ZenVideoSurface({
    super.key,
    required this.controller,
    this.colorFilter = VideoColorFilterSettings.standard,
  });

  final VideoPlayerController controller;
  final VideoColorFilterSettings colorFilter;

  /// Width/height from the decoder; [VideoPlayer] applies [rotationCorrection]
  /// via [RotatedBox]. The layout box must match the *displayed* aspect ratio.
  static double displayAspectRatio(VideoPlayerValue value) {
    final w = value.size.width;
    final h = value.size.height;
    if (!value.isInitialized || w <= 0 || h <= 0) return 1.0;
    final rot = value.rotationCorrection % 360;
    if (rot == 90 || rot == 270) return h / w;
    return w / h;
  }

  @override
  Widget build(BuildContext context) {
    final value = controller.value;
    if (!value.isInitialized ||
        value.size.width <= 0 ||
        value.size.height <= 0) {
      return const ColoredBox(color: Colors.black);
    }

    final aspectRatio = displayAspectRatio(value);

    return Center(
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: _filteredPlayer(),
      ),
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
