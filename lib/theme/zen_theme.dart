import 'package:flutter/material.dart';

import 'zen_palette.dart';

/// Palette from the original Zen home / preview gradient screens.
abstract final class ZenTheme {
  static const Color gradientTop = Color(0xFF0F0C29);
  static const Color gradientMid = Color(0xFF302B63);
  static const Color gradientBottom = Color(0xFF24243E);

  static const Color background = gradientBottom;
  /// Legacy card tint: `Colors.white.withOpacity(.08)`.
  static final Color surface = Colors.white.withValues(alpha: 0.08);
  static final Color surfaceElevated = Colors.white.withValues(alpha: 0.12);
  static const Color accent = Color(0xFF673AB7); // default deep purple
  static const Color accentBlue = Color(0xFF7E57C2);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF); // white70
  static const Color badgeNew = Color(0xFFE53935);

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [gradientTop, gradientMid, gradientBottom],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Alias kept for onboarding — same gradient as the rest of the app.
  static const LinearGradient onboardingGradient = backgroundGradient;

  static ThemeData dark({Color primary = accent}) => _build(
        brightness: Brightness.dark,
        primary: primary,
        scaffoldBackground: gradientBottom,
        surface: gradientBottom,
        navBackground: gradientBottom,
      );

  static ThemeData light({Color primary = accent}) => _build(
        brightness: Brightness.light,
        primary: primary,
        scaffoldBackground: Colors.white,
        surface: Colors.white,
        navBackground: Colors.white,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color primary,
    required Color scaffoldBackground,
    required Color surface,
    required Color navBackground,
  }) {
    final isDark = brightness == Brightness.dark;
    final onSurface = isDark ? textPrimary : const Color(0xFF1A1A1A);
    final onSecondary = isDark ? textSecondary : const Color(0xFF757575);

    final colorScheme = isDark
        ? ColorScheme.dark(
            surface: surface,
            primary: primary,
            onPrimary: textPrimary,
            onSurface: onSurface,
          )
        : ColorScheme.light(
            surface: surface,
            primary: primary,
            onPrimary: Colors.white,
            onSurface: onSurface,
          );

    final palette = ZenPalette.forBrightness(
      brightness: brightness,
      primary: primary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffoldBackground,
      colorScheme: colorScheme,
      extensions: [palette],
      iconTheme: IconThemeData(color: onSurface),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: onSurface),
        bodyMedium: TextStyle(color: onSurface),
        bodySmall: TextStyle(color: onSecondary, fontSize: 13),
        titleMedium: TextStyle(
          color: onSurface,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      dialogTheme: DialogThemeData(backgroundColor: palette.sheetBackground),
      popupMenuTheme: PopupMenuThemeData(
        color: palette.sheetBackground,
        textStyle: TextStyle(color: onSurface),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: onSurface,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: navBackground,
        selectedItemColor: primary,
        unselectedItemColor: onSecondary,
        type: BottomNavigationBarType.fixed,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: isDark ? textPrimary : Colors.white,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary.withValues(alpha: 0.45);
          }
          return null;
        }),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: onSurface,
        textColor: onSurface,
      ),
      dividerColor: isDark
          ? Colors.white.withValues(alpha: 0.12)
          : Colors.black.withValues(alpha: 0.08),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Full-screen background using [ZenTheme.backgroundGradient].
class ZenGradientBackground extends StatelessWidget {
  const ZenGradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: isDark ? ZenTheme.backgroundGradient : null,
        color: isDark ? null : Theme.of(context).scaffoldBackgroundColor,
      ),
      child: child,
    );
  }
}
