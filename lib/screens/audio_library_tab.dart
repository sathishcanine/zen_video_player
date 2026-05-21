import 'package:flutter/material.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';

import '../models/audio_track.dart';
import '../models/media_folder.dart';
import '../services/audio_artwork_cache.dart';
import '../services/audio_playback_permissions.dart';
import '../services/audio_player_service.dart';
import '../services/local_audio_service.dart';
import '../services/locale_service.dart';
import '../services/media_permission_service.dart';
import '../theme/zen_theme.dart';
import '../widgets/audio_artwork.dart';
import '../widgets/language_icon_button.dart';
import '../widgets/language_picker_sheet.dart';
import '../widgets/zen_brand_title.dart';
import '../utils/audio_playback_launcher.dart';
import 'audio_track_list_screen.dart';

enum _AudioSection { album, songs, artist, folder, playlist }

/// Audio home: Album / Songs / Artist / Folder / Playlist sub-nav.
class AudioLibraryTab extends StatefulWidget {
  const AudioLibraryTab({super.key});

  @override
  State<AudioLibraryTab> createState() => _AudioLibraryTabState();
}

class _AudioLibraryTabState extends State<AudioLibraryTab> {
  _AudioSection _section = _AudioSection.album;
  late final PageController _pageController;
  bool _loading = true;
  bool _hasAccess = false;
  String _query = '';

  List<AudioTrack> _tracks = [];
  List<AudioAlbum> _albums = [];
  List<AudioArtist> _artists = [];
  List<MediaFolder> _folders = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    LocaleService.instance.addListener(_onLocaleChanged);
    _refresh();
  }

  @override
  void dispose() {
    _pageController.dispose();
    LocaleService.instance.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _selectSection(_AudioSection section) {
    if (_section == section) return;
    setState(() => _section = section);
    _pageController.animateToPage(
      section.index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _onPageSwiped(int index) {
    final section = _AudioSection.values[index];
    if (_section == section) return;
    setState(() => _section = section);
  }

  void _onLocaleChanged() => _refresh();

  Future<void> _refresh() async {
    setState(() => _loading = true);
    AudioArtworkCache.instance.clear();
    _hasAccess = await MediaPermissionService.hasMediaAccess();
    if (!_hasAccess) {
      if (!mounted) return;
      setState(() {
        _tracks = [];
        _albums = [];
        _artists = [];
        _folders = [];
        _loading = false;
      });
      return;
    }

    final tracks = await LocalAudioService.loadTracks();
    final artists = LocalAudioService.groupArtists(tracks);
    final folders = await LocalAudioService.loadAudioFolders();

    if (!mounted) return;
    setState(() {
      _tracks = tracks;
      _albums = LocalAudioService.groupAlbums(tracks);
      _artists = artists;
      _folders = folders;
      _loading = false;
    });

    final albums = await LocalAudioService.groupAlbumsEnriched(tracks);
    if (!mounted) return;
    setState(() => _albums = albums);
  }

  List<AudioAlbum> get _filteredAlbums {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _albums;
    return _albums
        .where(
          (a) =>
              a.title.toLowerCase().contains(q) ||
              a.artist.toLowerCase().contains(q),
        )
        .toList();
  }

  List<AudioTrack> get _filteredTracks {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _tracks;
    return _tracks
        .where(
          (t) =>
              t.title.toLowerCase().contains(q) ||
              t.albumName.toLowerCase().contains(q),
        )
        .toList();
  }

  List<AudioArtist> get _filteredArtists {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _artists;
    return _artists.where((a) => a.name.toLowerCase().contains(q)).toList();
  }

  Future<void> _playTrack(AudioTrack track, {List<AudioTrack>? queue}) async {
    final list = queue ?? _filteredTracks;
    final idx = list.indexOf(track);
    await launchAudioPlayback(
      context,
      list,
      startIndex: idx >= 0 ? idx : 0,
    );
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.comingSoon)),
    );
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
                tooltip: l10n.chooseLanguage,
                onPressed: () => showLanguagePickerSheet(context),
              ),
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: l10n.searchAudio,
                onPressed: () => _showSearch(context),
              ),
              IconButton(
                icon: const Icon(Icons.cast_outlined),
                tooltip: l10n.cast,
                onPressed: _showComingSoon,
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    enabled: false,
                    child: Text(l10n.moreOptions),
                  ),
                ],
              ),
            ],
          ),
        ),
        _AudioSubNav(
          section: _section,
          onChanged: _selectSection,
        ),
        const SizedBox(height: 4),
        Expanded(child: _buildBody(l10n)),
      ],
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_loading) {
      return Center(child: Text(l10n.loadingLibrary));
    }
    if (!_hasAccess) {
      return _NoAccessAudio(onAllow: () async {
        await MediaPermissionService.openAllFilesAccessSettings();
        await LocalAudioService.requestAudioAccess();
        await _refresh();
      });
    }

    return PageView(
      controller: _pageController,
      onPageChanged: _onPageSwiped,
      children: [
        _buildAlbumGrid(l10n),
        _buildSongsList(l10n),
        _buildArtistList(l10n),
        _buildFolderList(l10n),
        _PlaylistPlaceholder(message: l10n.audioPlaylistHint),
      ],
    );
  }

  Widget _buildAlbumGrid(AppLocalizations l10n) {
    final albums = _filteredAlbums;
    if (albums.isEmpty) {
      return Center(child: Text(l10n.noAudioFound));
    }
    return RefreshIndicator(
      onRefresh: _refresh,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.82,
        ),
        itemCount: albums.length,
        itemBuilder: (_, i) {
          final album = albums[i];
          return _AlbumCard(
            album: album,
            unknownArtist: l10n.unknownArtist,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => AudioTrackListScreen(
                  title: album.title,
                  tracks: album.tracks,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSongsList(AppLocalizations l10n) {
    final tracks = _filteredTracks;
    if (tracks.isEmpty) return Center(child: Text(l10n.noAudioFound));
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 72),
            itemCount: tracks.length,
            itemBuilder: (_, i) {
              final t = tracks[i];
              return ListTile(
                leading: AudioArtwork(asset: t.asset),
                title: Text(
                  t.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  _trackSubtitle(t, l10n),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ZenTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formatDuration(Duration(seconds: t.asset.duration)),
                      style: const TextStyle(
                        color: ZenTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, size: 20),
                      onPressed: () {},
                    ),
                  ],
                ),
                onTap: () => _playTrack(t, queue: tracks),
              );
            },
          ),
        ),
        Positioned(
          right: 16,
          bottom: 12,
          child: FloatingActionButton.extended(
            heroTag: 'shuffle_all',
            backgroundColor: ZenTheme.gradientMid,
            onPressed: () async {
              await AudioPlaybackPermissions.ensureAcknowledged(context);
              await AudioPlayerService.instance.playShuffled(tracks);
            },
            icon: const Icon(Icons.shuffle),
            label: Text(l10n.shuffleAll),
          ),
        ),
      ],
    );
  }

  String _trackSubtitle(AudioTrack t, AppLocalizations l10n) {
    final artist = t.artist.isEmpty ? l10n.unknownArtist : t.artist;
    return '$artist | ${t.albumName}';
  }

  Widget _buildArtistList(AppLocalizations l10n) {
    final artists = _filteredArtists;
    if (artists.isEmpty) return Center(child: Text(l10n.noAudioFound));
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: artists.length,
        itemBuilder: (_, i) {
          final a = artists[i];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: ZenTheme.surfaceElevated,
              child: const Icon(Icons.person, color: ZenTheme.textSecondary),
            ),
            title: Text(
              a.name.isEmpty ? l10n.unknownArtist : a.name,
            ),
            subtitle: Text(
              l10n.songCount(a.trackCount),
              style: const TextStyle(color: ZenTheme.textSecondary),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => AudioTrackListScreen(
                  title: a.name,
                  tracks: a.tracks,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFolderList(AppLocalizations l10n) {
    if (_folders.isEmpty) return Center(child: Text(l10n.noAudioFound));
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _folders.length,
        itemBuilder: (_, i) {
          final folder = _folders[i];
          return ListTile(
            leading: const Icon(Icons.folder_outlined, color: ZenTheme.textSecondary),
            title: Text(folder.displayName),
            subtitle: Text(
              l10n.songCount(folder.videoCount),
              style: const TextStyle(color: ZenTheme.textSecondary),
            ),
            onTap: () async {
              final tracks = await LocalAudioService.loadTracksInFolder(folder);
              if (!mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => AudioTrackListScreen(
                    title: folder.displayName,
                    tracks: tracks,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showSearch(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: _query);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ZenTheme.gradientMid,
        title: Text(l10n.searchAudio),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.searchAudio),
        ),
        actions: [
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
    setState(() => _query = result);
  }
}

class _AudioSubNav extends StatelessWidget {
  const _AudioSubNav({required this.section, required this.onChanged});

  final _AudioSection section;
  final ValueChanged<_AudioSection> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = [
      (l10n.audioSubAlbum, _AudioSection.album),
      (l10n.audioSubSongs, _AudioSection.songs),
      (l10n.audioSubArtist, _AudioSection.artist),
      (l10n.audioSubFolder, _AudioSection.folder),
      (l10n.audioSubPlaylist, _AudioSection.playlist),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 20),
        itemBuilder: (_, i) {
          final active = items[i].$2 == section;
          return GestureDetector(
            onTap: () => onChanged(items[i].$2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  items[i].$1,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: active ? ZenTheme.textPrimary : ZenTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 3,
                  width: active ? 36 : 0,
                  decoration: BoxDecoration(
                    color: ZenTheme.accentBlue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AlbumCard extends StatelessWidget {
  const _AlbumCard({
    required this.album,
    required this.unknownArtist,
    required this.onTap,
  });

  final AudioAlbum album;
  final String unknownArtist;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final artist =
        album.artist.isEmpty ? unknownArtist : album.artist;
    return Material(
      color: ZenTheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: AudioArtwork(large: true, asset: album.coverAsset),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          album.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: ZenTheme.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: ZenTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, size: 20),
                    color: ZenTheme.textSecondary,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoAccessAudio extends StatelessWidget {
  const _NoAccessAudio({required this.onAllow});

  final VoidCallback onAllow;

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
              style: const TextStyle(color: ZenTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onAllow, child: Text(l10n.allowAccess)),
          ],
        ),
      ),
    );
  }
}

class _PlaylistPlaceholder extends StatelessWidget {
  const _PlaylistPlaceholder({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.queue_music,
              size: 48,
              color: ZenTheme.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.comingSoon,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ZenTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: ZenTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
