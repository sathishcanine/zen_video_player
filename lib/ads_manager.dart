import 'ads/ads_orchestrator.dart';

/// Backwards-compat facade kept so existing screens keep working.
class AdsManager {
  /// Convenience initializer for callers that only know the old API.
  static Future<void> init() => AdsOrchestrator.init();
}
