import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../analytics/telemetry.dart';

/// Firebase Remote Config keys (console parameter names).
abstract final class ForceUpdateRemoteConfigKeys {
  static const forceUpdateEnabled = 'force_update_enabled';
  static const minSupportedVersionCode = 'min_supported_version_code';
}

/// Result when this install is below [ForceUpdateRemoteConfigKeys.minSupportedVersionCode].
class ForceUpdateGate {
  const ForceUpdateGate({
    required this.requiredVersionCode,
    required this.currentVersionCode,
  });

  final int requiredVersionCode;
  final int currentVersionCode;
}

/// Reads force-update flags from Firebase Remote Config.
///
/// [min_supported_version_code] must be the Android **versionCode** (the number
/// after `+` in `pubspec.yaml`, e.g. `3.0.3+20` → use **20**), not `3` from
/// the marketing version.
class ForceUpdateRemoteConfig {
  ForceUpdateRemoteConfig._();

  static FirebaseRemoteConfig? _config;

  static Future<void> prefetch() async {
    if (!Telemetry.isFirebaseReady) return;
    try {
      final rc = _remoteConfig;
      await rc.setDefaults(const {
        ForceUpdateRemoteConfigKeys.forceUpdateEnabled: false,
        ForceUpdateRemoteConfigKeys.minSupportedVersionCode: 0,
      });
      await rc.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 12),
          minimumFetchInterval: kDebugMode
              ? Duration.zero
              : const Duration(hours: 1),
        ),
      );
      await rc.fetchAndActivate();
    } catch (e, st) {
      debugPrint('[force_update] Remote Config prefetch failed: $e\n$st');
    }
  }

  /// Returns a gate when the user must update; otherwise null.
  static Future<ForceUpdateGate?> evaluate() async {
    if (!Telemetry.isFirebaseReady) return null;

    try {
      await prefetch();
      final rc = _remoteConfig;
      if (!rc.getBool(ForceUpdateRemoteConfigKeys.forceUpdateEnabled)) {
        return null;
      }

      final required = rc.getInt(
        ForceUpdateRemoteConfigKeys.minSupportedVersionCode,
      );
      if (required <= 0) return null;

      final info = await PackageInfo.fromPlatform();
      final current = int.tryParse(info.buildNumber.trim()) ?? 0;
      if (current >= required) return null;

      return ForceUpdateGate(
        requiredVersionCode: required,
        currentVersionCode: current,
      );
    } catch (e, st) {
      debugPrint('[force_update] evaluate failed: $e\n$st');
      return null;
    }
  }

  static FirebaseRemoteConfig get _remoteConfig {
    return _config ??= FirebaseRemoteConfig.instance;
  }
}
