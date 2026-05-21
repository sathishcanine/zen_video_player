import 'package:flutter/material.dart';

/// Palette from the original Zen home / preview gradient screens.
abstract final class ZenTheme {
  static const Color gradientTop = Color(0xFF0F0C29);
  static const Color gradientMid = Color(0xFF302B63);
  static const Color gradientBottom = Color(0xFF24243E);

  static const Color background = gradientBottom;
  /// Legacy card tint: `Colors.white.withOpacity(.08)`.
  static final Color surface = Colors.white.withValues(alpha: 0.08);
  static final Color surfaceElevated = Colors.white.withValues(alpha: 0.12);
  static const Color accent = Color(0xFF673AB7); // Colors.deepPurple
  static const Color accentBlue = Color(0xFF7E57C2); // light purple from mid tone
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

  static ThemeData dark() {
    const colorScheme = ColorScheme.dark(
      surface: gradientBottom,
      primary: accent,
      onPrimary: textPrimary,
      onSurface: textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: gradientBottom,
      colorScheme: colorScheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: textPrimary,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: gradientBottom,
        selectedItemColor: textPrimary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: textPrimary,
        ),
      ),
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
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: ZenTheme.backgroundGradient),
      child: child,
    );
  }
}
