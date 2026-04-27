import 'package:flutter/material.dart';

/// Common interface every ad network adapter must implement.
///
/// The orchestrator only talks to this interface, so swapping or
/// reordering networks is just config work — no caller changes.
abstract class AdNetwork {
  /// Stable identifier used in deeplink config (e.g. "admob", "unity").
  String get name;

  /// Whether the SDK has been successfully initialized.
  bool get isInitialized;

  /// One-time SDK initialization. Safe to call multiple times.
  Future<void> init();

  /// Preload an interstitial in the background. Should be idempotent.
  void preloadInterstitial();

  /// Preload a rewarded ad in the background. Should be idempotent.
  void preloadRewarded();

  /// Show an interstitial if one is ready. Returns true if shown.
  Future<bool> showInterstitial();

  /// Show a rewarded ad. [onReward] fires only if the user actually
  /// earned the reward. Returns true if an ad was displayed.
  Future<bool> showRewarded({required VoidCallback onReward});

  /// Build a banner widget. Returns null if banner is not supported
  /// or the SDK is not ready.
  Widget? buildBanner();
}
