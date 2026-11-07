import 'package:asksam/l10n.dart';
import 'package:asksam/services/update_service.dart';
import 'package:asksam/widgets/update_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  setUp(() => SharedPreferences.setMockInitialValues({}));

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

    // A browser cannot open in tests: once the safety timeout fires the
    // button returns (nothing was fetched) and the dialog still blocks.
    await tester.pump(const Duration(seconds: 7));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('Pakua sasa'), findsOneWidget);
  });

  testWidgets('the download button disappears once the APK was fetched', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        UpdateGate(
          check: () async => _release,
          download: (_) async => true,
          child: const Text('app'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Pakua sasa'), findsOneWidget);

    await tester.tap(find.text('Pakua sasa'));
    await tester.pumpAndSettle();

    // The button makes way for a confirmation, but the dialog still blocks
    // until the new version is installed.
    expect(find.text('Pakua sasa'), findsNothing);
    expect(find.text('Imepakuliwa'), findsOneWidget);
    expect(
      find.text('Sakinisha APK uliopakua kisha fungua app tena ili kuendelea.'),
      findsOneWidget,
    );
    expect(find.text('Jaribu tena kupakua'), findsOneWidget);
    expect(find.byType(Dialog), findsOneWidget);

    // A relaunch with the same release must start in the downloaded state.
    SharedPreferences.setMockInitialValues({
      'asksam_update_downloaded_v1': '9.9.9',
    });
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      _wrap(
        UpdateGate(
          check: () async => _release,
          download: (_) async => true,
          child: const Text('app'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Pakua sasa'), findsNothing);
    expect(find.text('Imepakuliwa'), findsOneWidget);
    expect(find.byType(Dialog), findsOneWidget);
  });
}
