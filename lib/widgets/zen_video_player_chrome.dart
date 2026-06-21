import 'dart:async';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:video_player/video_player.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';
import 'package:zen_video_player/services/cast_service.dart';
import 'package:zen_video_player/video/video_color_filter.dart';
import 'package:zen_video_player/ads/video_pause_native_ad.dart';
import 'package:zen_video_player/services/video_player_color_tutorial_service.dart';
import 'package:zen_video_player/widgets/video_color_tutorial_coach.dart';
import 'package:zen_video_player/widgets/zen_color_filter_menu.dart';
import 'package:zen_video_player/widgets/sleep_timer_sheet.dart';

/// UPlayer-style video chrome: top bar, tool row, seek bar, transport controls.
class ZenVideoPlayerChrome extends StatefulWidget {
  const ZenVideoPlayerChrome({
    super.key,
    required this.videoController,
    required this.chewieController,
    required this.title,
    required this.onBack,
    required this.onRotate,
    required this.onCast,
    this.onDownload,
    this.onPip,
    this.showPip = false,
    this.showDownload = false,
    required this.colorFilter,
    required this.onColorFilterChanged,
    this.colorTutorialTrigger = 0,
    this.isLocalPlayback = true,
    this.resumedFrom,
    this.onResumePromptDismiss,
    this.onStartOver,
    this.onSkipPrevious,
    this.onSkipNext,
    this.canSkipToPrevious = false,
  });

  final VideoPlayerController videoController;
  final ChewieController chewieController;
  final String title;
  final VoidCallback onBack;
  final VoidCallback onRotate;
  final void Function(BuildContext context) onCast;
  final VoidCallback? onDownload;
  final VoidCallback? onPip;
  final bool showPip;
  final bool showDownload;
  final VideoColorFilterSettings colorFilter;
  final ValueChanged<VideoColorFilterSettings> onColorFilterChanged;

  /// Increment to request the post-gesture color tutorial.
  final int colorTutorialTrigger;

  /// Drives pause native ad unit (local vs network) in [VideoPauseNativeAdOverlay].
  final bool isLocalPlayback;

  /// When set, shows a brief resume prompt above the transport bar.
  final Duration? resumedFrom;
  final VoidCallback? onResumePromptDismiss;
  final VoidCallback? onStartOver;
  final VoidCallback? onSkipPrevious;
  final VoidCallback? onSkipNext;
  final bool canSkipToPrevious;

  static const double minPlaybackSpeed = 0.25;
  static const double maxPlaybackSpeed = 2.0;

  @override
  State<ZenVideoPlayerChrome> createState() => _ZenVideoPlayerChromeState();
}

class _ZenVideoPlayerChromeState extends State<ZenVideoPlayerChrome> {
  static const Duration _seekStep = Duration(seconds: 10);
  static const Duration _hideDelay = Duration(seconds: 4);
  static const Duration _speedPanelAutoCloseDelay = Duration(seconds: 3);
  static const Duration _resumeBannerDuration = Duration(seconds: 3);
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
  Timer? _resumeBannerTimer;
  Timer? _doubleTapHintTimer;
  String? _modeBannerText;
  bool _resumeBannerVisible = false;
  bool? _doubleTapHintForward;
  bool _userPausedForAd = false;
  bool _colorTutorialActive = false;
  bool _castConnected = false;
  StreamSubscription<bool>? _castConnectionSub;

  VideoPlayerController get _video => widget.videoController;
  ChewieController get _chewie => widget.chewieController;

  bool get _controllersReady {
    try {
      return _video.value.isInitialized;
    } catch (_) {
      return false;
    }
  }

  bool get _gestureExtras =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  void initState() {
    super.initState();
    _video.addListener(_onVideoTick);
    _castConnected = CastService.instance.isConnected;
    _castConnectionSub = CastService.instance.isConnectedStream.listen((connected) {
      if (!mounted || _castConnected == connected) return;
      setState(() => _castConnected = connected);
    });
    _scheduleHide();
    if (widget.resumedFrom != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showResumeBanner());
    }
  }

  @override
  void didUpdateWidget(ZenVideoPlayerChrome oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoController != widget.videoController) {
      oldWidget.videoController.removeListener(_onVideoTick);
      widget.videoController.addListener(_onVideoTick);
    }
    if (widget.colorTutorialTrigger != oldWidget.colorTutorialTrigger) {
      unawaited(_beginColorTutorialIfNeeded());
    }
    if (widget.resumedFrom != null &&
        widget.resumedFrom != oldWidget.resumedFrom) {
      _showResumeBanner();
    }
    if (widget.resumedFrom == null && oldWidget.resumedFrom != null) {
      _hideResumeBanner(notifyParent: false);
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _speedPanelTimer?.cancel();
    _modeBannerTimer?.cancel();
    _resumeBannerTimer?.cancel();
    _doubleTapHintTimer?.cancel();
    _castConnectionSub?.cancel();
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
    if (_video.value.isPlaying && _userPausedForAd) {
      _userPausedForAd = false;
    }
    if (mounted && !_scrubbing) setState(() {});
  }

  void _wakeControls() {
    _hideTimer?.cancel();
    if (!_visible) {
      setState(() => _visible = true);
    }
    if (!_locked) _scheduleHide();
  }

  void _hideControls() {
    if (_locked || _scrubbing || _scrubbingSpeed) return;
    _hideTimer?.cancel();
    if (_visible) {
      setState(() {
        _visible = false;
        _speedPanelOpen = false;
        _colorMenuOpen = false;
      });
    }
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

  Future<void> _doubleTapSeek({required bool forward}) async {
    if (_chewie.isLive) return;
    await _seekRelative(forward ? _seekStep : -_seekStep);
    _showDoubleTapHint(forward);
  }

  void _showDoubleTapHint(bool forward) {
    _doubleTapHintTimer?.cancel();
    setState(() => _doubleTapHintForward = forward);
    _doubleTapHintTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() => _doubleTapHintForward = null);
    });
  }

  void _toggleControls() {
    if (_locked || _speedPanelOpen || _colorMenuOpen) return;
    if (_visible) {
      _hideControls();
    } else {
      _wakeControls();
    }
  }

  void _onDoubleTapSeekDown(TapDownDetails details) {
    if (_chewie.isLive) return;
    final w = MediaQuery.sizeOf(context).width;
    final forward = details.globalPosition.dx >= w / 2;
    unawaited(_doubleTapSeek(forward: forward));
  }

  Widget _doubleTapSeekHint() {
    final forward = _doubleTapHintForward;
    if (forward == null) return const SizedBox.shrink();
    return IgnorePointer(
      child: Align(
        alignment: forward ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Material(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    forward ? Icons.forward_10 : Icons.replay_10,
                    color: Colors.white,
                    size: 42,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    forward ? '+10 s' : '-10 s',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _togglePlayPause() async {
    if (!_controllersReady) return;
    try {
      if (_video.value.isPlaying) {
        await _video.pause();
        if (mounted) setState(() => _userPausedForAd = true);
      } else {
        await _video.play();
        if (mounted) {
          setState(() => _userPausedForAd = false);
        }
      }
    } catch (e, st) {
      debugPrint('[chrome] play/pause failed: $e\n$st');
      return;
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
    setState(() {
      _colorMenuOpen = false;
      _colorTutorialActive = false;
    });
    _scheduleHide();
  }

  Future<void> _beginColorTutorialIfNeeded() async {
    if (_colorTutorialActive) return;
    if (await VideoPlayerColorTutorialService.wasSeen()) return;
    if (!mounted) return;
    setState(() {
      _colorTutorialActive = true;
      _colorMenuOpen = true;
      _speedPanelOpen = false;
      _visible = true;
    });
    _hideTimer?.cancel();
  }

  Future<void> _dismissColorTutorial() async {
    await VideoPlayerColorTutorialService.markSeen();
    if (!mounted) return;
    setState(() => _colorTutorialActive = false);
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

  void _showResumeBanner() {
    _resumeBannerTimer?.cancel();
    setState(() => _resumeBannerVisible = true);
    _resumeBannerTimer = Timer(_resumeBannerDuration, () {
      _hideResumeBanner();
    });
  }

  void _hideResumeBanner({bool notifyParent = true, bool startOver = false}) {
    _resumeBannerTimer?.cancel();
    if (!_resumeBannerVisible) return;
    setState(() => _resumeBannerVisible = false);
    if (!notifyParent) return;
    if (startOver) {
      widget.onStartOver?.call();
    } else {
      widget.onResumePromptDismiss?.call();
    }
  }

  Widget _resumeBannerOverlay() {
    if (!_resumeBannerVisible) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 76 + bottomInset,
      child: Material(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.only(left: 2, right: 8),
          child: Row(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                tooltip: 'Dismiss',
                onPressed: () => _hideResumeBanner(),
              ),
              Expanded(
                child: Text(
                  l10n.resumePlaybackPrompt,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () => _hideResumeBanner(startOver: true),
                child: Text(
                  l10n.resumeStartOver,
                  style: const TextStyle(
                    color: Color(0xFF64B5F6),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
    if (!_hasMoreMenuItems) return;
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
            ],
          ),
        );
      },
    );
  }

  bool get _hasMoreMenuItems =>
      widget.showDownload && widget.onDownload != null;

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
            icon: Icon(
              _castConnected ? Icons.cast_connected : Icons.cast,
              color: Colors.white,
            ),
            tooltip: 'Cast',
            onPressed: () {
              _wakeControls();
              widget.onCast(context);
            },
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
            onPressed: _hasMoreMenuItems ? _showMoreMenu : null,
          ),
        ],
      ),
    );
  }

  Widget _toolRow() {
    final l10n = AppLocalizations.of(context)!;
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
            icon: _nightMode ? Icons.dark_mode : Icons.brightness_6,
            tooltip: _nightMode ? 'Normal mode' : 'Night mode',
            onTap: () => unawaited(_toggleNightMode()),
          ),
          _toolIcon(
            icon: Icons.timer_outlined,
            tooltip: l10n.sleepTimerTitle,
            onTap: () => unawaited(showSleepTimerSheet(context)),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final landscape = constraints.maxWidth > constraints.maxHeight;
        final topInset = MediaQuery.paddingOf(context).top;

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _colorTutorialActive ? null : _closeColorMenu,
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.35),
                ),
              ),
            ),
            if (_colorTutorialActive)
              Positioned(
                left: 16,
                right: 16,
                top: landscape ? topInset + 72 : topInset + 96,
                child: VideoColorTutorialCoach(
                  landscape: landscape,
                  onDismiss: () => unawaited(_dismissColorTutorial()),
                ),
              ),
            Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  12,
                  _colorTutorialActive ? (landscape ? 120 : 200) : 16,
                  12,
                  16,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: GestureDetector(
                    onTap: () {},
                    child: ZenColorFilterMenu(
                      initial: widget.colorFilter,
                      onApply: _applyColorFilter,
                      onClose: _colorTutorialActive
                          ? () => unawaited(_dismissColorTutorial())
                          : _closeColorMenu,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
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

  static const double _transportClusterGap = 12;

  Widget _transportIconButton({
    required Widget icon,
    required String tooltip,
    VoidCallback? onPressed,
    double iconSize = 36,
  }) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      icon: icon,
      iconSize: iconSize,
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }

  Widget _centerPlayPause({required bool playing}) {
    return _transportIconButton(
      icon: Icon(
        playing ? Icons.pause : Icons.play_arrow,
        color: Colors.white,
      ),
      iconSize: 44,
      tooltip: playing ? 'Pause' : 'Play',
      onPressed: () => unawaited(_togglePlayPause()),
    );
  }

  Widget _transportCluster({required bool playing}) {
    final canPrevious = widget.onSkipPrevious != null &&
        (widget.canSkipToPrevious || _video.value.position.inSeconds > 3);
    final canNext = widget.onSkipNext != null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _transportIconButton(
          icon: const Icon(Icons.replay_10, color: Colors.white),
          tooltip: 'Back 10 seconds',
          onPressed: () => unawaited(_seekRelative(-_seekStep)),
        ),
        const SizedBox(width: _transportClusterGap),
        _transportIconButton(
          icon: Icon(
            Icons.skip_previous,
            color: canPrevious ? Colors.white : Colors.white38,
          ),
          tooltip: 'Previous',
          onPressed: canPrevious ? widget.onSkipPrevious : null,
        ),
        _transportIconButton(
          icon: Icon(
            playing ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
          ),
          iconSize: 44,
          tooltip: playing ? 'Pause' : 'Play',
          onPressed: () => unawaited(_togglePlayPause()),
        ),
        _transportIconButton(
          icon: Icon(
            Icons.skip_next,
            color: canNext ? Colors.white : Colors.white38,
          ),
          tooltip: 'Next',
          onPressed: canNext ? widget.onSkipNext : null,
        ),
        const SizedBox(width: _transportClusterGap),
        _transportIconButton(
          icon: const Icon(Icons.forward_10, color: Colors.white),
          tooltip: 'Forward 10 seconds',
          onPressed: () => unawaited(_seekRelative(_seekStep)),
        ),
      ],
    );
  }

  Widget _bottomBar() {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
        child: Row(
          children: [
            IconButton(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              icon: Icon(
                _locked ? Icons.lock : Icons.lock_open,
                color: Colors.white,
                size: 26,
              ),
              tooltip: _locked ? 'Unlock controls' : 'Lock controls',
              onPressed: _toggleLock,
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: _transportCluster(
                      playing: _video.value.isPlaying,
                    ),
                  );
                },
              ),
            ),
            if (widget.showPip && widget.onPip != null)
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                icon: const Icon(
                  Icons.picture_in_picture_alt_outlined,
                  color: Colors.white,
                  size: 26,
                ),
                tooltip: l10n.pictureInPicture,
                onPressed: () {
                  _wakeControls();
                  widget.onPip!();
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
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _toggleControls,
            onDoubleTapDown: _onDoubleTapSeekDown,
          ),
        ),
        IgnorePointer(
          ignoring: !_visible,
          child: AnimatedOpacity(
            opacity: _visible ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: Stack(
              fit: StackFit.expand,
              children: [
                const Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xB8000000),
                            Colors.transparent,
                            Colors.transparent,
                            Color(0xC7000000),
                          ],
                          stops: [0.0, 0.22, 0.62, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
                Column(
                  children: [
                    _topBar(),
                    _toolRow(),
                    const Expanded(child: IgnorePointer(child: SizedBox.expand())),
                    _progressBar(),
                    _bottomBar(),
                  ],
                ),
              ],
            ),
          ),
        ),
        IgnorePointer(
          ignoring: !_visible,
          child: AnimatedOpacity(
            opacity: _visible ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: Center(
              child: _centerPlayPause(
                playing: _video.value.isPlaying,
              ),
            ),
          ),
        ),
        if (_speedPanelOpen) _speedPanelOverlay(context),
        if (_colorMenuOpen) _colorMenuOverlay(),
        _doubleTapSeekHint(),
        _modeBannerOverlay(),
        _resumeBannerOverlay(),
        VideoPauseNativeAdOverlay(
          controller: _video,
          isLocalPlayback: widget.isLocalPlayback,
          userPausedForAd: _userPausedForAd,
        ),
      ],
    );
  }
}
