
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:zen_video_player/rewarded_ads.dart';
import 'package:zen_video_player/video_preview_screen.dart';
import 'home_screen.dart';
import 'video_player_screen.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await AdManager.initialize();

  runApp(const DiskwalaApp());

}

class DiskwalaApp extends StatefulWidget {
  const DiskwalaApp({super.key});

  @override
  State<DiskwalaApp> createState() => _DiskwalaAppState();
}

class _DiskwalaAppState extends State<DiskwalaApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    initDeepLinks();
  }

  void initDeepLinks() async {
    final appLinks = AppLinks();
    appLinks.uriLinkStream.listen((uri) {
      if (uri != null) {
        String video = uri.queryParameters['url'] ?? "";
        _navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => VideoPreviewScreen(videoSource: video),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}
