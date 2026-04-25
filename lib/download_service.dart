
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

class DownloadService {

  static Future<String> downloadFile(
    String source, {
    bool isLocal = false,
  }) async {
    print("[DownloadService] downloadFile called");
    print("[DownloadService] source: $source");
    print("[DownloadService] isLocal: $isLocal");

    final dir = await _resolveTargetDirectory();
    print("[DownloadService] external dir: ${dir.path}");

    final fileName = isLocal
        ? p.basename(source)
        : _fileNameFromUrl(source);
    final targetPath = _nextAvailablePath(dir.path, fileName);
    print("[DownloadService] resolved fileName: $fileName");
    print("[DownloadService] targetPath: $targetPath");

    if (isLocal) {
      print("[DownloadService] Mode: local copy");
      final sourceFile = File(source);
      if (!await sourceFile.exists()) {
        print("[DownloadService] ERROR: Source file does not exist");
        throw Exception("Source file does not exist");
      }
      await sourceFile.copy(targetPath);
      print("[DownloadService] Local copy completed");
    } else {
      print("[DownloadService] Mode: remote download");
      final uri = Uri.tryParse(source);
      final isHttp = uri != null &&
          (uri.scheme.toLowerCase() == 'http' ||
              uri.scheme.toLowerCase() == 'https');
      if (!isHttp) {
        print("[DownloadService] ERROR: Non-HTTP URL: $source");
        throw Exception("Only HTTP/HTTPS links can be downloaded");
      }

      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(minutes: 2),
          sendTimeout: const Duration(seconds: 20),
          followRedirects: true,
          maxRedirects: 5,
          headers: const {
            'User-Agent': 'Mozilla/5.0 (Android) ZenVideoPlayer/2.0',
          },
        ),
      );

      try {
        await dio.download(source, targetPath);
        print("[DownloadService] Remote download completed");
      } on DioException catch (e) {
        print("[DownloadService] DioException: ${e.type} ${e.message} error=${e.error}");
        throw Exception(_humanizeDioError(e));
      } on SocketException catch (_) {
        print("[DownloadService] SocketException during download");
        throw Exception("Network error. Please check your internet connection.");
      } on HandshakeException catch (_) {
        print("[DownloadService] HandshakeException during download");
        throw Exception("Secure connection failed (TLS/SSL handshake).");
      }
    }

    print("[DownloadService] SUCCESS path: $targetPath");
    return targetPath;

  }

  static String _fileNameFromUrl(String url) {
    final uri = Uri.tryParse(url);
    final lastPart = uri?.pathSegments.isNotEmpty == true
        ? uri!.pathSegments.last
        : '';
    if (lastPart.isEmpty) {
      return "video_${DateTime.now().millisecondsSinceEpoch}.mp4";
    }
    return lastPart;
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
    return safe.trim().isEmpty ? "video_${DateTime.now().millisecondsSinceEpoch}.mp4" : safe;
  }

  static String _humanizeDioError(DioException e) {
    final status = e.response?.statusCode;
    final statusText = e.response?.statusMessage;
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return "Connection timeout while starting download.";
      case DioExceptionType.sendTimeout:
        return "Request timeout while starting download.";
      case DioExceptionType.receiveTimeout:
        return "Download timed out while receiving data.";
      case DioExceptionType.badCertificate:
        return "Certificate error. HTTPS connection is not trusted.";
      case DioExceptionType.badResponse:
        return "Server rejected download (HTTP $status${statusText != null ? ' - $statusText' : ''}).";
      case DioExceptionType.cancel:
        return "Download cancelled.";
      case DioExceptionType.connectionError:
        return "Network connection error while downloading.";
      case DioExceptionType.unknown:
        final base = e.error?.toString() ?? e.message ?? "Unknown Dio error";
        return "Download failed: $base";
    }
  }

  static Future<Directory> _resolveTargetDirectory() async {
    if (Platform.isAndroid) {
      try {
        final downloads = Directory('/storage/emulated/0/Download');
        if (!downloads.existsSync()) {
          downloads.createSync(recursive: true);
        }
        print("[DownloadService] Using public Downloads directory");
        return downloads;
      } catch (e) {
        print("[DownloadService] WARN: public Downloads unavailable: $e");
      }
    }

    final downloadsDir = await getDownloadsDirectory();
    if (downloadsDir != null) {
      final appDir = Directory(p.join(downloadsDir.path, 'ZenVideoPlayer'));
      if (!appDir.existsSync()) {
        appDir.createSync(recursive: true);
      }
      print("[DownloadService] Using platform downloads directory");
      return appDir;
    }

    final external = await getExternalStorageDirectory();
    if (external != null) {
      print("[DownloadService] Falling back to app external directory");
      return external;
    }

    final docs = await getApplicationDocumentsDirectory();
    print("[DownloadService] Falling back to app documents directory");
    return docs;
  }
}
