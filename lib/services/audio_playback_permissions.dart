import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/background_playback_sheet.dart';

class AudioPlaybackPermissions {
  AudioPlaybackPermissions._();

  static const _key = 'audio_background_playback_ack_v1';

  static Future<bool> wasAcknowledged() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  static Future<void> markAcknowledged() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }

  /// Shows background-play sheet once; requests battery opt-out on Android.
  static Future<void> ensureAcknowledged(BuildContext context) async {
    if (await wasAcknowledged()) return;
    if (!context.mounted) return;

    final allow = await showBackgroundPlaybackSheet(context);
    if (allow) {
      await markAcknowledged();
      if (Platform.isAndroid) {
        await Permission.ignoreBatteryOptimizations.request();
      }
    }
  }
}
