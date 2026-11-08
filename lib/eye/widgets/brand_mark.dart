import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// The Eye badge, drawn from the supplied brand artwork.
class EyeBadge extends StatelessWidget {
  const EyeBadge({super.key, this.size = 44, this.onBlue = false});

  static const String asset = 'assets/branding/eye-mark.png';

  /// Corner radius of the badge tile, measured from the artwork.
  static const double cornerRatio = 0.226;

  final double size;
  final bool onBlue;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * cornerRatio);
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: onBlue
            ? [
                BoxShadow(
                  color: EyeColors.navy.withValues(alpha: 0.22),
                  blurRadius: size * 0.18,
                  offset: Offset(0, size * 0.06),
                ),
              ]
            : null,
      ),
      foregroundDecoration: onBlue
          ? null
          : BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: EyeColors.blue,
                width: math.max(1, size * 0.022),
              ),
            ),
      child: Image.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.fill,
        filterQuality: FilterQuality.medium,
        excludeFromSemantics: true,
      ),
    );
  }
}

/// Badge plus the "Eye" wordmark used in headers.
class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.compact = false,
    this.onDark = false,
    this.tagline,
  });

  final bool compact;
  final bool onDark;
  final String? tagline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nameColor = onDark ? EyeColors.white : EyeColors.blue;
    final subColor = onDark
        ? EyeColors.white.withValues(alpha: 0.82)
        : EyeColors.muted;
    final badgeSize = compact ? 46.0 : 64.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        EyeBadge(size: badgeSize, onBlue: onDark),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Eye',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTheme.sans,
                  fontSize: compact ? 38 : 44,
                  height: 1.0,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: nameColor,
                ),
              ),
              if (tagline != null) ...[
                const SizedBox(height: 4),
                Text(
                  tagline!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: subColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// "Eye · Msaidizi wa maono" label used above headline copy.
class BrandEyebrow extends StatelessWidget {
  const BrandEyebrow(this.text, {super.key, this.onBlue = false});

  final String text;
  final bool onBlue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text.toUpperCase(),
      style: theme.textTheme.labelMedium?.copyWith(
        fontSize: 14,
        letterSpacing: 1.6,
        fontWeight: FontWeight.w700,
        color: onBlue ? EyeColors.ice : EyeColors.muted,
      ),
    );
  }
}
