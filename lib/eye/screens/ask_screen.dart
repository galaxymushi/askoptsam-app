import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../l10n/strings.dart';
import '../services/app_settings.dart';
import '../services/gemini_service.dart';
import '../services/haptics.dart';
import '../services/speech_service.dart';
import '../theme.dart';
import '../widgets/accessible_scaffold.dart';
import '../widgets/camera_shell.dart';
import '../widgets/eye_camera.dart';
import '../widgets/eye_ui.dart';

class AskScreen extends StatefulWidget {
  const AskScreen({super.key});

  @override
  State<AskScreen> createState() => _AskScreenState();
}

class _AskScreenState extends State<AskScreen> {
  final SpeechToText _speech = SpeechToText();
  final TextEditingController _questionController = TextEditingController();
  CameraController? _camera;
  bool _speechReady = false;
  bool _listening = false;
  bool _busy = false;
  String? _question;
  String? _answer;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  void dispose() {
    _questionController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    try {
      _speechReady = await _speech.initialize(
        onStatus: (status) {
          if (!mounted) return;
          if (status == 'done' || status == 'notListening') {
            setState(() => _listening = false);
          }
        },
        onError: (error) {
          if (!mounted) return;
          setState(() => _listening = false);
        },
      );
    } catch (_) {
      _speechReady = false;
    }
  }

  Future<void> _toggleListening() async {
    final s = S.of(context);
    if (_listening) {
      await _speech.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }
    if (!_speechReady) {
      await _initSpeech();
    }
    if (!_speechReady) {
      final message = s.askMicDenied;
      setState(() => _error = message);
      await SpeechService.instance.speak(message, force: true);
      return;
    }
    setState(() {
      _listening = true;
      _error = null;
    });
    await _speech.listen(
      listenOptions: SpeechListenOptions(
        localeId: s.sw ? 'sw-TZ' : 'en-US',
        partialResults: true,
        cancelOnError: true,
      ),
      onResult: (result) {
        if (!mounted) return;
        _questionController.text = result.recognizedWords;
        if (result.finalResult) {
          setState(() => _listening = false);
          final text = result.recognizedWords.trim();
          if (text.isEmpty) {
            setState(() => _error = s.askNoSpeech);
            SpeechService.instance.speak(s.askNoSpeech, force: true);
          } else {
            _ask();
          }
        }
      },
    );
  }

  Future<void> _ask() async {
    if (_busy) return;
    final controller = _camera;
    final s = S.of(context);
    final question = _questionController.text.trim();
    if (question.isEmpty) {
      setState(() => _error = s.askEmptyQuestion);
      await SpeechService.instance.speak(s.askEmptyQuestion, force: true);
      return;
    }
    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isTakingPicture) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
      _question = question;
      _answer = null;
    });
    try {
      final picture = await controller.takePicture();
      final bytes = await picture.readAsBytes();
      final result = await GeminiService.askAboutImage(bytes, question);
      if (!mounted) return;
      if (result.isOk) {
        setState(() => _answer = result.text);
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

  void _reset() {
    setState(() {
      _question = null;
      _answer = null;
      _error = null;
      _questionController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return AccessibleScaffold(
      title: s.askTitle,
      child: CameraShell(
        builder: (context, controller) {
          _camera = controller;
          final question = _question;
          final answer = _answer;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            children: [
              EyeCameraBox(
                controller: controller,
                hint: _listening
                    ? s.askListening
                    : (_busy ? s.asking : s.askCameraHint),
                height: 320,
              ),
              const SizedBox(height: 14),
              if (question != null) ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: 3,
                      ),
                    ),
                    child: Text(
                      question,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 23,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
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
              else if (answer != null)
                Semantics(
                  liveRegion: !AppSettings.instance.autoSpeak,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      answer,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 24,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                )
              else
                ResultCard(
                  label: s.askResultLabel,
                  child: Text(
                    s.askReadyHint,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              const SizedBox(height: 14),
              TextField(
                controller: _questionController,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _ask(),
                style: theme.textTheme.bodyLarge?.copyWith(fontSize: 22),
                decoration: InputDecoration(
                  labelText: s.askSpeakQuestion,
                  hintText: s.askPlaceholder,
                  suffixIcon: IconButton(
                    tooltip: s.askAction,
                    onPressed: _busy ? null : _ask,
                    icon: const Icon(Icons.send),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _busy ? null : _toggleListening,
                icon: Icon(_listening ? Icons.stop : Icons.mic, size: 34),
                label: Text(_listening ? s.askListening : s.askSpeakAction),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(84),
                ),
              ),
              if (answer != null) ...[
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: () =>
                      SpeechService.instance.speak(answer, force: true),
                  icon: const Icon(Icons.volume_up, size: 30),
                  label: Text(s.listenAgain),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(68),
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: EyeColors.white,
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.question_answer, size: 28),
                  label: Text(s.askAnother),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(64),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
