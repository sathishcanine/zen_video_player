import 'dart:async';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:video_player/video_player.dart';
import 'package:zen_video_player/video/video_color_filter.dart';
import 'package:zen_video_player/widgets/zen_color_filter_menu.dart';

/// UPlayer-style video chrome: top bar, tool row, seek bar, transport controls.
class ZenVideoPlayerChrome extends StatefulWidget {
  const ZenVideoPlayerChrome({
    super.key,
    required this.videoController,
    required this.chewieController,
    required this.title,
    required this.onBack,
    required this.onRotate,
    this.onDownload,
    this.onPip,
    this.showPip = false,
    this.showDownload = false,
    required this.colorFilter,
    required this.onColorFilterChanged,
  });

  final VideoPlayerController videoController;
  final ChewieController chewieController;
  final String title;
  final VoidCallback onBack;
  final VoidCallback onRotate;
  final VoidCallback? onDownload;
  final VoidCallback? onPip;
  final bool showPip;
  final bool showDownload;
  final VideoColorFilterSettings colorFilter;
  final ValueChanged<VideoColorFilterSettings> onColorFilterChanged;

  static const double minPlaybackSpeed = 0.25;
  static const double maxPlaybackSpeed = 2.0;

  @override
  State<ZenVideoPlayerChrome> createState() => _ZenVideoPlayerChromeState();
}

class _ZenVideoPlayerChromeState extends State<ZenVideoPlayerChrome> {
  static const Duration _seekStep = Duration(seconds: 10);
  static const Duration _hideDelay = Duration(seconds: 4);
  static const Duration _speedPanelAutoCloseDelay = Duration(seconds: 3);
  static const double _nightBrightness = 0.06;
  static const double _speedPanelMaxWidth = 300;

  bool _visible = true;
  bool _locked = false;
  bool _scrubbing = false;
  bool _scrubbingSpeed = false;
  bool _speedPanelOpen = false;
  bool _colorMenuOpen = false;
  bool _muted = false;
  double _volumeBeforeMute = 1.0;
  bool _nightMode = false;
  double? _brightnessBeforeNight;
  Timer? _hideTimer;
  Timer? _speedPanelTimer;
  Timer? _modeBannerTimer;
  String? _modeBannerText;

  VideoPlayerController get _video => widget.videoController;
  ChewieController get _chewie => widget.chewieController;

  bool get _gestureExtras =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  void initState() {
    super.initState();
    _video.addListener(_onVideoTick);
    _scheduleHide();
  }

  @override
  void didUpdateWidget(ZenVideoPlayerChrome oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoController != widget.videoController) {
      oldWidget.videoController.removeListener(_onVideoTick);
      widget.videoController.addListener(_onVideoTick);
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _speedPanelTimer?.cancel();
    _modeBannerTimer?.cancel();
    _video.removeListener(_onVideoTick);
    if (_nightMode && _gestureExtras) {
      unawaited(_restoreNormalBrightness());
    }
    super.dispose();
  }

  double _speedToProgress(double speed) {
    return ((speed - ZenVideoPlayerChrome.minPlaybackSpeed) /
            (ZenVideoPlayerChrome.maxPlaybackSpeed -
                ZenVideoPlayerChrome.minPlaybackSpeed))
        .clamp(0.0, 1.0);
  }

  double _progressToSpeed(double progress) {
    return ZenVideoPlayerChrome.minPlaybackSpeed +
        progress.clamp(0.0, 1.0) *
            (ZenVideoPlayerChrome.maxPlaybackSpeed -
                ZenVideoPlayerChrome.minPlaybackSpeed);
  }

  String _formatSpeed(double speed) {
    final rounded = (speed * 100).round() / 100;
    if ((rounded - rounded.round()).abs() < 0.01) {
      return '${rounded.toStringAsFixed(0)}x';
    }
    return '${rounded.toStringAsFixed(2)}x';
  }

  void _onVideoTick() {
    if (mounted && !_scrubbing) setState(() {});
  }

  void _wakeControls() {
    _hideTimer?.cancel();
    if (!_visible) {
      setState(() => _visible = true);
    }
    if (!_locked) _scheduleHide();
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    if (_locked || _scrubbing || _scrubbingSpeed || _colorMenuOpen) return;
    _hideTimer = Timer(_hideDelay, () {
      if (mounted && !_locked && !_scrubbing && !_scrubbingSpeed) {
        setState(() {
          _visible = false;
          _speedPanelOpen = false;
          _colorMenuOpen = false;
        });
      }
    });
  }

  void _scheduleSpeedPanelAutoClose() {
    _speedPanelTimer?.cancel();
    _speedPanelTimer = Timer(_speedPanelAutoCloseDelay, () {
      if (mounted && _speedPanelOpen && !_scrubbingSpeed) {
        _closeSpeedPanel();
      }
    });
  }

  void _closeSpeedPanel() {
    _speedPanelTimer?.cancel();
    if (!_speedPanelOpen) return;
    setState(() => _speedPanelOpen = false);
    _scheduleHide();
  }

  void _openSpeedPanel() {
    setState(() {
      _speedPanelOpen = true;
      _visible = true;
    });
    _hideTimer?.cancel();
    _scheduleSpeedPanelAutoClose();
  }

  void _toggleLock() {
    setState(() {
      _locked = !_locked;
      if (_locked) {
        _visible = false;
        _hideTimer?.cancel();
      } else {
        _visible = true;
        _scheduleHide();
      }
    });
  }

  Future<void> _seekRelative(Duration delta) async {
    final total = _video.value.duration;
    if (total == Duration.zero) return;
    var next = _video.value.position + delta;
    if (next < Duration.zero) next = Duration.zero;
    if (next > total) next = total;
    await _video.seekTo(next);
    _wakeControls();
  }

  Future<void> _togglePlayPause() async {
    if (_video.value.isPlaying) {
      await _video.pause();
    } else {
      await _video.play();
    }
    _wakeControls();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _toggleMute() async {
    if (_muted) {
      await _video.setVolume(_volumeBeforeMute);
      setState(() => _muted = false);
    } else {
      _volumeBeforeMute = _video.value.volume;
      await _video.setVolume(0);
      setState(() => _muted = true);
    }
    _wakeControls();
  }

  Future<void> _restoreNormalBrightness() async {
    try {
      final restore = _brightnessBeforeNight ?? 0.5;
      await ScreenBrightness().setApplicationScreenBrightness(restore);
    } catch (_) {}
  }

  Future<void> _toggleNightMode() async {
    if (!_gestureExtras) {
      _showSnack('Night mode is not available on this platform.');
      return;
    }
    if (_nightMode) {
      await _restoreNormalBrightness();
      setState(() => _nightMode = false);
    } else {
      try {
        _brightnessBeforeNight = await ScreenBrightness().application;
        await ScreenBrightness()
            .setApplicationScreenBrightness(_nightBrightness);
        setState(() => _nightMode = true);
      } catch (_) {
        _showSnack('Could not change brightness.');
      }
    }
    _wakeControls();
  }

  void _toggleSpeedPanel() {
    if (_speedPanelOpen) {
      _closeSpeedPanel();
    } else {
      setState(() => _colorMenuOpen = false);
      _openSpeedPanel();
    }
  }

  void _openColorMenu() {
    setState(() {
      _colorMenuOpen = true;
      _speedPanelOpen = false;
      _visible = true;
    });
    _hideTimer?.cancel();
  }

  void _closeColorMenu() {
    setState(() => _colorMenuOpen = false);
    _scheduleHide();
  }

  void _toggleColorMenu() {
    if (_colorMenuOpen) {
      _closeColorMenu();
    } else {
      _openColorMenu();
    }
  }

  void _applyColorFilter(
    VideoColorFilterSettings settings, {
    bool announce = true,
  }) {
    widget.onColorFilterChanged(settings);
    if (announce) _showModeBanner(settings.modeBannerLabel);
  }

  void _showModeBanner(String label) {
    _modeBannerTimer?.cancel();
    setState(() => _modeBannerText = label);
    _modeBannerTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _modeBannerText = null);
    });
  }

  Widget _modeBannerOverlay() {
    final text = _modeBannerText;
    if (text == null) return const SizedBox.shrink();
    return IgnorePointer(
      child: Center(
        child: AnimatedOpacity(
          opacity: 1,
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: text.contains('Black')
                    ? Colors.pinkAccent
                    : Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _applySpeedProgress(double progress) async {
    final speed = _progressToSpeed(progress);
    await _video.setPlaybackSpeed(speed);
    if (mounted) {
      setState(() {});
      _scheduleSpeedPanelAutoClose();
    }
  }

  void _showMoreMenu() {
    _wakeControls();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showDownload && widget.onDownload != null)
                ListTile(
                  leading: const Icon(Icons.download, color: Colors.white),
                  title: const Text(
                    'Download',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    widget.onDownload!();
                  },
                ),
              if (widget.showPip && widget.onPip != null)
                ListTile(
                  leading: const Icon(
                    Icons.picture_in_picture_alt_outlined,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Picture-in-picture',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    widget.onPip!();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  static String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (h > 0) return '$h:$m:$s';
    return '$m:$s';
  }

  Widget _toolIcon({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 26),
        tooltip: tooltip,
        onPressed: () {
          _wakeControls();
          onTap();
        },
      ),
    );
  }

  Widget _topBar() {
    return SafeArea(
      bottom: false,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: widget.onBack,
            tooltip: 'Back',
          ),
          Expanded(
            child: Text(
              widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.cast, color: Colors.white),
            tooltip: 'Cast',
            onPressed: () => _showSnack('Cast is not available yet.'),
          ),
          IconButton(
            icon: const Icon(Icons.audiotrack, color: Colors.white),
            tooltip: 'Audio track',
            onPressed: () =>
                _showSnack('No alternate audio tracks for this video.'),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            tooltip: 'More',
            onPressed: _showMoreMenu,
          ),
        ],
      ),
    );
  }

  Widget _toolRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          _toolIcon(
            icon: Icons.screen_rotation,
            tooltip: 'Rotate',
            onTap: widget.onRotate,
          ),
          _toolIcon(
            icon: _muted ? Icons.volume_off : Icons.volume_up,
            tooltip: _muted ? 'Unmute' : 'Mute',
            onTap: () => unawaited(_toggleMute()),
          ),
          _toolIcon(
            icon: Icons.speed,
            tooltip: 'Playback speed',
            onTap: _toggleSpeedPanel,
          ),
          _toolIcon(
            icon: Icons.format_paint,
            tooltip: 'Color',
            onTap: _toggleColorMenu,
          ),
          _toolIcon(
            icon: Icons.subtitles,
            tooltip: 'Subtitles',
            onTap: () => _showSnack('No subtitles for this video.'),
          ),
          _toolIcon(
            icon: _nightMode ? Icons.dark_mode : Icons.brightness_6,
            tooltip: _nightMode ? 'Normal mode' : 'Night mode',
            onTap: () => unawaited(_toggleNightMode()),
          ),
        ],
      ),
    );
  }

  Widget _speedAdjustPanel() {
    final speed = _video.value.playbackSpeed;
    final progress = _speedToProgress(speed);

    return Material(
      color: Colors.black87,
      elevation: 6,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 6, 4, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Speed ${_formatSpeed(speed)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  tooltip: 'Close',
                  onPressed: _closeSpeedPanel,
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  _formatSpeed(ZenVideoPlayerChrome.minPlaybackSpeed),
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 12),
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: Colors.white,
                      overlayColor: Colors.white24,
                    ),
                    child: Slider(
                      value: progress,
                      onChangeStart: (_) {
                        _speedPanelTimer?.cancel();
                        setState(() {
                          _scrubbingSpeed = true;
                          _hideTimer?.cancel();
                        });
                      },
                      onChanged: (v) => unawaited(_applySpeedProgress(v)),
                      onChangeEnd: (_) {
                        setState(() => _scrubbingSpeed = false);
                        _scheduleSpeedPanelAutoClose();
                        _scheduleHide();
                      },
                    ),
                  ),
                ),
                Text(
                  _formatSpeed(ZenVideoPlayerChrome.maxPlaybackSpeed),
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _colorMenuOverlay() {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _closeColorMenu,
            child: ColoredBox(
              color: Colors.black.withValues(alpha: 0.35),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: () {},
              child: ZenColorFilterMenu(
                initial: widget.colorFilter,
                onApply: _applyColorFilter,
                onClose: _closeColorMenu,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Compact card under the tool row; tap outside to dismiss.
  Widget _speedPanelOverlay(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top + 108;
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _closeSpeedPanel,
            child: const SizedBox.expand(),
          ),
        ),
        Positioned(
          top: top,
          left: 0,
          right: 0,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _speedPanelMaxWidth),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () {},
                  child: _speedAdjustPanel(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _progressBar() {
    final value = _video.value;
    final duration = value.duration;
    final position = value.position;
    final totalMs = duration.inMilliseconds;
    final posMs = position.inMilliseconds;
    final progress = totalMs > 0 ? (posMs / totalMs).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.white,
              overlayColor: Colors.white24,
            ),
            child: Slider(
              value: progress,
              onChangeStart: (_) {
                setState(() {
                  _scrubbing = true;
                  _hideTimer?.cancel();
                });
              },
              onChanged: totalMs > 0
                  ? (v) {
                      final ms = (v * totalMs).round();
                      _video.seekTo(Duration(milliseconds: ms));
                    }
                  : null,
              onChangeEnd: (_) {
                setState(() => _scrubbing = false);
                _scheduleHide();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(position),
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  _formatDuration(duration),
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    final playing = _video.value.isPlaying;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                _locked ? Icons.lock : Icons.lock_open,
                color: Colors.white,
                size: 28,
              ),
              tooltip: _locked ? 'Unlock controls' : 'Lock controls',
              onPressed: _toggleLock,
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous, color: Colors.white),
                    iconSize: 36,
                    tooltip: 'Back 10 seconds',
                    onPressed: () =>
                        unawaited(_seekRelative(-_seekStep)),
                  ),
                  IconButton(
                    icon: Icon(
                      playing ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    iconSize: 48,
                    tooltip: playing ? 'Pause' : 'Play',
                    onPressed: () => unawaited(_togglePlayPause()),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next, color: Colors.white),
                    iconSize: 36,
                    tooltip: 'Forward 10 seconds',
                    onPressed: () => unawaited(_seekRelative(_seekStep)),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.fit_screen, color: Colors.white),
              iconSize: 28,
              tooltip: 'Fullscreen',
              onPressed: () {
                _wakeControls();
                _chewie.enterFullScreen();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_locked) {
      return Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {},
            ),
          ),
          Positioned(
            left: 8,
            bottom: 8,
            child: SafeArea(
              child: Material(
                color: Colors.black54,
                shape: const CircleBorder(),
                child: IconButton(
                  icon: const Icon(Icons.lock, color: Colors.white),
                  tooltip: 'Unlock',
                  onPressed: _toggleLock,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        if (!_visible && !_speedPanelOpen && !_colorMenuOpen)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _wakeControls,
            ),
          ),
        IgnorePointer(
          ignoring: !_visible,
          child: AnimatedOpacity(
            opacity: _visible ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.72),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.78),
                  ],
                  stops: const [0.0, 0.22, 0.62, 1.0],
                ),
              ),
              child: Column(
                children: [
                  _topBar(),
                  _toolRow(),
                  const Spacer(),
                  _progressBar(),
                  _bottomBar(),
                ],
              ),
            ),
          ),
        ),
        if (_speedPanelOpen) _speedPanelOverlay(context),
        if (_colorMenuOpen) _colorMenuOverlay(),
        _modeBannerOverlay(),
      ],
    );
  }
}
