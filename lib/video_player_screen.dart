import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
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

  late VideoPlayerController _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {

    if (widget.isLocal) {
      _videoController =
          VideoPlayerController.file(File(widget.videoSource));
    } else {
      _videoController =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoSource));
    }

    await _videoController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoController,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      allowMuting: true,
      allowPlaybackSpeedChanging: true,
    );

    if (mounted) {
      setState(() {});
    }
  }

  void _downloadVideo() {
    DownloadService.downloadFile(widget.videoSource);
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
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
        child: _chewieController == null
            ? const CircularProgressIndicator()
            : Chewie(controller: _chewieController!),
      ),

    );
  }
}