/// In-memory playlist for skip previous/next while [VideoPlayerScreen] is open.
class VideoPlaybackQueue {
  VideoPlaybackQueue._();

  static List<String> _assetIds = const [];
  static int _index = 0;

  static void install(List<String> assetIds, String currentAssetId) {
    if (assetIds.length < 2) {
      clear();
      return;
    }
    _assetIds = List<String>.from(assetIds);
    final i = _assetIds.indexOf(currentAssetId);
    _index = i >= 0 ? i : 0;
  }

  static void syncCurrent(String assetId) {
    if (_assetIds.isEmpty) return;
    final i = _assetIds.indexOf(assetId);
    if (i >= 0) _index = i;
  }

  static void clear() {
    _assetIds = const [];
    _index = 0;
  }

  static bool get isActive => _assetIds.length > 1;

  static bool get hasPrevious => _index > 0;

  static bool get hasNext => _index < _assetIds.length - 1;

  static String? get previousAssetId =>
      hasPrevious ? _assetIds[_index - 1] : null;

  static String? get nextAssetId => hasNext ? _assetIds[_index + 1] : null;
}
