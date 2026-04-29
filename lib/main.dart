import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:zen_video_player/analytics/telemetry.dart';
import 'package:zen_video_player/video_preview_screen.dart';

import 'ads/ad_config.dart';
import 'ads/ads_orchestrator.dart';
import 'app_update/force_update_from_deeplink.dart';
import 'app_update/force_update_screen.dart';
import 'home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Telemetry.init();

  final coldStartUri = await AppLinks().getInitialAppLink();
  await AdsOrchestrator.init(coldStartUri: coldStartUri);

  runZonedGuarded(
    () => runApp(const DiskwalaApp()),
    (error, stack) => Telemetry.recordZoneError(error, stack),
  );
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

  /// Handles a deeplink URI. Responsibilities:
  ///   0. If `latest_version` is set and this build is older, show the
  ///      force-update screen and stop (no ads/video for that link).
  ///   1. Update ad-network config from any extra query params.
  ///   2. Navigate to the video preview if `url=` is present.
  Future<void> _handleDeeplink(Uri uri) async {
    final gate = await forceUpdateGateFromDeeplink(uri);
    if (gate != null) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final nav = _navigatorKey.currentState;
        if (nav == null) return;
        nav.popUntil((r) => r.isFirst);
        nav.push(
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: '/force-update'),
            fullscreenDialog: true,
            builder: (_) => ForceUpdateScreen(
              requiredVersionCode: gate.required,
              currentVersionCode: gate.current,
            ),
          ),
        );
      });
      return;
    }

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
