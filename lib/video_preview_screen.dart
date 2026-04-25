import 'dart:io';
import 'package:flutter/material.dart';
import 'package:zen_video_player/rewarded_ads.dart';
import 'package:zen_video_player/thumbnail_service.dart';

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

  String? thumbnail;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  Future<void> _loadThumbnail() async {

    final thumb =
    await ThumbnailService.generateThumbnail(widget.videoSource);

    if (!mounted) return;

    setState(() {
      thumbnail = thumb;
    });
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

        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              const SizedBox(height: 20),

              /// THUMBNAIL
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [

                    if (thumbnail == null)

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
                        child: Image.file(
                          File(thumbnail!),
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),

                    /// PLAY ICON OVERLAY
                    GestureDetector(
                      onTap: _playVideo,
                      child: Container(
                        height: 70,
                        width: 70,
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

              const SizedBox(height: 30),

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

              const SizedBox(height: 40),

              /// PLAY BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton.icon(

                  icon: const Icon(Icons.play_arrow),

                  label: const Text(
                    "Play Video",
                    style: TextStyle(fontSize: 16),
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
                  height: 55,

                  child: ElevatedButton.icon(

                    icon: const Icon(Icons.download),

                    label: const Text(
                      "Download Video",
                      style: TextStyle(fontSize: 16),
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

              const Spacer(),

              /// INFO TEXT
              Center(
                child: Text(
                  _showDownload
                      ? "Watch and complete a rewarded ad to start playback or download."
                      : "Watch and complete a rewarded ad to start playback.",
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(height: 20),

            ],
          ),
        ),
      ),
    );
  }
}