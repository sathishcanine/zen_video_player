import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../services/audio_artwork_cache.dart';
import '../theme/zen_palette.dart';

/// Album art from embedded audio tags, or a note placeholder.
class AudioArtwork extends StatefulWidget {
  const AudioArtwork({super.key, this.large = false, this.asset});

  final bool large;
  final AssetEntity? asset;

  @override
  State<AudioArtwork> createState() => _AudioArtworkState();
}

class _AudioArtworkState extends State<AudioArtwork> {
  Uint8List? _bytes;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(AudioArtwork oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asset?.id != widget.asset?.id) {
      _bytes = null;
      _load();
    }
  }

  Future<void> _load() async {
    final asset = widget.asset;
    if (asset == null) return;
    setState(() => _loading = true);
    final bytes = await AudioArtworkCache.instance.load(asset);
    if (!mounted) return;
    setState(() {
      _bytes = bytes;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.large ? null : 48.0;

    if (_bytes != null) {
      return Image.memory(
        _bytes!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    return _placeholder(loading: _loading && widget.asset != null);
  }

  Widget _placeholder({bool loading = false}) {
    final zen = context.zen;
    return Container(
      width: widget.large ? double.infinity : 48,
      height: widget.large ? double.infinity : 48,
      color: zen.surfaceElevated,
      alignment: Alignment.center,
      child: loading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              Icons.music_note,
              size: widget.large ? 56 : 28,
              color: zen.textSecondary,
            ),
    );
  }
}
