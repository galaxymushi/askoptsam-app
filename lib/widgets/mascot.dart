import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'gaze.dart';

/// AskOptSam's living, interactive companion mascot:
/// An ultra-clean, vector-drawn friendly robot assistant featuring:
/// - Smooth blue headset with dual rounded earcups
/// - Pure white spherical head with sleek gloss
/// - ONE SINGLE BIG, expressive, high-tech glowing robotic eye in the center
/// - Natural, lively periodic blinking (with occasional cute double-blinks)
/// - Interactive tap reaction (hops, happy squint/wink, waves arms, and triggers [onTap])
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
    duration: const Duration(milliseconds: 550),
  );
  late final AnimationController _blinkController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );

  Offset _smoothed = Offset.zero;
  int _tapCount = 0;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    if (!widget.frozen) {
      _clock.repeat();
      _scheduleNextBlink();
    }
  }

  void _scheduleNextBlink() {
    if (!mounted || widget.frozen) return;
    // Natural interval: between 2.2 and 4.0 seconds
    final delayMs = 2200 + _random.nextInt(1800);
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (!mounted) return;
      _blinkController.forward(from: 0).then((_) {
        // 25% chance of a cute double-blink!
        if (_random.nextDouble() < 0.25) {
          Future.delayed(const Duration(milliseconds: 90), () {
            if (mounted) _blinkController.forward(from: 0);
          });
        }
        _scheduleNextBlink();
      });
    });
  }

  @override
  void dispose() {
    _clock.dispose();
    _hop.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _tapCount++;
    _hop.forward(from: 0);
    _blinkController.forward(from: 0);
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
            blinkProgress: 0,
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
        animation: Listenable.merge([_clock, _hop, _blinkController]),
        builder: (context, _) {
          final s = _clock.value * 12.0;

          final bob = math.sin(s * 1.9) * 4.5 + math.sin(s * 0.8) * 1.8;
          final sway = math.sin(s * 1.05) * 4.2;
          final tilt = math.sin(s * 1.05 + 0.4) * 0.025;
          final armWave = math.sin(s * 2.8) * 0.22 + (_hop.isAnimating ? 0.45 : 0.0);
          final breathe = 1.0 + math.sin(s * 2.0) * 0.015;
          final hop = -math.sin(math.pi * _hop.value) * 22.0;
          final wink = _tapCount.isOdd && _hop.isAnimating;

          // Blink progress: 0.0 (open) -> 1.0 (closed) -> 0.0 (reopened)
          final blinkVal = math.sin(_blinkController.value * math.pi);

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
              blinkProgress: blinkVal,
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
}

class _CleanMascotPainter extends CustomPainter {
  const _CleanMascotPainter({
    required this.bob,
    required this.sway,
    required this.tilt,
    required this.armWave,
    required this.breathe,
    required this.blinkProgress,
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
  final double blinkProgress;
  final Offset gaze;
  final double hop;
  final bool wink;
  final bool thinking;

  static const _blue = Color(0xFF0057FF);
  static const _cyan = Color(0xFF00E5FF);
  static const _navy = Color(0xFF08102F);
  static const _deepEye = Color(0xFF0A2E8A);

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
    final cyanPaint = Paint()..color = const Color(0xFF2CA9F2);

    // 1. Animated Arms
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

    // 2. Clean Body
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

    // 3. Headset Halo (Smooth, precision arc)
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

    // 4. White Spherical Head with soft shadow
    const headCenter = Offset(140, 150);
    const headRadius = 110.0;

    canvas.drawCircle(
      headCenter.translate(0, 4),
      headRadius,
      Paint()..color = const Color(0x15000000),
    );
    canvas.drawCircle(
      headCenter,
      headRadius,
      Paint()..color = Colors.white,
    );

    // Soft Cute Rosy Cheeks
    final cheekPaint = Paint()..color = const Color(0x28FF6B8B);
    canvas.drawCircle(const Offset(80, 175), 14, cheekPaint);
    canvas.drawCircle(const Offset(200, 175), 14, cheekPaint);

    // 5. ONE SINGLE BIG EYE (Centered, Expressive, Gaze-tracking & Natural Blinking)
    const eyeCenter = Offset(140, 142);
    final gazeShift = Offset(gaze.dx * 12, gaze.dy * 9);

    if (wink) {
      // Happy smiling squint arc when tapped
      final winkPaint = Paint()
        ..color = _blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7.5
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCenter(center: eyeCenter, width: 56, height: 32),
        0.2,
        2.74,
        false,
        winkPaint,
      );
    } else {
      final blinkScale = (1.0 - blinkProgress).clamp(0.04, 1.0);

      if (blinkScale < 0.16) {
        // Completely closed blink line
        canvas.drawLine(
          Offset(eyeCenter.dx - 28, eyeCenter.dy),
          Offset(eyeCenter.dx + 28, eyeCenter.dy),
          Paint()
            ..color = _blue
            ..strokeWidth = 6.5
            ..strokeCap = StrokeCap.round,
        );
      } else {
        canvas.save();
        // Scale vertically for natural blink animation
        canvas.translate(eyeCenter.dx, eyeCenter.dy);
        canvas.scale(1.0, blinkScale);
        canvas.translate(-eyeCenter.dx, -eyeCenter.dy);

        // Big Outer Eye Socket with sleek blue border
        final eyeOuterRect = Rect.fromCenter(
          center: eyeCenter,
          width: 72,
          height: 68,
        );
        final eyeRRect = RRect.fromRectAndRadius(
          eyeOuterRect,
          const Radius.circular(34),
        );

        // Gradient Iris Fill (Cyan to Deep Sapphire Blue)
        final eyeGradient = Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_cyan, _deepEye],
          ).createShader(eyeOuterRect);
        canvas.drawRRect(eyeRRect, eyeGradient);

        // Sleek outer accent rim
        final rimPaint = Paint()
          ..color = _blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5;
        canvas.drawRRect(eyeRRect, rimPaint);

        // Big Inner Pupil with smooth gaze tracking
        final pupilCenter = eyeCenter + gazeShift;
        canvas.drawCircle(
          pupilCenter,
          18,
          Paint()..color = _navy,
        );

        // Specular Light Glints (Gives the single big eye vivid life and charm!)
        canvas.drawCircle(
          pupilCenter + const Offset(7, -7),
          7.0,
          Paint()..color = Colors.white,
        );
        canvas.drawCircle(
          pupilCenter + const Offset(-7, 6),
          4.0,
          Paint()..color = const Color(0xDDFFFFFF),
        );

        canvas.restore();
      }
    }

    // 6. Cute Smile Curve
    final smilePaint = Paint()
      ..color = _navy
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(140, 196), width: 38, height: 18),
      0.15,
      2.84,
      false,
      smilePaint,
    );

    // 7. Thinking Halo Ring
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
