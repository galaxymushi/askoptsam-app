import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../eye/services/app_settings.dart';
import '../eye/services/gemini_http.dart';
import '../eye/services/gemini_voice.dart';
import '../eye/services/speech_service.dart';

enum ConciergeAction {
  openEyeNavigate,
  openEyeRead,
  promptForQuestion,
  askQuestion,
  stop,
  unknown,
}

class ConciergeDecision {
  const ConciergeDecision(this.action, {this.question, this.targetObject});

  final ConciergeAction action;
  final String? question;
  final String? targetObject;
}

enum ConciergeState {
  idle,
  speaking,
  listening,
  processing,
}

abstract class ConciergeNavigator {
  String get currentLanguage;
  Future<void> onOpenEyeNavigate({String? targetObject});
  Future<void> onOpenEyeRead();
  Future<void> onAskQuestion(String question, {String? precomputedReply});
}

class VoiceConciergeService extends ChangeNotifier {
  VoiceConciergeService._();

  static final VoiceConciergeService instance = VoiceConciergeService._();

  static const MethodChannel _channel =
      MethodChannel('com.optsam.asksam/accessibility');
  static const String _prefHandsFreeKey = 'hands_free_blind_mode';

  final SpeechToText _speech = SpeechToText();
  final ValueNotifier<ConciergeState> state =
      ValueNotifier<ConciergeState>(ConciergeState.idle);
  final ValueNotifier<String> lastHeard = ValueNotifier<String>('');
  final ValueNotifier<String> statusMessage = ValueNotifier<String>('');

  final List<Map<String, dynamic>> _voiceHistory = [];

  ConciergeNavigator? _navigator;
  bool _speechReady = false;
  bool _handsFreeEnabled = true;
  bool _passiveWakeAllowed = true;
  bool _awaitingDirectQuestion = false;
  bool _passiveListening = false;
  int _sessionToken = 0;
  int _emptyListenRetries = 0;
  Timer? _silenceCommitTimer;
  Timer? _listenWatchdogTimer;
  Timer? _passiveRestartTimer;
  bool _commandDispatched = false;

  bool _micGranted = false;
  bool _overlayGranted = false;
  bool _batteryIgnored = false;
  bool _serviceRunning = false;

  bool get handsFreeEnabled => _handsFreeEnabled;
  bool get isActive => state.value != ConciergeState.idle;
  bool get micGranted => _micGranted;
  bool get overlayGranted => _overlayGranted;
  bool get batteryIgnored => _batteryIgnored;
  bool get serviceRunning => _serviceRunning;
  bool get allWakePermissionsGranted =>
      _micGranted && _overlayGranted && _batteryIgnored;

  static String greetingFor(String lang) {
    if (lang == 'en') {
      return 'I am here! Would you like me to open the aEye camera to guide you, '
          'or what question do you have about your eyes today?';
    }
    return 'Niko hapa! Unataka nikufungulie kamera ya aEye nikuongoze, '
        'au una swali gani kuhusu macho yako leo?';
  }

  static String askPromptFor(String lang) {
    if (lang == 'en') {
      return 'I am listening. Tell me what is bothering your eyes, or ask me any question.';
    }
    return 'Nakusikiliza. Niambie macho yako yanakusumbua nini, au niulize swali lolote.';
  }

  static String gentleRepromptFor(String lang) {
    if (lang == 'en') {
      return 'I am still here listening. Do your eyes hurt, itch, or feel blurry, '
          'or say aEye to use the camera?';
    }
    return 'Bado niko hapa nakusikiliza. Je, macho yako yanauma, yanawasha, au '
        'uoni umefifia, au sema aEye kutumia kamera?';
  }

  static String followUpPromptFor(String lang) {
    if (lang == 'en') {
      return 'Do you have another question, or say aEye to open the camera?';
    }
    return 'Je, una swali lingine, au sema aEye kufungua kamera?';
  }

  static String goodbyeFor(String lang) {
    if (lang == 'en') {
      return 'Okay, take care. Shake your phone or tap the voice button anytime you need me.';
    }
    return 'Sawa, nakutakia siku njema. Tikisa simu au gusa kitufe cha sauti wakati wowote ukiniitaji.';
  }

  /// Strictly checks whether [raw] begins with or is an explicit wake call to
  /// "Eye" / "aEye" / "AskOptSam" so the assistant NEVER wakes up randomly
  /// during ordinary background conversation.
  static bool isWakePhrase(String raw) {
    final norm = _normalize(raw);
    if (norm.isEmpty) return false;

    // Reject long unrelated background chatter unless it explicitly starts with
    // the wake word.
    final words = norm.split(' ');
    if (words.length > 7) return false;

    const exactOrPrefixTriggers = [
      'eye',
      'aeye',
      'a eye',
      'ai',
      'a i',
      'aye',
      'hai',
      'hey eye',
      'hey aeye',
      'hey a eye',
      'hey ai',
      'habari eye',
      'habari aeye',
      'habari ai',
      'amka eye',
      'amka aeye',
      'amka ai',
      'fungua aeye',
      'fungua ai',
      'askoptsam',
      'ask optsam',
      'ask opt sam',
      'ask op sam',
      'ask of sam',
      'ask up sam',
      'ask obsam',
      'ask option',
      'asko sam',
      'ask sam',
      'hey askoptsam',
      'hey ask optsam',
      'hey ask sam',
      'hey sam',
      'habari askoptsam',
      'habari ask sam',
      'habari sam',
      'amka askoptsam',
      'optsam',
      'opt sam',
    ];
    for (final t in exactOrPrefixTriggers) {
      if (norm == t || norm.startsWith('$t ')) {
        return true;
      }
    }
    return false;
  }

  /// Strips the wake prefix from a spoken utterance if the user spoke both
  /// the wake phrase and a command in one breath (e.g. "aEye niongoze").
  static String stripWakePrefix(String raw) {
    var norm = raw.trim();
    final pattern = RegExp(
      r'^(?:hey\s+|habari\s+|amka\s+)?(?:ask\s*(?:optsam|opt\s*sam|op\s*sam|of\s*sam|up\s*sam|obsam|option|sam)|optsam|opt\s*sam|a\s*eye|aeye|eye|a\s*i|ai|aye|hai|sam)\b[,.\s]*',
      caseSensitive: false,
    );
    norm = norm.replaceFirst(pattern, '').trim();
    return norm;
  }

  /// Classifies a spoken command in Kiswahili or English into an autonomous
  /// navigation action.
  static ConciergeDecision classifyCommand(
    String raw, {
    bool awaitingQuestion = false,
  }) {
    final cleaned = raw.trim();
    final norm = _normalize(cleaned);
    if (norm.isEmpty) {
      return const ConciergeDecision(ConciergeAction.unknown);
    }

    // 1. Stop / Cancel / Exit phrases
    const stopWords = [
      'acha',
      'simama',
      'funga',
      'imetosha',
      'hapana',
      'hapana asante',
      'asante',
      'stop',
      'cancel',
      'close',
      'exit',
      'no thank you',
      'no thanks',
      'nothing',
    ];
    if (stopWords.contains(norm)) {
      return const ConciergeDecision(ConciergeAction.stop);
    }

    // 2. Read text with camera
    const readKeywords = [
      'soma',
      'soma maandishi',
      'nisomee',
      'maandishi',
      'read',
      'read text',
    ];
    for (final kw in readKeywords) {
      if (norm == kw || norm.startsWith('$kw ')) {
        return const ConciergeDecision(ConciergeAction.openEyeRead);
      }
    }

    // 2.5 Find specific object with camera (e.g. "tafuta mlango", "find the chair")
    final findMatch = RegExp(
      r'^(?:tafuta|nitafutie|angalia\s+wapi|find|locate|look\s+for)\s+(.+)$',
      caseSensitive: false,
    ).firstMatch(cleaned);
    if (findMatch != null) {
      final obj = findMatch.group(1)?.trim();
      if (obj != null && obj.isNotEmpty) {
        return ConciergeDecision(
          ConciergeAction.openEyeNavigate,
          targetObject: obj,
        );
      }
    }

    // 3. Navigate / Describe scene with aEye camera
    const eyeKeywords = [
      'aeye',
      'a eye',
      'eye',
      'ai',
      'a i',
      'aye',
      'ai ya macho',
      'kamera',
      'camera',
      'niongoze',
      'navigate',
      'navigation',
      'elezea',
      'elezea mazingira',
      'describe',
      'describe scene',
      'angalia',
      'njia',
      'tembea',
      'help me walk',
      'guide me',
      'mazingira',
    ];
    for (final kw in eyeKeywords) {
      if (norm == kw ||
          norm.contains('kwenda aeye') ||
          norm.contains('kwenda ai') ||
          norm.contains('fungua aeye') ||
          norm.contains('fungua ai') ||
          norm.contains('open aeye') ||
          norm.contains('open eye') ||
          norm.contains('open camera') ||
          norm.contains('fungua kamera') ||
          norm.contains('niongoze') ||
          norm.contains('navigate') ||
          norm.contains('elezea mazingira') ||
          norm.contains('describe scene')) {
        return const ConciergeDecision(ConciergeAction.openEyeNavigate);
      }
    }

    if (awaitingQuestion) {
      return ConciergeDecision(ConciergeAction.askQuestion, question: cleaned);
    }

    // 4. User says they want to ask a question / go to AskOptSam chat
    const askIntentPhrases = [
      'askoptsam',
      'ask optsam',
      'ask sam',
      'swali',
      'nina swali',
      'nataka kuuliza',
      'nataka kuuliza swali',
      'niulize',
      'uliza',
      'uliza swali',
      'mazungumzo',
      'question',
      'ask a question',
      'i have a question',
      'ask you',
      'chat',
    ];
    if (askIntentPhrases.contains(norm)) {
      return const ConciergeDecision(ConciergeAction.promptForQuestion);
    }

    // 5. Otherwise, treat the spoken sentence itself as a direct question for AskOptSam!
    return ConciergeDecision(ConciergeAction.askQuestion, question: cleaned);
  }

  static String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Future<void> init(ConciergeNavigator navigator) async {
    _navigator = navigator;
    try {
      final prefs = await SharedPreferences.getInstance();
      _handsFreeEnabled = prefs.getBool(_prefHandsFreeKey) ?? true;
    } catch (_) {
      _handsFreeEnabled = true;
    }

    try {
      _channel.setMethodCallHandler((call) async {
        if (call.method == 'onWakeTriggered') {
          if (_handsFreeEnabled) {
            await triggerWake(reason: call.arguments?.toString() ?? 'native');
          }
        } else if (call.method == 'onPermissionsUpdated') {
          final map = call.arguments;
          if (map is Map) {
            _applyPermissionsMap(map);
          }
        }
        return null;
      });
      await refreshPermissionsStatus();
      if (_handsFreeEnabled && !_micGranted) {
        await requestMicAndNotifications();
      }
      await _channel.invokeMethod('setShakeEnabled', _handsFreeEnabled);
      final launchedViaAssist =
          await _channel.invokeMethod<bool>('consumeAssistLaunch') ?? false;
      // Pre-cache the voice greeting in the background on real devices so
      // waking up speaks with zero network wait!
      final lang = _navigator?.currentLanguage ?? 'sw';
      GeminiVoice.instance.prefetchFirstSentence(greetingFor(lang));
      if (launchedViaAssist) {
        unawaited(triggerWake(reason: 'assist'));
      } else if (_handsFreeEnabled) {
        _schedulePassiveWakeListening();
      }
    } catch (_) {
      // MethodChannel unavailable in unit tests or non-Android platforms.
    }
    notifyListeners();
  }

  void _applyPermissionsMap(Map<dynamic, dynamic> map) {
    final wasMicGranted = _micGranted;
    _micGranted = map['mic'] == true;
    _overlayGranted = map['overlay'] == true;
    _batteryIgnored = map['battery'] == true;
    _serviceRunning = map['serviceRunning'] == true;
    notifyListeners();
    if (!wasMicGranted && _micGranted && _handsFreeEnabled && !isActive) {
      _schedulePassiveWakeListening();
    }
  }

  Future<void> refreshPermissionsStatus() async {
    try {
      final map = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'getPermissionsStatus',
      );
      if (map != null) {
        _applyPermissionsMap(map);
      }
    } catch (_) {}
  }

  Future<void> requestMicAndNotifications() async {
    try {
      await _channel.invokeMethod('requestMicAndNotifications');
      await refreshPermissionsStatus();
    } catch (_) {}
  }

  Future<void> requestIgnoreBatteryOptimizations() async {
    try {
      await _channel.invokeMethod('requestIgnoreBatteryOptimizations');
    } catch (_) {}
  }

  Future<void> requestOverlayPermission() async {
    try {
      await _channel.invokeMethod('requestOverlayPermission');
    } catch (_) {}
  }

  Future<void> openVoiceAssistantSettings() async {
    try {
      await _channel.invokeMethod('openVoiceAssistantSettings');
    } catch (_) {}
  }

  Future<void> setHandsFreeEnabled(bool enabled) async {
    _handsFreeEnabled = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefHandsFreeKey, enabled);
    } catch (_) {}
    try {
      if (enabled && !_micGranted) {
        await requestMicAndNotifications();
      }
      await _channel.invokeMethod('setShakeEnabled', enabled);
    } catch (_) {}
    if (!enabled) {
      await cancelSession();
    } else {
      _schedulePassiveWakeListening();
    }
    notifyListeners();
  }

  Future<bool> _ensureSpeechInitialized() async {
    if (_speechReady) return true;
    try {
      _speechReady = await _speech.initialize(
        onStatus: (status) {
          if (status == 'notListening' || status == 'done') {
            if (state.value == ConciergeState.listening) {
              _onRecognizerStopped();
            } else if (state.value == ConciergeState.idle &&
                _handsFreeEnabled) {
              _passiveListening = false;
              _schedulePassiveWakeListening();
            }
          }
        },
        onError: (_) {
          if (state.value == ConciergeState.listening) {
            _onRecognizerStopped();
          } else if (state.value == ConciergeState.idle && _handsFreeEnabled) {
            _passiveListening = false;
            _schedulePassiveWakeListening();
          }
        },
      );
    } catch (_) {
      _speechReady = false;
    }
    return _speechReady;
  }

  /// Pauses or resumes background wake-word listening (e.g. paused when the
  /// user is actively inside the aEye camera tab so it never conflicts with
  /// aEye's own camera/microphone actions).
  Future<void> setPassiveWakeAllowed(bool allowed) async {
    _passiveWakeAllowed = allowed;
    if (!allowed) {
      _passiveRestartTimer?.cancel();
      if (_passiveListening && state.value == ConciergeState.idle) {
        _passiveListening = false;
        try {
          await _speech.stop();
        } catch (_) {}
      }
    } else if (_handsFreeEnabled && state.value == ConciergeState.idle) {
      _schedulePassiveWakeListening();
    }
  }

  /// ChatGPT-style Barge-In: interrupts the AI while it is speaking and
  /// immediately switches to listening to the user.
  Future<void> bargeInAndListen() async {
    if (!isActive) return;
    final token = ++_sessionToken;
    _cancelListenTimers();
    await SpeechService.instance.stop();
    await _listenForUserCommand(token);
  }

  /// Listens in the background for the user saying "Eye" / "aEye" / "AskOptSam"
  /// whenever the voice concierge is idle and Hands-Free Blind Mode is enabled.
  void _schedulePassiveWakeListening() {
    _passiveRestartTimer?.cancel();
    if (!_handsFreeEnabled ||
        !_passiveWakeAllowed ||
        state.value != ConciergeState.idle) {
      return;
    }
    _passiveRestartTimer = Timer(const Duration(milliseconds: 1200), () {
      if (_handsFreeEnabled &&
          _passiveWakeAllowed &&
          state.value == ConciergeState.idle &&
          !SpeechService.instance.isSpeaking.value) {
        unawaited(_startPassiveWakeListen());
      }
    });
  }

  Future<void> _startPassiveWakeListen() async {
    if (!_handsFreeEnabled ||
        !_passiveWakeAllowed ||
        state.value != ConciergeState.idle ||
        _passiveListening) {
      return;
    }
    final ready = await _ensureSpeechInitialized();
    if (!ready || state.value != ConciergeState.idle) return;

    _passiveListening = true;
    final lang = _navigator?.currentLanguage ?? 'sw';
    try {
      await _speech.listen(
        listenOptions: SpeechListenOptions(
          localeId: lang == 'en' ? 'en-US' : 'sw-TZ',
          partialResults: true,
          cancelOnError: false,
        ),
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 6),
        onResult: (result) {
          if (state.value != ConciergeState.idle) return;
          final words = result.recognizedWords.trim();
          if (isWakePhrase(words)) {
            _passiveListening = false;
            _passiveRestartTimer?.cancel();
            try {
              _speech.stop();
            } catch (_) {}
            final remainder = stripWakePrefix(words);
            if (remainder.split(' ').length >= 2 && result.finalResult) {
              unawaited(handleSpokenCommand(remainder));
            } else {
              unawaited(triggerWake(reason: 'voice_wake'));
            }
          }
        },
      );
    } catch (_) {
      _passiveListening = false;
    }
  }

  /// Called when Android's SpeechRecognizer stops listening. If the user had
  /// already spoken words, dispatch them immediately; if they hadn't spoken
  /// yet, automatically re-open the microphone so it never cuts off abruptly!
  void _onRecognizerStopped() {
    if (state.value != ConciergeState.listening || _commandDispatched) return;
    final token = _sessionToken;
    final spoken = lastHeard.value.trim();
    if (spoken.isNotEmpty) {
      _commandDispatched = true;
      _cancelListenTimers();
      unawaited(handleSpokenCommand(spoken));
      return;
    }

    // User hasn't spoken yet: keep the mic alive or gently re-prompt!
    _emptyListenRetries++;
    if (_emptyListenRetries <= 2) {
      Future<void>.delayed(const Duration(milliseconds: 350), () {
        if (token == _sessionToken &&
            state.value == ConciergeState.listening &&
            !_commandDispatched) {
          _startListeningAttempt(token);
        }
      });
    } else if (_emptyListenRetries == 3) {
      unawaited(_repromptAfterSilence(token));
    }
  }

  Future<void> _repromptAfterSilence(int token) async {
    if (token != _sessionToken) return;
    _emptyListenRetries = 0;
    final lang = _navigator?.currentLanguage ?? 'sw';
    final reprompt = gentleRepromptFor(lang);
    state.value = ConciergeState.speaking;
    statusMessage.value = reprompt;
    notifyListeners();

    await _speakAndWait(reprompt, token);
    if (token != _sessionToken) return;
    await _listenForUserCommand(token);
  }

  /// Wakes the screen, vibrates, asks the user where they want to go or how
  /// their eyes feel, and automatically opens the microphone when finished.
  Future<void> triggerWake({String reason = 'manual'}) async {
    final token = ++_sessionToken;
    _cancelListenTimers();
    _awaitingDirectQuestion = false;
    _emptyListenRetries = 0;
    _voiceHistory.clear();
    lastHeard.value = '';

    try {
      await _channel.invokeMethod('wakeScreen');
    } catch (_) {}
    HapticFeedback.heavyImpact();

    try {
      await _speech.stop();
    } catch (_) {}

    final lang = _navigator?.currentLanguage ?? 'sw';
    final greeting = greetingFor(lang);
    state.value = ConciergeState.speaking;
    statusMessage.value = greeting;
    notifyListeners();

    await _speakAndWait(greeting, token);
    if (token != _sessionToken) return;

    await _listenForUserCommand(token);
  }

  /// Prompts the user after answering a question so they can keep talking
  /// hands-free or switch to aEye camera navigation.
  Future<void> offerFollowUp() async {
    if (!_handsFreeEnabled) return;
    final token = ++_sessionToken;
    _cancelListenTimers();
    _emptyListenRetries = 0;
    final lang = _navigator?.currentLanguage ?? 'sw';
    final prompt = followUpPromptFor(lang);

    state.value = ConciergeState.speaking;
    statusMessage.value = prompt;
    notifyListeners();

    await _speakAndWait(prompt, token);
    if (token != _sessionToken) return;

    await _listenForUserCommand(token);
  }

  Future<void> _speakAndWait(String text, int token) async {
    await SpeechService.instance.speak(text, force: true);
    // Give SpeechService a brief moment to mark isSpeaking = true, then wait
    // until playback completes (up to 35s safety cap).
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final sw = Stopwatch()..start();
    while (SpeechService.instance.isSpeaking.value &&
        sw.elapsedMilliseconds < 35000 &&
        token == _sessionToken) {
      await Future<void>.delayed(const Duration(milliseconds: 120));
    }
    // Small cushion so the microphone doesn't record the speaker's tail echo.
    await Future<void>.delayed(const Duration(milliseconds: 220));
  }

  void _cancelListenTimers() {
    _silenceCommitTimer?.cancel();
    _silenceCommitTimer = null;
    _listenWatchdogTimer?.cancel();
    _listenWatchdogTimer = null;
    _passiveRestartTimer?.cancel();
    _passiveRestartTimer = null;
    _passiveListening = false;
  }

  Future<void> _listenForUserCommand(int token) async {
    if (token != _sessionToken) return;
    _cancelListenTimers();
    _commandDispatched = false;
    lastHeard.value = '';

    final lang = _navigator?.currentLanguage ?? 'sw';
    state.value = ConciergeState.listening;
    statusMessage.value = lang == 'en'
        ? 'Listening... Speak naturally or say "aEye"'
        : 'Inasikiliza... Ongea moja kwa moja au sema "aEye"';
    notifyListeners();
    HapticFeedback.selectionClick();

    final ready = await _ensureSpeechInitialized();
    if (!ready || token != _sessionToken) {
      return;
    }

    await _startListeningAttempt(token);
  }

  Future<void> _startListeningAttempt(int token) async {
    if (token != _sessionToken || _commandDispatched) return;
    final lang = _navigator?.currentLanguage ?? 'sw';
    try {
      await _speech.listen(
        listenOptions: SpeechListenOptions(
          localeId: lang == 'en' ? 'en-US' : 'sw-TZ',
          partialResults: true,
          cancelOnError: false,
        ),
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 6),
        onResult: (result) {
          if (token != _sessionToken || _commandDispatched) return;
          final words = result.recognizedWords.trim();
          if (words.isNotEmpty) {
            _emptyListenRetries = 0;
            lastHeard.value = words;
            notifyListeners();

            // Commit after 2.2s of pause once the user has spoken words, or
            // immediately when Android marks finalResult = true.
            _silenceCommitTimer?.cancel();
            if (result.finalResult) {
              _commandDispatched = true;
              _cancelListenTimers();
              unawaited(handleSpokenCommand(words));
            } else {
              _silenceCommitTimer = Timer(
                const Duration(milliseconds: 2200),
                () {
                  if (token == _sessionToken &&
                      !_commandDispatched &&
                      lastHeard.value.trim().isNotEmpty) {
                    _commandDispatched = true;
                    _cancelListenTimers();
                    try {
                      _speech.stop();
                    } catch (_) {}
                    unawaited(handleSpokenCommand(lastHeard.value.trim()));
                  }
                },
              );
            }
          }
        },
      );
    } catch (_) {}
  }

  /// Generates a fast (~0.8s), natural 2-3 sentence ChatGPT-style spoken
  /// optometrist response that always ends with a direct follow-up question
  /// for the blind/low-vision user.
  Future<String?> _generateFastVoiceReply(String question, String lang) async {
    _voiceHistory.add({
      'role': 'user',
      'parts': [
        {'text': question},
      ],
    });
    if (_voiceHistory.length > 8) {
      _voiceHistory.removeRange(0, 2);
    }

    final systemPrompt = lang == 'en'
        ? 'You are AskOptSam in Live Voice Mode, a warm, caring optometrist '
            'talking directly by voice to a blind or low-vision person in '
            'Dar es Salaam (Optsam Eye Care, founded by J.M. Samwel and '
            'J.M. Emanueli). Rules for voice conversation:\n'
            '1. Keep your reply brief and natural for speech: 2 to 3 short '
            'sentences ONLY (maximum 45 words). Never use bullet points, '
            'numbered lists, asterisks, or markdown.\n'
            '2. ALWAYS end your reply by asking the user ONE direct, helpful '
            'follow-up question (like a real doctor or ChatGPT Voice Mode) to '
            'understand their symptoms better or ask if they want to open '
            'aEye camera navigation.'
        : 'Wewe ni AskOptSam kwenye Hali ya Mazungumzo ya Sauti Moja kwa Moja '
            '(kama ChatGPT Voice Mode), daktari bingwa na rafiki wa macho '
            'unayeongea kwa sauti na mtu asiyeona au mwenye uoni hafifu '
            '(Optsam Eye Care, Dar es Salaam). Kanuni za sauti:\n'
            '1. Jibu kwa ufupi na kwa lugha ya kuongea: sentensi 2 hadi 3 '
            'fupi TU (isizidi maneno 45). Usitumie orodha, alama za nyota, '
            'wala markdown.\n'
            '2. LAZIMA umalizie kila jibu kwa kumuuliza mtumiaji SWALI MOJA '
            'la moja kwa moja (kama daktari halisi anavyododosa dalili au '
            'kumuuliza kama anataka kufungua kamera ya aEye).';

    for (final model in const [
      'gemini-3.5-flash-lite',
      'gemini-3.1-flash-lite',
      'gemini-3.5-flash',
    ]) {
      for (final apiKey in <String>{
        AppSettings.instance.apiKey,
        AppSettings.builtInApiKey,
      }) {
        if (apiKey.trim().isEmpty) continue;
        try {
          final uri = Uri.https(
            'generativelanguage.googleapis.com',
            '/v1beta/models/$model:generateContent',
          );
          final response = await GeminiHttp.client
              .post(
                uri,
                headers: {
                  'Content-Type': 'application/json',
                  'x-goog-api-key': apiKey,
                },
                body: jsonEncode({
                  'systemInstruction': {
                    'parts': [
                      {'text': systemPrompt},
                    ],
                  },
                  'contents': _voiceHistory,
                  'generationConfig': {
                    'temperature': 0.4,
                    'maxOutputTokens': 160,
                    'thinkingConfig': const {'thinkingLevel': 'MINIMAL'},
                  },
                }),
              )
              .timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            final data = jsonDecode(utf8.decode(response.bodyBytes))
                as Map<String, dynamic>;
            final candidates = data['candidates'];
            if (candidates is List && candidates.isNotEmpty) {
              final parts = (candidates.first as Map?)?['content']?['parts'];
              if (parts is List) {
                final buf = StringBuffer();
                for (final part in parts) {
                  if (part is Map &&
                      part['thought'] != true &&
                      part['text'] is String) {
                    buf.write(part['text']);
                  }
                }
                final reply = buf
                    .toString()
                    .replaceAll(RegExp(r'\*\*|__|`+|#+\s*'), '')
                    .trim();
                if (reply.isNotEmpty) {
                  _voiceHistory.add({
                    'role': 'model',
                    'parts': [
                      {'text': reply},
                    ],
                  });
                  return reply;
                }
              }
            }
          }
        } catch (_) {}
      }
    }
    return null;
  }

  /// Processes a spoken command (from microphone or quick voice action)
  /// and automatically navigates the app or continues the live voice dialogue.
  Future<void> handleSpokenCommand(String rawCommand) async {
    final token = ++_sessionToken;
    _cancelListenTimers();
    _commandDispatched = true;
    final lang = _navigator?.currentLanguage ?? 'sw';
    final decision = classifyCommand(
      rawCommand,
      awaitingQuestion: _awaitingDirectQuestion,
    );

    state.value = ConciergeState.processing;
    lastHeard.value = rawCommand.trim();
    notifyListeners();

    switch (decision.action) {
      case ConciergeAction.openEyeNavigate:
        _awaitingDirectQuestion = false;
        final msg = lang == 'en'
            ? 'Opening aEye camera guide now. Point your phone ahead.'
            : 'Inafungua kamera ya aEye kukuongoza sasa. Elekeza simu mbele yako.';
        statusMessage.value = msg;
        state.value = ConciergeState.idle;
        notifyListeners();
        HapticFeedback.mediumImpact();
        await _navigator?.onOpenEyeNavigate(
          targetObject: decision.targetObject,
        );
        break;

      case ConciergeAction.openEyeRead:
        _awaitingDirectQuestion = false;
        final msg = lang == 'en'
            ? 'Opening aEye text reader now. Hold the phone over the text.'
            : 'Inafungua aEye kusoma maandishi sasa. Shikilia simu mbele ya maandishi.';
        statusMessage.value = msg;
        state.value = ConciergeState.idle;
        notifyListeners();
        HapticFeedback.mediumImpact();
        await _navigator?.onOpenEyeRead();
        break;

      case ConciergeAction.promptForQuestion:
        _awaitingDirectQuestion = true;
        final prompt = askPromptFor(lang);
        state.value = ConciergeState.speaking;
        statusMessage.value = prompt;
        notifyListeners();
        await _speakAndWait(prompt, token);
        if (token != _sessionToken) return;
        await _listenForUserCommand(token);
        break;

      case ConciergeAction.askQuestion:
        _awaitingDirectQuestion = false;
        final q = decision.question?.trim() ?? rawCommand.trim();
        statusMessage.value = lang == 'en'
            ? 'Thinking...'
            : 'AskOptSam inafikiria jibu...';
        notifyListeners();

        // Generate a fast (~0.8s) ChatGPT-style conversational reply that ends
        // with a direct follow-up question, keep the Voice Mode screen OPEN,
        // speak the entire reply smoothly, and automatically re-open the mic!
        final fastReply = await _generateFastVoiceReply(q, lang);
        if (token != _sessionToken) return;

        if (fastReply != null && fastReply.isNotEmpty) {
          unawaited(
            _navigator?.onAskQuestion(q, precomputedReply: fastReply),
          );
          state.value = ConciergeState.speaking;
          statusMessage.value = fastReply;
          notifyListeners();

          await _speakAndWait(fastReply, token);
          if (token != _sessionToken) return;

          // Immediately listen for the user's answer to the AI's question!
          await _listenForUserCommand(token);
        } else {
          // Fallback to standard ChatScreen stream if direct call is offline
          state.value = ConciergeState.idle;
          notifyListeners();
          await _navigator?.onAskQuestion(q);
        }
        break;

      case ConciergeAction.stop:
        _awaitingDirectQuestion = false;
        final bye = goodbyeFor(lang);
        state.value = ConciergeState.speaking;
        statusMessage.value = bye;
        notifyListeners();
        await _speakAndWait(bye, token);
        if (token != _sessionToken) return;
        await cancelSession();
        break;

      case ConciergeAction.unknown:
        await _listenForUserCommand(token);
        break;
    }
  }

  Future<void> cancelSession() async {
    _sessionToken++;
    _cancelListenTimers();
    _commandDispatched = false;
    _awaitingDirectQuestion = false;
    try {
      await _speech.stop();
    } catch (_) {}
    await SpeechService.instance.stop();
    state.value = ConciergeState.idle;
    statusMessage.value = '';
    lastHeard.value = '';
    notifyListeners();
    if (_handsFreeEnabled) {
      _schedulePassiveWakeListening();
    }
  }
}
