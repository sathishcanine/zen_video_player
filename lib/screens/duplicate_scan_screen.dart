import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';
import 'package:zen_video_player/theme/zen_palette.dart';
import 'package:zen_video_player/theme/zen_theme.dart';

import '../models/duplicate_media_kind.dart';
import '../navigation/library_navigation.dart';
import '../navigation/library_shell_scope.dart';
import '../services/duplicate_finder_service.dart';
import '../services/media_permission_service.dart';
import 'duplicate_results_screen.dart';

/// Full-screen duplicate scan (UPlayer-style progress).
class DuplicateScanScreen extends StatefulWidget {
  const DuplicateScanScreen({super.key, required this.kind});

  final DuplicateMediaKind kind;

  @override
  State<DuplicateScanScreen> createState() => _DuplicateScanScreenState();
}

class _DuplicateScanScreenState extends State<DuplicateScanScreen> {
  DuplicateScanProgress _progress = const DuplicateScanProgress(percent: 0);
  bool _running = true;
  bool _cancelled = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_runScan());
    });
  }

  void _applyProgress(DuplicateScanProgress next) {
    if (!mounted) return;
    setState(() {
      _progress = next.percent >= _progress.percent
          ? next
          : DuplicateScanProgress(
              percent: _progress.percent,
              scanned: next.scanned,
              total: next.total,
              groupsFound: next.groupsFound,
              currentFileName: next.currentFileName,
              isLoadingLibrary: next.isLoadingLibrary,
            );
    });
  }

  Future<void> _runScan() async {
    final l10n = AppLocalizations.of(context)!;

    if (!await MediaPermissionService.ensureMediaAccessFor(widget.kind)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.permissionRequired)),
      );
      Navigator.pop(context);
      return;
    }

    _applyProgress(const DuplicateScanProgress(percent: 0));
    await Future<void>.delayed(Duration.zero);

    try {
      final groups = await DuplicateFinderService.scan(
        kind: widget.kind,
        isCancelled: () => _cancelled,
        onProgress: _applyProgress,
      );

      if (!mounted || _cancelled) return;

      setState(() {
        _running = false;
        _progress = const DuplicateScanProgress(percent: 100);
      });

      await Future<void>.delayed(const Duration(milliseconds: 350));

      if (!mounted || _cancelled) return;

      final nav =
          LibraryShellScope.navigatorOf(context) ?? Navigator.of(context);
      nav.pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => DuplicateResultsScreen(
            kind: widget.kind,
            groups: groups,
          ),
        ),
      );
    } catch (e) {
      if (!mounted || _cancelled) return;
      setState(() {
        _running = false;
        _error = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.duplicateScanFailed)),
      );
    }
  }

  @override
  void dispose() {
    _cancelled = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final zen = context.zen;
    final primary = Theme.of(context).colorScheme.primary;
    final percent = _progress.percent.clamp(0, 100);
    final fraction = percent / 100.0;
    final current = _progress.currentFileName;
    final loading = _progress.isLoadingLibrary;

    return LibraryRoutePage(
      child: Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _cancelled = true;
            LibraryNavigation.pop(context);
          },
        ),
      ),
      body: ZenGradientBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _error != null
                        ? l10n.duplicateScanFailed
                        : loading && percent < _loadEndLabel
                            ? l10n.loadingLibrary
                            : l10n.duplicateScanning,
                    style: TextStyle(
                      fontSize: 16,
                      color: zen.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: CircularProgressIndicator(
                            value: _running && percent > 0
                                ? fraction
                                : _running
                                    ? null
                                    : 1,
                            strokeWidth: 6,
                            backgroundColor: zen.textSecondary.withValues(
                              alpha: 0.25,
                            ),
                            color: primary.withValues(alpha: 0.85),
                          ),
                        ),
                        Text(
                          '$percent%',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w300,
                            color: primary,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (current != null && current.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        current,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}

/// Matches [DuplicateFinderService] load-phase end for status label.
const int _loadEndLabel = 40;
