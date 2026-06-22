/// Ensures only one exit interstitial flow runs at a time (player / preview).
class ExitInterstitialGate {
  ExitInterstitialGate._();

  static bool _active = false;

  static bool get isActive => _active;

  static bool tryAcquire() {
    if (_active) return false;
    _active = true;
    return true;
  }

  static void release() {
    _active = false;
  }
}
