import 'dart:math' as math;

import 'package:flutter/material.dart' show Color;

class ColorReading {
  const ColorReading({
    required this.name,
    required this.hex,
    required this.r,
    required this.g,
    required this.b,
  });

  final String name;
  final String hex;
  final int r;
  final int g;
  final int b;

  Color get color => Color.fromARGB(255, r, g, b);

  bool get isDark => ColorTools.luminance(r, g, b) < 0.18;

  double get contrastWithWhite => ColorTools.contrastRatio(
        ColorTools.luminance(r, g, b),
        1.0,
      );

  double get contrastWithBlack => ColorTools.contrastRatio(
        ColorTools.luminance(r, g, b),
        0.0,
      );

  bool get prefersWhiteText => contrastWithWhite >= contrastWithBlack;

  double get bestContrast =>
      prefersWhiteText ? contrastWithWhite : contrastWithBlack;

  String get contrastGuidance {
    final foreground = prefersWhiteText ? 'white' : 'black';
    final ratio = bestContrast.toStringAsFixed(1);
    if (bestContrast >= 7) {
      return 'Strong contrast with $foreground text, $ratio to 1.';
    }
    if (bestContrast >= 4.5) {
      return 'Good contrast with $foreground text, $ratio to 1.';
    }
    return 'Low contrast. Only $ratio to 1 against $foreground text.';
  }

  String get spokenHex => hex.replaceFirst('#', '').split('').join(' ');

  String get spokenSummary {
    final tone = isDark ? 'dark' : 'light';
    return '$name. A $tone color. $contrastGuidance Hex $spokenHex.';
  }
}

class ColorTools {
  ColorTools._();

  static double luminance(int r, int g, int b) {
    final rl = _channel(r);
    final gl = _channel(g);
    final bl = _channel(b);
    return 0.2126 * rl + 0.7152 * gl + 0.0722 * bl;
  }

  static double contrastRatio(double luminanceA, double luminanceB) {
    final lighter = math.max(luminanceA, luminanceB);
    final darker = math.min(luminanceA, luminanceB);
    return (lighter + 0.05) / (darker + 0.05);
  }

  static double _channel(int value) {
    final c = value.clamp(0, 255) / 255.0;
    return c <= 0.04045
        ? c / 12.92
        : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  }
}
