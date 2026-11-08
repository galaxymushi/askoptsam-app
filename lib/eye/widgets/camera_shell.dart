import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../l10n/strings.dart';

/// Initializes the back camera, handles lifecycle, and shows permission or
/// failure messages with a retry action. Builds the screen with the live camera.
class CameraShell extends StatefulWidget {
  const CameraShell({super.key, required this.builder});

  final Widget Function(BuildContext context, CameraController controller)
      builder;

  @override
  State<CameraShell> createState() => _CameraShellState();
}

class _CameraShellState extends State<CameraShell> with WidgetsBindingObserver {
  CameraController? _controller;
  String? _errorCode;
  bool _starting = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WakelockPlus.enable();
    _start();
  }

  Future<void> _start() async {
    if (!mounted) return;
    setState(() {
      _starting = true;
      _errorCode = null;
    });
    CameraController? controller;
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _starting = false;
            _errorCode = 'none';
          });
        }
        return;
      }
      final back = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      controller = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      final previous = _controller;
      _controller = controller;
      await previous?.dispose();
      setState(() {
        _starting = false;
        _errorCode = null;
      });
    } on CameraException catch (error) {
      await controller?.dispose();
      final denied = error.code.contains('AccessDenied') ||
          error.code == 'CameraAccessRestricted';
      if (!mounted) return;
      setState(() {
        _starting = false;
        _errorCode = denied ? 'denied' : 'start:${error.code}';
      });
    } catch (_) {
      await controller?.dispose();
      if (!mounted) return;
      setState(() {
        _starting = false;
        _errorCode = 'generic';
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      final controller = _controller;
      _controller = null;
      controller?.dispose();
      if (mounted) setState(() {});
    } else if (state == AppLifecycleState.resumed &&
        _controller == null &&
        _errorCode == null) {
      _start();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  String _message(S s) {
    final code = _errorCode;
    if (code == null) return '';
    if (code == 'denied') return s.cameraDenied;
    if (code == 'none') return s.noCamera;
    if (code.startsWith('start:')) {
      return s.cameraStartFailed(code.substring('start:'.length));
    }
    return s.cameraGeneric;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    if (_starting) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 18),
            Text(s.startingCamera, style: theme.textTheme.bodyLarge),
          ],
        ),
      );
    }

    final controller = _controller;
    if (controller == null || _errorCode != null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.no_photography,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                _errorCode == null ? s.cameraNotAvailable : _message(s),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  setState(() => _errorCode = null);
                  _start();
                },
                icon: const Icon(Icons.refresh),
                label: Text(s.tryAgain),
              ),
            ],
          ),
        ),
      );
    }
    return widget.builder(context, controller);
  }
}

class CameraPreviewFill extends StatelessWidget {
  const CameraPreviewFill({super.key, required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final previewSize = controller.value.previewSize;
    if (previewSize == null) {
      return const ColoredBox(color: Colors.black);
    }
    return ClipRect(
      child: OverflowBox(
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: previewSize.height,
            height: previewSize.width,
            child: CameraPreview(controller),
          ),
        ),
      ),
    );
  }
}

class Reticle extends StatelessWidget {
  const Reticle({super.key, this.square = false});

  final bool square;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    if (square) {
      return IgnorePointer(
        child: Center(
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 4),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      );
    }
    return IgnorePointer(
      child: Center(
        child: Container(
          width: 280,
          height: 3,
          color: color.withValues(alpha: 0.85),
        ),
      ),
    );
  }
}
