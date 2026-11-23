import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:asksam/eye/services/gemini_service.dart';
import 'package:asksam/services/voice_concierge_service.dart';

class _FakeNavigator implements ConciergeNavigator {
  String lang = 'sw';
  int eyeNavigateCalls = 0;
  int eyeReadCalls = 0;
  String? lastTargetObject;
  final List<String> askedQuestions = [];

  @override
  String get currentLanguage => lang;

  @override
  Future<void> onOpenEyeNavigate({String? targetObject}) async {
    eyeNavigateCalls++;
    lastTargetObject = targetObject;
  }

  @override
  Future<void> onOpenEyeRead() async {
    eyeReadCalls++;
  }

  @override
  Future<void> onAskQuestion(String question) async {
    askedQuestions.add(question);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('detects Hey AskOptSam wake phrases in Kiswahili and English', () {
    expect(VoiceConciergeService.isWakePhrase('Hey AskOptSam'), isTrue);
    expect(VoiceConciergeService.isWakePhrase('hey ask optsam nisaidie'), isTrue);
    expect(VoiceConciergeService.isWakePhrase('Habari AskOptSam'), isTrue);
    expect(VoiceConciergeService.isWakePhrase('Hey aEye'), isTrue);
    expect(VoiceConciergeService.isWakePhrase('habari za asubuhi'), isFalse);
  });

  test('strips wake prefix when command is spoken in one sentence', () {
    expect(
      VoiceConciergeService.stripWakePrefix('Hey AskOptSam fungua aEye'),
      'fungua aEye',
    );
    expect(
      VoiceConciergeService.stripWakePrefix('AskOptSam, macho yangu yanawasha'),
      'macho yangu yanawasha',
    );
  });

  test('classifies navigation, reading, question, and stop commands', () {
    expect(
      VoiceConciergeService.classifyCommand('aEye').action,
      ConciergeAction.openEyeNavigate,
    );
    expect(
      VoiceConciergeService.classifyCommand('Fungua kamera niongoze').action,
      ConciergeAction.openEyeNavigate,
    );
    expect(
      VoiceConciergeService.classifyCommand('Navigate with camera').action,
      ConciergeAction.openEyeNavigate,
    );
    expect(
      VoiceConciergeService.classifyCommand('Soma maandishi').action,
      ConciergeAction.openEyeRead,
    );
    expect(
      VoiceConciergeService.classifyCommand('Read text').action,
      ConciergeAction.openEyeRead,
    );
    expect(
      VoiceConciergeService.classifyCommand('Nina swali').action,
      ConciergeAction.promptForQuestion,
    );
    expect(
      VoiceConciergeService.classifyCommand('I have a question').action,
      ConciergeAction.promptForQuestion,
    );

    final directSw = VoiceConciergeService.classifyCommand(
      'Macho yangu yanawasha sana nifanye nini?',
    );
    expect(directSw.action, ConciergeAction.askQuestion);
    expect(directSw.question, 'Macho yangu yanawasha sana nifanye nini?');

    final directEn = VoiceConciergeService.classifyCommand(
      'What causes blurry vision at night?',
    );
    expect(directEn.action, ConciergeAction.askQuestion);
    expect(directEn.question, 'What causes blurry vision at night?');

    expect(
      VoiceConciergeService.classifyCommand('Simama').action,
      ConciergeAction.stop,
    );
    expect(
      VoiceConciergeService.classifyCommand('Stop').action,
      ConciergeAction.stop,
    );
  });

  test('VoiceConciergeService routes spoken commands to ConciergeNavigator', () async {
    final nav = _FakeNavigator();
    final service = VoiceConciergeService.instance;
    await service.init(nav);

    await service.handleSpokenCommand('aEye');
    expect(nav.eyeNavigateCalls, 1);
    expect(nav.lastTargetObject, isNull);

    await service.handleSpokenCommand('Tafuta mlango');
    expect(nav.eyeNavigateCalls, 2);
    expect(nav.lastTargetObject, 'mlango');

    await service.handleSpokenCommand('Soma maandishi');
    expect(nav.eyeReadCalls, 1);

    await service.handleSpokenCommand('Dalili za mtoto wa jicho ni zipi?');
    expect(nav.askedQuestions, ['Dalili za mtoto wa jicho ni zipi?']);
  });

  test('GeminiService.indicatesLowLight detects darkness in Swahili and English', () {
    expect(GeminiService.indicatesLowLight('Kuna giza sana chumbani.'), isTrue);
    expect(GeminiService.indicatesLowLight('The room is too dark to see.'), isTrue);
    expect(GeminiService.indicatesLowLight('Njia mbele yako iko wazi.'), isFalse);
  });
}
