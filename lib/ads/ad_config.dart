import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Runtime ad configuration.
///
/// Driven by deeplink query params (and persisted) so we can flip
/// networks remotely without a Play Store update — useful when one
/// network suddenly restricts ads.
///
/// Only networks listed in [adOrder] are used by [AdsOrchestrator]
/// for init, preload, rewarded waterfall, and banner fallback — others
/// are not requested (see also cold-start merge in `AdsOrchestrator.init`).
///
/// Deeplink format (query params appended to the existing video deeplink):
///
///   zenvideoplayer://play?url=<videoUrl>
///       &latest_version=11              // optional: if app build < 11, force Play update
///       &ads=admob                       // AdMob only (rewarded → rewarded interstitial)
///       &banner=1                       // 0/1 enable banner
///       &rew=1                          // 0/1 enable rewarded
///       &cap=30                         // max ad requests per hour per device
class AdConfig {
  /// Networks in fallback order. First entry = primary.
  /// Allowed values: "admob".
  final List<String> adOrder;

  /// When true, [adOrder] is shuffled on cold start (see [AdConfig.load]).
  /// With a single network this has no effect; kept for deeplink compat.
  ///
  /// Explicit deeplink orders (e.g. `ads=admob`) flip this to false.
  final bool randomOrder;

  final bool bannerEnabled;
  final bool rewardedEnabled;

  /// Hard cap on total ad load requests per hour per device.
  /// Helps avoid sudden bursts that trigger AdMob "ad serving limit".
  final int maxRequestsPerHour;

  const AdConfig({
    required this.adOrder,
    this.randomOrder = false,
    this.bannerEnabled = true,
    this.rewardedEnabled = true,
    this.maxRequestsPerHour = 30,
  });

  /// Default config used on first install or when no deeplink config
  /// has been persisted yet.
  factory AdConfig.defaults() => AdConfig(
        adOrder: const ['admob'],
        randomOrder: false,
      );

  /// Generates a fresh random ordering of every known network.
  /// Used for default boot config and for `ads=random` deeplinks.
  static List<String> _shuffledKnownNetworks() =>
      _knownNetworks.toList()..shuffle();

  /// Set of network identifiers we recognise. Anything else in the
  /// deeplink is silently dropped to avoid arbitrary input.
  static const Set<String> _knownNetworks = {
    'admob',
  };

  /// Keeps first occurrence only (e.g. `ads=inmobi,admob,inmobi` → inmobi, admob).
  static List<String> _dedupeKnownOrder(List<String> names) {
    final seen = <String>{};
    final out = <String>[];
    for (final n in names) {
      if (_knownNetworks.contains(n) && seen.add(n)) out.add(n);
    }
    return out;
  }

  /// Parse ad config from a deeplink URI. Falls back to [previous]
  /// for any value that's missing or invalid, so partial overrides
  /// from a deeplink are fine.
  factory AdConfig.fromUri(Uri uri, AdConfig previous) {
    final params = uri.queryParameters;

    List<String> order = previous.adOrder;
    bool random = previous.randomOrder;
    final adsParam = params['ads'];
    if (adsParam != null && adsParam.trim().isNotEmpty) {
      final raw = adsParam.trim().toLowerCase();
      if (raw == 'random') {
        // Pin the chain to "rotate every cold start". The shuffle here
        // is just the order for THIS deeplink session; [AdConfig.load]
        // re-shuffles on every subsequent boot while randomOrder=true.
        order = _shuffledKnownNetworks();
        random = true;
      } else {
        final parsed = raw
            .split(',')
            .map((s) => s.trim())
            .where((s) => _knownNetworks.contains(s))
            .toList();
        if (parsed.isNotEmpty) {
          order = _dedupeKnownOrder(parsed);
          // An explicit deeplink order should be respected verbatim,
          // not re-shuffled on the next boot.
          random = false;
        }
      }
    }

    return AdConfig(
      adOrder: order,
      randomOrder: random,
      bannerEnabled: _parseBool(params['banner'], previous.bannerEnabled),
      rewardedEnabled: _parseBool(params['rew'], previous.rewardedEnabled),
      maxRequestsPerHour: _parseIntInRange(
        params['cap'],
        previous.maxRequestsPerHour,
        min: 1,
        max: 1000,
      ),
    );
  }

  AdConfig copyWith({
    List<String>? adOrder,
    bool? randomOrder,
    bool? bannerEnabled,
    bool? rewardedEnabled,
    int? maxRequestsPerHour,
  }) {
    return AdConfig(
      adOrder: adOrder ?? this.adOrder,
      randomOrder: randomOrder ?? this.randomOrder,
      bannerEnabled: bannerEnabled ?? this.bannerEnabled,
      rewardedEnabled: rewardedEnabled ?? this.rewardedEnabled,
      maxRequestsPerHour: maxRequestsPerHour ?? this.maxRequestsPerHour,
    );
  }

  Map<String, dynamic> toJson() => {
        'adOrder': adOrder,
        'random': randomOrder,
        'banner': bannerEnabled,
        'rew': rewardedEnabled,
        'cap': maxRequestsPerHour,
      };

  factory AdConfig.fromJson(Map<String, dynamic> j) {
    final raw = (j['adOrder'] as List?)
        ?.map((e) => e.toString())
        .where(_knownNetworks.contains)
        .toList();
    final order = (raw == null || raw.isEmpty)
        ? AdConfig.defaults().adOrder
        : _dedupeKnownOrder(raw);
    return AdConfig(
      adOrder: order,
      randomOrder: j['random'] as bool? ?? false,
      bannerEnabled: j['banner'] as bool? ?? true,
      rewardedEnabled: j['rew'] as bool? ?? true,
      maxRequestsPerHour: j['cap'] as int? ?? 30,
    );
  }

  static const String _prefsKey = 'ads_config_v1';

  static Future<AdConfig> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return AdConfig.defaults();
      final loaded = AdConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      // Re-shuffle on every cold start while in random mode, so a manual
      // launch doesn't keep hitting the same network first when one of
      // them (like AdMob) is currently restricted. Explicit deeplink
      // orders bypass this branch and are used verbatim.
      if (loaded.randomOrder) {
        return loaded.copyWith(adOrder: _shuffledKnownNetworks());
      }
      return loaded;
    } catch (_) {
      return AdConfig.defaults();
    }
  }

  Future<void> save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(toJson()));
    } catch (_) {
      // Persistence is best-effort. In-memory config still works.
    }
  }

  @override
  String toString() =>
      'AdConfig(order=$adOrder${randomOrder ? " (random)" : ""} '
      'banner=$bannerEnabled rew=$rewardedEnabled '
      'cap=$maxRequestsPerHour/h)';
}

bool _parseBool(String? raw, bool fallback) {
  if (raw == null) return fallback;
  final v = raw.trim().toLowerCase();
  if (v == '1' || v == 'true' || v == 'on' || v == 'yes') return true;
  if (v == '0' || v == 'false' || v == 'off' || v == 'no') return false;
  return fallback;
}

int _parseIntInRange(String? raw, int fallback, {required int min, required int max}) {
  if (raw == null) return fallback;
  final v = int.tryParse(raw.trim());
  if (v == null) return fallback;
  if (v < min || v > max) return fallback;
  return v;
}
