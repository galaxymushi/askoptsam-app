import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../services/app_settings.dart';
import '../services/gemini_service.dart';
import '../services/haptics.dart';
import '../services/speech_service.dart';
import '../widgets/accessible_scaffold.dart';
import '../widgets/camera_shell.dart';
import '../widgets/eye_camera.dart';
import '../widgets/eye_ui.dart';
import '../widgets/semantic_control.dart';

class DescribeScreen extends StatefulWidget {
  const DescribeScreen({super.key});

  @override
  State<DescribeScreen> createState() => _DescribeScreenState();
}

class _DescribeScreenState extends State<DescribeScreen> {
  CameraController? _camera;
  bool _busy = false;
  bool _auto = false;
  bool _torch = false;
  String? _description;
  String? _error;
  Timer? _autoTimer;

  @override
  void dispose() {
    _autoTimer?.cancel();
    super.dispose();
  }

  Future<void> _describe() async {
    final controller = _camera;
    if (controller == null ||
        !controller.value.isInitialized ||
        _busy ||
        controller.value.isTakingPicture) {
      return;
    }
    final s = S.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final picture = await controller.takePicture();
      final bytes = await picture.readAsBytes();
      final result = await GeminiService.describeScene(bytes);
      if (!mounted) return;
      if (result.isOk) {
        setState(() => _description = result.text);
        await SpeechService.instance.speak(result.text!);
        await Haptics.cue(NavCue.success);
      } else {
        final message = s.aiError(result.errorCode);
        setState(() => _error = message);
        await SpeechService.instance.speak(message);
        await Haptics.cue(NavCue.error);
      }
    } on CameraException {
      if (mounted) setState(() => _error = s.cameraPictureFailed);
    } catch (_) {
      if (mounted) setState(() => _error = s.cameraImageFailed);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _toggleTorch() async {
    final controller = _camera;
    if (controller == null) return;
    final s = S.of(context);
    try {
      await controller.setFlashMode(
        _torch ? FlashMode.off : FlashMode.torch,
      );
      if (mounted) setState(() => _torch = !_torch);
    } catch (_) {
      if (mounted) setState(() => _error = s.noFlash);
    }
  }

  void _setAuto(bool enabled) {
    final s = S.of(context);
    setState(() => _auto = enabled);
    _autoTimer?.cancel();
    if (enabled) {
      SpeechService.instance.speak(s.autoStarted);
      _autoTimer = Timer.periodic(
        const Duration(seconds: 6),
        (_) => _describe(),
      );
    } else {
      SpeechService.instance.speak(s.autoStopped);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return AccessibleScaffold(
      title: s.describeTitle,
      child: CameraShell(
        builder: (context, controller) {
          _camera = controller;
          final description = _description;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            children: [
              EyeCameraBox(
                controller: controller,
                hint: _busy ? s.describing : s.describeCameraHint,
                height: 360,
              ),
              const SizedBox(height: 14),
              if (_error != null)
                ResultCard(
                  label: s.problem,
                  live: true,
                  child: Text(
                    _error!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                )
              else
                ResultCard(
                  label: s.describeResultLabel,
                  live: !AppSettings.instance.autoSpeak,
                  child: description == null
                      ? Text(
                          s.describeReadyHint,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        )
                      : SelectableText(
                          description,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 23,
                          ),
                        ),
                ),
              const SizedBox(height: 16),
              if (description != null) ...[
                FilledButton.icon(
                  onPressed: () => SpeechService.instance.speak(
                    description,
                    force: true,
                  ),
                  icon: const Icon(Icons.volume_up, size: 30),
                  label: Text(s.listenAgain),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(72),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _describe,
                  icon: const Icon(Icons.camera_alt, size: 28),
                  label: Text(s.describeAgain),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(68),
                  ),
                ),
              ] else
                FilledButton.icon(
                  onPressed: _busy ? null : _describe,
                  icon: _busy
                      ? const SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        )
                      : const Icon(Icons.volume_up, size: 30),
                  label: Text(_busy ? s.describing : s.describeAction),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(76),
                  ),
                ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: SemanticControl(
                      label: s.light,
                      toggled: _torch,
                      onTap: _toggleTorch,
                      child: OutlinedButton.icon(
                        onPressed: _toggleTorch,
                        icon: Icon(_torch ? Icons.flash_on : Icons.flash_off),
                        label: Text(_torch ? s.lightOn : s.light),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SemanticControl(
                      label: s.autoOn,
                      hint: s.autoHint,
                      toggled: _auto,
                      onTap: () => _setAuto(!_auto),
                      child: OutlinedButton.icon(
                        onPressed: () => _setAuto(!_auto),
                        icon: Icon(_auto ? Icons.videocam : Icons.videocam_off),
                        label: Text(s.autoOn),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
