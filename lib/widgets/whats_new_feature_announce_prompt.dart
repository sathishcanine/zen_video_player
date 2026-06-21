import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zen_video_player/services/feature_announcement_service.dart';
import 'package:zen_video_player/widgets/whats_new_feature_announce_dialog.dart';

/// Shows the 4.0.1 "what's new" dialog once for users who updated the app.
class WhatsNewFeatureAnnouncePrompt {
  WhatsNewFeatureAnnouncePrompt._();

  static bool _showing = false;

  static Future<void> maybeShow(BuildContext context) async {
    if (_showing) return;
    try {
      if (!await FeatureAnnouncementService.shouldShowWhatsNewV401()) {
        return;
      }
      if (!context.mounted) return;

      _showing = true;
      // Clear pending before show so a crash cannot re-trigger on every launch.
      await FeatureAnnouncementService.markWhatsNewV401Shown();
      if (!context.mounted) return;

      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!context.mounted) return;

      await showWhatsNewFeatureAnnounceDialog(context);
    } catch (_) {
      // Never break the library home for existing users.
    } finally {
      _showing = false;
    }
  }
}
