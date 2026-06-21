import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';

import '../services/hidden_folders_service.dart';

Future<void> showHiddenFoldersSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (ctx) => const _HiddenFoldersSheet(),
  );
}

class _HiddenFoldersSheet extends StatefulWidget {
  const _HiddenFoldersSheet();

  @override
  State<_HiddenFoldersSheet> createState() => _HiddenFoldersSheetState();
}

class _HiddenFoldersSheetState extends State<_HiddenFoldersSheet> {
  List<HiddenFolderEntry> _entries = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final entries = await HiddenFoldersService.instance.loadHiddenEntries();
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  Future<void> _restore(HiddenFolderEntry entry) async {
    await HiddenFoldersService.instance.unhide(entry.id);
    if (!mounted) return;
    await _load();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.hiddenFolderRestored(entry.displayName)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _restoreAll() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.hiddenFoldersRestoreAllTitle),
        content: Text(l10n.hiddenFoldersRestoreAllBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.hiddenFoldersRestoreAllConfirm),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await HiddenFoldersService.instance.unhideAll();
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.hiddenFoldersRestoreAllDone),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text(
                l10n.settingsHiddenFolders,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                l10n.settingsHiddenFoldersSheetBody,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            if (_loading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_entries.isEmpty)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l10n.hiddenFoldersEmpty,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _entries.length,
                  itemBuilder: (context, index) {
                    final entry = _entries[index];
                    return ListTile(
                      leading: const Icon(Icons.folder_off_outlined),
                      title: Text(entry.displayName),
                      trailing: TextButton(
                        onPressed: () => unawaited(_restore(entry)),
                        child: Text(l10n.hiddenFolderRestore),
                      ),
                    );
                  },
                ),
              ),
            if (!_loading && _entries.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: OutlinedButton(
                  onPressed: () => unawaited(_restoreAll()),
                  child: Text(l10n.hiddenFoldersRestoreAllConfirm),
                ),
              ),
          ],
        );
      },
    );
  }
}
