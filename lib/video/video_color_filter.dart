import 'package:flutter/material.dart';

/// Built-in color presets for video playback.
enum VideoColorPreset {
  standard,
  vivid,
  game,
  movie,
  cozy,
  dynamic,
  blackAndWhite,
  custom,
}

/// Contrast / brightness / saturation / temperature applied via [ColorFilter.matrix].
class VideoColorFilterSettings {
  const VideoColorFilterSettings({
    this.preset = VideoColorPreset.standard,
    this.contrast = 1.0,
    this.brightness = 0.0,
    this.saturation = 0.0,
    this.temperature = 0.0,
  });

  final VideoColorPreset preset;
  final double contrast;
  final double brightness;
  final double saturation;
  final double temperature;

  static const VideoColorFilterSettings standard =
      VideoColorFilterSettings();

  VideoColorFilterSettings copyWith({
    VideoColorPreset? preset,
    double? contrast,
    double? brightness,
    double? saturation,
    double? temperature,
  }) {
    return VideoColorFilterSettings(
      preset: preset ?? this.preset,
      contrast: contrast ?? this.contrast,
      brightness: brightness ?? this.brightness,
      saturation: saturation ?? this.saturation,
      temperature: temperature ?? this.temperature,
    );
  }

  /// Resolves sliders for the active preset (custom uses stored values).
  VideoColorFilterSettings resolved() {
    switch (preset) {
      case VideoColorPreset.standard:
        return const VideoColorFilterSettings();
      case VideoColorPreset.vivid:
        return const VideoColorFilterSettings(
          preset: VideoColorPreset.vivid,
          contrast: 1.15,
          saturation: 0.35,
        );
      case VideoColorPreset.game:
        return const VideoColorFilterSettings(
          preset: VideoColorPreset.game,
          contrast: 1.25,
          saturation: 0.2,
          brightness: 0.06,
        );
      case VideoColorPreset.movie:
        return const VideoColorFilterSettings(
          preset: VideoColorPreset.movie,
          contrast: 1.1,
          saturation: -0.12,
          temperature: 0.12,
        );
      case VideoColorPreset.cozy:
        return const VideoColorFilterSettings(
          preset: VideoColorPreset.cozy,
          temperature: 0.38,
          saturation: 0.08,
          brightness: -0.08,
        );
      case VideoColorPreset.dynamic:
        return const VideoColorFilterSettings(
          preset: VideoColorPreset.dynamic,
          temperature: -0.38,
          saturation: 0.12,
          contrast: 1.08,
        );
      case VideoColorPreset.blackAndWhite:
        return const VideoColorFilterSettings(
          preset: VideoColorPreset.blackAndWhite,
          saturation: -1.0,
          contrast: 1.08,
        );
      case VideoColorPreset.custom:
        return this;
    }
  }

  bool get isIdentity {
    final r = resolved();
    return r.preset == VideoColorPreset.standard ||
        (r.contrast == 1.0 &&
            r.brightness == 0.0 &&
            r.saturation == 0.0 &&
            r.temperature == 0.0);
  }

  /// Filters applied in order around the [VideoPlayer] widget.
  List<ColorFilter> buildColorFilters() {
    final r = resolved();
    if (isIdentity) return const [];

    final filters = <ColorFilter>[];
    final contrast = r.contrast.clamp(0.5, 2.0);
    if ((contrast - 1.0).abs() > 0.01) {
      filters.add(ColorFilter.matrix(_contrastMatrix(contrast)));
    }
    final sat = 1.0 + r.saturation.clamp(-1.0, 1.0);
    if ((sat - 1.0).abs() > 0.01) {
      filters.add(ColorFilter.matrix(_saturationMatrix(sat)));
    }
    final temp = r.temperature.clamp(-1.0, 1.0);
    if (temp.abs() > 0.01) {
      filters.add(ColorFilter.matrix(_temperatureMatrix(temp)));
    }
    final bright = r.brightness.clamp(-1.0, 1.0);
    if (bright.abs() > 0.01) {
      filters.add(ColorFilter.matrix(_brightnessMatrix(bright)));
    }
    return filters;
  }

  /// Short label on grid tiles.
  static String presetLabel(VideoColorPreset p) {
    switch (p) {
      case VideoColorPreset.standard:
        return 'Standard';
      case VideoColorPreset.vivid:
        return 'Vivid';
      case VideoColorPreset.game:
        return 'Game';
      case VideoColorPreset.movie:
        return 'Movie';
      case VideoColorPreset.cozy:
        return 'Cozy';
      case VideoColorPreset.dynamic:
        return 'Dynamic';
      case VideoColorPreset.blackAndWhite:
        return 'Black & White';
      case VideoColorPreset.custom:
        return 'Custom';
    }
  }

  /// Toast text when a preset is applied (e.g. "Vivid Mode").
  String get modeBannerLabel {
    if (preset == VideoColorPreset.custom) {
      return 'Custom Mode';
    }
    return '${presetLabel(preset)} Mode';
  }

  /// Thumbnail asset for the color preset grid.
  static String? presetAsset(VideoColorPreset p) {
    switch (p) {
      case VideoColorPreset.standard:
        return 'assets/images/color_filters/standard.png';
      case VideoColorPreset.vivid:
        return 'assets/images/color_filters/vivid.png';
      case VideoColorPreset.game:
        return 'assets/images/color_filters/game.png';
      case VideoColorPreset.movie:
        return 'assets/images/color_filters/movie.png';
      case VideoColorPreset.cozy:
        return 'assets/images/color_filters/cozy.png';
      case VideoColorPreset.dynamic:
        return 'assets/images/color_filters/dynamic.png';
      case VideoColorPreset.blackAndWhite:
        return 'assets/images/color_filters/black_and_white.png';
      case VideoColorPreset.custom:
        return 'assets/images/color_filters/custom.png';
    }
  }

  static List<double> _brightnessMatrix(double b) {
    final offset = b * 40;
    return <double>[
      1, 0, 0, 0, offset,
      0, 1, 0, 0, offset,
      0, 0, 1, 0, offset,
      0, 0, 0, 1, 0,
    ];
  }

  static List<double> _contrastMatrix(double c) {
    final t = (1 - c) * 128;
    return <double>[
      c, 0, 0, 0, t,
      0, c, 0, 0, t,
      0, 0, c, 0, t,
      0, 0, 0, 1, 0,
    ];
  }

  static List<double> _saturationMatrix(double s) {
    const lumR = 0.2126;
    const lumG = 0.7152;
    const lumB = 0.0722;
    final sr = (1 - s) * lumR;
    final sg = (1 - s) * lumG;
    final sb = (1 - s) * lumB;
    return <double>[
      sr + s, sg, sb, 0, 0,
      sr, sg + s, sb, 0, 0,
      sr, sg, sb + s, 0, 0,
      0, 0, 0, 1, 0,
    ];
  }

  static List<double> _temperatureMatrix(double t) {
    final warm = t.clamp(-1.0, 1.0);
    final rBoost = 1 + warm * 0.22;
    final bCut = 1 - warm * 0.18;
    return <double>[
      rBoost, 0, 0, 0, warm * 12,
      0, 1, 0, 0, 0,
      0, 0, bCut, 0, -warm * 12,
      0, 0, 0, 1, 0,
    ];
  }
}
