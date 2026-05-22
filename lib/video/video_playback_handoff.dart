import 'package:video_player/video_player.dart';

/// Passes an already-initialized [VideoPlayerController] from preview to the
/// player so the same URL is not initialized twice after a rewarded ad.
class VideoPlaybackHandoff {
  VideoPlaybackHandoff._();

  static VideoPlayerController? _controller;
  static String? _source;

  static void offer(VideoPlayerController controller, String source) {
    dispose();
    _controller = controller;
    _source = source;
  }

  /// Returns a prepared controller when [source] matches; ownership transfers
  /// to the caller (player must dispose it).
  static VideoPlayerController? take(String source) {
    final c = _controller;
    final s = _source;
    if (c == null || s != source) return null;
    _controller = null;
    _source = null;
    return c;
  }

  static void dispose() {
    _controller?.dispose();
    _controller = null;
    _source = null;
  }
}
