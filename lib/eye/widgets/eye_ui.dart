import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../theme.dart';

/// White pill with a chevron, used as the back control in the blue header.
class RudiPill extends StatelessWidget {
  const RudiPill({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final surface = theme.extension<EyeSurface>() ??
        const EyeSurface(onBlue: EyeColors.white, mutedOnBlue: EyeColors.ice);
    final background = surface.onBlue;
    final foreground = theme.appBarTheme.backgroundColor ?? theme.colorScheme.primary;
    return Semantics(
      button: true,
      label: s.back,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.of(context).maybePop(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chevron_left, size: 28, color: foreground),
                const SizedBox(width: 2),
                Flexible(
                  child: Text(
                    s.back,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTheme.sans,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: foreground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Rounded rectangle with a dashed border, mirroring the mockup camera frame.
class DashedFrame extends StatelessWidget {
  const DashedFrame({
    super.key,
    required this.child,
    this.radius = 24,
    this.color,
    this.stroke = 4,
  });

  final Widget child;
  final double radius;
  final Color? color;
  final double stroke;

  @override
  Widget build(BuildContext context) {
    final paintColor = color ?? Theme.of(context).colorScheme.primary;
    return CustomPaint(
      foregroundPainter: _DashedBorderPainter(
        color: paintColor,
        radius: radius,
        stroke: stroke,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.stroke,
  });

  final Color color;
  final double radius;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            stroke / 2,
            stroke / 2,
            size.width - stroke,
            size.height - stroke,
          ),
          Radius.circular(radius),
        ),
      );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;

    const dash = 12.0;
    const gap = 9.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(distance + dash, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.radius != radius ||
      oldDelegate.stroke != stroke;
}

/// Hint shown over the camera preview.
class CameraHint extends StatelessWidget {
  const CameraHint(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: false,
      child: Container(
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: EyeColors.blue.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: AppTheme.sans,
            color: EyeColors.white,
            fontSize: 21,
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
        ),
      ),
    );
  }
}

/// White card with the thick blue border used for results.
class ResultCard extends StatelessWidget {
  const ResultCard({super.key, this.label, required this.child, this.live = false});

  final String? label;
  final Widget child;
  final bool live;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      liveRegion: live,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.primary, width: 3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label != null) ...[
              Text(
                label!,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

/// Small outlined pill with guidance or status text.
class BottomNote extends StatelessWidget {
  const BottomNote(this.text, {super.key, this.icon});

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.colorScheme.primary, width: 2.5),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 24, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section heading inside settings and secondary screens.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.number});

  final String text;
  final String? number;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (number != null) ...[
            Text(
              number!,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary.withValues(alpha: 0.55),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Big blue card for the home actions.
class EyeActionCard extends StatelessWidget {
  const EyeActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.hint,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String hint;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onCard = theme.colorScheme.onPrimary;
    return Semantics(
      button: true,
      label: title,
      hint: hint,
      child: Material(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Row(
              children: [
                Icon(icon, size: 46, color: onCard),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: onCard,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hint,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: onCard.withValues(alpha: 0.85),
                          fontSize: 18,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
