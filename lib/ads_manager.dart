import 'package:flutter/material.dart';

import 'ads/ads_orchestrator.dart';

/// Backwards-compat facade kept so existing screens keep working.
class AdsManager {
  /// Convenience initializer for callers that only know the old API.
  static Future<void> init() => AdsOrchestrator.init();
}

/// Banner widget backed by the orchestrator's primary network.
/// Renders nothing if banners are disabled or no network is available.
class BannerAdWidget extends StatelessWidget {
  const BannerAdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final w = AdsOrchestrator.buildBanner();
    return w ?? const SizedBox.shrink();
  }
}
