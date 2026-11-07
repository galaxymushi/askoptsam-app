import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

    // Verify Stop button
    expect(find.text('Acha kusema'), findsOneWidget);

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
    expect(find.text('Stop speaking'), findsOneWidget);
    expect(find.text('Smart Glasses'), findsOneWidget);
  });

  testWidgets('Tapping Soma opens the camera viewfinder',
      (WidgetTester tester) async {
    await tester.pumpWidget(_wrap(const EyeAssistantScreen(), lang: 'sw'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Tap 'Soma'
    await tester.tap(find.text('Soma'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify camera viewfinder opens with Rudi back button
    expect(find.text('Rudi'), findsOneWidget);

    // Tap Rudi to close viewfinder
    await tester.tap(find.text('Rudi'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Confirm returned to main Eye dashboard
    expect(find.text('Tazama dunia kwa sauti'), findsOneWidget);
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
