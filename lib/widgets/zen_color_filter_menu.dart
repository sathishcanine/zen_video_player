import 'package:flutter/material.dart';
import 'package:zen_video_player/video/video_color_filter.dart';

/// Compact popup: 4×2 grid in landscape, 2×4 in portrait.
class ZenColorFilterMenu extends StatefulWidget {
  const ZenColorFilterMenu({
    super.key,
    required this.initial,
    required this.onApply,
    required this.onClose,
  });

  final VideoColorFilterSettings initial;
  final void Function(VideoColorFilterSettings settings, {bool announce}) onApply;
  final VoidCallback onClose;

  static const List<VideoColorPreset> gridPresets = <VideoColorPreset>[
    VideoColorPreset.standard,
    VideoColorPreset.vivid,
    VideoColorPreset.game,
    VideoColorPreset.movie,
    VideoColorPreset.cozy,
    VideoColorPreset.dynamic,
    VideoColorPreset.blackAndWhite,
    VideoColorPreset.custom,
  ];

  @override
  State<ZenColorFilterMenu> createState() => _ZenColorFilterMenuState();
}

class _ZenColorFilterMenuState extends State<ZenColorFilterMenu> {
  static const Color _accent = Color(0xFF5EC4B7);
  static const Color _sheetBg = Color(0xFF1A1A1A);

  /// Popup and tiles scaled +50% from the compact baseline.
  static const double _scale = 1.5;
  static double get _tileHeightLandscape => 72 * _scale;
  static double get _tileHeightPortrait => 58 * _scale;
  static double get _gridSpacing => 8 * _scale;
  static double get _gridPadding => 10 * _scale;
  static double get _colWidthLandscape => 82 * _scale;
  static double get _colWidthPortrait => 96 * _scale;

  late VideoColorFilterSettings _draft;
  bool _customPage = false;

  late double _contrast;
  late double _brightness;
  late double _saturation;
  late double _temperature;

  @override
  void initState() {
    super.initState();
    _draft = widget.initial;
    _syncCustomSlidersFrom(_draft);
    _customPage = _draft.preset == VideoColorPreset.custom;
  }

  void _syncCustomSlidersFrom(VideoColorFilterSettings s) {
    final r = s.preset == VideoColorPreset.custom ? s : s.resolved();
    _contrast = r.contrast;
    _brightness = r.brightness;
    _saturation = r.saturation;
    _temperature = r.temperature;
  }

  void _applyPreset(VideoColorPreset preset) {
    if (preset == VideoColorPreset.custom) {
      setState(() {
        _customPage = true;
        _draft = VideoColorFilterSettings(
          preset: VideoColorPreset.custom,
          contrast: _contrast,
          brightness: _brightness,
          saturation: _saturation,
          temperature: _temperature,
        );
      });
      widget.onApply(_draft, announce: false);
      return;
    }
    final next = VideoColorFilterSettings(preset: preset).resolved();
    setState(() {
      _draft = next;
      _customPage = false;
      _syncCustomSlidersFrom(next);
    });
    widget.onApply(_draft, announce: true);
    widget.onClose();
  }

  void _applyCustomDraft() {
    final next = VideoColorFilterSettings(
      preset: VideoColorPreset.custom,
      contrast: _contrast,
      brightness: _brightness,
      saturation: _saturation,
      temperature: _temperature,
    );
    setState(() => _draft = next);
    widget.onApply(next, announce: false);
  }

  void _resetCustom() {
    setState(() {
      _contrast = 1.0;
      _brightness = 0.0;
      _saturation = 0.0;
      _temperature = 0.0;
    });
    _applyCustomDraft();
  }

  Widget _header({
    required bool showBack,
    required VoidCallback onBack,
    required bool compact,
  }) {
    final iconSize = (compact ? 20.0 : 22.0) * _scale;
    final fontSize = (compact ? 15.0 : 17.0) * _scale;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        showBack ? 0 : 8 * _scale,
        4 * _scale,
        0,
        compact ? 4 * _scale : 8 * _scale,
      ),
      child: Row(
        children: [
          if (showBack)
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: iconSize),
              onPressed: onBack,
              tooltip: 'Back',
              visualDensity: VisualDensity.compact,
            ),
          Icon(Icons.format_paint, color: Colors.white, size: iconSize),
          const SizedBox(width: 6),
          Text(
            'Color',
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.close, color: Colors.white, size: iconSize),
            onPressed: widget.onClose,
            tooltip: 'Close',
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _presetTile(VideoColorPreset preset) {
    final asset = VideoColorFilterSettings.presetAsset(preset);
    final selected = _draft.preset == preset && !_customPage ||
        (preset == VideoColorPreset.custom && _customPage);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _applyPreset(preset),
        borderRadius: BorderRadius.circular(8 * _scale),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8 * _scale),
            border: selected
                ? Border.all(color: _accent, width: 2)
                : Border.all(color: Colors.white12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7 * _scale),
            child: asset != null
                ? Image.asset(
                    asset,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (_, __, ___) =>
                        const ColoredBox(color: Color(0xFF2A2A2A)),
                  )
                : const ColoredBox(color: Color(0xFF2A2A2A)),
          ),
        ),
      ),
    );
  }

  Widget _presetGrid({required bool landscape}) {
    final crossAxisCount = landscape ? 4 : 2;
    final tileHeight =
        landscape ? _tileHeightLandscape : _tileHeightPortrait;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        _gridPadding,
        0,
        _gridPadding,
        _gridPadding,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: tileHeight,
        crossAxisSpacing: _gridSpacing,
        mainAxisSpacing: _gridSpacing,
      ),
      itemCount: ZenColorFilterMenu.gridPresets.length,
      itemBuilder: (_, i) => _presetTile(ZenColorFilterMenu.gridPresets[i]),
    );
  }

  Widget _customSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required String Function(double) format,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 84 * _scale,
            child: Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: 13 * _scale),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                activeTrackColor: _accent,
                inactiveTrackColor: Colors.white24,
                thumbColor: _accent,
                overlayColor: _accent.withValues(alpha: 0.2),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              ),
              child: Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                divisions: divisions,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 40 * _scale,
            child: Text(
              format(value),
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.white70, fontSize: 12 * _scale),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gridPage(bool landscape) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header(showBack: false, onBack: () {}, compact: true),
        _presetGrid(landscape: landscape),
      ],
    );
  }

  Widget _customPageView(bool landscape) {
    final screenW = MediaQuery.sizeOf(context).width - 24;
    final desired = (landscape ? 360.0 : 300.0) * _scale;
    final popupWidth = desired < screenW ? desired : screenW;
    return SizedBox(
      width: popupWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(
            showBack: true,
            onBack: () => setState(() => _customPage = false),
            compact: true,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _customSlider(
                  label: 'Contrast',
                  value: _contrast,
                  min: 0.5,
                  max: 2.0,
                  divisions: 30,
                  format: (v) => v.toStringAsFixed(2),
                  onChanged: (v) {
                    setState(() => _contrast = v);
                    _applyCustomDraft();
                  },
                ),
                _customSlider(
                  label: 'Brightness',
                  value: _brightness,
                  min: -1.0,
                  max: 1.0,
                  divisions: 40,
                  format: (v) => v.toStringAsFixed(2),
                  onChanged: (v) {
                    setState(() => _brightness = v);
                    _applyCustomDraft();
                  },
                ),
                _customSlider(
                  label: 'Saturation',
                  value: _saturation,
                  min: -1.0,
                  max: 1.0,
                  divisions: 40,
                  format: (v) => v.toStringAsFixed(2),
                  onChanged: (v) {
                    setState(() => _saturation = v);
                    _applyCustomDraft();
                  },
                ),
                _customSlider(
                  label: 'Temperature',
                  value: _temperature,
                  min: -1.0,
                  max: 1.0,
                  divisions: 40,
                  format: (v) => v.toStringAsFixed(2),
                  onChanged: (v) {
                    setState(() => _temperature = v);
                    _applyCustomDraft();
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 4, bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white, size: 22),
                  tooltip: 'Reset',
                  onPressed: _resetCustom,
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.white, size: 22),
                  tooltip: 'Done',
                  onPressed: () {
                    widget.onApply(_draft, announce: true);
                    widget.onClose();
                  },
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _popupWidth(BuildContext context, bool landscape) {
    final size = MediaQuery.sizeOf(context);
    final crossAxisCount = landscape ? 4 : 2;
    final colWidth = landscape ? _colWidthLandscape : _colWidthPortrait;
    final raw = crossAxisCount * colWidth +
        _gridPadding * 2 +
        (crossAxisCount - 1) * _gridSpacing;
    final maxW = (size.width - 24) * (landscape ? 0.72 : 0.92);
    return raw < maxW ? raw : maxW;
  }

  @override
  Widget build(BuildContext context) {
    final landscape = MediaQuery.sizeOf(context).width >
        MediaQuery.sizeOf(context).height;
    final popupWidth = _popupWidth(context, landscape);

    final child = _customPage
        ? _customPageView(landscape)
        : SizedBox(
            width: popupWidth,
            child: _gridPage(landscape),
          );

    return Material(
      color: _sheetBg,
      elevation: 16,
      shadowColor: Colors.black54,
      borderRadius: BorderRadius.circular(12 * _scale),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
