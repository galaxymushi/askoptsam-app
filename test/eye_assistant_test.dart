import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:asksam/eye/l10n/strings.dart';
import 'package:asksam/eye/services/app_settings.dart';
import 'package:asksam/eye/services/gemini_voice.dart';
import 'package:asksam/eye/services/speech_service.dart';
import 'package:asksam/l10n.dart';
import 'package:asksam/screens/eye_assistant_screen.dart';
import 'package:asksam/widgets/mascot.dart';

Widget _wrap(Widget child, {String lang = 'sw'}) {
  return MaterialApp(
    builder: (context, c) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: true),
      child: c!,
    ),
    home: L10nScope(
      strings: Strings(lang),
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppSettings.instance.load();
  });

  testWidgets('EyeAssistantScreen renders real Eye 0.3.3 HomeScreen in Kiswahili',
      (WidgetTester tester) async {
    await AppSettings.instance.setLanguage(AppLanguage.sw);
    await tester.pumpWidget(_wrap(const EyeAssistantScreen(), lang: 'sw'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Eye'), findsOneWidget);
    expect(find.text('Tazama dunia kwa sauti'), findsOneWidget);
    expect(find.text('Soma'), findsOneWidget);
    expect(find.text('Uliza'), findsOneWidget);
    expect(find.text('Elezea'), findsOneWidget);
    expect(find.text('Acha kusema'), findsOneWidget);
  });

  testWidgets('EyeAssistantScreen renders real Eye 0.3.3 HomeScreen in English',
      (WidgetTester tester) async {
    await AppSettings.instance.setLanguage(AppLanguage.en);
    await tester.pumpWidget(_wrap(const EyeAssistantScreen(), lang: 'en'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Eye'), findsOneWidget);
    expect(find.text('See the world by voice'), findsOneWidget);
    expect(find.text('Read'), findsOneWidget);
    expect(find.text('Ask'), findsOneWidget);
    expect(find.text('Describe'), findsOneWidget);
    expect(find.text('Stop speaking'), findsOneWidget);
  });

  testWidgets('Tapping Mipangilio opens real Eye 0.3.3 SettingsScreen with voice models',
      (WidgetTester tester) async {
    await AppSettings.instance.setLanguage(AppLanguage.sw);
    await tester.pumpWidget(_wrap(const EyeAssistantScreen(), lang: 'sw'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final settingsIconFinder = find.byIcon(Icons.settings);
    expect(settingsIconFinder, findsOneWidget);
    await tester.tap(settingsIconFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Mipangilio'), findsOneWidget);
    expect(find.text('Lugha'), findsOneWidget);
    expect(find.text('Sauti'), findsOneWidget);
    await tester.drag(find.byType(ListView).last, const Offset(0, -350));
    await tester.pump();
    expect(find.text('Chagua sauti'), findsWidgets);
    expect(GeminiVoice.voices, contains('Charon'));
    expect(AppSettings.instance.isConfigured, isTrue);
  });

  testWidgets('Interactive Mascot widget renders and reacts to tap',
      (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      _wrap(
        Mascot(
          height: 150,
          onTap: () {
            tapped = true;
          },
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(Mascot), findsOneWidget);

    await tester.tap(find.byType(Mascot));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tapped, isTrue);
  });

  test('SpeechService stays strictly silent when Eye tab is not active', () async {
    SpeechService.instance.isEyeTabActive = false;
    await SpeechService.instance.speak('Eye msaidizi wa maono');
    expect(SpeechService.instance.isSpeaking.value, isFalse);
  });
}
