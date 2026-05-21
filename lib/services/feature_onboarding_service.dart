import 'package:shared_preferences/shared_preferences.dart';

/// Persists whether the 4-page feature intro was completed.
class FeatureOnboardingService {
  FeatureOnboardingService._();

  static const _completedKey = 'feature_onboarding_completed_v1';

  static Future<bool> isCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_completedKey) ?? false;
  }

  static Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_completedKey, true);
  }
}
