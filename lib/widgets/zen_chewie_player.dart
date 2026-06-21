import 'dart:async';

import 'package:chewie/chewie.dart';
// Chewie does not export [PlayerNotifier]; required for [MaterialControls].
// ignore: implementation_imports
import 'package:chewie/src/notifiers/player_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:zen_video_player/services/video_orientation_channel.dart';
import 'package:zen_video_player/video/video_color_filter.dart';
import 'package:zen_video_player/widgets/zen_video_surface.dart';

/// Chewie controls with a rotation-friendly video surface.
class ZenChewiePlayer extends StatefulWidget {
  final ChewieController controller;
  final VideoColorFilterSettings colorFilter;
  final int surfaceEpoch;

  /// When false, only renders the video surface (used inside Chewie's fullscreen route).
  final bool manageFullScreen;

  /// Android PiP source-rect hint; should wrap the visible video frame only.
  final GlobalKey? pipBoundsKey;

  const ZenChewiePlayer({
    super.key,
    required this.controller,
    this.colorFilter = VideoColorFilterSettings.standard,
    this.surfaceEpoch = 0,
    this.manageFullScreen = true,
    this.pipBoundsKey,
  });

  @override
  State<ZenChewiePlayer> createState() => _ZenChewiePlayerState();
}

class _ZenChewiePlayerState extends State<ZenChewiePlayer> {
  late PlayerNotifier _notifier;
  bool _isFullScreen = false;

  bool get _controllerFullScreen => widget.controller.isFullScreen;

  @override
  void initState() {
    super.initState();
    _notifier = PlayerNotifier.init();
    if (widget.manageFullScreen) {
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void didUpdateWidget(ZenChewiePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.manageFullScreen != widget.manageFullScreen) {
      if (oldWidget.manageFullScreen) {
        oldWidget.controller.removeListener(_onControllerChanged);
      }
      if (widget.manageFullScreen) {
        widget.controller.addListener(_onControllerChanged);
      }
    } else if (widget.manageFullScreen &&
        oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    if (widget.manageFullScreen) {
      widget.controller.removeListener(_onControllerChanged);
    }
    _notifier.dispose();
    super.dispose();
  }

  Future<void> _onControllerChanged() async {
    if (!widget.manageFullScreen || !mounted) return;
    if (_controllerFullScreen && !_isFullScreen) {
      _isFullScreen = _controllerFullScreen;
      await _pushFullScreen();
    } else if (_isFullScreen) {
      Navigator.of(
        context,
        rootNavigator: widget.controller.useRootNavigator,
      ).pop();
      _isFullScreen = false;
    }
    if (mounted) setState(() {});
  }

  void _onEnterFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    unawaited(VideoOrientationChannel.enterPlayerMode());
  }

  Future<void> _pushFullScreen() async {
    if (!mounted) return;
    final c = widget.controller;
    final navigator = Navigator.of(
      context,
      rootNavigator: c.useRootNavigator,
    );
    final route = PageRouteBuilder<void>(
      pageBuilder: (ctx, animation, secondaryAnimation) {
        if (c.routePageBuilder != null) {
          final provider = ChewieControllerProvider(
            controller: c,
            child: ChangeNotifierProvider<PlayerNotifier>.value(
              value: _notifier,
              builder: (context, _) => const SizedBox.shrink(),
            ),
          );
          return c.routePageBuilder!(
            ctx,
            animation,
            secondaryAnimation,
            provider,
          );
        }
        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.black,
              body: Center(
                child: ChewieControllerProvider(
                  controller: c,
                  child: ChangeNotifierProvider<PlayerNotifier>.value(
                    value: _notifier,
                    child: ZenChewiePlayer(controller: c, manageFullScreen: false),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    _onEnterFullScreen();
    if (!c.allowedScreenSleep) {
      await WakelockPlus.enable();
    }

    await navigator.push(route);

    _isFullScreen = false;
    c.exitFullScreen();

    if (!c.allowedScreenSleep) {
      await WakelockPlus.disable();
    }

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: c.systemOverlaysAfterFullScreen,
    );
    unawaited(VideoOrientationChannel.enterPlayerMode());
  }

  @override
  Widget build(BuildContext context) {
    final chewie = widget.controller;
    // Only one [VideoPlayer] per controller — hide embedded surface while fullscreen route is up.
    if (widget.manageFullScreen && chewie.isFullScreen) {
      return const ColoredBox(color: Colors.black);
    }
    return ChewieControllerProvider(
      controller: chewie,
      child: ChangeNotifierProvider<PlayerNotifier>.value(
        value: _notifier,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (chewie.placeholder != null) chewie.placeholder!,
            InteractiveViewer(
              transformationController: chewie.transformationController,
              maxScale: chewie.maxScale,
              panEnabled: chewie.zoomAndPan,
              scaleEnabled: chewie.zoomAndPan,
              child: ZenVideoSurface(
                controller: chewie.videoPlayerController,
                colorFilter: widget.colorFilter,
                surfaceEpoch: widget.surfaceEpoch,
                pipBoundsKey: widget.pipBoundsKey,
              ),
            ),
            if (chewie.overlay != null) chewie.overlay!,
            chewie.customControls ?? const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
