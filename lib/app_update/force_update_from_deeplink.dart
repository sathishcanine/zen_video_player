import 'package:package_info_plus/package_info_plus.dart';

/// Parses `latest_version` from a deeplink (Android versionCode / build number).
int? parseRequiredVersionFromDeeplink(Uri uri) {
  final raw = uri.queryParameters['latest_version']?.trim();
  if (raw == null || raw.isEmpty) return null;
  final v = int.tryParse(raw);
  if (v == null || v <= 0) return null;
  return v;
}

/// If the app must update before honoring the deeplink, returns
/// `(required, current)`; otherwise null.
Future<({int required, int current})?> forceUpdateGateFromDeeplink(
  Uri uri,
) async {
  final required = parseRequiredVersionFromDeeplink(uri);
  if (required == null) return null;
  final info = await PackageInfo.fromPlatform();
  final current = int.tryParse(info.buildNumber.trim()) ?? 0;
  if (current >= required) return null;
  return (required: required, current: current);
}
