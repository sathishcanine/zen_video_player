import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zen_video_player/app_navigator.dart';
import 'package:zen_video_player/services/play_store_rating_service.dart';
import 'package:zen_video_player/widgets/play_store_rating_dialog.dart';

/// Listens for app resume and shows the Play Store rating prompt when the
/// user returns after a rewarded download was started.
class PlayStoreRatingCoordinator extends StatefulWidget {
  const PlayStoreRatingCoordinator({super.key, required this.child});

  final Widget child;

  @override
  State<PlayStoreRatingCoordinator> createState() =>
      _PlayStoreRatingCoordinatorState();
}

class _PlayStoreRatingCoordinatorState extends State<PlayStoreRatingCoordinator>
    with WidgetsBindingObserver {
  /// Shown after the user returns from the browser / download manager.
  static const Duration _promptDelay = Duration(seconds: 1);

  bool _promptInFlight = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_maybeShowRatingPrompt());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_maybeShowRatingPrompt());
    }
  }

  Future<void> _maybeShowRatingPrompt() async {
    if (_promptInFlight) return;
    if (!await PlayStoreRatingService.shouldPromptOnResume()) return;

    _promptInFlight = true;
    try {
      await Future<void>.delayed(_promptDelay);
      if (!mounted) return;

      final navContext = rootNavigatorKey.currentContext;
      if (navContext == null || !navContext.mounted) return;

      final result = await showPlayStoreRatingDialog(navContext);
      if (result == null) {
        await PlayStoreRatingService.snooze();
      }
    } finally {
      _promptInFlight = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
