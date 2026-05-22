import 'package:flutter/material.dart';

import '../services/media_permission_service.dart';
import 'ads_orchestrator.dart';

/// Bottom banner on the library shell — AdMob unit depends on full vs limited
/// video access.
class HomeBannerAd extends StatefulWidget {
  const HomeBannerAd({super.key});

  @override
  State<HomeBannerAd> createState() => _HomeBannerAdState();
}

class _HomeBannerAdState extends State<HomeBannerAd>
    with WidgetsBindingObserver {
  bool? _hasFullVideoAccess;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshAccess();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshAccess();
    }
  }

  Future<void> _refreshAccess() async {
    final full = await MediaPermissionService.hasFullVideoAccess();
    if (!mounted) return;
    if (_hasFullVideoAccess == full) return;
    setState(() => _hasFullVideoAccess = full);
  }

  @override
  Widget build(BuildContext context) {
    if (!AdsOrchestrator.config.bannerEnabled) {
      return const SizedBox.shrink();
    }

    final hasFull = _hasFullVideoAccess;
    if (hasFull == null) {
      return const SizedBox(height: 50);
    }

    final banner = AdsOrchestrator.buildHomeBanner(hasFullVideoAccess: hasFull);
    if (banner == null) return const SizedBox.shrink();

    return SafeArea(
      top: false,
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: banner,
      ),
    );
  }
}
