import 'package:flutter/material.dart';
import 'package:zen_video_player/theme/zen_theme.dart';

/// Full-screen loader shown briefly before a video-exit interstitial.
class InterstitialLoadingOverlay extends StatefulWidget {
  const InterstitialLoadingOverlay({super.key});

  @override
  State<InterstitialLoadingOverlay> createState() =>
      _InterstitialLoadingOverlayState();
}

class _InterstitialLoadingOverlayState extends State<InterstitialLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(decoration: BoxDecoration(gradient: ZenTheme.backgroundGradient)),
          ModalBarrier(
            dismissible: false,
            color: Colors.black.withValues(alpha: 0.35),
          ),
          Center(
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.82, end: 1.0).animate(
                CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                  boxShadow: [
                    BoxShadow(
                      color: ZenTheme.accent.withValues(alpha: 0.25),
                      blurRadius: 32,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: CircularProgressIndicator(
                        strokeWidth: 3.5,
                        backgroundColor: Colors.white.withValues(alpha: 0.12),
                        color: ZenTheme.accentBlue,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Just a moment',
                      style: TextStyle(
                        color: ZenTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Loading…',
                      style: TextStyle(
                        color: ZenTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
