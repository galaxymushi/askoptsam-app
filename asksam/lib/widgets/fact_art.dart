import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../content/eye_facts.dart';

/// Illustrations for the eye facts. They are painted at runtime, so the app
/// ships no photos and stays tiny while every fact still gets its own picture.
class FactArtwork extends StatelessWidget {
  const FactArtwork({
    super.key,
    required this.kind,
    this.height = 150,
    this.radius = 22,
    this.borderRadius,
  });

  final FactArt kind;
  final double height;
  final double radius;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(radius),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(painter: _ArtPainter(kind: kind, dark: dark)),
      ),
    );
  }
}

class _ArtPainter extends CustomPainter {
  _ArtPainter({required this.kind, required this.dark});

  final FactArt kind;
  final bool dark;

  static const _lightA = Color(0xFF0A5FF2);
  static const _lightB = Color(0xFF26B8F2);
  static const _darkA = Color(0xFF142C63);
  static const _darkB = Color(0xFF0B4382);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark ? const [_darkA, _darkB] : const [_lightA, _lightB],
        ).createShader(rect),
    );

    final bokeh = Paint()..color = Colors.white.withValues(alpha: 0.08);
    canvas.drawCircle(Offset(size.width * 0.86, size.height * 0.18),
        size.height * 0.42, bokeh);
    canvas.drawCircle(Offset(size.width * 0.12, size.height * 0.92),
        size.height * 0.3, bokeh);

    final unit = math.min(size.width, size.height) / 150;
    final center = Offset(size.width * 0.5, size.height * 0.54);
    final ink = Colors.white.withValues(alpha: 0.96);
    final soft = Colors.white.withValues(alpha: 0.5);

    switch (kind) {
      case FactArt.eye:
        _eye(canvas, center, 46 * unit, ink, soft);
      case FactArt.screen:
        _screen(canvas, center, unit, ink, soft);
      case FactArt.sun:
        _sun(canvas, center, unit, ink, soft);
      case FactArt.food:
        _food(canvas, center, unit, ink);
      case FactArt.drop:
        _drop(canvas, center, unit, ink, soft);
      case FactArt.clock:
        _clock(canvas, center, unit, ink, soft);
      case FactArt.moon:
        _moon(canvas, center, unit, ink, soft);
      case FactArt.smoke:
        _smoke(canvas, center, unit, ink, soft);
    }
  }

  void _eye(
    Canvas canvas,
    Offset c,
    double rx,
    Color ink,
    Color soft,
  ) {
    final ry = rx * 0.58;
    final white = Paint()..color = Colors.white;
    final outline = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = rx * 0.075;
    final path = Path()
      ..moveTo(c.dx - rx, c.dy)
      ..quadraticBezierTo(c.dx, c.dy - ry * 1.5, c.dx + rx, c.dy)
      ..quadraticBezierTo(c.dx, c.dy + ry * 1.5, c.dx - rx, c.dy)
      ..close();
    canvas.drawPath(path, white);
    canvas.drawPath(path, outline);

    final iris = Paint()..color = _lightA;
    canvas.drawCircle(c, rx * 0.42, iris);
    canvas.drawCircle(
      c,
      rx * 0.42,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = rx * 0.05,
    );
    canvas.drawCircle(c, rx * 0.18, Paint()..color = const Color(0xFF071B3E));
    canvas.drawCircle(
      c.translate(rx * 0.13, -rx * 0.14),
      rx * 0.06,
      Paint()..color = Colors.white,
    );

    final lash = Paint()
      ..color = soft
      ..strokeWidth = rx * 0.05
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final x = c.dx + rx * (0.35 + i * 0.22);
      canvas.drawLine(
        Offset(x, c.dy - ry * 0.72),
        Offset(x + rx * 0.08, c.dy - ry * 1.02),
        lash,
      );
    }
  }

  void _screen(Canvas canvas, Offset c, double unit, Color ink, Color soft) {
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: c, width: 66 * unit, height: 92 * unit),
      Radius.circular(12 * unit),
    );
    canvas.drawRRect(body, Paint()..color = Colors.white.withValues(alpha: 0.14));
    canvas.drawRRect(
      body,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * unit,
    );
    _eye(canvas, c.translate(0, -6 * unit), 20 * unit, ink, soft);
    canvas.drawLine(
      Offset(c.dx, c.dy + 36 * unit),
      Offset(c.dx, c.dy + 34 * unit),
      Paint()..color = soft,
    );
    final ring = Paint()
      ..color = soft
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * unit;
    canvas.drawArc(
      Rect.fromCenter(
          center: c.translate(0, 18 * unit), width: 26 * unit, height: 26 * unit),
      -math.pi / 2,
      math.pi * 1.6,
      false,
      ring,
    );
    canvas.drawCircle(
      c.translate(0, 18 * unit),
      2.5 * unit,
      Paint()..color = ink,
    );
  }

  void _sun(Canvas canvas, Offset c, double unit, Color ink, Color soft) {
    final ray = Paint()
      ..color = soft
      ..strokeWidth = 3 * unit
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      canvas.drawLine(
        c + Offset(math.cos(a), math.sin(a)) * 34 * unit,
        c + Offset(math.cos(a), math.sin(a)) * 46 * unit,
        ray,
      );
    }
    canvas.drawCircle(
        c, 27 * unit, Paint()..color = Colors.white.withValues(alpha: 0.9));

    final lens = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: c.translate(-13 * unit, 6 * unit),
          width: 22 * unit,
          height: 15 * unit),
      Radius.circular(7 * unit),
    );
    final lens2 = lens.shift(Offset(26 * unit, 0));
    final glass = Paint()..color = const Color(0xFF08234F);
    canvas.drawRRect(lens, glass);
    canvas.drawRRect(lens2, glass);
    canvas.drawLine(
      c.translate(-2 * unit, 6 * unit),
      c.translate(2 * unit, 6 * unit),
      Paint()
        ..color = const Color(0xFF08234F)
        ..strokeWidth = 3 * unit,
    );
  }

  void _food(Canvas canvas, Offset c, double unit, Color ink) {
    canvas.drawCircle(
        c, 46 * unit, Paint()..color = Colors.white.withValues(alpha: 0.16));
    canvas.drawCircle(
      c,
      46 * unit,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 * unit,
    );

    final leaf = Paint()..color = const Color(0xFF8BE36B);
    final leaf2 = Paint()..color = const Color(0xFF4FC169);
    canvas.save();
    canvas.translate(c.dx - 10 * unit, c.dy - 4 * unit);
    canvas.rotate(-0.5);
    canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 40 * unit, height: 20 * unit),
        leaf);
    canvas.restore();
    canvas.save();
    canvas.translate(c.dx + 8 * unit, c.dy + 2 * unit);
    canvas.rotate(0.4);
    canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 36 * unit, height: 18 * unit),
        leaf2);
    canvas.restore();

    final carrot = Path()
      ..moveTo(c.dx + 12 * unit, c.dy - 20 * unit)
      ..lineTo(c.dx + 30 * unit, c.dy - 6 * unit)
      ..lineTo(c.dx + 8 * unit, c.dy - 4 * unit)
      ..close();
    canvas.drawPath(carrot, Paint()..color = const Color(0xFFFFA33C));
    canvas.drawCircle(
      c.translate(-26 * unit, -20 * unit),
      3 * unit,
      Paint()..color = Colors.white.withValues(alpha: 0.7),
    );
  }

  void _drop(Canvas canvas, Offset c, double unit, Color ink, Color soft) {
    final path = Path()
      ..moveTo(c.dx, c.dy - 44 * unit)
      ..cubicTo(
        c.dx + 26 * unit,
        c.dy - 10 * unit,
        c.dx + 26 * unit,
        c.dy + 22 * unit,
        c.dx,
        c.dy + 30 * unit,
      )
      ..cubicTo(
        c.dx - 26 * unit,
        c.dy + 22 * unit,
        c.dx - 26 * unit,
        c.dy - 10 * unit,
        c.dx,
        c.dy - 44 * unit,
      )
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.white.withValues(alpha: 0.92));
    canvas.drawCircle(
      c.translate(-8 * unit, 4 * unit),
      5 * unit,
      Paint()..color = _lightB.withValues(alpha: 0.55),
    );
    final ring = Paint()
      ..color = soft
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * unit;
    canvas.drawCircle(c.translate(0, 8 * unit), 46 * unit, ring);
  }

  void _clock(Canvas canvas, Offset c, double unit, Color ink, Color soft) {
    canvas.drawCircle(
        c, 42 * unit, Paint()..color = Colors.white.withValues(alpha: 0.94));
    canvas.drawCircle(
      c,
      42 * unit,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * unit,
    );
    final tick = Paint()
      ..color = _lightA
      ..strokeWidth = 2.5 * unit
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 12; i++) {
      final a = i * math.pi / 6;
      canvas.drawLine(
        c + Offset(math.cos(a), math.sin(a)) * 32 * unit,
        c + Offset(math.cos(a), math.sin(a)) * 36 * unit,
        tick,
      );
    }
    canvas.drawLine(
      c,
      c.translate(0, -22 * unit),
      Paint()
        ..color = const Color(0xFF08234F)
        ..strokeWidth = 3.5 * unit
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      c,
      c.translate(16 * unit, 8 * unit),
      Paint()
        ..color = const Color(0xFF08234F)
        ..strokeWidth = 3.5 * unit
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(c, 3.5 * unit, Paint()..color = _lightA);
    canvas.drawCircle(c.translate(0, 52 * unit), 2 * unit, Paint()..color = soft);
  }

  void _moon(Canvas canvas, Offset c, double unit, Color ink, Color soft) {
    final moon = Path()
      ..addOval(Rect.fromCircle(center: c, radius: 38 * unit))
      ..addOval(Rect.fromCircle(
          center: c.translate(20 * unit, -12 * unit), radius: 32 * unit))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(moon, Paint()..color = Colors.white.withValues(alpha: 0.94));

    final star = Paint()..color = soft;
    for (final p in [
      c.translate(-34 * unit, -26 * unit),
      c.translate(-22 * unit, 26 * unit),
      c.translate(30 * unit, -30 * unit),
    ]) {
      canvas.drawCircle(p, 3 * unit, star);
    }
    canvas.drawCircle(
      c.translate(34 * unit, 24 * unit),
      4.5 * unit,
      Paint()..color = Colors.white.withValues(alpha: 0.7),
    );
  }

  void _smoke(Canvas canvas, Offset c, double unit, Color ink, Color soft) {
    _eye(canvas, c.translate(0, 22 * unit), 34 * unit, ink, soft);
    final wisp = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * unit
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final x = c.dx - 24 * unit + i * 24 * unit;
      final path = Path()
        ..moveTo(x, c.dy + 2 * unit)
        ..cubicTo(
          x - 10 * unit,
          c.dy - 14 * unit,
          x + 10 * unit,
          c.dy - 26 * unit,
          x,
          c.dy - 44 * unit,
        );
      canvas.drawPath(path, wisp);
    }
  }

  @override
  bool shouldRepaint(_ArtPainter oldDelegate) =>
      oldDelegate.kind != kind || oldDelegate.dark != dark;
}
