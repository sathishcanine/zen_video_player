import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:zen_video_player/video_preview_screen.dart';

import 'ads/ad_config.dart';
import 'ads/ads_orchestrator.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AdsOrchestrator.init();

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

  /// Handles a deeplink URI. Two responsibilities:
  ///   1. Update ad-network config from any extra query params.
  ///   2. Navigate to the video preview if `url=` is present.
  Future<void> _handleDeeplink(Uri uri) async {
    // Always parse the ad config first so the next ad request uses
    // the freshest network order — this is the runtime kill-switch
    // for restricted networks.
    final updated = AdConfig.fromUri(uri, AdsOrchestrator.config);
    await AdsOrchestrator.applyConfig(updated);

    final video = uri.queryParameters['url'] ?? '';
    if (video.isEmpty) return;
    _navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => VideoPreviewScreen(
          videoSource: video,
          openedViaDeeplink: true,
        ),
      ),
    );
  }

  Future<void> initDeepLinks() async {
    final appLinks = AppLinks();

    final initial = await appLinks.getInitialAppLink();
    if (initial != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleDeeplink(initial);
      });
    }

    _linkSubscription = appLinks.uriLinkStream.listen(_handleDeeplink);
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
