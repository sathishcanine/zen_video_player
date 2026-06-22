import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_chrome_cast/lib.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';
import 'package:zen_video_player/services/cast_service.dart';

/// Shows a bottom sheet to pick a Cast device and optionally load [media].
Future<void> showCastDevicePicker(
  BuildContext context, {
  CastMediaPayload? media,
}) async {
  final l10n = AppLocalizations.of(context)!;
  if (!CastService.instance.isSupported) {
    _showCastSnack(context, l10n.castUnsupportedPlatform);
    return;
  }

  if (!context.mounted) return;

  // Open the sheet immediately so the tap always has visible feedback.
  // Cast SDK init runs inside the sheet (0.0.11 Android never replied to init).
  await showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF1C1C24),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => _CastDevicePickerBody(media: media),
  );
}

void _showCastSnack(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

class _CastDevicePickerBody extends StatefulWidget {
  const _CastDevicePickerBody({this.media});

  final CastMediaPayload? media;

  @override
  State<_CastDevicePickerBody> createState() => _CastDevicePickerBodyState();
}

class _CastDevicePickerBodyState extends State<_CastDevicePickerBody> {
  bool _busy = false;
  String? _busyDeviceId;
  String? _initError;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    try {
      await CastService.instance.init().timeout(const Duration(seconds: 8));
      if (!CastService.instance.canUseCast) {
        if (!mounted) return;
        setState(() {
          _initError = 'cast_unavailable';
          _ready = false;
        });
        return;
      }
      await CastService.instance.startDiscovery();
      if (!mounted) return;
      setState(() {
        _ready = true;
        _initError = null;
      });
    } catch (e, st) {
      debugPrint('Cast bootstrap failed: $e\n$st');
      if (!mounted) return;
      setState(() {
        _initError = e.toString();
        _ready = false;
      });
    }
  }

  @override
  void dispose() {
    unawaited(CastService.instance.stopDiscovery());
    super.dispose();
  }

  Future<void> _onDeviceTap(GoogleCastDevice device) async {
    if (_busy || !_ready) return;
    setState(() {
      _busy = true;
      _busyDeviceId = device.deviceID;
    });

    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    try {
      await CastService.instance.castToDevice(
        device,
        media: widget.media,
      );
      if (!mounted) return;
      Navigator.pop(context);
      final name = device.friendlyName;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            widget.media != null
                ? l10n.castPlayingOn(name)
                : l10n.castConnectedTo(name),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint('Cast session failed: $e');
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(_errorMessage(l10n, e)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _busyDeviceId = null;
        });
      }
    }
  }

  String _errorMessage(AppLocalizations l10n, Object error) {
    final msg = error.toString();
    if (msg.contains('cast_unavailable')) {
      return l10n.castUnsupportedPlatform;
    }
    if (msg.contains('content_uri_unsupported')) {
      return l10n.castUnsupportedContentUri;
    }
    if (msg.contains('local_wifi_unavailable')) {
      return l10n.castLocalWifiRequired;
    }
    return l10n.castFailed;
  }

  Future<void> _disconnect() async {
    await CastService.instance.disconnect();
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.castDisconnected),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.5;

    return SafeArea(
      top: false,
      child: SizedBox(
        height: sheetHeight,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.castSelectDevice,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (CastService.instance.isConnected)
                    TextButton(
                      onPressed: _busy ? null : () => unawaited(_disconnect()),
                      child: Text(l10n.castDisconnect),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                widget.media?.title ?? l10n.castPlayVideoToCast,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white60, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Expanded(child: _buildDeviceList(l10n)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceList(AppLocalizations l10n) {
    if (_initError != null) {
      final message = _initError == 'cast_unavailable'
          ? l10n.castUnsupportedPlatform
          : l10n.castFailed;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    if (!_ready) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.castSearching,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<List<GoogleCastDevice>>(
      stream: GoogleCastDiscoveryManager.instance.devicesStream,
      builder: (context, snapshot) {
        final devices = snapshot.data ?? [];
        if (devices.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.castSearching,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.castWifiHint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          itemCount: devices.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final device = devices[index];
            final connecting = _busy && _busyDeviceId == device.deviceID;
            return ListTile(
              leading: Icon(
                Icons.cast,
                color: connecting ? Colors.white54 : Colors.white,
              ),
              title: Text(
                device.friendlyName,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: device.modelName != null
                  ? Text(
                      device.modelName!,
                      style: const TextStyle(color: Colors.white54),
                    )
                  : null,
              trailing: connecting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
              onTap: _busy ? null : () => unawaited(_onDeviceTap(device)),
            );
          },
        );
      },
    );
  }
}
