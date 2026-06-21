import 'package:flutter/material.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';

import '../models/media_folder.dart';
import '../theme/zen_palette.dart';
import '../theme/zen_theme.dart';
import '../widgets/media_folder_list_icon.dart';

/// Typical Android video buckets shown when the full library is locked.
const _kTeaserFolderNames = [
  'Camera',
  'Download',
  'WhatsApp Video',
  'Movies',
  'Screen recordings',
  'Instagram',
  'AzScreenRecorder',
];

/// Limited-access video tab: CTA plus folder glimpse (partial + locked teasers).
class LimitedVideoLibraryPreview extends StatelessWidget {
  const LimitedVideoLibraryPreview({
    super.key,
    required this.visibleFolders,
    required this.onGrantFullAccess,
    this.onOpenSettings,
    required this.onPickFile,
    required this.onPlayFromUrl,
  });

  final List<MediaFolder> visibleFolders;
  final VoidCallback onGrantFullAccess;
  final VoidCallback? onOpenSettings;
  final VoidCallback onPickFile;
  final VoidCallback onPlayFromUrl;

  List<MediaFolder> _displayFolders() {
    final partial = List<MediaFolder>.from(visibleFolders);
    final names = partial.map((f) => f.displayName.toLowerCase()).toSet();
    if (partial.isEmpty) {
      return _kTeaserFolderNames
          .map(
            (name) => MediaFolder(
              id: 'teaser_$name',
              displayName: name,
              videoCount: 0,
            ),
          )
          .toList();
    }
    final teasers = _kTeaserFolderNames
        .where((name) => !names.contains(name.toLowerCase()))
        .map(
          (name) => MediaFolder(
            id: 'teaser_$name',
            displayName: name,
            videoCount: 0,
          ),
        );
    return [...partial, ...teasers];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rows = _displayFolders();
    final hasPartial = visibleFolders.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AccessPromptCard(
          title: l10n.limitedVideoAccessTitle,
          message: hasPartial
              ? l10n.limitedPartialLibraryHint
              : l10n.limitedAccessPreviewHint,
          primaryLabel: l10n.allowAllVideos,
          onPrimary: onGrantFullAccess,
          settingsLabel: onOpenSettings != null ? l10n.openSettings : null,
          onSettings: onOpenSettings,
        ),
        Expanded(
          child: Stack(
            children: [
              ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 56),
                itemCount: rows.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final folder = rows[index];
                  return _LockedFolderTile(
                    folder: folder,
                    isTeaser: folder.id.startsWith('teaser_'),
                    onTap: onGrantFullAccess,
                  );
                },
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _AlternativeActionsBar(
                  title: l10n.limitedAccessAlternatives,
                  pickLabel: l10n.pickVideoFile,
                  urlLabel: l10n.playFromUrl,
                  onPickFile: onPickFile,
                  onPlayFromUrl: onPlayFromUrl,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AccessPromptCard extends StatelessWidget {
  const _AccessPromptCard({
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    this.settingsLabel,
    this.onSettings,
  });

  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? settingsLabel;
  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context) {
    final zen = context.zen;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: zen.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: ZenTheme.accent.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: ZenTheme.accent.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.folder_special_outlined,
                      color: ZenTheme.textPrimary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: ZenTheme.textPrimary,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          message,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.45,
                            color: zen.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onPrimary,
                icon: const Icon(Icons.lock_open_rounded, size: 20),
                label: Text(primaryLabel),
                style: FilledButton.styleFrom(
                  backgroundColor: ZenTheme.accent,
                  foregroundColor: ZenTheme.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (settingsLabel != null && onSettings != null) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: onSettings,
                  icon: const Icon(Icons.settings_outlined, size: 18),
                  label: Text(settingsLabel!),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ZenTheme.textPrimary,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LockedFolderTile extends StatelessWidget {
  const _LockedFolderTile({
    required this.folder,
    required this.isTeaser,
    required this.onTap,
  });

  final MediaFolder folder;
  final bool isTeaser;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final zen = context.zen;

    final String subtitle;
    if (isTeaser) {
      subtitle = l10n.lockedFolderUnlock;
    } else {
      final countLabel = l10n.videoCount(folder.videoCount);
      final size = folder.formatBytes();
      final counts = size.isEmpty
          ? countLabel
          : l10n.folderSizeSummary(countLabel, size);
      subtitle = '$counts · ${l10n.limitedPartialFolderNote}';
    }

    return Material(
      color: zen.surfaceCard,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              MediaFolderListIcon(size: 28, muted: isTeaser),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            folder.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: isTeaser
                                  ? zen.textSecondary
                                  : zen.textPrimary,
                            ),
                          ),
                        ),
                        if (!isTeaser && folder.isNew) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: ZenTheme.badgeNew,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              l10n.badgeNew,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        color: zen.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lock_outline,
                  size: 18,
                  color: isTeaser ? zen.textSecondary : ZenTheme.accentBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlternativeActionsBar extends StatelessWidget {
  const _AlternativeActionsBar({
    required this.title,
    required this.pickLabel,
    required this.urlLabel,
    required this.onPickFile,
    required this.onPlayFromUrl,
  });

  final String title;
  final String pickLabel;
  final String urlLabel;
  final VoidCallback onPickFile;
  final VoidCallback onPlayFromUrl;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ZenTheme.gradientMid,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: ZenTheme.textPrimary.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _CompactActionButton(
                      icon: Icons.video_file_outlined,
                      label: pickLabel,
                      onPressed: onPickFile,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _CompactActionButton(
                      icon: Icons.link_rounded,
                      label: urlLabel,
                      onPressed: onPlayFromUrl,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactActionButton extends StatelessWidget {
  const _CompactActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: ZenTheme.textPrimary, size: 16),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: ZenTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
