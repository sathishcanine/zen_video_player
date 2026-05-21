import 'package:flutter/material.dart';

import '../models/audio_track.dart';
import '../services/audio_playback_permissions.dart';
import '../services/audio_player_service.dart';

/// Starts audio playback in-app (mini-player), not the video screen.
Future<void> launchAudioPlayback(
  BuildContext context,
  List<AudioTrack> tracks, {
  int startIndex = 0,
}) async {
  if (tracks.isEmpty) return;
  await AudioPlaybackPermissions.ensureAcknowledged(context);
  await AudioPlayerService.instance.playQueue(
    tracks,
    startIndex: startIndex,
  );
}
