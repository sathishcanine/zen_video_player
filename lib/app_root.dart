import 'package:flutter/material.dart';

import 'theme/zen_theme.dart';
import 'screens/feature_onboarding_screen.dart';
import 'screens/library_shell_screen.dart';
import 'screens/media_access_screen.dart';
import 'services/feature_onboarding_service.dart';
import 'services/media_permission_service.dart';

enum _StartupPhase { loading, featureOnboarding, mediaPermission, library }

/// Feature intro → media permission → library.
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  _StartupPhase _phase = _StartupPhase.loading;

  @override
  void initState() {
    super.initState();
    _resolveStartScreen();
  }

  Future<void> _resolveStartScreen() async {
    final featureDone = await FeatureOnboardingService.isCompleted();
    final needsMedia = await MediaPermissionService.shouldShowOnboarding();

    if (!mounted) return;
    setState(() {
      if (!featureDone) {
        _phase = _StartupPhase.featureOnboarding;
      } else if (needsMedia) {
        _phase = _StartupPhase.mediaPermission;
      } else {
        _phase = _StartupPhase.library;
      }
    });
  }

  Future<void> _goToPostFeatureOnboarding() async {
    final needsMedia = await MediaPermissionService.shouldShowOnboarding();
    if (!mounted) return;
    setState(() {
      _phase =
          needsMedia ? _StartupPhase.mediaPermission : _StartupPhase.library;
    });
  }

  void _enterLibrary() {
    setState(() => _phase = _StartupPhase.library);
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case _StartupPhase.loading:
        return const Scaffold(
          backgroundColor: Colors.transparent,
          body: ZenGradientBackground(
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      case _StartupPhase.featureOnboarding:
        return FeatureOnboardingScreen(
          onComplete: _goToPostFeatureOnboarding,
        );
      case _StartupPhase.mediaPermission:
        return MediaAccessScreen(onComplete: _enterLibrary);
      case _StartupPhase.library:
        return const LibraryShellScreen();
    }
  }
}
