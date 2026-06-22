import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../analytics/telemetry.dart';
import '../firebase_options.dart';
import '../utils/external_app_launcher.dart';
import 'app_settings_service.dart';

/// FCM background isolate entry — must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await PushNotificationService.handleBackgroundMessage(message);
  } catch (e, st) {
    debugPrint('[push] background handler failed: $e\n$st');
  }
}

/// Promotional push notifications (Minnal Browser–style).
class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  static const String channelId = 'zen_announcements';
  static const String topicAnnouncements = 'zen_announcements';
  static const String prefPromotionalPushEnabled = 'promotional_push_enabled_v1';
  static const String prefPendingAction = 'push_pending_action_v1';

  static const String typeAppUpdate = 'app_update';
  static const String typeDifferent = 'different';
  static const String typeOpenApp = 'open_app';
  static const String typeDeeplink = 'deeplink';

  static const String dataType = 'type';
  static const String dataTarget = 'target';
  static const String dataTitle = 'title';
  static const String dataBody = 'body';
  static const String dataDeeplink = 'deeplink';

  static const int _notificationId = 7402;

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> Function(Uri uri)? _onDeeplink;
  static bool _initialized = false;
  static bool _initAttempted = false;
  static bool _backgroundHandlerRegistered = false;

  static bool get _platformSupported => !kIsWeb && Platform.isAndroid;

  /// Call once from [main] before [runApp] (Firebase requirement).
  static void registerBackgroundHandler() {
    if (!_platformSupported || _backgroundHandlerRegistered) return;
    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      _backgroundHandlerRegistered = true;
    } catch (e, st) {
      debugPrint('[push] registerBackgroundHandler failed: $e\n$st');
    }
  }

  static Future<void> init({
    required Future<void> Function(Uri uri) onDeeplink,
  }) async {
    if (_initialized || _initAttempted || !_platformSupported) return;
    _initAttempted = true;
    _onDeeplink = onDeeplink;

    if (!Telemetry.isFirebaseReady) {
      debugPrint('[push] skip init: Firebase not ready');
      return;
    }

    try {
      await _initLocalNotifications().timeout(const Duration(seconds: 8));
      if (AppSettingsService.instance.promotionalPushEnabled) {
        unawaited(_requestPermissionIfNeeded());
      }

      try {
        final initial = await FirebaseMessaging.instance
            .getInitialMessage()
            .timeout(const Duration(seconds: 4));
        if (initial != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            unawaited(
              handleMessageData(
                _stringifyData(initial.data),
                fromUserTap: true,
              ),
            );
          });
        }
      } catch (e) {
        debugPrint('[push] getInitialMessage failed: $e');
      }

      FirebaseMessaging.onMessage.listen(
        (message) => unawaited(_presentForegroundMessage(message)),
        onError: (Object e, StackTrace st) {
          debugPrint('[push] onMessage stream error: $e\n$st');
        },
      );

      FirebaseMessaging.onMessageOpenedApp.listen(
        (message) => unawaited(
          handleMessageData(_stringifyData(message.data), fromUserTap: true),
        ),
        onError: (Object e, StackTrace st) {
          debugPrint('[push] onMessageOpenedApp stream error: $e\n$st');
        },
      );

      FirebaseMessaging.instance.onTokenRefresh.listen(
        (_) => unawaited(syncTopicSubscription()),
        onError: (Object e, StackTrace st) {
          debugPrint('[push] onTokenRefresh stream error: $e\n$st');
        },
      );

      await syncTopicSubscription();
      await drainPendingAction();
      _initialized = true;

      if (kDebugMode) {
        try {
          final token = await FirebaseMessaging.instance.getToken();
          debugPrint('[push] FCM token (debug): $token');
        } catch (e) {
          debugPrint('[push] getToken failed: $e');
        }
      }
    } catch (e, st) {
      debugPrint('[push] init failed (app continues): $e\n$st');
      unawaited(
        Telemetry.recordNonFatal(e, st, reason: 'push_notification_init'),
      );
    }
  }

  static Future<void> syncTopicSubscription() async {
    if (!_platformSupported || !Telemetry.isFirebaseReady) return;
    final enabled = AppSettingsService.instance.promotionalPushEnabled;
    try {
      final messaging = FirebaseMessaging.instance;
      if (enabled) {
        await messaging
            .subscribeToTopic(topicAnnouncements)
            .timeout(const Duration(seconds: 12));
        debugPrint('[push] subscribed to $topicAnnouncements');
      } else {
        await messaging
            .unsubscribeFromTopic(topicAnnouncements)
            .timeout(const Duration(seconds: 12));
        debugPrint('[push] unsubscribed from $topicAnnouncements');
      }
    } catch (e, st) {
      debugPrint('[push] topic sync failed: $e\n$st');
    }
  }

  static Future<void> drainPendingAction() async {
    if (!_platformSupported) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(prefPendingAction);
      if (raw == null || raw.isEmpty) return;
      await prefs.remove(prefPendingAction);
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      await handleMessageData(_stringifyData(decoded), fromUserTap: true);
    } catch (e) {
      debugPrint('[push] drain pending action failed: $e');
    }
  }

  static Future<void> _enqueuePendingAction(Map<String, String> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(prefPendingAction, jsonEncode(data));
    } catch (e) {
      debugPrint('[push] enqueue pending action failed: $e');
    }
  }

  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    try {
      if (!await _readPromotionalPushEnabled()) return;
      final parsed = _parseAnnouncement(message);
      if (parsed == null) return;
      await _ensureLocalNotificationsInitialized();
      await _showLocalNotification(parsed);
    } catch (e, st) {
      debugPrint('[push] handleBackgroundMessage failed: $e\n$st');
    }
  }

  static Future<void> _presentForegroundMessage(RemoteMessage message) async {
    try {
      if (!AppSettingsService.instance.promotionalPushEnabled) return;
      final parsed = _parseAnnouncement(message);
      if (parsed == null) return;
      await _showLocalNotification(parsed);
    } catch (e, st) {
      debugPrint('[push] foreground message failed: $e\n$st');
    }
  }

  static Future<void> handleMessageData(
    Map<String, String> data, {
    required bool fromUserTap,
  }) async {
    if (!fromUserTap) return;
    try {
      if (!AppSettingsService.instance.promotionalPushEnabled &&
          !await _readPromotionalPushEnabled()) {
        return;
      }

      final type = data[dataType] ?? '';
      if (type.isEmpty) {
        final legacyLink = data[dataDeeplink]?.trim() ?? '';
        if (legacyLink.isNotEmpty) {
          final uri = Uri.tryParse(legacyLink);
          if (uri != null) await _onDeeplink?.call(uri);
        }
        return;
      }
      if (!_isSupportedType(type)) return;

      final target = data[dataTarget]?.trim() ?? '';
      switch (type) {
        case typeAppUpdate:
          await ExternalAppLauncher.openPlayStore(
            target.isNotEmpty ? target : ExternalAppLauncher.zenPackageName,
          );
        case typeDifferent:
          if (target.isEmpty) return;
          await ExternalAppLauncher.openPlayStore(target);
        case typeOpenApp:
          await ExternalAppLauncher.launchApp(
            target.isNotEmpty
                ? target
                : ExternalAppLauncher.minnalBrowserPackageName,
          );
        case typeDeeplink:
          final link = data[dataDeeplink]?.trim() ?? '';
          if (link.isEmpty) return;
          final uri = Uri.tryParse(link);
          if (uri == null) return;
          await _onDeeplink?.call(uri);
      }
    } catch (e, st) {
      debugPrint('[push] handleMessageData failed: $e\n$st');
    }
  }

  static _AnnouncementPayload? _parseAnnouncement(RemoteMessage message) {
    try {
      final data = _stringifyData(message.data);
      var type = data[dataType] ?? '';
      final legacyDeeplink = data[dataDeeplink]?.trim() ?? '';
      if (type.isEmpty && legacyDeeplink.isNotEmpty) {
        type = typeDeeplink;
      }
      if (!_isSupportedType(type)) return null;

      final title = message.notification?.title ??
          data[dataTitle] ??
          'Zen Video Player';
      final body = message.notification?.body ?? data[dataBody];
      if (body == null || body.isEmpty) return null;

      return _AnnouncementPayload(
        type: type,
        title: title,
        body: body,
        target: data[dataTarget] ?? '',
        deeplink: legacyDeeplink.isNotEmpty
            ? legacyDeeplink
            : (data[dataDeeplink] ?? ''),
      );
    } catch (e) {
      debugPrint('[push] parse announcement failed: $e');
      return null;
    }
  }

  static bool _isSupportedType(String type) =>
      type == typeAppUpdate ||
      type == typeDifferent ||
      type == typeOpenApp ||
      type == typeDeeplink;

  static Map<String, String> _stringifyData(Map<String, dynamic> data) =>
      data.map((key, value) => MapEntry(key, value?.toString() ?? ''));

  static Future<void> _initLocalNotifications() async {
    await _ensureLocalNotificationsInitialized();

    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        channelId,
        'App announcements',
        description: 'Update alerts and messages about Zen and partner apps',
        importance: Importance.defaultImportance,
      ),
    );
  }

  static Future<void> _ensureLocalNotificationsInitialized() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTapped,
      onDidReceiveBackgroundNotificationResponse:
          pushNotificationBackgroundTapHandler,
    );
  }

  @pragma('vm:entry-point')
  static void pushNotificationBackgroundTapHandler(
    NotificationResponse response,
  ) {
    try {
      final payload = response.payload;
      if (payload == null || payload.isEmpty) return;
      final raw = jsonDecode(payload) as Map<String, dynamic>;
      final data = _stringifyData(raw);
      unawaited(_enqueuePendingAction(data));
    } catch (e) {
      debugPrint('[push] background tap payload parse failed: $e');
    }
  }

  static void _onLocalNotificationTapped(NotificationResponse response) {
    try {
      final payload = response.payload;
      if (payload == null || payload.isEmpty) return;
      final raw = jsonDecode(payload) as Map<String, dynamic>;
      final data = _stringifyData(raw);
      unawaited(handleMessageData(data, fromUserTap: true));
    } catch (e) {
      debugPrint('[push] tap payload parse failed: $e');
    }
  }

  static Future<void> _showLocalNotification(
    _AnnouncementPayload payload,
  ) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        channelId,
        'App announcements',
        channelDescription:
            'Update alerts and messages about Zen and partner apps',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        styleInformation: BigTextStyleInformation(payload.body),
      );

      final payloadJson = jsonEncode(<String, String>{
        dataType: payload.type,
        dataTitle: payload.title,
        dataBody: payload.body,
        dataTarget: payload.target,
        dataDeeplink: payload.deeplink,
      });

      await _localNotifications.show(
        id: _notificationId,
        title: payload.title,
        body: payload.body,
        notificationDetails: NotificationDetails(android: androidDetails),
        payload: payloadJson,
      );
    } catch (e, st) {
      debugPrint('[push] show local notification failed: $e\n$st');
    }
  }

  static Future<void> _requestPermissionIfNeeded() async {
    if (!Platform.isAndroid) return;
    try {
      await FirebaseMessaging.instance
          .requestPermission()
          .timeout(const Duration(seconds: 8));
      await Permission.notification.request();
    } catch (e) {
      debugPrint('[push] permission request failed: $e');
    }
  }

  static Future<bool> _readPromotionalPushEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(prefPromotionalPushEnabled) ?? true;
    } catch (_) {
      return true;
    }
  }
}

class _AnnouncementPayload {
  const _AnnouncementPayload({
    required this.type,
    required this.title,
    required this.body,
    required this.target,
    required this.deeplink,
  });

  final String type;
  final String title;
  final String body;
  final String target;
  final String deeplink;
}
