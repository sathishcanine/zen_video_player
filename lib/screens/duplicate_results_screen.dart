import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';
import 'package:zen_video_player/theme/zen_palette.dart';
import 'package:zen_video_player/theme/zen_theme.dart';
import 'package:zen_video_player/utils/format_bytes.dart';

import '../models/duplicate_group.dart';
import '../models/duplicate_media_item.dart';
import '../models/duplicate_media_kind.dart';
import '../navigation/library_navigation.dart';
import '../services/duplicate_finder_service.dart';

/// Lists duplicate groups and lets the user delete extra copies.
class DuplicateResultsScreen extends StatefulWidget {
  const DuplicateResultsScreen({
    super.key,
    required this.kind,
    required this.groups,
  });

  final DuplicateMediaKind kind;
  final List<DuplicateGroup> groups;

  @override
  State<DuplicateResultsScreen> createState() => _DuplicateResultsScreenState();
}

class _DuplicateResultsScreenState extends State<DuplicateResultsScreen> {
  late List<DuplicateGroup> _groups;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _groups = List<DuplicateGroup>.from(widget.groups);
  }

  int get _deletableCount =>
      _groups.fold<int>(0, (n, g) => n + g.deletable.length);

  Future<void> _confirmDelete(DuplicateMediaItem item) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.zen.sheetBackground,
        title: Text(l10n.duplicateDeleteTitle),
        content: Text(l10n.duplicateDeleteBody(item.displayName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.notNow),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.duplicateDeleteConfirm),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await _deleteItems([item]);
  }

  Future<void> _deleteItems(List<DuplicateMediaItem> items) async {
    if (items.isEmpty || _busy) return;
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    try {
      final deleted = await DuplicateFinderService.deleteItems(items);
      if (!mounted) return;

      final deletedIds = deleted.toSet();
      setState(() {
        _groups = _groups
            .map((group) {
              final remaining = group.items
                  .where((i) => !deletedIds.contains(i.asset.id))
                  .toList();
              if (remaining.length < 2) return null;
              remaining.sort(
                (a, b) =>
                    a.asset.createDateTime.compareTo(b.asset.createDateTime),
              );
              final items = <DuplicateMediaItem>[];
              for (var i = 0; i < remaining.length; i++) {
                final old = remaining[i];
                items.add(
                  DuplicateMediaItem(
                    asset: old.asset,
                    displayName: old.displayName,
                    bytes: old.bytes,
                    kind: old.kind,
                    isKeeper: i == 0,
                  ),
                );
              }
              return DuplicateGroup(key: group.key, items: items);
            })
            .whereType<DuplicateGroup>()
            .toList();
        _busy = false;
      });

      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.duplicateDeleted(deleted.length)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.duplicateDeleteFailed),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final zen = context.zen;

    return LibraryRoutePage(
      child: Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => LibraryNavigation.pop(context),
        ),
        title: Text(l10n.duplicateResultsTitle),
        actions: [
          if (_deletableCount > 0)
            TextButton(
              onPressed: _busy
                  ? null
                  : () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: ctx.zen.sheetBackground,
                          title: Text(l10n.duplicateDeleteAllTitle),
                          content: Text(
                            l10n.duplicateDeleteAllBody(_deletableCount),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text(l10n.notNow),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text(l10n.duplicateDeleteConfirm),
                            ),
                          ],
                        ),
                      );
                      if (ok != true || !mounted) return;
                      final all = _groups.expand((g) => g.deletable).toList();
                      await _deleteItems(all);
                    },
              child: Text(l10n.duplicateDeleteAll),
            ),
        ],
      ),
      body: ZenGradientBackground(
        child: SafeArea(
          child: _groups.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      l10n.duplicateNoneFound,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: zen.textSecondary, fontSize: 16),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  itemCount: _groups.length,
                  itemBuilder: (context, index) {
                    final group = _groups[index];
                    return _DuplicateGroupCard(
                      group: group,
                      busy: _busy,
                      onDelete: _confirmDelete,
                    );
                  },
                ),
        ),
      ),
      ),
    );
  }
}

class _DuplicateGroupCard extends StatelessWidget {
  const _DuplicateGroupCard({
    required this.group,
    required this.busy,
    required this.onDelete,
  });

  final DuplicateGroup group;
  final bool busy;
  final Future<void> Function(DuplicateMediaItem item) onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final zen = context.zen;
    final keeper = group.keeper;
    final sizeLabel = formatBytes(keeper.bytes);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: zen.surfaceCard,
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text(
          l10n.duplicateGroupTitle(group.duplicateCount, keeper.displayName),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: zen.textPrimary,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          sizeLabel,
          style: TextStyle(color: zen.textSecondary, fontSize: 13),
        ),
        children: [
          for (final item in group.items)
            _DuplicateItemTile(
              item: item,
              busy: busy,
              onDelete: () => onDelete(item),
            ),
        ],
      ),
    );
  }
}

class _DuplicateItemTile extends StatelessWidget {
  const _DuplicateItemTile({
    required this.item,
    required this.busy,
    required this.onDelete,
  });

  final DuplicateMediaItem item;
  final bool busy;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final zen = context.zen;

    return ListTile(
      leading: _ThumbnailPreview(item: item),
      title: Text(
        item.displayName,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: zen.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        formatBytes(item.bytes),
        style: TextStyle(color: zen.textSecondary, fontSize: 12),
      ),
      trailing: item.isKeeper
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(
                      alpha: 0.15,
                    ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                l10n.duplicateKeep,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            )
          : IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.redAccent,
              tooltip: l10n.duplicateDeleteConfirm,
              onPressed: busy ? null : onDelete,
            ),
    );
  }
}

class _ThumbnailPreview extends StatelessWidget {
  const _ThumbnailPreview({required this.item});

  final DuplicateMediaItem item;

  @override
  Widget build(BuildContext context) {
    final icon = item.kind == DuplicateMediaKind.video
        ? Icons.videocam_outlined
        : Icons.music_note;

    return FutureBuilder<Uint8List?>(
      future: item.asset.thumbnailDataWithSize(
        const ThumbnailSize.square(96),
      ),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes != null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.memory(bytes, width: 48, height: 48, fit: BoxFit.cover),
          );
        }
        return Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.zen.surfaceElevated,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: context.zen.textSecondary),
        );
      },
    );
  }
}
