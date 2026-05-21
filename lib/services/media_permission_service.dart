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

  /// True when the user can browse device media (all-files and/or gallery).
  static Future<bool> hasMediaAccess() async {
    if (Platform.isAndroid &&
        await Permission.manageExternalStorage.isGranted) {
      return true;
    }
    final state = await PhotoManager.getPermissionState(
      requestOption: _videoRequestOption,
    );
    return state.isAuth || state.hasAccess;
  }

  /// Ensures gallery access for the given duplicate scan type (video or audio).
  static Future<bool> ensureMediaAccessFor(DuplicateMediaKind kind) async {
    if (Platform.isAndroid &&
        await Permission.manageExternalStorage.isGranted) {
      return true;
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

  /// Opens Android **All files access** (Allow flow) or requests gallery access.
  static Future<void> openAllFilesAccessSettings() async {
    if (Platform.isAndroid) {
      if (!await Permission.manageExternalStorage.isGranted) {
        await Permission.manageExternalStorage.request();
      }
      if (!await Permission.manageExternalStorage.isGranted) {
        await Permission.storage.request();
      }
    }
    await PhotoManager.requestPermissionExtend(
      requestOption: _videoRequestOption,
    );
  }

  static Future<void> openSystemSettings() => openAppSettings();
}
