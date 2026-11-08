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

class ReadScreen extends StatefulWidget {
  const ReadScreen({super.key});

  @override
  State<ReadScreen> createState() => _ReadScreenState();
}

class _ReadScreenState extends State<ReadScreen> {
  CameraController? _camera;
  bool _busy = false;
  bool _torch = false;
  String? _text;
  String? _error;

  Future<void> _read() async {
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
      final result = await GeminiService.readText(bytes);
      if (!mounted) return;
      if (result.isOk) {
        final raw = result.text!;
        final none = raw.toLowerCase().contains('no text found');
        final text = none ? s.noTextFound : raw;
        setState(() => _text = text);
        await SpeechService.instance.speak(text);
        await Haptics.cue(none ? NavCue.error : NavCue.success);
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

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return AccessibleScaffold(
      title: s.readTitle,
      child: CameraShell(
        builder: (context, controller) {
          _camera = controller;
          final text = _text;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            children: [
              EyeCameraBox(
                controller: controller,
                hint: _busy ? s.reading : s.readCameraHint,
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
                  label: s.readResultLabel,
                  live: !AppSettings.instance.autoSpeak,
                  child: text == null
                      ? Text(
                          s.readReadyHint,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        )
                      : SelectableText(
                          text,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 24,
                          ),
                        ),
                ),
              const SizedBox(height: 16),
              if (text != null) ...[
                FilledButton.icon(
                  onPressed: () =>
                      SpeechService.instance.speak(text, force: true),
                  icon: const Icon(Icons.volume_up, size: 30),
                  label: Text(s.listenAgain),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(72),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _read,
                  icon: const Icon(Icons.camera_alt, size: 28),
                  label: Text(s.readAnother),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(68),
                  ),
                ),
              ] else
                FilledButton.icon(
                  onPressed: _busy ? null : _read,
                  icon: _busy
                      ? const SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        )
                      : const Icon(Icons.subject, size: 30),
                  label: Text(_busy ? s.reading : s.readAction),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(76),
                  ),
                ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
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
            ],
          );
        },
      ),
    );
  }
}
