import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../analytics/telemetry.dart';
import '../models/duplicate_media_kind.dart';

/// Result of asking the user to upgrade from limited to full media access.
enum FullMediaAccessResult {
  granted,
  /// User already has partial access; must use system Settings → Allow all.
  needsSettings,
  denied,
}

/// Persists onboarding choices and wraps platform media permission APIs.
class MediaPermissionService {
  MediaPermissionService._();

  static const _skippedKey = 'media_onboarding_skipped';

  static const PermissionRequestOption _videoRequestOption =
      PermissionRequestOption(
    androidPermission: AndroidPermission(
      type: RequestType.video,
      mediaLocation: false,
    ),
  );

  static const PermissionRequestOption _audioRequestOption =
      PermissionRequestOption(
    androidPermission: AndroidPermission(
      type: RequestType.audio,
      mediaLocation: false,
    ),
  );

  static PermissionRequestOption _optionFor(RequestType type) {
    switch (type) {
      case RequestType.audio:
        return _audioRequestOption;
      case RequestType.video:
        return _videoRequestOption;
      default:
        return _videoRequestOption;
    }
  }

  static Future<PermissionState> _safePermissionState(
    PermissionRequestOption option, {
    String reason = 'getPermissionState',
  }) async {
    try {
      return await PhotoManager.getPermissionState(requestOption: option);
    } on PlatformException catch (e, st) {
      debugPrint('[media_permission] $reason failed: $e\n$st');
      unawaited(Telemetry.recordNonFatal(e, st, reason: reason));
      return PermissionState.denied;
    } catch (e, st) {
      debugPrint('[media_permission] $reason failed: $e\n$st');
      unawaited(Telemetry.recordNonFatal(e, st, reason: reason));
      return PermissionState.denied;
    }
  }

  static Future<PermissionState> _safeRequestPermission(
    PermissionRequestOption option, {
    String reason = 'requestPermissionExtend',
  }) async {
    try {
      return await PhotoManager.requestPermissionExtend(requestOption: option);
    } on PlatformException catch (e, st) {
      debugPrint('[media_permission] $reason failed: $e\n$st');
      unawaited(Telemetry.recordNonFatal(e, st, reason: reason));
      return PermissionState.denied;
    } catch (e, st) {
      debugPrint('[media_permission] $reason failed: $e\n$st');
      unawaited(Telemetry.recordNonFatal(e, st, reason: reason));
      return PermissionState.denied;
    }
  }

  static Future<PermissionState> _videoState() =>
      _safePermissionState(_videoRequestOption, reason: 'videoPermissionState');

  static Future<PermissionState> _audioState() =>
      _safePermissionState(_audioRequestOption, reason: 'audioPermissionState');

  static Future<bool> wasOnboardingSkipped() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_skippedKey) ?? false;
  }

  static Future<void> setOnboardingSkipped(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_skippedKey, value);
  }

  static Future<bool> _permissionGranted(PermissionRequestOption option) async {
    final state = await _safePermissionState(option);
    return state.isAuth || state.hasAccess;
  }

  /// True when the user can browse on-device videos (full or limited).
  static Future<bool> hasVideoAccess() =>
      _permissionGranted(_videoRequestOption);

  /// True when the app has full library access (not “selected only”).
  static Future<bool> hasFullVideoAccess() async {
    final state = await _videoState();
    return state.isAuth;
  }

  /// True when the user chose “select videos” / partial access (Android 14+, iOS).
  static Future<bool> isVideoAccessLimited() async {
    final state = await _videoState();
    return state == PermissionState.limited;
  }

  /// Partial or limited access — can see some items but not the full library.
  static Future<bool> needsFullVideoAccessPrompt() async {
    if (!await hasVideoAccess()) return false;
    return !await hasFullVideoAccess();
  }

  /// True when the user can browse on-device audio (full or limited).
  static Future<bool> hasAudioAccess() =>
      _permissionGranted(_audioRequestOption);

  static Future<bool> isAudioAccessLimited() async {
    final state = await _audioState();
    return state == PermissionState.limited;
  }

  /// Video access — used for library shell onboarding and video tab.
  static Future<bool> hasMediaAccess() => hasVideoAccess();

  /// Shows system dialogs for video and audio (Photos/Videos + Music on Android).
  static Future<bool> requestMediaAccess() async {
    final videoState = await _safeRequestPermission(
      _videoRequestOption,
      reason: 'requestVideoPermission',
    );
    await _safeRequestPermission(
      _audioRequestOption,
      reason: 'requestAudioPermission',
    );
    return videoState.isAuth || videoState.hasAccess;
  }

  /// Upgrades from limited/selected access to full video library access.
  ///
  /// On Android 14+, if the user already chose “select videos”, the system
  /// will not show the permission dialog again — [needsSettings] is returned
  /// so the UI can open app Settings (Photos and videos → Allow all).
  static Future<FullMediaAccessResult> requestFullVideoAccess() async {
    var state = await _videoState();
    if (state.isAuth) return FullMediaAccessResult.granted;

    // Do not call [PhotoManager.presentLimited] — on Android it opens the
    // Photos picker (not “Allow all”) and still leaves access limited.
    if (state == PermissionState.limited) {
      return FullMediaAccessResult.needsSettings;
    }

    state = await _safeRequestPermission(
      _videoRequestOption,
      reason: 'requestFullVideoPermission',
    );
    if (state.isAuth) return FullMediaAccessResult.granted;
    if (state == PermissionState.limited) {
      return FullMediaAccessResult.needsSettings;
    }
    return FullMediaAccessResult.denied;
  }

  /// Upgrades from limited/selected access to full audio library access.
  static Future<FullMediaAccessResult> requestFullAudioAccess() async {
    var state = await _audioState();
    if (state.isAuth) return FullMediaAccessResult.granted;

    if (state == PermissionState.limited) {
      return FullMediaAccessResult.needsSettings;
    }

    state = await _safeRequestPermission(
      _audioRequestOption,
      reason: 'requestFullAudioPermission',
    );
    if (state.isAuth) return FullMediaAccessResult.granted;
    if (state == PermissionState.limited) {
      return FullMediaAccessResult.needsSettings;
    }
    return FullMediaAccessResult.denied;
  }

  /// App info screen where the user can set Photos and videos → Allow all.
  static Future<void> openVideoPermissionSettings() => PhotoManager.openSetting();

  /// Ensures access for duplicate scan.
  static Future<bool> ensureMediaAccessFor(DuplicateMediaKind kind) async {
    final type = kind == DuplicateMediaKind.video
        ? RequestType.video
        : RequestType.audio;
    final option = _optionFor(type);
    if (await _permissionGranted(option)) return true;
    final state = await _safeRequestPermission(
      option,
      reason: 'ensureMediaAccessFor',
    );
    return state.isAuth || state.hasAccess;
  }

  static Future<bool> shouldShowOnboarding() async {
    if (await wasOnboardingSkipped()) return false;
    return !await hasVideoAccess();
  }

  static Future<void> openSystemSettings() => openAppSettings();
}
