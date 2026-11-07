import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'gaze.dart';

/// AskOptSam's living, interactive mascot:
/// An ultra-clean, vector-drawn friendly robot assistant featuring:
/// - Smooth blue headset with dual rounded earcups
/// - Pure white spherical head with sleek gloss
/// - Expressive center eye/visor that tracks gaze, blinks smoothly, and pulses when thinking
/// - Interactive tap reaction (hops, winks, waves arms, and triggers [onTap])
/// - Zero jagged/dusty lines, fully anti-aliased with precision vector paths.
class Mascot extends StatelessWidget {
  const Mascot({
    super.key,
    this.height = 150,
    this.thinking = false,
    this.onTap,
  });

  final double height;
  final bool thinking;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final frozen = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return RepaintBoundary(
      child: SizedBox(
        width: height * 0.76,
        height: height,
        child: _MascotView(
          thinking: thinking,
          frozen: frozen,
          onTap: onTap,
        ),
      ),
    );
  }
}

class _MascotView extends StatefulWidget {
  const _MascotView({
    required this.thinking,
    required this.frozen,
    this.onTap,
  });

  final bool thinking;
  final bool frozen;
  final VoidCallback? onTap;

  @override
  State<_MascotView> createState() => _MascotViewState();
}

class _MascotViewState extends State<_MascotView>
    with TickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  );
  late final AnimationController _hop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );

  Offset _smoothed = Offset.zero;
  int _tapCount = 0;

  @override
  void initState() {
    super.initState();
    if (!widget.frozen) _clock.repeat();
  }

  @override
  void dispose() {
    _clock.dispose();
    _hop.dispose();
    super.dispose();
  }

  void _handleTap() {
    _tapCount++;
    _hop.forward(from: 0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.frozen) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: const CustomPaint(
          painter: _CleanMascotPainter(
            bob: 0,
            sway: 0,
            tilt: 0,
            armWave: 0,
            breathe: 1,
            blink: 0,
            gaze: Offset.zero,
            hop: 0,
            wink: false,
            thinking: false,
          ),
        ),
      );
    }

    final gaze = GazeScope.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_clock, _hop]),
        builder: (context, _) {
          final s = _clock.value * 12.0;

          final bob = math.sin(s * 1.9) * 4.5 + math.sin(s * 0.8) * 1.8;
          final sway = math.sin(s * 1.05) * 4.2;
          final tilt = math.sin(s * 1.05 + 0.4) * 0.025;
          final armWave = math.sin(s * 2.8) * 0.22 + (_hop.isAnimating ? 0.4 : 0.0);
          final breathe = 1.0 + math.sin(s * 2.0) * 0.015;
          final hop = -math.sin(math.pi * _hop.value) * 22.0;
          final wink = _tapCount.isOdd && _hop.isAnimating;

          final pointer = gaze?.value ?? Offset.zero;
          Offset target;
          if (widget.thinking) {
            target = Offset(
              math.cos(s * 3.0) * 0.85,
              math.sin(s * 3.0) * 0.55,
            );
          } else if (pointer != Offset.zero) {
            target = pointer;
          } else {
            target = Offset(
              math.sin(s * 0.95) * 0.55 + math.sin(s * 2.3) * 0.18,
              math.cos(s * 0.8) * 0.34 + math.sin(s * 1.7) * 0.12,
            );
          }
          if (target.distance > 1) target = target / target.distance;
          _smoothed = Offset.lerp(_smoothed, target, 0.16)!;

          return CustomPaint(
            painter: _CleanMascotPainter(
              bob: bob,
              sway: sway,
              tilt: tilt,
              armWave: armWave,
              breathe: breathe,
              blink: _blinkAt(s),
              gaze: _smoothed,
              hop: hop,
              wink: wink,
              thinking: widget.thinking,
            ),
          );
        },
      ),
    );
  }

  static double _blinkAt(double seconds) {
    final cycle = (seconds + 0.8) % 4.6;
    const length = 0.20;
    if (cycle >= length) return 0;
    return math.sin((cycle / length) * math.pi);
  }
}

class _CleanMascotPainter extends CustomPainter {
  const _CleanMascotPainter({
    required this.bob,
    required this.sway,
    required this.tilt,
    required this.armWave,
    required this.breathe,
    required this.blink,
    required this.gaze,
    required this.hop,
    required this.wink,
    required this.thinking,
  });

  final double bob;
  final double sway;
  final double tilt;
  final double armWave;
  final double breathe;
  final double blink;
  final Offset gaze;
  final double hop;
  final bool wink;
  final bool thinking;

  static const _blue = Color(0xFF0057FF);
  static const _cyan = Color(0xFF2CA9F2);
  static const _navy = Color(0xFF08102F);

  @override
  void paint(Canvas canvas, Size size) {
    const designW = 280.0;
    const designH = 370.0;
    final scale = math.min(size.width / designW, size.height / designH);

    canvas.save();
    canvas.translate(
      (size.width - designW * scale) / 2,
      (size.height - designH * scale) / 2,
    );
    canvas.scale(scale);

    // Apply floating and hop dynamics
    canvas.translate(140, 340);
    canvas.rotate(tilt);
    canvas.translate(sway, bob + hop);
    canvas.translate(-140, -340);

    final bluePaint = Paint()..color = _blue;
    final cyanPaint = Paint()..color = _cyan;

    // 1. Draw smooth animated arms
    void drawArm(double cx, double cy, double angle) {
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(angle);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: 34, height: 72),
          const Radius.circular(17),
        ),
        cyanPaint,
      );
      canvas.restore();
    }

    drawArm(42, 290, 0.36 + armWave);
    drawArm(238, 290, -0.36 - armWave);

    // 2. Draw clean body
    canvas.save();
    canvas.translate(140, 295);
    canvas.scale(1.0, breathe);
    canvas.translate(-140, -295);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(140, 295), width: 150, height: 86),
        const Radius.circular(38),
      ),
      bluePaint,
    );
    canvas.restore();

    // 3. Draw sleek headset halo (Smooth, no floating dusty hair arc!)
    final headsetPaint = Paint()
      ..color = _blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(140, 150), radius: 122),
      3.45,
      2.50,
      false,
      headsetPaint,
    );

    // Headset Earcup Left
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(20, 155), width: 18, height: 42),
        const Radius.circular(9),
      ),
      bluePaint,
    );
    // Headset Earcup Right
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(260, 155), width: 18, height: 42),
        const Radius.circular(9),
      ),
      bluePaint,
    );

    // 4. White Spherical Head with pristine anti-aliasing
    const headCenter = Offset(140, 150);
    const headRadius = 110.0;
    
    // Soft shadow behind head
    canvas.drawCircle(
      headCenter.translate(0, 4),
      headRadius,
      Paint()..color = const Color(0x15000000),
    );
    // Pure White Head
    canvas.drawCircle(
      headCenter,
      headRadius,
      Paint()..color = Colors.white,
    );

    // 5. Smiling Center Eye / High-Tech Visor (Authentic & Powerfully Expressive)
    final eyeCenter = headCenter + Offset(gaze.dx * 16, gaze.dy * 12);

    if (wink) {
      // Winking curved arc when tapped
      final winkPaint = Paint()
        ..color = _blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCenter(center: eyeCenter, width: 68, height: 38),
        0.2,
        2.74,
        false,
        winkPaint,
      );
    } else {
      // Clean smooth eye visor
      canvas.save();
      final effectiveBlink = blink.clamp(0.0, 1.0);
      final eyeHeight = math.max(6.0, 48.0 * (1.0 - effectiveBlink));
      
      final eyeRect = Rect.fromCenter(
        center: eyeCenter,
        width: 82,
        height: eyeHeight,
      );

      // Smiling curved eye path
      final eyePath = Path();
      if (effectiveBlink > 0.8) {
        // Closed / Blinking line
        canvas.drawLine(
          Offset(eyeCenter.dx - 36, eyeCenter.dy),
          Offset(eyeCenter.dx + 36, eyeCenter.dy),
          Paint()
            ..color = _blue
            ..strokeWidth = 6
            ..strokeCap = StrokeCap.round,
        );
      } else {
        eyePath.moveTo(eyeRect.left, eyeCenter.dy);
        eyePath.quadraticBezierTo(
          eyeCenter.dx,
          eyeCenter.dy + eyeHeight * 0.9,
          eyeRect.right,
          eyeCenter.dy,
        );
        eyePath.quadraticBezierTo(
          eyeCenter.dx,
          eyeCenter.dy - eyeHeight * 0.25,
          eyeRect.left,
          eyeCenter.dy,
        );
        eyePath.close();

        // Eye Fill
        canvas.drawPath(eyePath, Paint()..color = _blue);

        // Pupil Specular Glow (Glint)
        canvas.drawCircle(
          eyeCenter + const Offset(10, -6),
          6.5,
          Paint()..color = Colors.white,
        );
        canvas.drawCircle(
          eyeCenter + const Offset(-12, 4),
          3.5,
          Paint()..color = const Color(0xCCFFFFFF),
        );
      }
      canvas.restore();
    }

    // 6. Cute Smile Curve
    final smilePaint = Paint()
      ..color = _navy
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(140, 204), width: 44, height: 24),
      0.2,
      2.74,
      false,
      smilePaint,
    );

    // 7. Thinking indicator ring when AI is reasoning
    if (thinking) {
      final ringPaint = Paint()
        ..color = _cyan.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      canvas.drawCircle(headCenter, headRadius + 14, ringPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CleanMascotPainter oldDelegate) => true;
}
