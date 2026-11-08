import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'gaze.dart';

/// AskOptSam's living mascot: a big-eyed helper that floats, sways, blinks and
/// watches the pointer. Drawn in code so the eye can actually move.
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
        width: height * 0.727,
        height: height,
        child: _MascotView(thinking: thinking, frozen: frozen, onTap: onTap),
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
    duration: const Duration(milliseconds: 460),
  );

  Offset _smoothed = Offset.zero;

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

  @override
  Widget build(BuildContext context) {
    if (widget.frozen) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: CustomPaint(
          painter: const _MascotPainter(
            bob: 0,
            sway: 0,
            tilt: 0,
            armWave: 0,
            breathe: 1,
            blink: 0,
            gaze: Offset.zero,
            hop: 0,
          ),
        ),
      );
    }

    final gaze = GazeScope.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _hop.forward(from: 0);
        widget.onTap?.call();
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_clock, _hop]),
        builder: (context, _) {
          final s = _clock.value * 12.0;

          final bob = math.sin(s * 1.9) * 5.0 + math.sin(s * 0.8) * 2.0;
          final sway = math.sin(s * 1.05) * 5.0;
          final tilt = math.sin(s * 1.05 + 0.4) * 0.02;
          final armWave = math.sin(s * 2.6) * 0.16 + 0.05;
          final breathe = 1 + math.sin(s * 1.9) * 0.012;
          final hop = -math.sin(math.pi * _hop.value) * 20.0;
          final tapBlink = _hop.isAnimating && _hop.value < 0.55
              ? math.sin((_hop.value / 0.55) * math.pi)
              : 0.0;
          final blink = math.max(_blinkAt(s), tapBlink);

          final pointer = gaze?.value ?? Offset.zero;
          Offset target;
          if (widget.thinking) {
            target = Offset(
              math.cos(s * 2.6) * 0.8,
              math.sin(s * 2.6) * 0.55,
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
          _smoothed = Offset.lerp(_smoothed, target, 0.14)!;

          return CustomPaint(
            painter: _MascotPainter(
              bob: bob,
              sway: sway,
              tilt: tilt,
              armWave: armWave,
              breathe: breathe,
              blink: blink,
              gaze: _smoothed,
              hop: hop,
            ),
          );
        },
      ),
    );
  }

  static double _blinkAt(double seconds) {
    final cycle = (seconds + 1.8) % 3.4;
    const length = 0.24;
    if (cycle >= length) return 0;
    return math.sin((cycle / length) * math.pi);
  }
}

class _MascotPainter extends CustomPainter {
  const _MascotPainter({
    required this.bob,
    required this.sway,
    required this.tilt,
    required this.armWave,
    required this.breathe,
    required this.blink,
    required this.gaze,
    required this.hop,
  });

  final double bob;
  final double sway;
  final double tilt;
  final double armWave;
  final double breathe;
  final double blink;
  final Offset gaze;
  final double hop;

  static const _blue = Color(0xFF0B5FF2);
  static const _cyan = Color(0xFF2CA9F2);
  static const _navy = Color(0xFF0B1230);
  static const _lidLine = Color(0xFFB9D3FF);

  @override
  void paint(Canvas canvas, Size size) {
    const designW = 288.0;
    const designH = 396.0;
    final scale = math.min(size.width / designW, size.height / designH);

    canvas.save();
    canvas.translate(
      (size.width - designW * scale) / 2,
      (size.height - designH * scale) / 2,
    );
    canvas.scale(scale);

    canvas.translate(144, 372);
    canvas.rotate(tilt);
    canvas.translate(sway, bob + hop);
    canvas.translate(-144, -372);

    final blue = Paint()..color = _blue;
    final cyan = Paint()..color = _cyan;

    void drawArm(double cx, double angle) {
      canvas.save();
      canvas.translate(cx, 322);
      canvas.rotate(angle);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 36, height: 76),
        cyan,
      );
      canvas.restore();
    }

    drawArm(40, 0.32 + armWave);
    drawArm(248, -0.32 - armWave);

    canvas.save();
    canvas.translate(144, 328);
    canvas.scale(1.0, breathe);
    canvas.translate(-144, -328);
    canvas.drawRRect(
      RRect.fromLTRBR(64, 284, 224, 372, const Radius.circular(42)),
      blue,
    );
    canvas.restore();

    const head = Offset(144, 160);
    const headR = 126.0;
    const eyeR = 73.0;
    canvas.drawCircle(head, headR, Paint()..color = Colors.white);
    canvas.drawCircle(
      head,
      headR,
      Paint()
        ..color = _blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 13,
    );

    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: head, radius: eyeR)),
    );
    canvas.drawCircle(head, eyeR, blue);
    canvas.drawCircle(head, 55, cyan);
    final pupil =
        head + Offset(gaze.dx * 20, gaze.dy * 20) + const Offset(0, 2);
    canvas.drawCircle(pupil, 29, Paint()..color = _navy);
    canvas.drawCircle(
      pupil + const Offset(13, -14),
      11,
      Paint()..color = Colors.white,
    );

    if (blink > 0.01) {
      final lidTop = head.dy - eyeR;
      final lidY = lidTop + eyeR * 2 * blink;
      canvas.drawRect(
        Rect.fromLTRB(head.dx - eyeR - 4, lidTop - 4, head.dx + eyeR + 4, lidY),
        Paint()..color = Colors.white,
      );
      if (blink < 0.98) {
        canvas.drawLine(
          Offset(head.dx - eyeR, lidY),
          Offset(head.dx + eyeR, lidY),
          Paint()
            ..color = _lidLine
            ..strokeWidth = 4
            ..strokeCap = StrokeCap.round,
        );
      }
    }
    canvas.restore();

    if (blink > 0.01) {
      canvas.drawCircle(
        head,
        eyeR,
        Paint()
          ..color = _blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5,
      );
    }

    final smile = Paint()
      ..color = _navy
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(144, 232), radius: 54),
      0.7,
      1.74,
      false,
      smile,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MascotPainter oldDelegate) => true;
}
