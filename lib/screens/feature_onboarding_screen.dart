import 'package:flutter/material.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';

import '../services/feature_onboarding_service.dart';
import '../theme/zen_theme.dart';
import '../widgets/onboarding_picture_modes.dart';

class FeatureOnboardingScreen extends StatefulWidget {
  const FeatureOnboardingScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<FeatureOnboardingScreen> createState() => _FeatureOnboardingScreenState();
}

class _FeatureOnboardingScreenState extends State<FeatureOnboardingScreen> {
  static const _pageCount = 4;

  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await FeatureOnboardingService.markCompleted();
    widget.onComplete();
  }

  void _next() {
    if (_page >= _pageCount - 1) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = _buildPages(l10n);
    final isLast = _page == _pageCount - 1;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _BokehBackground(),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _finish,
                    child: Text(
                      l10n.skip,
                      style: const TextStyle(
                        color: ZenTheme.textPrimary,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _pageCount,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (_, i) => pages[i],
                  ),
                ),
                _PageDots(count: _pageCount, index: _page),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
                  child: _OnboardingCtaButton(
                    label: isLast ? l10n.getStarted : l10n.next,
                    onPressed: _next,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPages(AppLocalizations l10n) {
    return [
      _OnboardingPage(
        illustration: const OnboardingPictureModes(),
        title: l10n.onboardingTitle1,
        labelBelowTitle: l10n.onboardingPictureModes,
        subtitle: l10n.onboardingSubtitle1,
      ),
      _OnboardingPage(
        illustration: const _AudioPlayIllustration(),
        title: l10n.onboardingTitle2,
        subtitle: l10n.onboardingSubtitle2,
      ),
      _OnboardingPage(
        illustration: const _VisualizerIllustration(),
        title: l10n.onboardingTitle3,
        subtitle: l10n.onboardingSubtitle3,
      ),
      _OnboardingPage(
        illustration: const _SecureFeaturesIllustration(),
        title: l10n.onboardingTitle4,
        subtitle: l10n.onboardingSubtitle4,
      ),
    ];
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.illustration,
    required this.title,
    required this.subtitle,
    this.labelBelowTitle,
  });

  final Widget illustration;
  final String title;
  final String subtitle;
  final String? labelBelowTitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 240, child: illustration),
          const SizedBox(height: 28),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: ZenTheme.textPrimary,
              height: 1.25,
            ),
          ),
          if (labelBelowTitle != null) ...[
            const SizedBox(height: 8),
            Text(
              labelBelowTitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: ZenTheme.textPrimary,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: ZenTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 10 : 8,
          height: active ? 10 : 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active
                ? ZenTheme.accentBlue
                : Colors.white.withValues(alpha: 0.2),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: ZenTheme.accentBlue.withValues(alpha: 0.6),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}

class _OnboardingCtaButton extends StatelessWidget {
  const _OnboardingCtaButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(
            colors: [
              ZenTheme.accentBlue.withValues(alpha: 0.5),
              ZenTheme.accent.withValues(alpha: 0.35),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(1.2),
          child: Material(
            color: Colors.black.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(25),
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(25),
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ZenTheme.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Soft purple bokeh behind content.
class _BokehBackground extends StatelessWidget {
  const _BokehBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A0A2E), Color(0xFF000000)],
            ),
          ),
        ),
        Positioned(
          top: 80,
          left: MediaQuery.sizeOf(context).width * 0.15,
          child: _orb(140, ZenTheme.gradientMid),
        ),
        Positioned(
          top: 160,
          right: 40,
          child: _orb(100, ZenTheme.accentBlue),
        ),
        Positioned(
          top: 280,
          left: 60,
          child: _orb(70, ZenTheme.accent),
        ),
      ],
    );
  }

  Widget _orb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.45),
            blurRadius: size * 0.55,
            spreadRadius: size * 0.08,
          ),
        ],
      ),
    );
  }
}

// --- Illustrations (icon-based; swap for assets later) ---

class _GlowRing extends StatelessWidget {
  const _GlowRing({required this.child, this.size = 180});

  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: ZenTheme.accentBlue.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: ZenTheme.accent.withValues(alpha: 0.35),
            blurRadius: 28,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Center(child: child),
    );
  }
}

class _AudioPlayIllustration extends StatelessWidget {
  const _AudioPlayIllustration();

  @override
  Widget build(BuildContext context) {
    return _GlowRing(
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              ZenTheme.accentBlue,
              ZenTheme.gradientMid,
              Colors.black,
            ],
          ),
        ),
        child: const Icon(
          Icons.play_arrow_rounded,
          color: Colors.white,
          size: 48,
        ),
      ),
    );
  }
}

class _VisualizerIllustration extends StatelessWidget {
  const _VisualizerIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: CustomPaint(
        painter: _RingVisualizerPainter(),
        child: const Center(
          child: Icon(
            Icons.graphic_eq,
            color: ZenTheme.accentBlue,
            size: 36,
          ),
        ),
      ),
    );
  }
}

class _RingVisualizerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (var i = 0; i < 5; i++) {
      final radius = 35.0 + i * 16;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Color.lerp(
          ZenTheme.accentBlue,
          ZenTheme.accent,
          i / 4,
        )!
            .withValues(alpha: 0.35 + i * 0.08);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SecureFeaturesIllustration extends StatelessWidget {
  const _SecureFeaturesIllustration();

  @override
  Widget build(BuildContext context) {
    return _GlowRing(
      child: const Icon(
        Icons.shield_outlined,
        color: ZenTheme.accentBlue,
        size: 72,
      ),
    );
  }
}
