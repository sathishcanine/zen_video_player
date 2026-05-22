import 'package:flutter/material.dart';
import 'package:zen_video_player/l10n/app_localizations.dart';
import 'package:zen_video_player/l10n/picker_locale_labels.dart';

import '../services/locale_service.dart';
import '../theme/zen_theme.dart';

/// First-time coach mark pointing at the language button.
class LanguageTutorialOverlay {
  LanguageTutorialOverlay._();

  static OverlayEntry? _entry;

  static Future<void> showIfNeeded({
    required BuildContext context,
    required GlobalKey targetKey,
  }) async {
    if (await LocaleService.wasLanguageTutorialSeen()) return;
    if (!context.mounted) return;

    final targetContext = targetKey.currentContext;
    if (targetContext == null) return;

    final box = targetContext.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final l10n = AppLocalizations.of(context)!;
    final offset = box.localToGlobal(Offset.zero);
    final size = box.size;
    final screen = MediaQuery.sizeOf(context);
    final cardHeight = 220.0;
    final showAbove =
        offset.dy + size.height + 12 + cardHeight > screen.height - 24;

    _entry?.remove();
    _entry = OverlayEntry(
      builder: (ctx) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: dismiss,
              child: Container(color: Colors.black.withValues(alpha: 0.72)),
            ),
          ),
          Positioned(
            left: offset.dx - 4,
            top: offset.dy - 4,
            width: size.width + 8,
            height: size.height + 8,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: ZenTheme.accentBlue, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: ZenTheme.accentBlue.withValues(alpha: 0.45),
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (!showAbove) ...[
            Positioned(
              left: offset.dx + size.width / 2 - 10,
              top: offset.dy + size.height + 2,
              child: CustomPaint(
                size: const Size(20, 12),
                painter: _ArrowPainter(pointDown: true),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              top: offset.dy + size.height + 14,
              child: _TutorialCard(
                title: l10n.languageTutorialTitle,
                body: l10n.languageTutorialBody,
                languages: _tutorialLanguageSamples(l10n),
                onGotIt: dismiss,
              ),
            ),
          ] else ...[
            Positioned(
              left: offset.dx + size.width / 2 - 10,
              bottom: screen.height - offset.dy + 2,
              child: CustomPaint(
                size: const Size(20, 12),
                painter: _ArrowPainter(pointDown: false),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: screen.height - offset.dy + 14,
              child: _TutorialCard(
                title: l10n.languageTutorialTitle,
                body: l10n.languageTutorialBody,
                languages: _tutorialLanguageSamples(l10n),
                onGotIt: dismiss,
              ),
            ),
          ],
        ],
      ),
    );

    Overlay.of(context, rootOverlay: true).insert(_entry!);
  }

  static void dismiss() {
    _entry?.remove();
    _entry = null;
    LocaleService.markLanguageTutorialSeen();
  }
}

List<String> _tutorialLanguageSamples(AppLocalizations l10n) {
  const sampleCodes = ['en', 'es', 'ar', 'zh', 'hi', 'fr'];
  return [
    for (final code in sampleCodes)
      pickerLabelForLocale(Locale(code), l10n),
  ];
}

class _TutorialCard extends StatelessWidget {
  const _TutorialCard({
    required this.title,
    required this.body,
    required this.languages,
    required this.onGotIt,
  });

  final String title;
  final String body;
  final List<String> languages;
  final VoidCallback onGotIt;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ZenTheme.gradientMid,
      borderRadius: BorderRadius.circular(16),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: ZenTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              body,
              style: const TextStyle(
                fontSize: 14,
                height: 1.45,
                color: ZenTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: languages
                  .map(
                    (name) => Chip(
                      label: Text(name),
                      backgroundColor: ZenTheme.surface,
                      labelStyle: const TextStyle(
                        color: ZenTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: onGotIt,
                style: FilledButton.styleFrom(
                  backgroundColor: ZenTheme.accent,
                ),
                child: Text(AppLocalizations.of(context)!.gotIt),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  _ArrowPainter({required this.pointDown});

  final bool pointDown;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (pointDown) {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height)
        ..close();
    } else {
      path
        ..moveTo(size.width / 2, 0)
        ..lineTo(0, size.height)
        ..lineTo(size.width, size.height)
        ..close();
    }
    canvas.drawPath(path, Paint()..color = ZenTheme.gradientMid);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
