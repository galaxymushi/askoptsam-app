import 'dart:async';

import 'package:flutter/services.dart';

enum NavCue { left, right, uTurn, straight, arrive, offRoute, success, error }

class Haptics {
  Haptics._();

  static Future<void> _pulse(
    int count, [
    Duration gap = const Duration(milliseconds: 140),
  ]) async {
    for (var i = 0; i < count; i++) {
      await HapticFeedback.mediumImpact();
      if (i < count - 1) {
        await Future<void>.delayed(gap);
      }
    }
  }

  static Future<void> cue(NavCue cue) async {
    try {
      switch (cue) {
        case NavCue.left:
          await _pulse(2);
          break;
        case NavCue.right:
          await _pulse(3);
          break;
        case NavCue.uTurn:
          await _pulse(4);
          break;
        case NavCue.straight:
          await HapticFeedback.selectionClick();
          break;
        case NavCue.arrive:
          await HapticFeedback.heavyImpact();
          await Future<void>.delayed(const Duration(milliseconds: 220));
          await HapticFeedback.heavyImpact();
          break;
        case NavCue.offRoute:
          await _pulse(2, const Duration(milliseconds: 320));
          break;
        case NavCue.success:
          await HapticFeedback.mediumImpact();
          break;
        case NavCue.error:
          await HapticFeedback.heavyImpact();
          break;
      }
    } catch (_) {
      // Haptics are optional on devices without a vibration motor.
    }
  }
}
