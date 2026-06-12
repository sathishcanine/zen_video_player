import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zen_video_player/services/feature_announcement_service.dart';
import 'package:zen_video_player/widgets/equalizer_feature_announce_dialog.dart';

/// Shows the equalizer "what's new" dialog once for users who updated the app.
class EqualizerFeatureAnnouncePrompt {
  EqualizerFeatureAnnouncePrompt._();

  static bool _showing = false;

  static Future<void> maybeShow(BuildContext context) async {
    if (_showing) return;
    try {
      if (!await FeatureAnnouncementService.shouldShowEqualizerAnnounce()) {
        return;
      }
      if (!context.mounted) return;

      _showing = true;
      await FeatureAnnouncementService.markEqualizerAnnounceShown();
      if (!context.mounted) return;

      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (!context.mounted) return;

      await showEqualizerFeatureAnnounceDialog(context);
    } catch (_) {
      // Never break the library home for existing users.
    } finally {
      _showing = false;
    }
  }
}
