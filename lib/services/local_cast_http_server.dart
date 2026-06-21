import 'dart:async';
import 'dart:io';

/// Serves a single local video file over HTTP so a Chromecast on the same
/// Wi‑Fi network can fetch it (Cast receivers cannot read `file://` URLs).
class LocalCastHttpServer {
  HttpServer? _server;
  String? _filePath;

  bool get isRunning => _server != null;

  Future<void> stop() async {
    final server = _server;
    _server = null;
    _filePath = null;
    if (server != null) {
      await server.close(force: true);
    }
  }

  /// Returns an `http://<lan-ip>:<port>/media` URI for [filePath], or null.
  Future<Uri?> serveFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return null;

    await stop();
    final ip = await _lanIpv4();
    if (ip == null) return null;

    _filePath = filePath;
    _server = await HttpServer.bind(InternetAddress.anyIPv4, 0);
    final port = _server!.port;

    _server!.listen((request) async {
      try {
        if (request.uri.path != '/media') {
          request.response.statusCode = HttpStatus.notFound;
          await request.response.close();
          return;
        }
        await _handleMediaRequest(request);
      } catch (_) {
        try {
          request.response.statusCode = HttpStatus.internalServerError;
          await request.response.close();
        } catch (_) {}
      }
    });

    return Uri(scheme: 'http', host: ip, port: port, path: '/media');
  }

  Future<void> _handleMediaRequest(HttpRequest request) async {
    final path = _filePath;
    if (path == null) {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      return;
    }

    final media = File(path);
    if (!await media.exists()) {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      return;
    }

    final length = await media.length();
    final mime = _mimeForPath(path);
    final rangeHeader = request.headers.value(HttpHeaders.rangeHeader);

    if (rangeHeader != null) {
      final match = RegExp(r'bytes=(\d*)-(\d*)').firstMatch(rangeHeader);
      if (match != null) {
        final start = match.group(1)!.isEmpty
            ? 0
            : int.parse(match.group(1)!);
        var end = match.group(2)!.isEmpty
            ? length - 1
            : int.parse(match.group(2)!);
        if (start >= length) {
          request.response.statusCode = HttpStatus.requestedRangeNotSatisfiable;
          request.response.headers.set(
            HttpHeaders.contentRangeHeader,
            'bytes */$length',
          );
          await request.response.close();
          return;
        }
        end = end.clamp(0, length - 1);
        if (start <= end) {
          final contentLength = end - start + 1;
          request.response.statusCode = HttpStatus.partialContent;
          request.response.headers.set(HttpHeaders.contentTypeHeader, mime);
          request.response.headers.set(HttpHeaders.acceptRangesHeader, 'bytes');
          request.response.headers.set(
            HttpHeaders.contentRangeHeader,
            'bytes $start-$end/$length',
          );
          request.response.contentLength = contentLength;
          if (request.method != 'HEAD') {
            await request.response.addStream(
              media.openRead(start, end + 1),
            );
          }
          await request.response.close();
          return;
        }
      }
    }

    request.response.statusCode = HttpStatus.ok;
    request.response.headers.set(HttpHeaders.contentTypeHeader, mime);
    request.response.headers.set(HttpHeaders.acceptRangesHeader, 'bytes');
    request.response.contentLength = length;
    if (request.method != 'HEAD') {
      await request.response.addStream(media.openRead());
    }
    await request.response.close();
  }

  static Future<String?> _lanIpv4() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLinkLocal: false,
        type: InternetAddressType.IPv4,
      );
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          final ip = addr.address;
          if (ip.startsWith('127.') || ip.startsWith('169.254.')) continue;
          return ip;
        }
      }
    } catch (_) {}
    return null;
  }

  static String _mimeForPath(String path) {
    final ext = path.split('.').last.toLowerCase();
    return switch (ext) {
      'mp4' || 'm4v' => 'video/mp4',
      'webm' => 'video/webm',
      'mkv' => 'video/x-matroska',
      'mov' => 'video/quicktime',
      'avi' => 'video/x-msvideo',
      '3gp' => 'video/3gpp',
      _ => 'video/mp4',
    };
  }
}
