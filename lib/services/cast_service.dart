import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_chrome_cast/lib.dart';
import 'package:path/path.dart' as p;
import 'package:photo_manager/photo_manager.dart';

import '../analytics/telemetry.dart';
import 'cast_local_media_channel.dart';
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
    this.assetId,
  });

  final String title;
  final String videoSource;
  final bool isLocal;
  final bool useContentUri;
  final Duration playPosition;
  final Duration? duration;

  /// MediaStore / gallery asset id — used to resolve `content://` for Cast.
  final String? assetId;
}

/// Google Cast discovery, session, and media loading.
class CastService {
  CastService._();

  static final CastService instance = CastService._();

  final LocalCastHttpServer _localServer = LocalCastHttpServer();
  bool _initialized = false;
  bool _initFailed = false;
  bool _initInFlight = false;

  bool get isSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  bool get isInitialized => _initialized;

  /// `false` when Play Services / Cast framework is missing on this device.
  bool get canUseCast => isSupported && _initialized && !_initFailed;

  bool get isConnected {
    if (!canUseCast) return false;
    try {
      return GoogleCastSessionManager.instance.connectionState ==
          GoogleCastConnectState.connected;
    } catch (e) {
      debugPrint('[cast] isConnected check failed: $e');
      return false;
    }
  }

  Stream<bool> get isConnectedStream {
    if (!canUseCast) return Stream<bool>.value(false);
    try {
      return GoogleCastSessionManager.instance.currentSessionStream
          .map((_) => isConnected)
          .handleError((Object e, StackTrace st) {
        debugPrint('[cast] connection stream error: $e\n$st');
      });
    } catch (e) {
      debugPrint('[cast] connection stream unavailable: $e');
      return Stream<bool>.value(false);
    }
  }

  /// Safe to call on every cold start — never throws.
  Future<void> init() async {
    if (!isSupported || _initialized || _initFailed || _initInFlight) return;
    _initInFlight = true;
    try {
      const appId = GoogleCastDiscoveryCriteria.kDefaultApplicationId;
      final GoogleCastOptions options;
      if (Platform.isIOS) {
        options = IOSGoogleCastOptions(
          GoogleCastDiscoveryCriteriaInitialize.initWithApplicationID(appId),
        );
      } else {
        options = GoogleCastOptionsAndroid(appId: appId);
      }

      final ok = await GoogleCastContext.instance
          .setSharedInstanceWithOptions(options)
          .timeout(const Duration(seconds: 10));
      if (ok != true) {
        _markInitFailed('Google Cast SDK returned false');
        return;
      }
      _initialized = true;
    } on PlatformException catch (e, st) {
      _markInitFailed('${e.code}: ${e.message}', e, st);
    } on TimeoutException catch (e, st) {
      _markInitFailed('init timed out', e, st);
    } catch (e, st) {
      _markInitFailed(e.toString(), e, st);
    } finally {
      _initInFlight = false;
    }
  }

  void _markInitFailed(
    String reason, [
    Object? exception,
    StackTrace? stackTrace,
  ]) {
    _initFailed = true;
    debugPrint('[cast] init unavailable: $reason');
    if (exception != null) {
      unawaited(
        Telemetry.recordNonFatal(
          exception,
          stackTrace,
          reason: 'cast_init_unavailable',
          context: <String, String>{'detail': reason},
        ),
      );
    }
  }

  Future<void> startDiscovery() async {
    if (_initFailed) return;
    if (!_initialized) await init();
    if (!canUseCast) return;
    try {
      await GoogleCastDiscoveryManager.instance.startDiscovery();
    } catch (e, st) {
      debugPrint('[cast] startDiscovery failed: $e\n$st');
    }
  }

  Future<void> stopDiscovery() async {
    if (!canUseCast) return;
    try {
      await GoogleCastDiscoveryManager.instance.stopDiscovery();
    } catch (e, st) {
      debugPrint('[cast] stopDiscovery failed: $e\n$st');
    }
  }

  Future<void> disconnect() async {
    if (!canUseCast) {
      await _localServer.stop();
      return;
    }
    try {
      await GoogleCastRemoteMediaClient.instance.stop();
      await GoogleCastSessionManager.instance.endSessionAndStopCasting();
    } catch (e, st) {
      debugPrint('[cast] disconnect failed: $e\n$st');
    }
    await _localServer.stop();
  }

  /// Resolves a URL the Cast receiver can fetch.
  Future<Uri?> resolvePlayableUrl(CastMediaPayload media) async {
    if (_requiresLocalHttpServer(media)) {
      final path = await _resolveLocalMediaPath(media);
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
    if (_initFailed) {
      throw StateError('cast_unavailable');
    }
    if (!_initialized) await init();
    if (!canUseCast) {
      throw StateError('cast_unavailable');
    }

    await _ensureSession(device);

    if (media == null) return;

    final url = await resolvePlayableUrl(media);
    if (url == null) {
      if (!isConnected) {
        await disconnect();
      }
      if (media.useContentUri || media.videoSource.startsWith('content://')) {
        throw StateError('content_uri_unsupported');
      }
      if (_requiresLocalHttpServer(media)) {
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

  Future<void> _ensureSession(GoogleCastDevice device) async {
    final sessionManager = GoogleCastSessionManager.instance;
    if (sessionManager.hasConnectedSession) {
      final currentId = sessionManager.currentSession?.device?.deviceID;
      if (currentId == device.deviceID) return;
      await disconnect();
    }

    final connected = await sessionManager.startSessionWithDevice(device);
    if (!connected) {
      throw StateError('Could not connect to ${device.friendlyName}');
    }

    // Receiver needs a moment before loadMedia succeeds on some TVs.
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  bool _requiresLocalHttpServer(CastMediaPayload media) {
    if (media.isLocal || media.useContentUri) return true;
    final source = media.videoSource;
    if (source.startsWith('content://') || source.startsWith('file://')) {
      return true;
    }
    if (source.startsWith('/')) return true;
    return false;
  }

  Future<String?> _resolveLocalMediaPath(CastMediaPayload media) async {
    if (media.assetId != null) {
      final fromAsset = await _pathFromAssetId(media.assetId!);
      if (fromAsset != null) return fromAsset;
    }

    if (!media.videoSource.startsWith('content://')) {
      final path = _localFilePath(media.videoSource);
      if (path != null) {
        final file = File(path);
        if (await file.exists()) return path;
      }
    }

    if (media.useContentUri || media.videoSource.startsWith('content://')) {
      return CastLocalMediaChannel.resolveReadablePath(media.videoSource);
    }

    return null;
  }

  Future<String?> _pathFromAssetId(String assetId) async {
    try {
      final entity = await AssetEntity.fromId(assetId);
      if (entity == null) return null;
      final origin = await entity.originFile;
      if (origin != null && await origin.exists()) return origin.path;
      final file = await entity.file;
      if (file != null && await file.exists()) return file.path;
    } catch (e, st) {
      debugPrint('[cast] asset resolve failed: $e\n$st');
    }
    return null;
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
    if (source.startsWith('content://')) return null;
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
