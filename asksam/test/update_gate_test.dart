import 'package:asksam/l10n.dart';
import 'package:asksam/services/update_service.dart';
import 'package:asksam/widgets/update_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _release = AppRelease(
  version: '9.9.9',
  tagName: 'v9.9.9',
  title: 'AskOptSam 9.9.9',
  notes: 'Kila kitu kipya kwenye toleo hili.',
  downloadUrl: 'https://example.com/app-release.apk',
  pageUrl: 'https://github.com/galaxymushi/askoptsam-app/releases/tag/v9.9.9',
);

Widget _wrap(Widget gate) => L10nScope(
  strings: Strings('sw'),
  child: MaterialApp(
    home: Scaffold(body: gate),
  ),
);

void main() {
  testWidgets('a newer release blocks the app with a mandatory dialog', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(UpdateGate(check: () async => _release, child: const Text('app'))),
    );
    await tester.pumpAndSettle();

    expect(find.text('Toleo jipya 9.9.9 lipo'), findsOneWidget);
    expect(find.text('Pakua sasa'), findsOneWidget);
    expect(find.text('app'), findsOneWidget); // still there, behind the dialog
  });

  testWidgets('no release reported means no dialog at all', (tester) async {
    await tester.pumpWidget(
      _wrap(UpdateGate(check: () async => null, child: const Text('app'))),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    expect(find.text('app'), findsOneWidget);
  });

  testWidgets('the dialog survives a tap outside and a back request', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(UpdateGate(check: () async => _release, child: const Text('app'))),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);

    // Tapping the barrier must not close it.
    await tester.tapAt(const Offset(4, 4));
    await tester.pump();
    expect(find.byType(Dialog), findsOneWidget);

    // Neither may the Android back gesture (the real system back path).
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
  });

  testWidgets('tapping download keeps the dialog up', (tester) async {
    await tester.pumpWidget(
      _wrap(UpdateGate(check: () async => _release, child: const Text('app'))),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pakua sasa'));
    await tester.pump();
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('Toleo jipya 9.9.9 lipo'), findsOneWidget);
  });
}
