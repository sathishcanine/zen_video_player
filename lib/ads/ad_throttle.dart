import 'dart:collection';

/// Device-side rate limiter for ad requests.
///
/// Background: AdMob's "ad serving limit" can be triggered by sudden
/// request bursts (e.g. 25k requests in 3 hours right after launch).
/// Throttling on-device gives every network breathing room and
/// reduces the chance of a network-level restriction.
class AdThrottle {
  AdThrottle._();

  /// Sliding window of recent ad LOAD timestamps (across all networks).
  /// Used to enforce [maxRequestsPerHour].
  static final Queue<DateTime> _recentRequests = Queue<DateTime>();

  /// Returns true if we're under the hourly cap. Prefer calling this
  /// before kicking off any network's load() to avoid wasted requests.
  static bool canRequest(int maxPerHour) {
    _evictOld();
    return _recentRequests.length < maxPerHour;
  }

  static void recordRequest() {
    _recentRequests.add(DateTime.now());
    _evictOld();
  }

  static void _evictOld() {
    final cutoff = DateTime.now().subtract(const Duration(hours: 1));
    while (_recentRequests.isNotEmpty &&
        _recentRequests.first.isBefore(cutoff)) {
      _recentRequests.removeFirst();
    }
  }

  /// Test/debug helper.
  static int get recentRequestCount {
    _evictOld();
    return _recentRequests.length;
  }
}
