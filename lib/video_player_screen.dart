import 'dart:async';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:zen_video_player/analytics/video_player_telemetry.dart';

import 'download_service.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoSource;
  final bool isLocal;

  /// App bar download for network URLs; ignored when [isLocal] is true.
  final bool allowNetworkDownload;

  const VideoPlayerScreen({
    super.key,
    required this.videoSource,
    this.isLocal = false,
    this.allowNetworkDownload = true,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  /// Hard ceiling so a hung CDN, redirect chain, or unsupported codec
  /// can't strand the user on the spinner forever. ExoPlayer's
  /// `initialize()` future does not always settle on its own when the
  /// underlying media source fails — wrapping it in a timeout is the
  /// only reliable way to recover.
  static const Duration _initTimeout = Duration(seconds: 20);

  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  /// Populated when init throws or times out. Drives the error state
  /// in [build]; null while still loading or after a successful init.
  String? _initError;

  /// Dedupes repeated [VideoPlayerValue.hasError] listener callbacks.
  String? _lastEmittedPlaybackError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        VideoPlayerTelemetry.screenOpened(
          isLocal: widget.isLocal,
          allowNetworkDownload: widget.allowNetworkDownload,
          videoSource: widget.videoSource,
        ),
      );
    });
    unawaited(_initializePlayer());
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
        isLocal: widget.isLocal,
        videoSource: widget.videoSource,
      ),
    );

    final controller = widget.isLocal
        ? VideoPlayerController.file(File(widget.videoSource))
        : VideoPlayerController.networkUrl(Uri.parse(widget.videoSource));

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
          isLocal: widget.isLocal,
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
      await controller.dispose();
      if (identical(_videoController, controller)) {
        _videoController = null;
      }
      return;
    }

    if (!mounted) {
      await controller.dispose();
      return;
    }

    dismissLoadingHint();
    sw.stop();
    unawaited(
      VideoPlayerTelemetry.initSucceeded(
        isLocal: widget.isLocal,
        videoSource: widget.videoSource,
        elapsed: sw.elapsed,
      ),
    );

    controller.addListener(_onVideoValueChanged);

    _chewieController = ChewieController(
      videoPlayerController: controller,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      allowMuting: true,
      allowPlaybackSpeedChanging: true,
    );

    setState(() {});
  }

  void _onVideoValueChanged() {
    final c = _videoController;
    if (c == null || !mounted) return;
    if (!c.value.hasError) return;
    final desc = c.value.errorDescription ?? 'unknown';
    if (desc == _lastEmittedPlaybackError) return;
    _lastEmittedPlaybackError = desc;
    unawaited(
      VideoPlayerTelemetry.playbackError(
        isLocal: widget.isLocal,
        videoSource: widget.videoSource,
        errorDescription: desc,
      ),
    );
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
    _videoController?.removeListener(_onVideoValueChanged);
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Widget _buildBody() {
    final error = _initError;
    if (error != null) {
      return Padding(
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
      );
    }

    final chewie = _chewieController;
    if (chewie == null) {
      return const CircularProgressIndicator();
    }
    return Chewie(controller: chewie);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video Player"),
        actions: [
          if (!widget.isLocal && widget.allowNetworkDownload)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _downloadVideo,
            )
        ],
      ),
      body: Center(
        child: _buildBody(),
      ),
    );
  }
}
