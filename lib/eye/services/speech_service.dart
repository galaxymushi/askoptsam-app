import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../l10n/strings.dart';
import 'app_settings.dart';
import 'gemini_voice.dart';

class SpeechService {
  SpeechService._();

  static final SpeechService instance = SpeechService._();

  final FlutterTts _tts = FlutterTts();
  final ValueNotifier<bool> isSpeaking = ValueNotifier<bool>(false);
  StreamSubscription<void>? _geminiCompletion;
  bool _ready = false;
  int _speechRunId = 0;

  /// True ONLY when the Eye tab is currently open and visible to the user.
  /// Prevents Eye from speaking or playing audio while the user is on other
  /// tabs (Chat, Library, Settings) or while the app is in the background.
  bool isEyeTabActive = false;

  Future<void> init() async {
    try {
      await _tts.awaitSpeakCompletion(true);
      await setLanguage(AppSettings.instance.language);
      await _tts.setSpeechRate(AppSettings.instance.speechRate);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _tts.setStartHandler(() => isSpeaking.value = true);
      _tts.setCompletionHandler(() => isSpeaking.value = false);
      _tts.setCancelHandler(() => isSpeaking.value = false);
      _tts.setErrorHandler((_) => isSpeaking.value = false);
      _ready = true;
    } catch (error) {
      debugPrint('Text to speech could not start: $error');
    }
  }

  /// Picks a Swahili voice when the phone has one, otherwise keeps English.
  Future<void> setLanguage(AppLanguage language) async {
    final candidates = language == AppLanguage.sw
        ? const ['sw-TZ', 'sw-KE', 'sw', 'en-US']
        : const ['en-US'];
    var chosen = candidates.last;
    try {
      for (final code in candidates) {
        final available = await _tts.isLanguageAvailable(code);
        if (available == true || available == 1) {
          chosen = code;
          break;
        }
      }
      await _tts.setLanguage(chosen);
    } catch (error) {
      debugPrint('Could not set speech language: $error');
    }
  }

  Future<void> setRate(double rate) async {
    if (!_ready) return;
    try {
      await _tts.setSpeechRate(rate);
    } catch (error) {
      debugPrint('Could not change speech rate: $error');
    }
  }

  /// Speaks [text]. Automatic speech is skipped when the user turned it off
  /// unless [force] is true (used by explicit Repeat buttons).
  ///
  /// Speech is strictly blocked unless [isEyeTabActive] is true.
  /// Uses the assistant voice when a key is set, falling back to the phone's
  /// engine on any failure. [urgent] speech (navigation cues) always uses the
  /// phone engine so it is instant and works offline.
  Future<void> speak(
    String text, {
    bool force = false,
    bool urgent = false,
  }) async {
    final cleaned = text
        .replaceAll(RegExp(r'\*\*|__|`+|#+\s*'), '')
        .trim();
    if (cleaned.isEmpty) return;
    if (!force && !AppSettings.instance.autoSpeak) return;
    if (!force && !isEyeTabActive) {
      debugPrint('SpeechService: speak blocked because Eye tab is not active.');
      return;
    }

    await stop();
    final runId = ++_speechRunId;
    isSpeaking.value = true;

    final settings = AppSettings.instance;
    if (settings.isConfigured) {
      final started = await GeminiVoice.instance.speak(cleaned);
      if (runId != _speechRunId || (!force && !isEyeTabActive)) {
        return;
      }
      if (started) {
        _geminiCompletion =
            GeminiVoice.instance.onComplete.listen((_) {
          if (runId == _speechRunId) {
            isSpeaking.value = false;
          }
        });
        return;
      }
      // Keep pure Gemini AI voice without falling back to robotic device TTS.
      debugPrint('SpeechService: Gemini voice did not start; suppressing robotic device TTS fallback.');
      if (runId == _speechRunId) {
        isSpeaking.value = false;
      }
      return;
    }

    if (runId != _speechRunId || (!force && !isEyeTabActive)) return;
    await _speakWithDevice(cleaned, runId, force: force);
  }

  Future<void> _speakWithDevice(
    String text,
    int runId, {
    bool force = false,
  }) async {
    if (!_ready) {
      await init();
    }
    if (!_ready || runId != _speechRunId || (!force && !isEyeTabActive)) {
      if (runId == _speechRunId) isSpeaking.value = false;
      return;
    }
    try {
      await _tts.stop();
      if (runId != _speechRunId || (!force && !isEyeTabActive)) return;
      isSpeaking.value = true;
      await _tts.speak(text);
      if (runId == _speechRunId) {
        isSpeaking.value = false;
      }
    } catch (error) {
      debugPrint('Text to speech failed: $error');
      if (runId == _speechRunId) isSpeaking.value = false;
    }
  }

  Future<void> stop() async {
    _speechRunId++;
    try {
      await _tts.stop();
    } catch (error) {
      debugPrint('Text to speech could not stop: $error');
    }
    _geminiCompletion?.cancel();
    _geminiCompletion = null;
    await GeminiVoice.instance.stop();
    isSpeaking.value = false;
  }
}
