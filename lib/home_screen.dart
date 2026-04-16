import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

import 'video_preview_screen.dart';
import 'ads_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final TextEditingController controller = TextEditingController();
  final FocusNode urlFocus = FocusNode();

  /// banner ad
  BannerAdWidget? banner;

  /// recently opened local videos
  List<String> recentVideos = [];

  @override
  void initState() {
    super.initState();
    banner = BannerAdWidget();
  }

  /// PICK LOCAL VIDEO
  Future<void> pickVideo() async {

    FilePickerResult? result =
    await FilePicker.platform.pickFiles(type: FileType.video);

    if (result != null) {

      String path = result.files.single.path!;

      /// add to recent list
      setState(() {

        recentVideos.remove(path);
        recentVideos.insert(0, path);

        if (recentVideos.length > 10) {
          recentVideos = recentVideos.sublist(0, 10);
        }
      });

      openVideo(path, true);
    }
  }

  /// PLAY VIDEO FROM URL
  void playUrl() {

    if (controller.text.isEmpty) return;

    openVideo(controller.text, false);
  }

  /// OPEN VIDEO PLAYER
  void openVideo(String source, bool isLocal) {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPreviewScreen(
          videoSource: source,
          isLocal: isLocal,
        ),
      ),
    );
  }

  /// FEATURE CARD
  Widget buildCard({
    required IconData icon,
    required String title,
    required Color color,
    VoidCallback? onTap,
  }) {

    return GestureDetector(

      onTap: onTap,

      child: Container(

        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.08),
          borderRadius: BorderRadius.circular(20),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(icon, size: 40, color: color),

            const SizedBox(height: 10),

            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// RECENT VIDEO LIST
  Widget recentVideosSection() {

    if (recentVideos.isEmpty) {

      return Container(
        height: 110,
        alignment: Alignment.center,
        child: const Text(
          "No recent videos",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return SizedBox(
      height: 120,

      child: ListView.builder(

        scrollDirection: Axis.horizontal,
        itemCount: recentVideos.length,

        itemBuilder: (context, index) {

          String video = recentVideos[index];
          String name = p.basename(video);

          return GestureDetector(

            onTap: () => openVideo(video, true),

            child: Container(

              width: 160,
              margin: const EdgeInsets.only(right: 12),

              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.08),
                borderRadius: BorderRadius.circular(12),
              ),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  const Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 40,
                  ),

                  const SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),

                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      resizeToAvoidBottomInset: true,

      appBar: AppBar(
        title: const Text("Zen Video Player"),
        centerTitle: true,
        elevation: 0,
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

                /// TITLE
                const Text(
                  "Play Videos Instantly",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                /// RECENT VIDEOS
                recentVideosSection(),

                const SizedBox(height: 25),

                /// FEATURE GRID
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  physics: const NeverScrollableScrollPhysics(),

                  children: [

                    buildCard(
                      icon: Icons.video_library,
                      title: "Local Videos",
                      color: Colors.deepPurple,
                      onTap: pickVideo,
                    ),

                    buildCard(
                      icon: Icons.link,
                      title: "Play URL",
                      color: Colors.blue,
                      onTap: () {

                        FocusScope.of(context).requestFocus(urlFocus);

                        Future.delayed(const Duration(milliseconds: 300), () {

                          if (urlFocus.context != null) {
                            Scrollable.ensureVisible(
                              urlFocus.context!,
                              duration: const Duration(milliseconds: 300),
                            );
                          }
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                /// URL INPUT
                Container(
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.08),
                    borderRadius: BorderRadius.circular(15),
                  ),

                  child: Column(
                    children: [

                      TextField(
                        controller: controller,
                        focusNode: urlFocus,
                        style: const TextStyle(color: Colors.white),

                        decoration: InputDecoration(

                          hintText: "Paste video URL here",
                          hintStyle: const TextStyle(color: Colors.white70),

                          border: const OutlineInputBorder(),

                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => controller.clear(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      SizedBox(
                        width: double.infinity,
                        height: 50,

                        child: ElevatedButton.icon(

                          onPressed: playUrl,

                          icon: const Icon(Icons.play_arrow),

                          label: const Text(
                            "Play Video",
                            style: TextStyle(fontSize: 16),
                          ),

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                /// BANNER AD
                if (banner != null)
                  Center(
                    child: banner!,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}