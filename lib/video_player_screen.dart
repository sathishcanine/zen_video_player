import 'dart:async';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:zen_video_player/analytics/video_player_telemetry.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

import 'download_service.dart';
import 'app_navigator.dart';
import 'services/app_settings_service.dart';
import 'services/asset_playback_resolver.dart';
import 'services/playback_resume_service.dart';
import 'services/sleep_timer_service.dart';
import 'services/video_continue_watching_service.dart';
import 'services/video_exit_interstitial_service.dart';
import 'services/network_video_exit_interstitial_service.dart';
import 'services/video_orientation_channel.dart';
import 'services/video_playback_queue.dart';
import 'utils/safe_stream.dart';
import 'utils/video_navigation.dart';
import 'video/video_playback_handoff.dart';
import 'video_pip_helper.dart';
import 'services/video_player_color_tutorial_service.dart';
import 'video_player_gestures.dart';
import 'video/video_color_filter.dart';
import 'services/cast_service.dart';
import 'widgets/cast_device_picker_sheet.dart';
import 'widgets/zen_chewie_player.dart';
import 'widgets/zen_video_player_chrome.dart';
import 'widgets/zen_video_surface.dart';
import 'utils/media_display_name.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoSource;
  final bool isLocal;

  /// Android `content://…` from another app ("Open with"); uses
  /// [VideoPlayerController.contentUri].
  final bool useContentUri;

  /// App bar download for network URLs; ignored when [isLocal] is true.
  final bool allowNetworkDownload;

  /// Shown in the player top bar, e.g. `MyMovie.mp4`.
  final String? displayTitle;

  /// Stable id for resume position (e.g. MediaStore asset id).
  final String? resumeKey;

  const VideoPlayerScreen({
    super.key,
    required this.videoSource,
    this.isLocal = false,
    this.useContentUri = false,
    this.allowNetworkDownload = true,
    this.displayTitle,
    this.resumeKey,
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

  bool _inPipMode = false;
  StreamSubscription<bool>? _pipModeSub;
  StreamSubscription<void>? _pipControlSub;
  bool? _lastPipSyncPlaying;
  bool? _lastPipActionPlaying;
  Size? _lastPipSyncSize;
  bool _playerBackHandling = false;
  bool _pendingPopAfterExitAd = false;

  final GlobalKey _pipVideoBoundsKey = GlobalKey(debugLabel: 'pipVideoBounds');

  /// Dedupes [ChewieController] listener work when unrelated fields change.
  bool? _lastChewieFullScreen;

  /// Bumped on rotation so the platform video view is recreated (Android blank fix).
  int _videoSurfaceEpoch = 0;
  Orientation? _lastReportedOrientation;
  Timer? _orientationRebindTimer;

  VideoColorFilterSettings _colorFilter = VideoColorFilterSettings.standard;

  bool _gestureTutorialVisible = false;
  int _colorTutorialTrigger = 0;
  bool _colorTutorialScheduleAttempted = false;
  VoidCallback? _sleepTimerListener;
  Timer? _positionSaveTimer;
  Timer? _exitAdPreloadTimer;
  Duration? _resumedFromPosition;

  static const List<DeviceOrientation> _playerOrientations = <DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];

  static void _restoreSystemChrome() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  /// Lets the Android Activity rotate; avoids Flutter re-locking portrait.
  Future<void> _primePlayerOrientation() async {
    await SystemChrome.setPreferredOrientations(const <DeviceOrientation>[]);
    await VideoOrientationChannel.enterPlayerMode();
  }

  @override
  void initState() {
    super.initState();
    if (widget.resumeKey != null) {
      VideoPlaybackQueue.syncCurrent(widget.resumeKey!);
    } else {
      VideoPlaybackQueue.clear();
    }
    WidgetsBinding.instance.addObserver(this);
    _sleepTimerListener = _onSleepTimerExpired;
    SleepTimerService.instance.addOnExpireListener(_sleepTimerListener!);
    if (AppSettingsService.instance.keepScreenOnVideo) {
      unawaited(WakelockPlus.enable());
    }
    unawaited(_primePlayerOrientation());
    final isNetworkPlayback = !widget.isLocal && !widget.useContentUri;
    if (!isNetworkPlayback) {
      _exitAdPreloadTimer = Timer.periodic(const Duration(seconds: 45), (_) {
        if (!mounted) return;
        VideoExitInterstitialService.instance.preloadIfNearEligible();
      });
    }
    if (Platform.isAndroid) {
      _pipModeSub = VideoPipHelper.pipModeChanges.listen(
        (inPip) {
          if (!mounted) return;
          setState(() {
            _inPipMode = inPip;
            if (!inPip) {
              _pipPreparedSignature = null;
              _lastPipActionPlaying = null;
            }
          });
          if (inPip) {
            final playing = _videoController?.value.isPlaying ?? true;
            _lastPipActionPlaying = playing;
            unawaited(VideoPipHelper.updatePipPlaybackAction(playing));
          } else {
            _syncNativePipEligibility();
          }
        },
        onError: (_) {},
      );
      _pipControlSub = VideoPipHelper.pipPlayPauseToggles.listen(
        (_) => unawaited(_onPipPlayPauseToggle()),
        onError: (_) {},
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.isLocal || widget.useContentUri) {
        VideoExitInterstitialService.instance.preloadIfNearEligible();
      }
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

  ChewieController _createChewieController(VideoPlayerController controller) {
    final aspectRatio = ZenVideoSurface.displayAspectRatio(controller.value);
    return ChewieController(
      videoPlayerController: controller,
      autoPlay: true,
      looping: false,
      allowFullScreen: false,
      allowMuting: true,
      allowPlaybackSpeedChanging: true,
      allowedScreenSleep: !AppSettingsService.instance.keepScreenOnVideo,
      showControls: false,
      showControlsOnInitialize: false,
      customControls: const SizedBox.shrink(),
      useRootNavigator: true,
      aspectRatio: aspectRatio,
      deviceOrientationsOnEnterFullScreen: _playerOrientations,
      deviceOrientationsAfterFullScreen: _playerOrientations,
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
                    key: const ValueKey('pipFullscreenStage'),
                    child: Container(
                      color: Colors.black,
                      alignment: Alignment.center,
                      child: VideoPlayerGestureShell(
                        chewieController: _chewieController!,
                        onTutorialVisibilityChanged: _onGestureTutorialVisibility,
                        videoChild: ZenChewiePlayer(
                          controller: _chewieController!,
                          colorFilter: _colorFilter,
                          surfaceEpoch: _videoSurfaceEpoch,
                          manageFullScreen: false,
                          pipBoundsKey: _pipVideoBoundsKey,
                        ),
                      ),
                    ),
                  ),
                  ..._playerChromeOverlays(context),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    _scheduleOrientationRebind();
  }

  void _scheduleOrientationRebind() {
    _orientationRebindTimer?.cancel();
    _orientationRebindTimer = Timer(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      final inFullscreen = _chewieController?.isFullScreen == true;
      final orientation = MediaQuery.orientationOf(context);
      if (_lastReportedOrientation == null) {
        _lastReportedOrientation = orientation;
        return;
      }
      if (_lastReportedOrientation == orientation) {
        // Avoid rebuilding the embedded surface while Chewie fullscreen is open.
        if (!inFullscreen && mounted) setState(() {});
        return;
      }
      _lastReportedOrientation = orientation;
      if (inFullscreen) {
        unawaited(_rebindVideoAfterLayoutChange());
        _pipPreparedSignature = null;
        _syncNativePipEligibility();
        return;
      }
      unawaited(_handleOrientationChange());
    });
  }

  /// Rebuilds the video surface after portrait ↔ landscape (fixes blank screen).
  Future<void> _handleOrientationChange() async {
    _zoomTransform?.value = Matrix4.identity();
    if (mounted) {
      setState(() => _videoSurfaceEpoch++);
    }
    await _rebindVideoAfterLayoutChange();
    _pipPreparedSignature = null;
    _syncNativePipEligibility();
  }

  Future<void> _rebindVideoAfterLayoutChange() async {
    final c = _videoController;
    if (c == null || !c.value.isInitialized || c.value.hasError) return;
    try {
      final pos = c.value.position;
      final playing = c.value.isPlaying;
      if (playing) await c.pause();
      await Future<void>.delayed(const Duration(milliseconds: 60));
      if (!mounted || c != _videoController) return;
      await c.seekTo(pos);
      if (playing) await c.play();
    } catch (e, st) {
      debugPrint('[video] rebind after rotation failed: $e\n$st');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_pendingPopAfterExitAd) {
        _popPlayerRoute();
        return;
      }
      unawaited(VideoOrientationChannel.enterPlayerMode());
      // Re-arm PiP after returning from PiP/fullscreen; native auto-enter may reset.
      _pipPreparedSignature = null;
      _syncNativePipEligibility();
      return;
    }
    // Hide chrome as soon as the user leaves the app while PiP is armed.
    if (Platform.isAndroid &&
        _pipPreparedSignature != null &&
        _videoController?.value.isPlaying == true &&
        (state == AppLifecycleState.inactive ||
            state == AppLifecycleState.paused)) {
      if (mounted && !_inPipMode) setState(() => _inPipMode = true);
    }
  }

  /// Android PiP must be armed while still resumed (see [VideoPipHelper.prepareAutoEnterWhilePlaying]).
  void _syncNativePipEligibility() {
    final c = _videoController;
    if (c == null || !mounted) return;
    // Never push new PiP params while already in PiP — layout bounds change each
    // resize and cause square ↔ rectangle oscillation with seamlessResize.
    if (_inPipMode) return;
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
    final (aspectNum, aspectDen) = VideoPipHelper.standardAspectRational(c.value);
    final fs = (_chewieController?.isFullScreen == true) ? 'fs' : 'em';
    final playing = c.value.isPlaying;
    final signature = '$aspectNum:$aspectDen@$fs@$playing';
    if (_pipPreparedSignature == signature) return;
    _pipPreparedSignature = signature;
    unawaited(VideoPipHelper.prepareAutoEnterWhilePlaying(c.value));
  }

  Future<void> _onPipPlayPauseToggle() async {
    if (!mounted) return;
    final c = _videoController;
    if (c == null) return;
    try {
      if (!c.value.isInitialized) return;
      if (c.value.isPlaying) {
        await c.pause();
      } else {
        await c.play();
      }
    } catch (e, st) {
      debugPrint('[video] PiP play/pause failed: $e\n$st');
    }
  }

  void _syncPipPlaybackActionIcon(bool playing) {
    if (!_inPipMode) return;
    if (playing == _lastPipActionPlaying) return;
    _lastPipActionPlaying = playing;
    unawaited(VideoPipHelper.updatePipPlaybackAction(playing));
  }

  bool get _isNetworkPlayback => !widget.isLocal && !widget.useContentUri;

  Future<void> _onPlayerBackPressed() async {
    if (!mounted || _playerBackHandling) return;
    if (_inPipMode) {
      final nav = rootNavigatorKey.currentState ?? Navigator.of(context);
      if (nav.mounted && nav.canPop()) nav.pop();
      return;
    }

    final navigator = rootNavigatorKey.currentState ?? Navigator.of(context);
    _playerBackHandling = true;
    try {
      final video = _videoController;
      if (video?.value.isInitialized == true && video!.value.isPlaying) {
        await video.pause();
      }

      if (_isNetworkPlayback) {
        _popPlayerRouteImmediate(navigator);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          unawaited(
            NetworkVideoExitInterstitialService.instance.tryShowAfterLanding(),
          );
        });
        return;
      }

      _pendingPopAfterExitAd = true;
      if (mounted) {
        await VideoExitInterstitialService.instance.tryShowBeforeExit(context);
      }
    } catch (e, st) {
      debugPrint('[video] exit interstitial failed: $e\n$st');
    } finally {
      _playerBackHandling = false;
      _popPlayerRoute(navigator: navigator);
    }
  }

  void _popPlayerRouteImmediate(NavigatorState nav) {
    if (!nav.mounted || !nav.canPop()) return;
    _pendingPopAfterExitAd = false;
    final video = _videoController;
    if (video?.value.isInitialized == true && video!.value.isPlaying) {
      unawaited(video.pause());
    }
    nav.pop();
  }

  /// Pops the player route after the native ad releases the Flutter surface.
  void _popPlayerRoute({NavigatorState? navigator}) {
    if (!_pendingPopAfterExitAd) return;
    final nav = navigator ??
        rootNavigatorKey.currentState ??
        (mounted ? Navigator.of(context) : null);
    if (nav == null) return;

    void attemptPop() {
      if (!_pendingPopAfterExitAd) return;
      if (!nav.mounted || !nav.canPop()) return;
      _pendingPopAfterExitAd = false;
      final video = _videoController;
      if (video?.value.isInitialized == true && video!.value.isPlaying) {
        unawaited(video.pause());
      }
      nav.pop();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      attemptPop();
      // Native ad teardown can lag a frame or two on slower devices.
      Future<void>.delayed(const Duration(milliseconds: 250), attemptPop);
      Future<void>.delayed(const Duration(milliseconds: 750), attemptPop);
    });
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

  Future<void> _onRotatePressed() async {
    await VideoOrientationChannel.toggleOrientation();
    await Future<void>.delayed(const Duration(milliseconds: 280));
    if (!mounted) return;
    await _handleOrientationChange();
  }

  Future<void> _skipPrevious() async {
    final video = _videoController;
    if (video?.value.isInitialized == true &&
        video!.value.position.inSeconds > 3) {
      await video.seekTo(Duration.zero);
      return;
    }
    await _openQueuedAsset(VideoPlaybackQueue.previousAssetId);
  }

  Future<void> _skipNext() async {
    await _openQueuedAsset(VideoPlaybackQueue.nextAssetId);
  }

  Future<void> _openQueuedAsset(String? assetId) async {
    if (assetId == null || !mounted) return;
    await _saveVideoPosition();
    final entity = await AssetEntity.fromId(assetId);
    if (entity == null || !mounted) return;
    final target = await AssetPlaybackResolver.resolve(entity);
    if (target == null || !mounted) return;

    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: VideoRoutes.player),
        builder: (_) => VideoPlayerScreen(
          videoSource: target.videoSource,
          isLocal: target.isLocal,
          useContentUri: target.useContentUri,
          displayTitle: target.displayName,
          resumeKey: target.assetId,
        ),
      ),
    );
  }

  void _onCastPressed(BuildContext chromeContext) {
    final video = _videoController;
    final position = video?.value.isInitialized == true
        ? video!.value.position
        : Duration.zero;
    final duration = video?.value.isInitialized == true
        ? video!.value.duration
        : null;
    unawaited(
      showCastDevicePicker(
        chromeContext,
        media: CastMediaPayload(
          title: _videoTitle,
          videoSource: widget.videoSource,
          isLocal: widget.isLocal || widget.useContentUri,
          useContentUri: widget.useContentUri,
          playPosition: position,
          duration: duration,
          assetId: widget.resumeKey,
        ),
      ),
    );
  }

  Future<void> _onPipButtonPressed() async {
    if (!Platform.isAndroid) return;
    final c = _videoController;
    if (c == null || !c.value.isInitialized || _initError != null) return;

    if (!c.value.isPlaying) {
      await c.play();
    }

    if (mounted) setState(() => _inPipMode = true);

    final playing = c.value.isPlaying;
    _lastPipActionPlaying = playing;
    final ok = await VideoPipHelper.enterPictureInPicture(c.value);

    if (!mounted) return;
    if (!ok) {
      setState(() => _inPipMode = false);
      final l10n = AppLocalizations.of(context)!;
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.pictureInPictureUnavailable),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: l10n.openSettings,
            onPressed: () => unawaited(openAppSettings()),
          ),
        ),
      );
    }
  }

  Future<void> _initializePlayer() async {
    _lastEmittedPlaybackError = null;
    if (mounted) setState(() { _initError = null; });

    // content:// URIs never go through VideoPreviewScreen, so no handoff exists.
    if (!widget.useContentUri) {
      final handoff = VideoPlaybackHandoff.take(widget.videoSource);
      if (handoff != null) {
        await _applyHandoffController(handoff);
        return;
      }
    }

    // Full init path: local file opened directly, content URI, or no handoff.
    final sw = Stopwatch()..start();

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
      unawaited(VideoOrientationChannel.exitPlayerMode());
      _restoreSystemChrome();
      await controller.dispose();
      if (identical(_videoController, controller)) {
        _videoController = null;
      }
      return;
    }

    if (!mounted) {
      await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      unawaited(VideoOrientationChannel.exitPlayerMode());
      _restoreSystemChrome();
      await controller.dispose();
      return;
    }

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

    await VideoOrientationChannel.enterPlayerMode();
    if (!mounted) return;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _pipPreparedSignature = null;
    unawaited(VideoPipHelper.clearPipEligibility());
    _chewieController?.removeListener(_onChewieChanged);
    _chewieController?.dispose();
    _zoomTransform?.dispose();
    _zoomTransform = TransformationController();

    _chewieController = _createChewieController(controller);
    _lastChewieFullScreen = _chewieController!.isFullScreen;
    _chewieController!.addListener(_onChewieChanged);
    _pipPreparedSignature = null;
    _syncNativePipEligibility();

    await _applyResumePosition(controller);
    _startPositionSaver();

    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_scheduleColorTutorialIfGestureAlreadyDone());
    });
  }

  Future<void> _applyResumePosition(VideoPlayerController controller) async {
    if (!AppSettingsService.instance.resumeVideo) return;
    final resume = await PlaybackResumeService.loadVideoPosition(_resumeKey);
    if (resume == null || !mounted) return;
    if (resume.inSeconds < 5) return;
    await controller.seekTo(resume);
    if (!mounted) return;
    setState(() => _resumedFromPosition = resume);
  }

  void _dismissResumePrompt() {
    if (_resumedFromPosition == null) return;
    setState(() => _resumedFromPosition = null);
  }

  Future<void> _startVideoOver() async {
    final c = _videoController;
    if (c != null && c.value.isInitialized) {
      await c.seekTo(Duration.zero);
    }
    if (mounted) setState(() => _resumedFromPosition = null);
  }

  void _startPositionSaver() {
    _positionSaveTimer?.cancel();
    _positionSaveTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      _saveVideoPosition();
    });
  }

  Future<void> _saveVideoPosition() async {
    final c = _videoController;
    if (c == null || !c.value.isInitialized) return;
    final pos = c.value.position;
    final dur = c.value.duration;
    if (pos.inMilliseconds < 5000) return;

    if (!AppSettingsService.instance.resumeVideo) return;

    await PlaybackResumeService.saveVideoPosition(_resumeKey, pos);
    await VideoContinueWatchingService.instance.updateFromPlayback(
      storageKey: _resumeKey,
      videoSource: widget.videoSource,
      displayTitle: _videoTitle,
      position: pos,
      duration: dur,
      isLocal: widget.isLocal,
      useContentUri: widget.useContentUri,
      allowNetworkDownload: widget.allowNetworkDownload,
      assetId: widget.resumeKey,
    );
  }

  String get _resumeKey => PlaybackResumeService.videoKeyForSource(
        widget.videoSource,
        assetId: widget.resumeKey,
      );

  String get _videoTitle => MediaDisplayName.forVideoSource(
        source: widget.videoSource,
        displayTitle: widget.displayTitle,
        isLocal: widget.isLocal || widget.useContentUri,
      );

  void _onSleepTimerExpired() {
    final c = _videoController;
    if (c != null && c.value.isInitialized) {
      unawaited(c.pause());
    }
    if (mounted) Navigator.of(context).maybePop();
  }

  /// Fast path: the preview screen already initialized the controller and
  /// handed it off via [VideoPlaybackHandoff].  We skip the heavy
  /// [controller.initialize()] call and go straight to playback setup.
  Future<void> _applyHandoffController(VideoPlayerController controller) async {
    _videoController = controller;

    // Preview muted the controller for the silent thumbnail; restore volume.
    await controller.setVolume(1);

    if (!mounted) {
      await controller.dispose();
      return;
    }

    controller.addListener(_onVideoValueChanged);
    _syncNativePipEligibility();

    await VideoOrientationChannel.enterPlayerMode();
    if (!mounted) return;

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _pipPreparedSignature = null;
    unawaited(VideoPipHelper.clearPipEligibility());
    _chewieController?.removeListener(_onChewieChanged);
    _chewieController?.dispose();
    _zoomTransform?.dispose();
    _zoomTransform = TransformationController();

    _chewieController = _createChewieController(controller);
    _lastChewieFullScreen = _chewieController!.isFullScreen;
    _chewieController!.addListener(_onChewieChanged);
    _pipPreparedSignature = null;
    _syncNativePipEligibility();

    await _applyResumePosition(controller);
    _startPositionSaver();

    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_scheduleColorTutorialIfGestureAlreadyDone());
    });
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
    if (c.value.isInitialized &&
        !c.value.isPlaying &&
        !c.value.isBuffering &&
        c.value.duration > Duration.zero) {
      final remaining = c.value.duration - c.value.position;
      if (remaining <= const Duration(milliseconds: 500)) {
        unawaited(SleepTimerService.instance.onMediaCompleted());
        unawaited(VideoContinueWatchingService.instance.clear());
      }
    }
    final playing = c.value.isPlaying;
    final size = c.value.size;
    if (playing == _lastPipSyncPlaying && size == _lastPipSyncSize) return;
    _lastPipSyncPlaying = playing;
    _lastPipSyncSize = size;
    _syncPipPlaybackActionIcon(playing);
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
  void deactivate() {
    unawaited(_saveVideoPosition());
    super.deactivate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _positionSaveTimer?.cancel();
    _exitAdPreloadTimer?.cancel();
    _orientationRebindTimer?.cancel();
    if (_sleepTimerListener != null) {
      SleepTimerService.instance.removeOnExpireListener(_sleepTimerListener!);
    }
    if (AppSettingsService.instance.keepScreenOnVideo) {
      unawaited(WakelockPlus.disable());
    }
    _pipPreparedSignature = null;
    final pipModeSub = _pipModeSub;
    final pipControlSub = _pipControlSub;
    _pipModeSub = null;
    _pipControlSub = null;
    unawaited(safeCancelSubscription(pipModeSub));
    unawaited(safeCancelSubscription(pipControlSub));
    unawaited(VideoPipHelper.clearPipEligibility());
    unawaited(VideoOrientationChannel.exitPlayerMode());
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
                    onPressed: () => unawaited(_onPlayerBackPressed()),
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
      child: VideoPlayerGestureShell(
        chewieController: chewie,
        onTutorialVisibilityChanged: _onGestureTutorialVisibility,
        videoChild: ZenChewiePlayer(
          controller: chewie,
          colorFilter: _colorFilter,
          surfaceEpoch: _videoSurfaceEpoch,
          pipBoundsKey: _pipVideoBoundsKey,
        ),
      ),
    );
  }

  void _onGestureTutorialVisibility(bool visible) {
    final wasVisible = _gestureTutorialVisible;
    if (!mounted || _gestureTutorialVisible == visible) return;
    setState(() => _gestureTutorialVisible = visible);
    if (wasVisible && !visible) {
      _requestColorTutorial();
    }
  }

  void _requestColorTutorial() {
    if (!mounted) return;
    setState(() => _colorTutorialTrigger++);
  }

  Future<void> _scheduleColorTutorialIfGestureAlreadyDone() async {
    if (_colorTutorialScheduleAttempted) return;
    _colorTutorialScheduleAttempted = true;
    if (await VideoPlayerColorTutorialService.wasSeen()) return;
    final p = await SharedPreferences.getInstance();
    if (p.getBool(kVideoPlayerGestureTutorialPrefsKey) != true) return;
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _requestColorTutorial();
    });
  }

  /// UPlayer-style controls (embedded + Chewie fullscreen route).
  List<Widget> _playerChromeOverlays(BuildContext context) {
    final video = _videoController;
    final chewie = _chewieController;
    if (_initError != null || video == null || chewie == null) {
      return const [];
    }
    if (!video.value.isInitialized) return const [];
    if (_inPipMode) return const [];

    return [
      Positioned.fill(
        child: IgnorePointer(
          ignoring: _gestureTutorialVisible,
          child: ZenVideoPlayerChrome(
            videoController: video,
            chewieController: chewie,
          title: _videoTitle,
          onBack: () => unawaited(_onPlayerBackPressed()),
          onRotate: () => unawaited(_onRotatePressed()),
          onCast: _onCastPressed,
          onDownload: _downloadVideo,
          onPip: () => unawaited(_onPipButtonPressed()),
          showDownload: !widget.isLocal &&
              !widget.useContentUri &&
              widget.allowNetworkDownload,
          showPip: Platform.isAndroid,
          colorFilter: _colorFilter,
          onColorFilterChanged: (settings) {
            if (mounted) setState(() => _colorFilter = settings);
          },
          colorTutorialTrigger: _colorTutorialTrigger,
          isLocalPlayback: widget.isLocal || widget.useContentUri,
          resumedFrom: _resumedFromPosition,
          onResumePromptDismiss: _dismissResumePrompt,
          onStartOver: _startVideoOver,
          onSkipPrevious: VideoPlaybackQueue.isActive
              ? () => unawaited(_skipPrevious())
              : null,
          onSkipNext: VideoPlaybackQueue.isActive && VideoPlaybackQueue.hasNext
              ? () => unawaited(_skipNext())
              : null,
          canSkipToPrevious: VideoPlaybackQueue.hasPrevious,
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        unawaited(_onPlayerBackPressed());
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            _buildBody(),
            ..._playerChromeOverlays(context),
          ],
        ),
      ),
    );
  }
}
