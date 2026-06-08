import 'package:flutter/material.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';

import '../services/audio_media_actions.dart';
import '../services/audio_player_service.dart';
import '../theme/zen_theme.dart';
import 'audio_artwork.dart';

Future<void> showAudioQueueSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFF1E1E1E),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.45,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      builder: (_, scrollController) =>
          _QueueSheetBody(scrollController: scrollController),
    ),
  );
}

class _QueueSheetBody extends StatelessWidget {
  const _QueueSheetBody({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AudioPlayerService.instance,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context)!;
        final service = AudioPlayerService.instance;
        final queue = service.queue;
        final current = service.currentIndex;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  Text(
                    l10n.queue,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: ZenTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: queue.length,
                itemBuilder: (_, i) {
                  final track = queue[i];
                  final playing = i == current;
                  final artist = track.artist.isEmpty
                      ? l10n.unknownArtist
                      : track.artist;
                  return ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.drag_handle, color: ZenTheme.textSecondary),
                        const SizedBox(width: 8),
                        AudioArtwork(asset: track.asset),
                      ],
                    ),
                    title: Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (playing)
                          const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(
                              Icons.play_circle,
                              color: Color(0xFFE53935),
                              size: 20,
                            ),
                          ),
                        Text(
                          formatDuration(
                            Duration(seconds: track.asset.duration),
                          ),
                          style: const TextStyle(color: ZenTheme.textSecondary),
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert, size: 20),
                          onPressed: () => AudioMediaActions.openTrackMenu(
                            context,
                            track: track,
                            queue: queue,
                          ),
                        ),
                      ],
                    ),
                    onTap: () => service.jumpTo(i),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
