import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';

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
  Future<void> onAskQuestion(String question);
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

  ConciergeNavigator? _navigator;
  bool _speechReady = false;
  bool _handsFreeEnabled = true;
  bool _awaitingDirectQuestion = false;
  int _sessionToken = 0;

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
      return 'Hello, I am AskOptSam. Where do you want to go right now? '
          'Say aEye to use the camera to guide you, or ask me any question.';
    }
    return 'Habari, mimi ni AskOptSam. Unataka kwenda wapi sasa hivi? '
        'Sema aEye kutumia kamera kukuongoza, au niulize swali lolote.';
  }

  static String askPromptFor(String lang) {
    if (lang == 'en') {
      return 'Okay, ask me your question now. I am listening.';
    }
    return 'Sawa, niulize swali lako sasa. Nakusikiliza.';
  }

  static String followUpPromptFor(String lang) {
    if (lang == 'en') {
      return 'Do you have another question, or say aEye to open the camera?';
    }
    return 'Je, una swali lingine, au sema aEye kufungua kamera?';
  }

  static String goodbyeFor(String lang) {
    if (lang == 'en') {
      return 'Okay. Say Hey AskOptSam or shake your phone anytime you need me.';
    }
    return 'Sawa. Sema Hey AskOptSam au tikisa simu wakati wowote ukiniitaji.';
  }

  /// Checks whether [raw] contains the "Hey AskOptSam" wake phrase.
  static bool isWakePhrase(String raw) {
    final norm = _normalize(raw);
    if (norm.isEmpty) return false;
    const triggers = [
      'hey askoptsam',
      'hey ask optsam',
      'hey ask sam',
      'askoptsam',
      'ask optsam',
      'ask sam',
      'habari askoptsam',
      'habari ask sam',
      'amka askoptsam',
      'hey aeye',
      'hey a eye',
      'msaada wa macho',
    ];
    for (final t in triggers) {
      if (norm.contains(t)) return true;
    }
    return false;
  }

  /// Strips the wake prefix from a spoken utterance if the user spoke both
  /// the wake phrase and a command in one breath (e.g. "Hey AskOptSam open aEye").
  static String stripWakePrefix(String raw) {
    var norm = raw.trim();
    final pattern = RegExp(
      r'^(?:hey\s+|habari\s+|amka\s+)?(?:ask\s*optsam|ask\s*sam|a\s*eye|aeye)[,.\s]*',
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
          norm.contains('fungua aeye') ||
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
      await _channel.invokeMethod('setShakeEnabled', _handsFreeEnabled);
      final launchedViaAssist =
          await _channel.invokeMethod<bool>('consumeAssistLaunch') ?? false;
      if (launchedViaAssist) {
        unawaited(triggerWake(reason: 'assist'));
      }
    } catch (_) {
      // MethodChannel unavailable in unit tests or non-Android platforms.
    }
    notifyListeners();
  }

  void _applyPermissionsMap(Map<dynamic, dynamic> map) {
    _micGranted = map['mic'] == true;
    _overlayGranted = map['overlay'] == true;
    _batteryIgnored = map['battery'] == true;
    _serviceRunning = map['serviceRunning'] == true;
    notifyListeners();
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
    }
    notifyListeners();
  }

  Future<bool> _ensureSpeechInitialized() async {
    if (_speechReady) return true;
    try {
      _speechReady = await _speech.initialize(
        onStatus: (_) {},
        onError: (_) {},
      );
    } catch (_) {
      _speechReady = false;
    }
    return _speechReady;
  }

  /// Wakes the screen, vibrates, asks the user where they want to go,
  /// and automatically opens the microphone when finished speaking.
  Future<void> triggerWake({String reason = 'manual'}) async {
    final token = ++_sessionToken;
    _awaitingDirectQuestion = false;
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
    // Wait until SpeechService finishes speaking (up to 18s safety cap).
    final sw = Stopwatch()..start();
    while (SpeechService.instance.isSpeaking.value &&
        sw.elapsedMilliseconds < 18000 &&
        token == _sessionToken) {
      await Future<void>.delayed(const Duration(milliseconds: 120));
    }
  }

  Future<void> _listenForUserCommand(int token) async {
    if (token != _sessionToken) return;
    final lang = _navigator?.currentLanguage ?? 'sw';
    state.value = ConciergeState.listening;
    statusMessage.value = lang == 'en'
        ? 'Listening... Say "aEye" or ask your question'
        : ' Inasikiliza... Sema "aEye" au uliza swali lako';
    notifyListeners();

    final ready = await _ensureSpeechInitialized();
    if (!ready || token != _sessionToken) {
      return;
    }

    var handled = false;
    await _speech.listen(
      listenOptions: SpeechListenOptions(
        localeId: lang == 'en' ? 'en-US' : 'sw-TZ',
        partialResults: true,
        cancelOnError: true,
      ),
      listenFor: const Duration(seconds: 12),
      pauseFor: const Duration(seconds: 3),
      onResult: (result) {
        if (token != _sessionToken || handled) return;
        lastHeard.value = result.recognizedWords.trim();
        if (result.finalResult && lastHeard.value.isNotEmpty) {
          handled = true;
          unawaited(handleSpokenCommand(lastHeard.value));
        }
      },
    );
  }

  /// Processes a spoken command (from microphone or quick voice action)
  /// and automatically navigates the app.
  Future<void> handleSpokenCommand(String rawCommand) async {
    final token = ++_sessionToken;
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
            ? 'Opening aEye camera navigation now.'
            : 'Inafungua kamera ya aEye kukuongoza sasa.';
        statusMessage.value = msg;
        state.value = ConciergeState.idle;
        notifyListeners();
        await _navigator?.onOpenEyeNavigate(
          targetObject: decision.targetObject,
        );
        break;

      case ConciergeAction.openEyeRead:
        _awaitingDirectQuestion = false;
        final msg = lang == 'en'
            ? 'Opening aEye text reader now.'
            : 'Inafungua aEye kusoma maandishi sasa.';
        statusMessage.value = msg;
        state.value = ConciergeState.idle;
        notifyListeners();
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
        statusMessage.value = q;
        state.value = ConciergeState.idle;
        notifyListeners();
        await _navigator?.onAskQuestion(q);
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
    _awaitingDirectQuestion = false;
    try {
      await _speech.stop();
    } catch (_) {}
    await SpeechService.instance.stop();
    state.value = ConciergeState.idle;
    statusMessage.value = '';
    lastHeard.value = '';
    notifyListeners();
  }
}
