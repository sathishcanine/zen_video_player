import 'package:flutter/widgets.dart';

/// Tracks **foreground** time for the current app session (paused when backgrounded).
class ActiveSessionTracker with WidgetsBindingObserver {
  ActiveSessionTracker._();

  static final ActiveSessionTracker instance = ActiveSessionTracker._();

  /// Minimum engaged session before a video-exit interstitial may show.
  static const Duration videoExitAdMinSession = Duration(minutes: 3);

  /// Start preloading the exit interstitial when the user is close to eligible.
  static const Duration videoExitAdPreloadSession = Duration(minutes: 2);

  Duration _accumulated = Duration.zero;
  DateTime? _resumedAt;
  bool _observing = false;

  void start() {
    if (_observing) return;
    WidgetsBinding.instance.addObserver(this);
    _observing = true;
    if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      _resumedAt = DateTime.now();
    }
  }

  void stop() {
    if (!_observing) return;
    _flush();
    WidgetsBinding.instance.removeObserver(this);
    _observing = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _resumedAt ??= DateTime.now();
      return;
    }
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _flush();
    }
  }

  void _flush() {
    final start = _resumedAt;
    if (start != null) {
      _accumulated += DateTime.now().difference(start);
      _resumedAt = null;
    }
  }

  Duration get activeDuration {
    var total = _accumulated;
    final start = _resumedAt;
    if (start != null) {
      total += DateTime.now().difference(start);
    }
    return total;
  }

  bool get meetsVideoExitAdThreshold =>
      activeDuration >= videoExitAdMinSession;

  bool get meetsPreloadThreshold =>
      activeDuration >= videoExitAdPreloadSession;
}
