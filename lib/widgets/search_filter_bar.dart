import 'package:flutter/material.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';

import '../theme/zen_palette.dart';

/// Visible active-search strip with a clear action (below the app header).
class SearchFilterBar extends StatelessWidget {
  const SearchFilterBar({
    super.key,
    required this.query,
    required this.onClear,
  });

  final String query;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const SizedBox.shrink();

    final zen = context.zen;
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Material(
        color: zen.surfaceCard,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.only(left: 12, top: 6, bottom: 6),
          child: Row(
            children: [
              Icon(Icons.search, size: 20, color: primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.searchResultsFor(trimmed),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: zen.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.close, size: 18),
                label: Text(
                  l10n.clearSearch,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: primary,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
