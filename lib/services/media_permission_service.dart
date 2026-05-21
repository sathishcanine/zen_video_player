import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/duplicate_media_kind.dart';

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

  static Future<bool> wasOnboardingSkipped() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_skippedKey) ?? false;
  }

  static Future<void> setOnboardingSkipped(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_skippedKey, value);
  }

  /// True when the user can browse device media.
  ///
  /// Android: **All files access** only (no photos/videos-only fallback).
  /// iOS: photo library via [PhotoManager].
  static Future<bool> hasMediaAccess() async {
    if (Platform.isAndroid) {
      return Permission.manageExternalStorage.isGranted;
    }
    final state = await PhotoManager.getPermissionState(
      requestOption: _videoRequestOption,
    );
    return state.isAuth || state.hasAccess;
  }

  /// Ensures access for duplicate scan (same policy as [hasMediaAccess]).
  static Future<bool> ensureMediaAccessFor(DuplicateMediaKind kind) async {
    if (Platform.isAndroid) {
      if (!await Permission.manageExternalStorage.isGranted) {
        await openAllFilesAccessSettings();
      }
      return Permission.manageExternalStorage.isGranted;
    }
    final type = kind == DuplicateMediaKind.video
        ? RequestType.video
        : RequestType.audio;
    final option = _optionFor(type);
    var state = await PhotoManager.getPermissionState(requestOption: option);
    if (state.isAuth || state.hasAccess) return true;
    state = await PhotoManager.requestPermissionExtend(requestOption: option);
    return state.isAuth || state.hasAccess;
  }

  static Future<bool> shouldShowOnboarding() async {
    if (await wasOnboardingSkipped()) return false;
    return !await hasMediaAccess();
  }

  /// Opens the system screen to grant access (no extra runtime dialogs on Android).
  ///
  /// Android: **All files access** settings only — never shows the photos/videos
  /// picker here; users stay on onboarding until that toggle is ON.
  /// iOS: standard photo-library permission dialog.
  static Future<void> openAllFilesAccessSettings() async {
    if (Platform.isAndroid) {
      if (!await Permission.manageExternalStorage.isGranted) {
        await Permission.manageExternalStorage.request();
      }
      return;
    }
    await PhotoManager.requestPermissionExtend(
      requestOption: _videoRequestOption,
    );
  }

  static Future<void> openSystemSettings() => openAppSettings();
}
