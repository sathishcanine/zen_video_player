import 'package:flutter/material.dart';

import '../theme/zen_theme.dart';

/// Picture-modes grid asset for onboarding page 1.
class OnboardingPictureModes extends StatelessWidget {
  const OnboardingPictureModes({super.key});

  static const _asset = 'assets/images/onboarding_picture_modes.jpg';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width - 40;
    final dpr = MediaQuery.devicePixelRatioOf(context);

    return SizedBox(
      height: 248,
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: ZenTheme.accent.withValues(alpha: 0.35),
                blurRadius: 28,
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              _asset,
              width: width,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
              cacheWidth: (width * dpr).round(),
              errorBuilder: (_, __, ___) => const Icon(
                Icons.broken_image_outlined,
                color: ZenTheme.textSecondary,
                size: 48,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
