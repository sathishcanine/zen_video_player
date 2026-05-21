import 'package:flutter/material.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';

import '../theme/zen_theme.dart';

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

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Material(
        color: ZenTheme.surface,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.only(left: 12, top: 6, bottom: 6),
          child: Row(
            children: [
              const Icon(
                Icons.search,
                size: 20,
                color: ZenTheme.accentBlue,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.searchResultsFor(trimmed),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ZenTheme.textPrimary,
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
                  foregroundColor: ZenTheme.accentBlue,
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
