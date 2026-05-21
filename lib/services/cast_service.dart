import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_chrome_cast/lib.dart';
import 'package:path/path.dart' as p;

import 'local_cast_http_server.dart';

/// Media to load on a Cast receiver after the user picks a device.
class CastMediaPayload {
  const CastMediaPayload({
    required this.title,
    required this.videoSource,
    this.isLocal = false,
    this.useContentUri = false,
    this.playPosition = Duration.zero,
    this.duration,
  });

  final String title;
  final String videoSource;
  final bool isLocal;
  final bool useContentUri;
  final Duration playPosition;
  final Duration? duration;
}

/// Google Cast discovery, session, and media loading.
class CastService {
  CastService._();

  static final CastService instance = CastService._();

  final LocalCastHttpServer _localServer = LocalCastHttpServer();
  bool _initialized = false;

  bool get isSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  bool get isInitialized => _initialized;

  bool get isConnected =>
      GoogleCastSessionManager.instance.connectionState ==
      GoogleCastConnectState.connected;

  Stream<bool> get isConnectedStream =>
      GoogleCastSessionManager.instance.currentSessionStream.map((_) => isConnected);

  Future<void> init() async {
    if (!isSupported || _initialized) return;
    const appId = GoogleCastDiscoveryCriteria.kDefaultApplicationId;
    final GoogleCastOptions options;
    if (Platform.isIOS) {
      options = IOSGoogleCastOptions(
        GoogleCastDiscoveryCriteriaInitialize.initWithApplicationID(appId),
      );
    } else {
      options = GoogleCastOptionsAndroid(appId: appId);
    }
    final ok =
        await GoogleCastContext.instance.setSharedInstanceWithOptions(options);
    if (ok != true) {
      throw StateError('Google Cast SDK failed to initialize');
    }
    _initialized = true;
  }

  Future<void> startDiscovery() async {
    if (!_initialized) await init();
    await GoogleCastDiscoveryManager.instance.startDiscovery();
  }

  Future<void> stopDiscovery() async {
    await GoogleCastDiscoveryManager.instance.stopDiscovery();
  }

  Future<void> disconnect() async {
    await GoogleCastRemoteMediaClient.instance.stop();
    await GoogleCastSessionManager.instance.endSessionAndStopCasting();
    await _localServer.stop();
  }

  /// Resolves a URL the Cast receiver can fetch.
  Future<Uri?> resolvePlayableUrl(CastMediaPayload media) async {
    if (media.useContentUri) return null;

    if (media.isLocal) {
      final path = _localFilePath(media.videoSource);
      if (path == null) return null;
      return _localServer.serveFile(path);
    }

    final uri = Uri.tryParse(media.videoSource);
    if (uri == null || !uri.hasScheme) return null;
    if (uri.scheme == 'http' || uri.scheme == 'https') return uri;
    return null;
  }

  Future<void> castToDevice(
    GoogleCastDevice device, {
    CastMediaPayload? media,
  }) async {
    if (!_initialized) await init();

    final connected = await GoogleCastSessionManager.instance
        .startSessionWithDevice(device);
    if (!connected) {
      throw StateError('Could not connect to ${device.friendlyName}');
    }

    if (media == null) return;

    final url = await resolvePlayableUrl(media);
    if (url == null) {
      await disconnect();
      if (media.useContentUri) {
        throw StateError('content_uri_unsupported');
      }
      if (media.isLocal) {
        throw StateError('local_wifi_unavailable');
      }
      throw StateError('invalid_source');
    }

    final info = _buildMediaInformation(
      url: url,
      title: media.title,
      duration: media.duration,
    );

    await GoogleCastRemoteMediaClient.instance.loadMedia(
      info,
      autoPlay: true,
      playPosition: media.playPosition,
    );
  }

  GoogleCastMediaInformation _buildMediaInformation({
    required Uri url,
    required String title,
    Duration? duration,
  }) {
    final metadata = GoogleCastMovieMediaMetadata(title: title);
    if (Platform.isIOS) {
      return GoogleCastMediaInformationIOS(
        contentId: url.toString(),
        streamType: CastMediaStreamType.buffered,
        contentUrl: url,
        contentType: _contentTypeForUrl(url),
        metadata: metadata,
        duration: duration,
      );
    }
    return GoogleCastMediaInformationAndroid(
      contentId: url.toString(),
      streamType: CastMediaStreamType.buffered,
      contentUrl: url,
      contentType: _contentTypeForUrl(url),
      metadata: metadata,
      duration: duration,
    );
  }

  static String? _localFilePath(String source) {
    final parsed = Uri.tryParse(source);
    if (parsed != null && parsed.isScheme('file')) {
      return parsed.toFilePath();
    }
    if (source.startsWith('/')) return source;
    return p.normalize(source);
  }

  static String _contentTypeForUrl(Uri url) {
    final path = url.path;
    final ext = path.contains('.') ? path.split('.').last.toLowerCase() : '';
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
