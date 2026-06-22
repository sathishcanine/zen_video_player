import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the Play Store or launches another installed Android app.
abstract final class ExternalAppLauncher {
  static const MethodChannel _channel = MethodChannel('zen.push_intents');

  static const String zenPackageName = 'com.player.zen_video_player';
  static const String minnalBrowserPackageName = 'com.browser.minnal';

  static Future<void> openPlayStore(String target) async {
    final resolved = _resolvePackageName(target);
    if (resolved.isEmpty) return;
    if (!kIsWeb && Platform.isAndroid) {
      try {
        await _channel.invokeMethod<void>(
          'openPlayStore',
          <String, String>{'target': resolved},
        );
      } on PlatformException catch (e) {
        debugPrint('[push] openPlayStore native failed: $e');
        await _openPlayStoreWeb(resolved);
      }
      return;
    }
    await _openPlayStoreWeb(resolved);
  }

  /// Launches [target] when installed; otherwise opens its Play Store listing.
  static Future<bool> launchApp(String target) async {
    final resolved = _resolvePackageName(target);
    if (resolved.isEmpty) return false;
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final launched = await _channel.invokeMethod<bool>(
          'launchApp',
          <String, String>{'target': resolved},
        );
        return launched ?? false;
      } on PlatformException catch (e) {
        debugPrint('[push] launchApp native failed: $e');
        await _openPlayStoreWeb(resolved);
        return false;
      }
    }
    await _openPlayStoreWeb(resolved);
    return false;
  }

  static Future<void> _openPlayStoreWeb(String packageName) async {
    try {
      final web = Uri.parse(
        'https://play.google.com/store/apps/details?id=$packageName',
      );
      if (!await canLaunchUrl(web)) return;
      await launchUrl(web, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('[push] openPlayStore web failed: $e');
    }
  }

  static String _resolvePackageName(String target) {
    final trimmed = target.trim();
    if (trimmed.isEmpty) return trimmed;
    final uri = Uri.tryParse(trimmed);
    final id = uri?.queryParameters['id']?.trim();
    if (id != null && id.isNotEmpty) return _resolvePackageName(id);
    return trimmed;
  }
}
