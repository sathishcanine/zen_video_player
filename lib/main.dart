import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:zen_video_player/utils/media_display_name.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:zen_video_player/analytics/telemetry.dart';
import 'package:zen_video_player/video_preview_screen.dart';

import 'ads/ad_config.dart';
import 'ads/ads_orchestrator.dart';
import 'app_update/force_update_from_deeplink.dart';
import 'app_update/force_update_screen.dart';
import 'app_navigator.dart';
import 'home_screen.dart';
import 'services/app_cache_maintenance.dart';
import 'services/app_settings_service.dart';
import 'services/audio_player_service.dart';
import 'services/active_session_tracker.dart';
import 'services/feature_announcement_service.dart';
import 'services/pro_features_service.dart';
import 'services/cast_service.dart';
import 'services/locale_service.dart';
import 'services/play_store_rating_service.dart';
import 'theme/zen_theme.dart';
import 'video_player_screen.dart';
import 'widgets/play_store_rating_coordinator.dart';

bool _isOpenWithVideoUri(Uri? uri) {
  if (uri == null) return false;
  final s = uri.scheme.toLowerCase();
  return s == 'content' || s == 'file';
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Silent cache repair for 3.0.2 storage leak — no user steps required.
  await AppCacheMaintenance.runOnColdStart();

  // Parallel prefs — safe for 15k+ upgraders; avoids serial cold-start stalls.
  await Future.wait<void>([
    LocaleService.instance.load(),
    AppSettingsService.instance.load(),
    ProFeaturesService.instance.load(),
  ]);

  final coldStartUri = await AppLinks().getInitialAppLink();
  final coldStartOpenVideo =
      _isOpenWithVideoUri(coldStartUri) ? coldStartUri : null;

  if (!kIsWeb) {
    await AudioPlayerService.init();
  }

  runZonedGuarded(
    () {
      runApp(DiskwalaApp(coldStartOpenVideo: coldStartOpenVideo));
      // Defer heavy SDK init until after first frame (reduces ANR risk on update).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(Telemetry.init());
        if (!kIsWeb) {
          unawaited(CastService.instance.init());
        }
        unawaited(AdsOrchestrator.init(coldStartUri: coldStartUri));
        ActiveSessionTracker.instance.start();
        unawaited(PlayStoreRatingService.recordCalendarDay());
        unawaited(FeatureAnnouncementService.recordVersionOnColdStart());
      });
    },
    (error, stack) => Telemetry.recordZoneError(error, stack),
  );
}

class DiskwalaApp extends StatefulWidget {
  const DiskwalaApp({super.key, this.coldStartOpenVideo});

  /// Non-null when the app was cold-started from "Open with" on a video.
  final Uri? coldStartOpenVideo;

  @override
  State<DiskwalaApp> createState() => _DiskwalaAppState();
}

class _DiskwalaAppState extends State<DiskwalaApp> {
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    LocaleService.instance.addListener(_onLocaleChanged);
    initDeepLinks();
  }

  @override
  void dispose() {
    LocaleService.instance.removeListener(_onLocaleChanged);
    _linkSubscription?.cancel();
    super.dispose();
  }

  void _onLocaleChanged() => setState(() {});

  /// Handles a deeplink URI. Responsibilities:
  ///   0. If `latest_version` is set and this build is older, show the
  ///      force-update screen and stop (no ads/video for that link).
  ///   1. Update ad-network config from any extra query params.
  ///   2. Navigate to the video preview if `url=` is present.
  Future<void> _handleDeeplink(Uri uri) async {
    final scheme = uri.scheme.toLowerCase();
    if (scheme == 'content' || scheme == 'file') {
      if (!mounted) return;
      void pushOpenWith() {
        if (!mounted) return;
        final nav = rootNavigatorKey.currentState;
        if (nav == null) return;
        final isContent = scheme == 'content';
        final displayTitle = MediaDisplayName.forVideoSource(
          source: uri.toString(),
          isLocal: !isContent,
        );
        nav.push(
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: '/open-with'),
            builder: (_) => VideoPlayerScreen(
              videoSource: uri.toString(),
              isLocal: !isContent,
              useContentUri: isContent,
              allowNetworkDownload: false,
              displayTitle: displayTitle,
            ),
          ),
        );
      }

      if (rootNavigatorKey.currentState != null) {
        pushOpenWith();
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) => pushOpenWith());
      }
      return;
    }

    final gate = await forceUpdateGateFromDeeplink(uri);
    if (gate != null) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final nav = rootNavigatorKey.currentState;
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
    rootNavigatorKey.currentState?.push(
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
    if (initial != null && !_isOpenWithVideoUri(initial)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleDeeplink(initial);
      });
    }

    _linkSubscription = appLinks.uriLinkStream.listen(_handleDeeplink);
  }

  List<Route<dynamic>> _onGenerateInitialRoutes(String initialRoute) {
    final open = widget.coldStartOpenVideo;
    if (open != null) {
      final isContent = open.scheme.toLowerCase() == 'content';
      final displayTitle = MediaDisplayName.forVideoSource(
        source: open.toString(),
        isLocal: !isContent,
      );
      return <Route<dynamic>>[
        MaterialPageRoute<void>(
          settings: const RouteSettings(name: '/'),
          builder: (_) => const HomeScreen(),
        ),
        MaterialPageRoute<void>(
          settings: const RouteSettings(name: '/openWith'),
          builder: (_) => VideoPlayerScreen(
            videoSource: open.toString(),
            isLocal: !isContent,
            useContentUri: isContent,
            allowNetworkDownload: false,
            displayTitle: displayTitle,
          ),
        ),
      ];
    }
    return <Route<dynamic>>[
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: '/'),
        builder: (_) => const HomeScreen(),
      ),
    ];
  }

  /// Required alongside [onGenerateInitialRoutes]: Flutter's [MaterialApp]
  /// assertion only treats `home`, `routes`, [onGenerateRoute], or
  /// [onUnknownRoute] as a valid routing setup — [onGenerateInitialRoutes]
  /// alone is not enough. Initial paint still comes from
  /// [_onGenerateInitialRoutes]; this handles any later named-route requests.
  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const HomeScreen(),
        );
      default:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const HomeScreen(),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        LocaleService.instance,
        AppSettingsService.instance,
      ]),
      builder: (context, _) {
        final saved = LocaleService.instance.locale;
        final settings = AppSettingsService.instance;
        final appTheme = settings.isDarkTheme
            ? ZenTheme.dark(primary: settings.primaryColor)
            : ZenTheme.light(primary: settings.primaryColor);
        return MaterialApp(
          navigatorKey: rootNavigatorKey,
          debugShowCheckedModeBanner: false,
          builder: (context, child) => PlayStoreRatingCoordinator(
            child: child ?? const SizedBox.shrink(),
          ),
          theme: appTheme,
          locale: saved,
          localeResolutionCallback: (locale, supported) {
            if (saved != null) {
              for (final l in supported) {
                if (l.languageCode == saved.languageCode) return l;
              }
            }
            if (locale == null) return const Locale('en');
            for (final l in supported) {
              if (l.languageCode == locale.languageCode) return l;
            }
            return const Locale('en');
          },
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          initialRoute: '/',
          onGenerateInitialRoutes: _onGenerateInitialRoutes,
          onGenerateRoute: _onGenerateRoute,
        );
      },
    );
  }
}
