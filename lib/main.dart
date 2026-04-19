import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
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
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  void _pushVideoPreviewFromUri(Uri uri) {
    final video = uri.queryParameters['url'] ?? '';
    if (video.isEmpty) return;
    _navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => VideoPreviewScreen(videoSource: video),
      ),
    );
  }

  Future<void> initDeepLinks() async {
    final appLinks = AppLinks();

    // Link that launched the app from a terminated process (cold start).
    final initial = await appLinks.getInitialAppLink();
    if (initial != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pushVideoPreviewFromUri(initial);
      });
    }

    // Links while app is running or resumed from background.
    _linkSubscription = appLinks.uriLinkStream.listen(_pushVideoPreviewFromUri);
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
