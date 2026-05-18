import 'dart:async';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:zen_video_player/analytics/video_player_telemetry.dart';

import 'download_service.dart';
import 'video_pip_helper.dart';
import 'video_player_gestures.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoSource;
  final bool isLocal;

  /// Android `content://…` from another app ("Open with"); uses
  /// [VideoPlayerController.contentUri].
  final bool useContentUri;

  /// App bar download for network URLs; ignored when [isLocal] is true.
  final bool allowNetworkDownload;

  const VideoPlayerScreen({
    super.key,
    required this.videoSource,
    this.isLocal = false,
    this.useContentUri = false,
    this.allowNetworkDownload = true,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with WidgetsBindingObserver {
  /// Hard ceiling so a hung CDN, redirect chain, or unsupported codec
  /// can't strand the user on the spinner forever. ExoPlayer's
  /// `initialize()` future does not always settle on its own when the
  /// underlying media source fails — wrapping it in a timeout is the
  /// only reliable way to recover.
  static const Duration _initTimeout = Duration(seconds: 20);

  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  TransformationController? _zoomTransform;

  /// Populated when init throws or times out. Drives the error state
  /// in [build]; null while still loading or after a successful init.
  String? _initError;

  /// Dedupes repeated [VideoPlayerValue.hasError] listener callbacks.
  String? _lastEmittedPlaybackError;

  /// Last `prepare` signature sent to Android; null if [clearPipEligibility] sent.
  String? _pipPreparedSignature;

  final GlobalKey _pipStageKeyEmbedded = GlobalKey(debugLabel: 'pipEmbedded');
  final GlobalKey _pipStageKeyFullscreen = GlobalKey(debugLabel: 'pipFullscreen');

  /// Dedupes [ChewieController] listener work when unrelated fields change.
  bool? _lastChewieFullScreen;

  static void _restoreSystemChrome() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(SystemChrome.setPreferredOrientations(DeviceOrientation.values));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        VideoPlayerTelemetry.screenOpened(
          isLocal: widget.isLocal || widget.useContentUri,
          allowNetworkDownload: widget.allowNetworkDownload,
          videoSource: widget.videoSource,
        ),
      );
    });
    unawaited(_initializePlayer());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-arm PiP after returning from PiP/fullscreen; native auto-enter may reset.
      _pipPreparedSignature = null;
      _syncNativePipEligibility();
    }
  }

  /// Android PiP must be armed while still resumed (see [VideoPipHelper.prepareAutoEnterWhilePlaying]).
  void _syncNativePipEligibility() {
    final c = _videoController;
    if (c == null || !mounted) return;
    if (!c.value.isInitialized ||
        _initError != null ||
        c.value.hasError ||
        !Platform.isAndroid) {
      if (_pipPreparedSignature != null) {
        _pipPreparedSignature = null;
        unawaited(VideoPipHelper.clearPipEligibility());
      }
      return;
    }
    if (!c.value.isPlaying) {
      if (_pipPreparedSignature != null) {
        _pipPreparedSignature = null;
        unawaited(VideoPipHelper.clearPipEligibility());
      }
      return;
    }
    final s = c.value.size;
    if (s.width <= 0 || s.height <= 0) {
      if (_pipPreparedSignature != null) {
        _pipPreparedSignature = null;
        unawaited(VideoPipHelper.clearPipEligibility());
      }
      return;
    }
    final rect = _pipStageRectPhysical();
    final rSnap = rect == null
        ? 'n'
        : '${rect.left.round()}_${rect.top.round()}_${rect.width.round()}_${rect.height.round()}';
    final fs = (_chewieController?.isFullScreen == true) ? 'fs' : 'em';
    final signature = '${s.width.round()}x${s.height.round()}@$rSnap@$fs';
    if (_pipPreparedSignature == signature) return;
    _pipPreparedSignature = signature;
    unawaited(
      VideoPipHelper.prepareAutoEnterWhilePlaying(
        s.width,
        s.height,
        sourceRectPhysical: rect,
      ),
    );
  }

  /// Stage bounds in **physical pixels** for Android [PictureInPictureParams]
  /// source-rect hint (YouTube-style transition).
  Rect? _pipStageRectPhysical() {
    final chewie = _chewieController;
    final key = (chewie != null && chewie.isFullScreen)
        ? _pipStageKeyFullscreen
        : _pipStageKeyEmbedded;
    final ctx = key.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    final topLeft = box.localToGlobal(Offset.zero);
    final dpr = MediaQuery.devicePixelRatioOf(ctx);
    return Rect.fromLTRB(
      topLeft.dx * dpr,
      topLeft.dy * dpr,
      (topLeft.dx + box.size.width) * dpr,
      (topLeft.dy + box.size.height) * dpr,
    );
  }

  void _onChewieChanged() {
    final ch = _chewieController;
    if (ch == null) return;
    final next = ch.isFullScreen;
    if (next == _lastChewieFullScreen) return;
    _lastChewieFullScreen = next;
    if (!mounted) return;
    _pipPreparedSignature = null;
    _syncNativePipEligibility();
  }

  Future<void> _onPipButtonPressed() async {
    if (!Platform.isAndroid) return;
    final c = _videoController;
    if (c == null || !c.value.isInitialized || _initError != null) return;
    final s = c.value.size;
    if (s.width <= 0 || s.height <= 0) return;
    final rect = _pipStageRectPhysical();
    final ok = await VideoPipHelper.enterPictureInPicture(
      s.width,
      s.height,
      sourceRectPhysical: rect,
    );
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Picture-in-picture is not available on this device.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _initializePlayer() async {
    _lastEmittedPlaybackError = null;
    final sw = Stopwatch()..start();

    if (mounted) {
      setState(() {
        _initError = null;
      });
    }

    void dismissLoadingHint() {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Loading, please wait for 10 seconds.'),
          duration: Duration(seconds: 10),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });

    unawaited(
      VideoPlayerTelemetry.initStarted(
        isLocal: widget.isLocal || widget.useContentUri,
        videoSource: widget.videoSource,
      ),
    );

    late final VideoPlayerController controller;
    if (widget.useContentUri) {
      if (!Platform.isAndroid) {
        throw UnsupportedError('content:// playback is only supported on Android.');
      }
      controller = VideoPlayerController.contentUri(Uri.parse(widget.videoSource));
    } else if (widget.isLocal) {
      final parsed = Uri.tryParse(widget.videoSource);
      if (parsed != null && parsed.isScheme('file')) {
        controller = VideoPlayerController.file(File.fromUri(parsed));
      } else {
        controller = VideoPlayerController.file(File(widget.videoSource));
      }
    } else {
      controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoSource));
    }

    _videoController = controller;

    try {
      await controller.initialize().timeout(
        _initTimeout,
        onTimeout: () {
          throw TimeoutException(
            'Video took longer than ${_initTimeout.inSeconds}s to '
            'start. The URL may be unreachable, behind a redirect, or '
            'in a format the player cannot decode.',
          );
        },
      );
    } catch (e, st) {
      dismissLoadingHint();
      sw.stop();
      unawaited(
        VideoPlayerTelemetry.initFailed(
          isLocal: widget.isLocal || widget.useContentUri,
          videoSource: widget.videoSource,
          error: e,
          stackTrace: st,
          elapsed: sw.elapsed,
        ),
      );
      if (!mounted) return;
      setState(() {
        _initError = _humanizeError(e);
      });
      await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      _restoreSystemChrome();
      await controller.dispose();
      if (identical(_videoController, controller)) {
        _videoController = null;
      }
      return;
    }

    if (!mounted) {
      await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      _restoreSystemChrome();
      await controller.dispose();
      return;
    }

    dismissLoadingHint();
    sw.stop();
    unawaited(
      VideoPlayerTelemetry.initSucceeded(
        isLocal: widget.isLocal || widget.useContentUri,
        videoSource: widget.videoSource,
        elapsed: sw.elapsed,
      ),
    );

    controller.addListener(_onVideoValueChanged);
    _syncNativePipEligibility();

    final sz = controller.value.size;
    final bool portraitVideo =
        sz.width > 0 && sz.height > 0 && sz.height > sz.width;
    final videoOrientations = portraitVideo
        ? const <DeviceOrientation>[
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]
        : const <DeviceOrientation>[
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ];
    await SystemChrome.setPreferredOrientations(videoOrientations);
    if (!mounted) return;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _pipPreparedSignature = null;
    unawaited(VideoPipHelper.clearPipEligibility());
    _chewieController?.removeListener(_onChewieChanged);
    _chewieController?.dispose();
    _zoomTransform?.dispose();
    _zoomTransform = TransformationController();

    _chewieController = ChewieController(
      videoPlayerController: controller,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      allowMuting: true,
      allowPlaybackSpeedChanging: true,
      deviceOrientationsOnEnterFullScreen: videoOrientations,
      deviceOrientationsAfterFullScreen: videoOrientations,
      transformationController: _zoomTransform,
      zoomAndPan: true,
      routePageBuilder: (ctx, animation, secondaryAnimation, provider) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.black,
              body: Stack(
                fit: StackFit.expand,
                children: [
                  KeyedSubtree(
                    key: _pipStageKeyFullscreen,
                    child: Container(
                      color: Colors.black,
                      alignment: Alignment.center,
                      child: VideoPlayerGestureShell(
                        chewieController: _chewieController!,
                        videoChild: provider,
                      ),
                    ),
                  ),
                  ..._immersiveChromeOverlays(context),
                ],
              ),
            );
          },
        );
      },
    );

    _lastChewieFullScreen = _chewieController!.isFullScreen;
    _chewieController!.addListener(_onChewieChanged);
    _pipPreparedSignature = null;
    _syncNativePipEligibility();

    setState(() {});
  }

  void _onVideoValueChanged() {
    final c = _videoController;
    if (c == null || !mounted) return;
    if (c.value.hasError) {
      final desc = c.value.errorDescription ?? 'unknown';
      if (desc != _lastEmittedPlaybackError) {
        _lastEmittedPlaybackError = desc;
        unawaited(
          VideoPlayerTelemetry.playbackError(
            isLocal: widget.isLocal || widget.useContentUri,
            videoSource: widget.videoSource,
            errorDescription: desc,
          ),
        );
      }
    }
    _syncNativePipEligibility();
  }

  String _humanizeError(Object e) {
    if (e is TimeoutException) {
      return e.message ?? 'Timed out while loading the video.';
    }
    if (e is PlatformException) {
      // ExoPlayer / iOS player surface the underlying cause via
      // `message`. Fall back to `code` so we always show *something*
      // useful even when the platform leaves message empty.
      return e.message?.isNotEmpty == true
          ? e.message!
          : 'Player error (${e.code}).';
    }
    return e.toString();
  }

  Future<void> _downloadVideo() async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(
        content: Text("Opening system download manager..."),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.blueGrey,
      ),
    );
    try {
      final outcome = await DownloadService.downloadFile(widget.videoSource);
      if (!mounted) return;
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            outcome.handedOffToSystem
                ? " Started. Check your notifications or the folder."
                : " Saved to: ${outcome.localPath}",
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e, st) {
      unawaited(
        VideoPlayerTelemetry.downloadFailed(
          videoSource: widget.videoSource,
          error: e,
          stackTrace: st,
        ),
      );
      if (!mounted) return;
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text("Download failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pipPreparedSignature = null;
    unawaited(VideoPipHelper.clearPipEligibility());
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _restoreSystemChrome();
    _videoController?.removeListener(_onVideoValueChanged);
    _chewieController?.removeListener(_onChewieChanged);
    _chewieController?.dispose();
    _zoomTransform?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Widget _buildBody() {
    final error = _initError;
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 56,
              ),
              const SizedBox(height: 16),
              const Text(
                "Couldn't play this video",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => unawaited(_initializePlayer()),
                    icon: const Icon(Icons.refresh),
                    label: const Text("Retry"),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Back"),
                  ),
                ],
              ),
            ],
        ),
        ),
      );
    }

    final chewie = _chewieController;
    if (chewie == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return SizedBox.expand(
      key: _pipStageKeyEmbedded,
      child: VideoPlayerGestureShell(
        chewieController: chewie,
        videoChild: Chewie(controller: chewie),
      ),
    );
  }

  /// Back + download over the video (embedded and Chewie fullscreen route).
  List<Widget> _immersiveChromeOverlays(BuildContext context) {
    final chewieReady = _chewieController != null && _initError == null;
    return [
      if (_initError == null)
        Positioned(
          top: 0,
          left: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Material(
                color: Colors.black45,
                shape: const CircleBorder(),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).maybePop(),
                  tooltip: 'Back',
                ),
              ),
            ),
          ),
        ),
      if (chewieReady &&
          !widget.isLocal &&
          !widget.useContentUri &&
          widget.allowNetworkDownload)
        Positioned(
          top: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Material(
                color: Colors.black45,
                shape: const CircleBorder(),
                child: IconButton(
                  icon: const Icon(Icons.download, color: Colors.white),
                  onPressed: _downloadVideo,
                  tooltip: 'Download',
                ),
              ),
            ),
          ),
        ),
      if (chewieReady && Platform.isAndroid)
        Positioned(
          right: 8,
          bottom: 8,
          child: SafeArea(
            child: Material(
              color: Colors.black45,
              shape: const CircleBorder(),
              child: IconButton(
                icon: const Icon(
                  Icons.picture_in_picture_alt_outlined,
                  color: Colors.white,
                ),
                onPressed: () => unawaited(_onPipButtonPressed()),
                tooltip: 'Picture-in-picture',
              ),
            ),
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBody(),
          ..._immersiveChromeOverlays(context),
        ],
      ),
    );
  }
}
