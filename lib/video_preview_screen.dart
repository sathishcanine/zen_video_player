import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:zen_video_player/rewarded_ads.dart';

import 'ads/video_preview_native_ad.dart';

class VideoPreviewScreen extends StatefulWidget {

  final String videoSource;
  final bool isLocal;

  /// When true, the video was opened from an app deep link (not pasted on home).
  /// Remote download is offered only for deep links and local files.
  final bool openedViaDeeplink;

  const VideoPreviewScreen({
    super.key,
    required this.videoSource,
    this.isLocal = false,
    this.openedViaDeeplink = false,
  });

  @override
  State<VideoPreviewScreen> createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<VideoPreviewScreen> {

  VideoPlayerController? _previewController;
  bool _previewFailed = false;

  @override
  void initState() {
    super.initState();
    _initPreview();
  }

  @override
  void dispose() {
    _previewController?.dispose();
    super.dispose();
  }

  Future<void> _initPreview() async {
    VideoPlayerController? c;
    try {
      if (widget.isLocal) {
        c = VideoPlayerController.file(File(widget.videoSource));
      } else {
        c = VideoPlayerController.networkUrl(Uri.parse(widget.videoSource));
      }
      await c.initialize();
      await c.setVolume(0);
      await c.pause();
      if (!mounted) {
        await c.dispose();
        return;
      }
      setState(() {
        _previewController = c;
      });
    } catch (_) {
      await c?.dispose();
      if (mounted) {
        setState(() => _previewFailed = true);
      }
    }
  }

  void _playVideo() {

    AdManager.showRewarded(
      context,
      url: widget.videoSource,
      isLocal: widget.isLocal,
      allowNetworkDownloadInPlayer: widget.openedViaDeeplink,
    );

  }

  void _downloadVideo() {
    AdManager.showRewarded(
      context,
      url: widget.videoSource,
      isLocal: widget.isLocal,
      download: true,
    );

  }


  bool get _showDownload =>
      widget.isLocal || widget.openedViaDeeplink;

  @override
  Widget build(BuildContext context) {

    String fileName = widget.videoSource.split('/').last;

    return Scaffold(

      appBar: AppBar(
        title: const Text("Video Preview"),
        centerTitle: true,
      ),

      body: Container(

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xff0f0c29),
              Color(0xff302b63),
              Color(0xff24243e),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              const SizedBox(height: 2),

              /// PREVIEW
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [

                    if (_previewFailed)

                      Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.videocam_off_outlined,
                            color: Colors.white54,
                            size: 56,
                          ),
                        ),
                      )

                    else if (_previewController?.value.isInitialized != true)

                      Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      )

                    else

                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                          height: 220,
                          width: double.infinity,
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _previewController!.value.size.width,
                              height: _previewController!.value.size.height,
                              child: VideoPlayer(_previewController!),
                            ),
                          ),
                        ),
                      ),

                    /// PLAY ICON OVERLAY
                    GestureDetector(
                      onTap: _playVideo,
                      child: Container(
                        height: 65,
                        width: 65,
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    )

                  ],
                ),
              ),

              const SizedBox(height: 12),

              /// VIDEO SOURCE INFO
              Text(
                widget.isLocal ? "Local Video" : "Online Video",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                fileName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 10),

                Center(
                  child: Text(
                    _showDownload
                        ? "Watch and complete a rewarded ad to start playback or download."
                        : "Watch and complete a rewarded ad to start playback.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                /// PLAY BUTTON
              SizedBox(
                width: double.infinity,
                height: 45,

                child: ElevatedButton.icon(

                  icon: const Icon(Icons.play_arrow,color: Colors.white,),

                  label: const Text(
                    "Play Video",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),

                  onPressed: _playVideo,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),

                ),
              ),

              if (_showDownload) ...[

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 45,

                  child: ElevatedButton.icon(

                    icon: const Icon(Icons.download,color: Colors.white),

                    label: const Text(
                      "Download Video",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),

                    onPressed: _downloadVideo,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),

                  ),
                ),

              ],

              const SizedBox(height: 20),

              const Center(
                child: VideoPreviewNativeAd(),
              ),

              const SizedBox(height: 20),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
