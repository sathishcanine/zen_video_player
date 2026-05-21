import 'package:flutter/material.dart';

import 'zen_theme.dart';

/// Semantic colors that follow light / dark [ThemeData].
@immutable
class ZenPalette extends ThemeExtension<ZenPalette> {
  const ZenPalette({
    required this.textPrimary,
    required this.textSecondary,
    required this.surfaceCard,
    required this.surfaceElevated,
    required this.sheetBackground,
    required this.tabIndicator,
  });

  final Color textPrimary;
  final Color textSecondary;
  final Color surfaceCard;
  final Color surfaceElevated;
  final Color sheetBackground;
  final Color tabIndicator;

  factory ZenPalette.forBrightness({
    required Brightness brightness,
    required Color primary,
  }) {
    if (brightness == Brightness.dark) {
      return ZenPalette(
        textPrimary: ZenTheme.textPrimary,
        textSecondary: ZenTheme.textSecondary,
        surfaceCard: ZenTheme.surface,
        surfaceElevated: ZenTheme.surfaceElevated,
        sheetBackground: ZenTheme.gradientMid,
        tabIndicator: ZenTheme.accentBlue,
      );
    }
    return ZenPalette(
      textPrimary: const Color(0xFF1A1A1A),
      textSecondary: const Color(0xFF616161),
      surfaceCard: const Color(0xFFE8E8ED),
      surfaceElevated: const Color(0xFFF0F0F2),
      sheetBackground: Colors.white,
      tabIndicator: primary,
    );
  }

  @override
  ZenPalette copyWith({
    Color? textPrimary,
    Color? textSecondary,
    Color? surfaceCard,
    Color? surfaceElevated,
    Color? sheetBackground,
    Color? tabIndicator,
  }) {
    return ZenPalette(
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      sheetBackground: sheetBackground ?? this.sheetBackground,
      tabIndicator: tabIndicator ?? this.tabIndicator,
    );
  }

  @override
  ZenPalette lerp(ThemeExtension<ZenPalette>? other, double t) {
    if (other is! ZenPalette) return this;
    return ZenPalette(
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      sheetBackground: Color.lerp(sheetBackground, other.sheetBackground, t)!,
      tabIndicator: Color.lerp(tabIndicator, other.tabIndicator, t)!,
    );
  }
}

extension ZenPaletteContext on BuildContext {
  ZenPalette get zen =>
      Theme.of(this).extension<ZenPalette>() ??
      ZenPalette.forBrightness(
        brightness: Theme.of(this).brightness,
        primary: Theme.of(this).colorScheme.primary,
      );
}
