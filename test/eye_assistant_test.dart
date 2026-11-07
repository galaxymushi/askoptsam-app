import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('EyeAssistantScreen renders primary vision cards and actions in Swahili',
      (WidgetTester tester) async {
    await tester.pumpWidget(_wrap(const EyeAssistantScreen(), lang: 'sw'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify Title and Subtitle
    expect(find.text('Eye'), findsOneWidget);
    expect(find.text('Tazama dunia kwa sauti'), findsOneWidget);

    // Verify the 3 main actions: Soma, Uliza, Elezea
    expect(find.text('Soma'), findsOneWidget);
    expect(find.text('Uliza'), findsOneWidget);
    expect(find.text('Elezea'), findsOneWidget);

    // Verify Stop button by Key
    expect(find.byKey(const ValueKey('eye_stop_home')), findsOneWidget);

    // Verify Smart Glasses card
    expect(find.text('Miwani Janja'), findsOneWidget);
  });

  testWidgets('EyeAssistantScreen renders correctly in English',
      (WidgetTester tester) async {
    await tester.pumpWidget(_wrap(const EyeAssistantScreen(), lang: 'en'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify English labels
    expect(find.text('Eye'), findsOneWidget);
    expect(find.text('See the world with voice'), findsOneWidget);
    expect(find.text('Read'), findsOneWidget);
    expect(find.text('Ask'), findsOneWidget);
    expect(find.text('Describe'), findsOneWidget);
    expect(find.byKey(const ValueKey('eye_stop_home')), findsOneWidget);
    expect(find.text('Smart Glasses'), findsOneWidget);
  });

  testWidgets('Tapping Soma opens camera viewfinder and triggers analysis',
      (WidgetTester tester) async {
    await tester.pumpWidget(_wrap(const EyeAssistantScreen(), lang: 'sw'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Tap 'Soma'
    await tester.tap(find.text('Soma'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Verify camera viewfinder opens with Rudi back button & action button
    expect(find.text('Rudi'), findsOneWidget);
    expect(find.text('Soma maandishi'), findsOneWidget);

    // Tap 'Soma maandishi' to trigger OCR scan
    await tester.tap(find.text('Soma maandishi'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Verify scan result is populated and displayed
    expect(find.textContaining('Optsam'), findsWidgets);

    // Tap 'Acha kusema' on camera screen
    final stopCameraFinder = find.byKey(const ValueKey('eye_stop_camera'));
    expect(stopCameraFinder, findsOneWidget);
    await tester.tap(stopCameraFinder);
    await tester.pump();

    // Tap Rudi to close viewfinder
    await tester.tap(find.text('Rudi'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Confirm returned to main Eye dashboard
    expect(find.text('Tazama dunia kwa sauti'), findsOneWidget);
  });

  testWidgets('Smart Glasses switch toggles connection state and Settings dialog opens',
      (WidgetTester tester) async {
    await tester.pumpWidget(_wrap(const EyeAssistantScreen(), lang: 'sw'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Initially connected
    expect(find.text('Imeunganishwa kwa Bluetooth (BLE)'), findsOneWidget);

    // Toggle switch off
    final switchFinder = find.byType(Switch);
    expect(switchFinder, findsOneWidget);
    await tester.tap(switchFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Check offline text appears
    expect(find.text('Bluetooth Offline'), findsOneWidget);

    // Tap settings icon
    final settingsIconFinder = find.byIcon(Icons.settings);
    expect(settingsIconFinder, findsOneWidget);
    await tester.tap(settingsIconFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Check dialog opens
    expect(find.text('Eye Mipangilio'), findsOneWidget);
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

    // Verify Mascot is present
    expect(find.byType(Mascot), findsOneWidget);

    // Tap mascot
    await tester.tap(find.byType(Mascot));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tapped, isTrue);
  });
}
