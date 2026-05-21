import 'dart:async';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';

const _kGestureTutorialPrefsKey = 'video_player_gesture_tutorial_v1';

enum _HintKind { brightness, volume, seek, speed2x }

/// Wraps a [Chewie] (or fullscreen [ChewieControllerProvider]) with:
/// - **Left edge** (full height): brightness · **Right edge** (full height): volume
/// - **Bottom center** strip: hold long-press left = rewind · right = fast-forward
/// - Top-right: long-press hold for 2× speed (release restores)
/// - Pinch zoom: via [ChewieController] `zoomAndPan` + [TransformationController]
/// - First-launch gesture tutorial overlay
class VideoPlayerGestureShell extends StatefulWidget {
  const VideoPlayerGestureShell({
    super.key,
    required this.chewieController,
    required this.videoChild,
    this.onTutorialVisibilityChanged,
  });

  final ChewieController chewieController;
  final Widget videoChild;

  /// Fired when the first-launch gesture tutorial is shown or dismissed.
  final ValueChanged<bool>? onTutorialVisibilityChanged;

  @override
  State<VideoPlayerGestureShell> createState() =>
      _VideoPlayerGestureShellState();
}

class _VideoPlayerGestureShellState extends State<VideoPlayerGestureShell> {
  static const double _bottomBandFraction = 0.42;
  static const double _topSpeedBandFraction = 0.36;
  static const double _sideFlex = 22.0;
  static const double _centerFlex = 56.0;

  Timer? _hideHintTimer;
  _HintKind? _hintKind;
  String? _hintText;
  double? _hintLevel;

  double? _brightStart;
  double _dyBright = 0;

  double? _volStart;
  double _dyVol = 0;

  Timer? _seekHoldTimer;

  int? _brightnessActivePointer;
  int? _volumeActivePointer;

  double? _speedBeforeHold;

  bool _showTutorial = false;

  bool get _gesturesSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  VideoPlayerController get _video => widget.chewieController.videoPlayerController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowTutorial());
  }

  Future<void> _maybeShowTutorial() async {
    try {
      final p = await SharedPreferences.getInstance();
      if (!mounted) return;
      if (p.getBool(_kGestureTutorialPrefsKey) != true) {
        _setTutorialVisible(true);
      }
    } catch (_) {}
  }

  void _setTutorialVisible(bool visible) {
    if (_showTutorial == visible) return;
    setState(() => _showTutorial = visible);
    widget.onTutorialVisibilityChanged?.call(visible);
  }

  Future<void> _dismissTutorial() async {
    _setTutorialVisible(false);
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_kGestureTutorialPrefsKey, true);
    } catch (_) {}
  }

  @override
  void dispose() {
    _hideHintTimer?.cancel();
    _seekHoldTimer?.cancel();
    _brightnessActivePointer = null;
    _volumeActivePointer = null;
    if (_gesturesSupported) {
      unawaited(ScreenBrightness().resetApplicationScreenBrightness());
      VolumeController.instance.showSystemUI = true;
    }
    super.dispose();
  }

  void _scheduleHideHint() {
    _hideHintTimer?.cancel();
    _hideHintTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _hintKind = null;
        _hintText = null;
        _hintLevel = null;
      });
    });
  }

  double _sensitivityHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height * 0.55;

  Future<void> _primeBrightnessStart() async {
    if (!_gesturesSupported) return;
    try {
      final v = await ScreenBrightness().application;
      if (!mounted) return;
      _brightStart = v;
      await _applyBrightnessFromPrimed();
    } catch (_) {}
  }

  Future<void> _applyBrightnessFromPrimed() async {
    final start = _brightStart;
    if (!_gesturesSupported || start == null || !mounted) return;
    final sens = _sensitivityHeight(context);
    try {
      final delta = -_dyBright / sens;
      final v = (start + delta).clamp(0.0, 1.0);
      await ScreenBrightness().setApplicationScreenBrightness(v);
      if (!mounted) return;
      setState(() {
        _hintKind = _HintKind.brightness;
        _hintLevel = v;
        _hintText = '${(v * 100).round()}%';
      });
      _scheduleHideHint();
    } catch (_) {}
  }

  Future<void> _onBrightnessDelta(double dy) async {
    _dyBright += dy;
    if (!_gesturesSupported) return;
    if (_brightStart == null) return;
    await _applyBrightnessFromPrimed();
  }

  Future<void> _primeVolumeStart() async {
    if (!_gesturesSupported) return;
    try {
      final v = await VolumeController.instance.getVolume();
      if (!mounted) return;
      _volStart = v;
      await _applyVolumeFromPrimed();
    } catch (_) {}
  }

  Future<void> _applyVolumeFromPrimed() async {
    final start = _volStart;
    if (!_gesturesSupported || start == null || !mounted) return;
    final sens = _sensitivityHeight(context);
    try {
      final delta = -_dyVol / sens;
      final v = (start + delta).clamp(0.0, 1.0);
      VolumeController.instance.showSystemUI = false;
      await VolumeController.instance.setVolume(v);
      if (!mounted) return;
      setState(() {
        _hintKind = _HintKind.volume;
        _hintLevel = v;
        _hintText = '${(v * 100).round()}%';
      });
      _scheduleHideHint();
    } catch (_) {}
  }

  Future<void> _onVolumeDelta(double dy) async {
    _dyVol += dy;
    if (!_gesturesSupported) return;
    if (_volStart == null) return;
    await _applyVolumeFromPrimed();
  }

  static const Duration _seekHoldStep = Duration(seconds: 2);

  void _seekHoldTick({required bool forward}) {
    if (!mounted || widget.chewieController.isLive) return;
    final total = _video.value.duration;
    if (total == Duration.zero) return;
    final pos = _video.value.position;
    final delta = forward ? _seekHoldStep : -_seekHoldStep;
    var next = pos + delta;
    if (next < Duration.zero) next = Duration.zero;
    if (next > total) next = total;
    unawaited(_video.seekTo(next));
    if (!mounted) return;
    setState(() {
      _hintKind = _HintKind.seek;
      _hintLevel = null;
      _hintText = '${forward ? '>> ' : '<< '}${_formatDuration(next)}';
    });
    _scheduleHideHint();
  }

  void _startSeekHold({required bool forward}) {
    if (widget.chewieController.isLive) return;
    final total = _video.value.duration;
    if (total == Duration.zero) return;
    _seekHoldTimer?.cancel();
    _seekHoldTick(forward: forward);
    _seekHoldTimer = Timer.periodic(
      const Duration(milliseconds: 220),
      (_) => _seekHoldTick(forward: forward),
    );
  }

  void _stopSeekHold() {
    _seekHoldTimer?.cancel();
    _seekHoldTimer = null;
    _scheduleHideHint();
  }

  static String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return '${d.inHours}:$m:$s';
    }
    return '$m:$s';
  }

  void _onLongPressSpeedStart() {
    _speedBeforeHold = _video.value.playbackSpeed;
    unawaited(_video.setPlaybackSpeed(2.0));
    if (!mounted) return;
    setState(() {
      _hintKind = _HintKind.speed2x;
      _hintLevel = null;
      _hintText = '2×';
    });
    _scheduleHideHint();
  }

  void _onLongPressSpeedEnd() {
    final restore = _speedBeforeHold ?? 1.0;
    _speedBeforeHold = null;
    unawaited(_video.setPlaybackSpeed(restore));
    _scheduleHideHint();
  }

  Widget _hintBubble() {
    if (_hintKind == null || _hintText == null) return const SizedBox.shrink();
    final left = _hintKind == _HintKind.brightness ||
        _hintKind == _HintKind.seek ||
        _hintKind == _HintKind.speed2x;

    if (_hintKind == _HintKind.brightness || _hintKind == _HintKind.volume) {
      final level = (_hintLevel ?? 0).clamp(0.0, 1.0);
      final icon = _hintKind == _HintKind.brightness
          ? Icons.brightness_6
          : Icons.volume_up;
      return IgnorePointer(
        child: Align(
          alignment: left ? Alignment.centerLeft : Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Material(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white, size: 32),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 10,
                      height: 152,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            const ColoredBox(
                              color: Color(0x55FFFFFF),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor: level,
                                widthFactor: 1,
                                child: const ColoredBox(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _hintText!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
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

    final icon = _hintKind == _HintKind.seek
        ? Icons.fast_forward
        : Icons.speed;
    return IgnorePointer(
      child: Align(
        alignment: left ? Alignment.centerLeft : Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Material(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: 32),
                  const SizedBox(width: 10),
                  Text(
                    _hintText!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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

  Widget _gestureTutorialOverlay(BuildContext context, Size size) {
    final primary = Theme.of(context).colorScheme.primary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final l10n = AppLocalizations.of(context)!;
    const white = Colors.white;
    const titleStyle = TextStyle(
      color: white,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      shadows: [
        Shadow(color: Colors.black87, blurRadius: 12, offset: Offset(0, 2)),
      ],
    );

    Widget hintColumn({
      required List<Widget> icons,
      required String label,
    }) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(mainAxisSize: MainAxisSize.min, children: icons),
          const SizedBox(height: 6),
          Text(
            label,
            style: titleStyle,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    const pan = Icon(Icons.pan_tool_outlined, color: white, size: 30);

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.black.withValues(alpha: 0.38),
                    Colors.black.withValues(alpha: 0.48),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: size.width * 0.04,
          top: size.height * 0.06,
          child: hintColumn(
            icons: const [
              pan,
              SizedBox(width: 6),
              Icon(Icons.zoom_out_map, color: white, size: 30),
            ],
            label: 'Zoom',
          ),
        ),
        Positioned(
          right: size.width * 0.04,
          top: size.height * 0.06,
          child: hintColumn(
            icons: const [
              pan,
              SizedBox(width: 6),
              Icon(Icons.fast_forward, color: white, size: 28),
            ],
            label: '2× Speed',
          ),
        ),
        Positioned(
          left: size.width * 0.04,
          top: size.height * 0.32,
          bottom: size.height * 0.28,
          child: Center(
            child: hintColumn(
              icons: const [
                pan,
                SizedBox(width: 8),
                Icon(Icons.unfold_more, color: white, size: 26),
                SizedBox(width: 8),
                Icon(Icons.wb_sunny, color: white, size: 34),
              ],
              label: 'Brightness',
            ),
          ),
        ),
        Positioned(
          right: size.width * 0.04,
          top: size.height * 0.32,
          bottom: size.height * 0.28,
          child: Center(
            child: hintColumn(
              icons: const [
                pan,
                SizedBox(width: 8),
                Icon(Icons.unfold_more, color: white, size: 26),
                SizedBox(width: 8),
                Icon(Icons.volume_up, color: white, size: 34),
              ],
              label: 'Volume',
            ),
          ),
        ),
        Positioned(
          left: size.width * 0.22,
          right: size.width * 0.22,
          bottom: size.height * 0.12,
          child: Center(
            child: hintColumn(
              icons: [
                pan,
                const SizedBox(width: 8),
                const Icon(Icons.arrow_back, color: white, size: 22),
                const SizedBox(width: 10),
                const Icon(Icons.touch_app, color: white, size: 26),
                const SizedBox(width: 10),
                const Icon(Icons.arrow_forward, color: white, size: 22),
              ],
              label: 'Hold: rewind · forward',
            ),
          ),
        ),
        Center(
          child: FilledButton(
            onPressed: _dismissTutorial,
            style: FilledButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: onPrimary,
              elevation: 6,
              shadowColor: primary.withValues(alpha: 0.45),
              padding: const EdgeInsets.symmetric(
                horizontal: 36,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: Text(
              l10n.gotIt,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.videoChild;

    if (!_gesturesSupported) {
      return Stack(
        fit: StackFit.expand,
        children: [
          child,
          if (_showTutorial)
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, c) =>
                    _gestureTutorialOverlay(
                      context,
                      Size(c.maxWidth, c.maxHeight),
                    ),
              ),
            ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final sideW = w * (_sideFlex / (_sideFlex * 2 + _centerFlex));
        final bottomH = h * _bottomBandFraction;
        final topSpeedH = h * _topSpeedBandFraction;
        final topSpeedW = w * 0.42;

        return Stack(
          fit: StackFit.expand,
          children: [
            child,
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: sideW,
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: (e) {
                  _brightnessActivePointer = e.pointer;
                  _dyBright = 0;
                  _brightStart = null;
                  unawaited(_primeBrightnessStart());
                },
                onPointerMove: (e) {
                  if (_brightnessActivePointer != e.pointer) return;
                  unawaited(_onBrightnessDelta(e.delta.dy));
                },
                onPointerUp: (e) {
                  if (_brightnessActivePointer != e.pointer) return;
                  _brightnessActivePointer = null;
                  _scheduleHideHint();
                },
                onPointerCancel: (e) {
                  if (_brightnessActivePointer != e.pointer) return;
                  _brightnessActivePointer = null;
                  _scheduleHideHint();
                },
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: sideW,
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: (e) {
                  _volumeActivePointer = e.pointer;
                  _dyVol = 0;
                  _volStart = null;
                  unawaited(_primeVolumeStart());
                },
                onPointerMove: (e) {
                  if (_volumeActivePointer != e.pointer) return;
                  unawaited(_onVolumeDelta(e.delta.dy));
                },
                onPointerUp: (e) {
                  if (_volumeActivePointer != e.pointer) return;
                  _volumeActivePointer = null;
                  VolumeController.instance.showSystemUI = true;
                  _scheduleHideHint();
                },
                onPointerCancel: (e) {
                  if (_volumeActivePointer != e.pointer) return;
                  _volumeActivePointer = null;
                  VolumeController.instance.showSystemUI = true;
                  _scheduleHideHint();
                },
              ),
            ),
            Positioned(
              left: sideW,
              right: sideW,
              bottom: 0,
              height: bottomH,
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onLongPressStart: (_) =>
                          _startSeekHold(forward: false),
                      onLongPressEnd: (_) => _stopSeekHold(),
                      onLongPressCancel: _stopSeekHold,
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onLongPressStart: (_) =>
                          _startSeekHold(forward: true),
                      onLongPressEnd: (_) => _stopSeekHold(),
                      onLongPressCancel: _stopSeekHold,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              width: topSpeedW,
              height: topSpeedH,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onLongPressStart: (_) => _onLongPressSpeedStart(),
                onLongPressEnd: (_) => _onLongPressSpeedEnd(),
                onLongPressCancel: _onLongPressSpeedEnd,
              ),
            ),
            _hintBubble(),
            if (_showTutorial)
              Positioned.fill(
                child: _gestureTutorialOverlay(context, Size(w, h)),
              ),
          ],
        );
      },
    );
  }
}
