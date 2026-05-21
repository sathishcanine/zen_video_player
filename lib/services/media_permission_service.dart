import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
