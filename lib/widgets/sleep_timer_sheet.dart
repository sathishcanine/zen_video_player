import 'package:flutter/material.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';

import '../services/sleep_timer_service.dart';

Future<void> showSleepTimerSheet(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final timer = SleepTimerService.instance;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      return SafeArea(
        child: ListenableBuilder(
          listenable: timer,
          builder: (context, _) {
            final remaining = timer.remaining;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      l10n.sleepTimerTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  if (timer.isActive) ...[
                    const SizedBox(height: 8),
                    ListTile(
                      leading: const Icon(Icons.timer_off_outlined),
                      title: Text(l10n.sleepTimerCancel),
                      subtitle: timer.stopAtEndOfMedia
                          ? Text(l10n.sleepTimerEndOfMediaActive)
                          : remaining != null
                              ? Text(l10n.sleepTimerRemaining(
                                  _formatRemaining(remaining),
                                ))
                              : null,
                      onTap: () {
                        timer.cancel();
                        Navigator.pop(ctx);
                      },
                    ),
                    const Divider(),
                  ],
                  for (final min in [5, 10, 15, 30, 60])
                    ListTile(
                      leading: const Icon(Icons.timer_outlined),
                      title: Text(l10n.sleepTimerMinutes(min)),
                      onTap: () {
                        timer.start(minutes: min);
                        Navigator.pop(ctx);
                      },
                    ),
                  ListTile(
                    leading: const Icon(Icons.edit_calendar_outlined),
                    title: Text(l10n.sleepTimerCustom),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final minutes = await _pickCustomMinutes(context);
                      if (minutes != null && minutes > 0) {
                        timer.start(minutes: minutes);
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.movie_filter_outlined),
                    title: Text(l10n.sleepTimerEndOfMedia),
                    subtitle: Text(l10n.sleepTimerEndOfMediaSubtitle),
                    onTap: () {
                      timer.start(endOfMedia: true);
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

Future<int?> _pickCustomMinutes(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final controller = TextEditingController();
  return showDialog<int>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.sleepTimerCustom),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        autofocus: true,
        decoration: InputDecoration(hintText: l10n.sleepTimerCustomHint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(l10n.notNow),
        ),
        FilledButton(
          onPressed: () {
            final v = int.tryParse(controller.text.trim());
            Navigator.pop(ctx, v);
          },
          child: Text(l10n.sleepTimerSet),
        ),
      ],
    ),
  );
}

String _formatRemaining(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (h > 0) return '$h:$m:$s';
  return '$m:$s';
}
