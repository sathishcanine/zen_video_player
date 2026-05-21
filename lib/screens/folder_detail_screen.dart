import 'package:flutter/material.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';
import 'package:photo_manager/photo_manager.dart';

import '../models/media_folder.dart';
import '../services/local_media_service.dart';
import '../theme/zen_theme.dart';
import '../utils/video_navigation.dart';
class FolderDetailScreen extends StatefulWidget {
  const FolderDetailScreen({super.key, required this.folder});

  final MediaFolder folder;

  @override
  State<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends State<FolderDetailScreen> {
  List<AssetEntity> _assets = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final assets = await LocalMediaService.loadVideosInFolder(widget.folder);
    if (!mounted) return;
    setState(() {
      _assets = assets;
      _loading = false;
    });
  }

  String _title(AppLocalizations l10n) {
    if (widget.folder.isRecentlyAdded) {
      return l10n.folderRecentlyAdded;
    }
    return widget.folder.displayName;
  }

  Future<void> _openAsset(AssetEntity asset) async {
    final file = await asset.file;
    if (!mounted) return;
    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.noVideosFound)),
      );
      return;
    }

    VideoNavigation.openPlayer(
      context: context,
      videoSource: file.path,
      isLocal: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.videosInFolder(_title(l10n))),
      ),
      body: ZenGradientBackground(
        child: SafeArea(
          child: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _assets.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final asset = _assets[index];
                return ListTile(
                  leading: const Icon(Icons.videocam_outlined),
                  title: Text(
                    asset.title ?? 'Video ${index + 1}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    _formatDuration(asset.duration),
                    style: const TextStyle(color: ZenTheme.textSecondary),
                  ),
                  onTap: () => _openAsset(asset),
                );
              },
            ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
