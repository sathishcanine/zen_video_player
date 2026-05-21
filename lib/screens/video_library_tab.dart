import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';

import '../models/media_folder.dart';
import '../services/local_media_service.dart';
import '../services/locale_service.dart';
import '../services/media_permission_service.dart';
import '../theme/zen_palette.dart';
import '../theme/zen_theme.dart';
import '../widgets/language_icon_button.dart';
import '../widgets/language_picker_sheet.dart';
import '../widgets/language_tutorial_overlay.dart';
import '../widgets/network_stream_sheet.dart';
import '../widgets/search_filter_bar.dart';
import '../widgets/cast_device_picker_sheet.dart';
import '../widgets/zen_brand_title.dart';
import 'folder_detail_screen.dart';
import 'playlist_list_screen.dart';
import '../services/video_media_actions.dart';
import '../widgets/media_options_sheet.dart';
import '../utils/video_navigation.dart';

class VideoLibraryTab extends StatefulWidget {
  const VideoLibraryTab({super.key});

  @override
  State<VideoLibraryTab> createState() => _VideoLibraryTabState();
}

class _VideoLibraryTabState extends State<VideoLibraryTab>
    with WidgetsBindingObserver {
  List<MediaFolder> _folders = [];
  List<MediaFolder> _filtered = [];
  bool _loading = true;
  bool _hasAccess = false;
  String _query = '';
  bool _awaitingPermission = false;
  final GlobalKey _languageButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    LocaleService.instance.addListener(_onLocaleChanged);
    _refresh();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowLanguageTutorial());
  }

  void _onLocaleChanged() {
    if (!mounted) return;
    setState(() {
      _folders = _localizedFolders(_folders);
      _applyFilter();
    });
  }

  void _maybeShowLanguageTutorial() {
    if (!mounted) return;
    LanguageTutorialOverlay.showIfNeeded(
      context: context,
      targetKey: _languageButtonKey,
    );
  }

  void _openLanguagePicker() {
    LanguageTutorialOverlay.dismiss();
    showLanguagePickerSheet(context);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    LocaleService.instance.removeListener(_onLocaleChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _awaitingPermission) {
      _awaitingPermission = false;
      _refresh();
    }
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    _hasAccess = await MediaPermissionService.hasMediaAccess();
    if (_hasAccess) {
      final folders = await LocalMediaService.loadVideoFolders();
      if (!mounted) return;
      setState(() {
        _folders = _localizedFolders(folders);
        _applyFilter();
        _loading = false;
      });
      LocalMediaService.fillFolderSizes(_folders).then((_) {
        if (!mounted) return;
        setState(() {
          _folders = _localizedFolders(_folders);
          _applyFilter();
        });
      });
    } else {
      if (!mounted) return;
      setState(() {
        _folders = [];
        _filtered = [];
        _loading = false;
      });
    }
  }

  List<MediaFolder> _localizedFolders(List<MediaFolder> folders) {
    final l10n = AppLocalizations.of(context)!;
    return folders
        .map(
          (f) => f.isRecentlyAdded
              ? MediaFolder(
                  id: f.id,
                  displayName: l10n.folderRecentlyAdded,
                  videoCount: f.videoCount,
                  assetPath: f.assetPath,
                  totalBytes: f.totalBytes,
                  isRecentlyAdded: true,
                  isNew: f.isNew,
                )
              : f,
        )
        .toList();
  }

  void _applyFilter() {
    final q = _query.trim().toLowerCase();
    _filtered = q.isEmpty
        ? List<MediaFolder>.from(_folders)
        : _folders
            .where((f) => f.displayName.toLowerCase().contains(q))
            .toList();
  }

  void _openUrl(String url) {
    VideoNavigation.openPreview(
      context: context,
      videoSource: url,
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result == null || !mounted) return;
    final path = result.files.single.path;
    if (path == null) return;
    VideoNavigation.openPlayer(
      context: context,
      videoSource: path,
      isLocal: true,
    );
  }

  void _openPlaylists() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const PlaylistListScreen(),
      ),
    );
  }

  Future<void> _openFolderMenu(MediaFolder folder) async {
    final action = await showMediaOptionsSheet(
      context,
      actions: VideoMediaActions.folderActions(
        includeHide: !folder.isRecentlyAdded,
      ),
    );
    if (action == null || !mounted) return;
    await VideoMediaActions.handleFolder(
      context,
      folder: folder,
      action: action,
      onLibraryChanged: _refresh,
    );
  }

  void _openCastPicker() {
    unawaited(showCastDevicePicker(context));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
          child: Row(
            children: [
              const ZenBrandTitle(),
              const Spacer(),
              LanguageIconButton(
                key: _languageButtonKey,
                tooltip: l10n.chooseLanguage,
                onPressed: _openLanguagePicker,
              ),
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: l10n.searchFolders,
                onPressed: () => _showSearch(context),
              ),
              IconButton(
                icon: const Icon(Icons.cast_outlined),
                tooltip: l10n.cast,
                onPressed: _openCastPicker,
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                tooltip: l10n.moreOptions,
                onSelected: (value) {
                  switch (value) {
                    case 'pick':
                      _pickFile();
                    case 'url':
                      showNetworkStreamSheet(context, onSubmit: _openUrl);
                    case 'access':
                      _requestAccess();
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'pick',
                    child: Text(l10n.pickVideoFile),
                  ),
                  PopupMenuItem(
                    value: 'url',
                    child: Text(l10n.playFromUrl),
                  ),
                  if (!_hasAccess)
                    PopupMenuItem(
                      value: 'access',
                      child: Text(l10n.allowAccess),
                    ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _CategoryPill(
                icon: Icons.queue_music_outlined,
                label: l10n.pillPlaylist,
                onTap: _openPlaylists,
              ),
              const SizedBox(width: 8),
              _CategoryPill(
                icon: Icons.link,
                label: l10n.pillNetworkStream,
                onTap: () => showNetworkStreamSheet(context, onSubmit: _openUrl),
              ),
            ],
          ),
        ),
        SearchFilterBar(
          query: _query,
          onClear: _clearSearch,
        ),
        Expanded(
          child: _loading
              ? Center(child: Text(l10n.loadingLibrary))
              : !_hasAccess
                  ? _NoAccessState(
                      onAllow: _requestAccess,
                      onPick: _pickFile,
                      onUrl: () =>
                          showNetworkStreamSheet(context, onSubmit: _openUrl),
                    )
                  : _filtered.isEmpty
                      ? Center(child: Text(l10n.noVideosFound))
                      : RefreshIndicator(
                          onRefresh: _refresh,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 8),
                            itemCount: _filtered.length,
                            itemBuilder: (context, index) {
                              final folder = _filtered[index];
                              return _FolderTile(
                                folder: folder,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        FolderDetailScreen(folder: folder),
                                  ),
                                ),
                                onMenu: () => _openFolderMenu(folder),
                              );
                            },
                          ),
                        ),
        ),
      ],
    );
  }

  Future<void> _requestAccess() async {
    _awaitingPermission = true;
    await MediaPermissionService.openAllFilesAccessSettings();
    if (!mounted) return;
    if (await MediaPermissionService.hasMediaAccess()) {
      _awaitingPermission = false;
      await _refresh();
    }
  }

  void _clearSearch() {
    setState(() {
      _query = '';
      _applyFilter();
    });
  }

  Future<void> _showSearch(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: _query);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).extension<ZenPalette>()?.sheetBackground ??
            Theme.of(ctx).colorScheme.surface,
        title: Text(l10n.searchFolders),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.searchFolders),
        ),
        actions: [
          if (controller.text.trim().isNotEmpty)
            TextButton(
              onPressed: () => Navigator.pop(ctx, ''),
              child: Text(l10n.clearSearch),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.notNow),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Icon(Icons.search),
          ),
        ],
      ),
    );
    if (result == null) return;
    setState(() {
      _query = result;
      _applyFilter();
    });
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final zen = context.zen;
    return Material(
      color: zen.surfaceCard,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: zen.textSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: zen.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FolderTile extends StatelessWidget {
  const _FolderTile({
    required this.folder,
    required this.onTap,
    required this.onMenu,
  });

  final MediaFolder folder;
  final VoidCallback onTap;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final countLabel = l10n.videoCount(folder.videoCount);
    final size = folder.formatBytes();
    final subtitle = size.isEmpty
        ? countLabel
        : l10n.folderSizeSummary(countLabel, size);

    final zen = context.zen;
    return ListTile(
      leading: Icon(Icons.folder_outlined, color: zen.textSecondary),
      title: Row(
        children: [
          Flexible(
            child: Text(
              folder.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: zen.textPrimary,
              ),
            ),
          ),
          if (folder.isNew) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
      subtitle: Text(
        subtitle,
        style: TextStyle(color: zen.textSecondary, fontSize: 13),
      ),
      trailing: IconButton(
        icon: Icon(Icons.more_vert, color: zen.textSecondary),
        onPressed: onMenu,
      ),
      onTap: onTap,
    );
  }
}

class _NoAccessState extends StatelessWidget {
  const _NoAccessState({
    required this.onAllow,
    required this.onPick,
    required this.onUrl,
  });

  final VoidCallback onAllow;
  final VoidCallback onPick;
  final VoidCallback onUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.grantAccessToBrowse,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.zen.textSecondary),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onAllow,
              child: Text(l10n.allowAccess),
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onPick, child: Text(l10n.pickVideoFile)),
            const SizedBox(height: 8),
            TextButton(onPressed: onUrl, child: Text(l10n.playFromUrl)),
          ],
        ),
      ),
    );
  }
}
