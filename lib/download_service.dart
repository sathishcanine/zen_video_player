import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

/// Result of a [DownloadService.downloadFile] call.
class DownloadOutcome {
  /// `true` when the download was delegated to the OS browser / system
  /// download manager. The final file location is then decided by the OS
  /// (typically `/storage/emulated/0/Download/...` on Android) and is not
  /// knowable to the app.
  final bool handedOffToSystem;

  /// File path on disk if we copied the file ourselves (local-source case).
  final String? localPath;

  const DownloadOutcome.handedOff()
      : handedOffToSystem = true,
        localPath = null;

  const DownloadOutcome.savedAt(String path)
      : handedOffToSystem = false,
        localPath = path;
}

class DownloadService {
  /// Saves [source] for the user.
  ///
  /// - Remote (`http`/`https`) URLs are delegated to the system browser via
  ///   `url_launcher`, which in turn invokes Android's built-in
  ///   `DownloadManager`. The app does not write the file itself, so no
  ///   storage permissions or scoped-storage workarounds are required, and
  ///   the user gets a real progress notification + tap-to-open in the
  ///   system Downloads folder.
  /// - Local files (`isLocal: true`) are copied into the user's Downloads
  ///   folder so they persist independently of the original location.
  static Future<DownloadOutcome> downloadFile(
    String source, {
    bool isLocal = false,
  }) async {
    print("[DownloadService] downloadFile called source=$source isLocal=$isLocal");

    if (isLocal) {
      return _copyLocalToDownloads(source);
    }

    final uri = Uri.tryParse(source);
    final isHttp = uri != null &&
        (uri.scheme.toLowerCase() == 'http' ||
            uri.scheme.toLowerCase() == 'https');
    if (uri == null || !isHttp) {
      print("[DownloadService] ERROR: Non-HTTP URL: $source");
      throw Exception("Only HTTP/HTTPS links can be downloaded.");
    }

    bool launched;
    try {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      print("[DownloadService] launchUrl threw: $e");
      throw Exception("Could not open the system browser: $e");
    }

    if (!launched) {
      print("[DownloadService] launchUrl returned false");
      throw Exception(
        "No app available to handle this link. "
        "Please install a browser and try again.",
      );
    }

    print("[DownloadService] Handed off to system browser");
    return const DownloadOutcome.handedOff();
  }

  static Future<DownloadOutcome> _copyLocalToDownloads(String source) async {
    final sourceFile = File(source);
    if (!await sourceFile.exists()) {
      print("[DownloadService] ERROR: Source file does not exist: $source");
      throw Exception("Source file does not exist");
    }

    final dir = await _resolveTargetDirectory();
    final targetPath = _nextAvailablePath(dir.path, p.basename(source));
    print("[DownloadService] Copying local file -> $targetPath");
    await sourceFile.copy(targetPath);
    print("[DownloadService] Local copy complete");
    return DownloadOutcome.savedAt(targetPath);
  }

  static String _nextAvailablePath(String dirPath, String fileName) {
    final sanitized = _sanitizeFileName(
      fileName.isEmpty
          ? "video_${DateTime.now().millisecondsSinceEpoch}.mp4"
          : fileName,
    );
    final extension = p.extension(sanitized);
    final nameWithoutExt = p.basenameWithoutExtension(sanitized);

    var candidate = p.join(dirPath, sanitized);
    var index = 1;
    while (File(candidate).existsSync()) {
      candidate = p.join(
        dirPath,
        "${nameWithoutExt}_$index$extension",
      );
      index++;
    }
    return candidate;
  }

  static String _sanitizeFileName(String name) {
    final safe = name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    return safe.trim().isEmpty
        ? "video_${DateTime.now().millisecondsSinceEpoch}.mp4"
        : safe;
  }

  /// Picks the best place to write a copied local file.
  ///
  /// On Android we prefer the public `/storage/emulated/0/Download` folder
  /// (so the user can find the file in any file manager), but only after a
  /// real write probe — `existsSync()` alone is not enough under scoped
  /// storage. If that probe fails we fall back to app-specific external
  /// storage, which is always writable without runtime permissions.
  static Future<Directory> _resolveTargetDirectory() async {
    if (Platform.isAndroid) {
      final publicDownloads = Directory('/storage/emulated/0/Download');
      if (await _ensureWritable(publicDownloads)) {
        return publicDownloads;
      }
      print("[DownloadService] Public Downloads not writable, using app-specific storage");

      final external = await getExternalStorageDirectory();
      if (external != null) {
        final appDownloads = Directory(p.join(external.path, 'Downloads'));
        if (!appDownloads.existsSync()) {
          appDownloads.createSync(recursive: true);
        }
        return appDownloads;
      }
    }

    final downloadsDir = await getDownloadsDirectory();
    if (downloadsDir != null) {
      final appDir = Directory(p.join(downloadsDir.path, 'ZenVideoPlayer'));
      if (!appDir.existsSync()) {
        appDir.createSync(recursive: true);
      }
      return appDir;
    }

    final external = await getExternalStorageDirectory();
    if (external != null) return external;

    return getApplicationDocumentsDirectory();
  }

  static Future<bool> _ensureWritable(Directory dir) async {
    try {
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      final probe = File(p.join(
        dir.path,
        '.zvp_write_probe_${DateTime.now().millisecondsSinceEpoch}',
      ));
      await probe.writeAsString('ok', flush: true);
      await probe.delete();
      return true;
    } catch (e) {
      print("[DownloadService] Write probe failed for ${dir.path}: $e");
      return false;
    }
  }
}
