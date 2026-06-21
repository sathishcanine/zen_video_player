import 'dart:async';

import 'package:flutter/foundation.dart';

/// Stops audio/video after a delay or when the current item finishes.
class SleepTimerService extends ChangeNotifier {
  SleepTimerService._();

  static final SleepTimerService instance = SleepTimerService._();

  Timer? _timer;
  DateTime? _endsAt;
  bool _stopAtEndOfMedia = false;

  bool get isActive => _timer != null || _stopAtEndOfMedia;
  bool get stopAtEndOfMedia => _stopAtEndOfMedia;
  DateTime? get endsAt => _endsAt;

  Duration? get remaining {
    if (_endsAt == null) return null;
    final left = _endsAt!.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  /// [minutes] null with [endOfMedia] true = stop when current track/video ends.
  void start({int? minutes, bool endOfMedia = false}) {
    cancel();
    if (endOfMedia) {
      _stopAtEndOfMedia = true;
      notifyListeners();
      return;
    }
    if (minutes == null || minutes <= 0) return;
    _endsAt = DateTime.now().add(Duration(minutes: minutes));
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remaining == Duration.zero) {
        unawaited(_fire());
      } else {
        notifyListeners();
      }
    });
    notifyListeners();
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
    _endsAt = null;
    _stopAtEndOfMedia = false;
    notifyListeners();
  }

  /// Call when the current media item reaches the end.
  Future<void> onMediaCompleted() async {
    if (!_stopAtEndOfMedia) return;
    await _fire();
  }

  Future<void> _fire() async {
    cancel();
    for (final listener in List<VoidCallback>.from(_onExpire)) {
      listener();
    }
  }

  final List<VoidCallback> _onExpire = [];

  void addOnExpireListener(VoidCallback listener) {
    if (!_onExpire.contains(listener)) _onExpire.add(listener);
  }

  void removeOnExpireListener(VoidCallback listener) {
    _onExpire.remove(listener);
  }
}
