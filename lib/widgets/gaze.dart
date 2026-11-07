import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Tracks the pointer anywhere in the app so mascot eyes can follow it.
class GazeScope extends StatefulWidget {
  const GazeScope({super.key, required this.child});

  final Widget child;

  /// A -1..1 direction from the screen centre, or null outside a [GazeScope].
  static ValueListenable<Offset>? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_GazeInherited>()?.notifier;

  @override
  State<GazeScope> createState() => _GazeScopeState();
}

class _GazeScopeState extends State<GazeScope> {
  final _gaze = ValueNotifier<Offset>(Offset.zero);

  void _track(Offset local, Size size) {
    if (size.isEmpty) return;
    final center = size.center(Offset.zero);
    final dx = (local.dx - center.dx) / (size.width * 0.45);
    final dy = (local.dy - center.dy) / (size.height * 0.45);
    _gaze.value = Offset(dx.clamp(-1.0, 1.0), dy.clamp(-1.0, 1.0));
  }

  @override
  void dispose() {
    _gaze.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (e) => _track(e.localPosition, size),
          onPointerMove: (e) => _track(e.localPosition, size),
          onPointerHover: (e) => _track(e.localPosition, size),
          onPointerUp: (_) => _gaze.value = Offset.zero,
          onPointerCancel: (_) => _gaze.value = Offset.zero,
          child: _GazeInherited(notifier: _gaze, child: widget.child),
        );
      },
    );
  }
}

class _GazeInherited extends InheritedNotifier<ValueNotifier<Offset>> {
  const _GazeInherited({required ValueNotifier<Offset> notifier, required super.child})
      : super(notifier: notifier);
}
