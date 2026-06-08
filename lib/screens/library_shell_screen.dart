import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';

import '../app_update/force_update_dialog.dart';
import '../navigation/library_shell_scope.dart';
import '../navigation/library_tab_index.dart';
import '../navigation/mini_player_visibility_observer.dart';
import '../theme/zen_theme.dart';
import '../widgets/audio_mini_player.dart';
import 'audio_library_tab.dart';
import 'settings_tab.dart';
import 'video_library_tab.dart';

/// Main shell: video library, audio/settings, mini-player pinned above bottom nav.
class LibraryShellScreen extends StatefulWidget {
  const LibraryShellScreen({super.key});

  @override
  State<LibraryShellScreen> createState() => _LibraryShellScreenState();
}

class _LibraryShellScreenState extends State<LibraryShellScreen> {
  final GlobalKey<NavigatorState> _stackNavigatorKey = GlobalKey();
  late final MiniPlayerVisibilityObserver _miniPlayerObserver;
  int _index = 0;
  bool _showMiniPlayer = true;

  @override
  void initState() {
    super.initState();
    _miniPlayerObserver = MiniPlayerVisibilityObserver((visible) {
      if (_showMiniPlayer != visible && mounted) {
        setState(() => _showMiniPlayer = visible);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(showForceUpdateDialogIfNeeded(context));
    });
  }

  void _handleShellBack() {
    final nav = _stackNavigatorKey.currentState;
    if (nav != null && nav.canPop()) {
      nav.pop();
      return;
    }
    if (_index != 0) {
      setState(() => _index = 0);
      return;
    }
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tabs = <Widget>[
      const VideoLibraryTab(),
      const AudioLibraryTab(),
      const SettingsTab(),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleShellBack();
      },
      child: LibraryShellScope(
      stackNavigatorKey: _stackNavigatorKey,
      child: LibraryTabIndex(
        index: _index,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: false,
          body: ZenGradientBackground(
            child: SafeArea(
              bottom: false,
              child: Navigator(
                key: _stackNavigatorKey,
                observers: [_miniPlayerObserver],
                onGenerateRoute: (_) => MaterialPageRoute<void>(
                  builder: (_) => _LibraryTabHost(tabs: tabs),
                ),
              ),
            ),
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_showMiniPlayer) const AudioMiniPlayer(),
              BottomNavigationBar(
                currentIndex: _index,
                onTap: (i) {
                  if (i != _index) {
                    _stackNavigatorKey.currentState
                        ?.popUntil((route) => route.isFirst);
                  }
                  setState(() => _index = i);
                },
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.videocam_outlined),
                    activeIcon: const Icon(Icons.videocam),
                    label: l10n.tabVideo,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.music_note_outlined),
                    activeIcon: const Icon(Icons.music_note),
                    label: l10n.tabAudio,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.tune_outlined),
                    activeIcon: const Icon(Icons.tune),
                    label: l10n.tabSettings,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

/// Tab content shown as the shell navigator's root route.
class _LibraryTabHost extends StatelessWidget {
  const _LibraryTabHost({required this.tabs});

  final List<Widget> tabs;

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: LibraryTabIndex.of(context),
      children: tabs,
    );
  }
}
