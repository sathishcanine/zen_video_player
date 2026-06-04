import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zen_video_player/services/play_store_rating_service.dart';
import 'package:zen_video_player/widgets/play_store_rating_dialog.dart';

/// Shows the Play Store rating dialog on the folder list (day 2+; Maybe → next day).
class PlayStoreRatingHomePrompt {
  PlayStoreRatingHomePrompt._();

  static bool _showing = false;

  static Future<void> maybeShow(BuildContext context) async {
    if (_showing) return;
    try {
      if (!await PlayStoreRatingService.shouldPromptOnHomeScreen()) return;
      if (!context.mounted) return;

      _showing = true;
      await PlayStoreRatingService.clearHomePending();
      if (!context.mounted) return;

      await Future<void>.delayed(const Duration(seconds: 1));
      if (!context.mounted) return;

      final result = await showPlayStoreRatingDialog(context);
      if (result == null) {
        await PlayStoreRatingService.snooze();
      }
    } catch (_) {
      // Never break the folder list for existing users.
    } finally {
      _showing = false;
    }
  }
}
