import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:asksam/app_state.dart';
import 'package:asksam/content/eye_facts.dart';
import 'package:asksam/content/fact_photos.dart';
import 'package:asksam/l10n.dart';
import 'package:asksam/models.dart';
import 'package:asksam/screens/chat_screen.dart';
import 'package:asksam/screens/fact_screen.dart';
import 'package:asksam/screens/library_screen.dart';
import 'package:asksam/screens/notifications_screen.dart';
import 'package:asksam/screens/pay_screen.dart';
import 'package:asksam/screens/privacy_screen.dart';
import 'package:asksam/screens/settings_screen.dart';
import 'package:asksam/services/auth_service.dart';
import 'package:asksam/services/chat_store.dart';
import 'package:asksam/services/settings_controller.dart';
import 'package:asksam/theme.dart';

const _user = AppUser(uid: 'tester', email: 't@x.tz', name: 'Tester');

class _MemoryChatStore implements ChatStore {
  final List<ChatSession> sessions = [];

  @override
  Future<List<ChatSession>> load(String uid) async => [...sessions];

  @override
  Future<void> save(String uid, ChatSession session) async =>
      sessions.add(session);

  @override
  Future<void> delete(String uid, String sessionId) async =>
      sessions.removeWhere((s) => s.id == sessionId);

  @override
  Future<void> deleteAll(String uid) async => sessions.clear();

  @override
  Future<void> rename(String uid, String sessionId, String title) async {}
}

Future<void> _loadFonts() async {
  final inter = FontLoader('Inter');
  for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold']) {
    final bytes = File('assets/fonts/Inter-$weight.ttf').readAsBytesSync();
    inter.addFont(
      Future.value(ByteData.sublistView(Uint8List.fromList(bytes))),
    );
  }
  await inter.load();

  final root = Platform.environment['FLUTTER_ROOT'] ?? r'C:\src\flutter';
  final iconFile = File(
    '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  if (iconFile.existsSync()) {
    final icons = FontLoader('MaterialIcons');
    icons.addFont(
      Future.value(
        ByteData.sublistView(Uint8List.fromList(iconFile.readAsBytesSync())),
      ),
    );
    await icons.load();
  }
}

Future<AppState> _state() async {
  final prefs = await SharedPreferences.getInstance();
  return AppState(
    settings: SettingsController(prefs),
    auth: LocalAuthService(),
    store: _MemoryChatStore(),
  )..user = _user;
}

Widget _shot(
  AppState state,
  Widget home, {
  String lang = 'sw',
  bool dark = false,
}) {
  return RepaintBoundary(
    key: const ValueKey('shot'),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: dark ? AppTheme.dark() : AppTheme.light(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: child!,
      ),
      home: AppScope(
        state: state,
        child: L10nScope(strings: Strings(lang), child: home),
      ),
    ),
  );
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}

Future<void> _warmPhotos(WidgetTester tester) async {
  await tester.runAsync(() async {
    final context = tester.element(find.byType(MaterialApp));
    for (final photo in factPhotos.values) {
      await precacheImage(AssetImage(photo.asset), context);
    }
  });
}

Future<void> _capture(WidgetTester tester, String name) async {
  await expectLater(
    find.byKey(const ValueKey('shot')),
    matchesGoldenFile('goldens/$name.png'),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('capture feature screens', (tester) async {
    await _loadFonts();
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    final state = await _state();

    await tester.pumpWidget(_shot(state, const LibraryScreen()));
    await _settle(tester);
    await _warmPhotos(tester);
    await tester.pump();
    await _capture(tester, 'library');

    await tester.pumpWidget(_shot(state, const LibraryScreen(), dark: true));
    await _settle(tester);
    await _capture(tester, 'library_dark');

    final fact = EyeFacts.forDay(DateTime.now());
    await tester.pumpWidget(_shot(state, FactScreen(fact: fact)));
    await _settle(tester);
    await _capture(tester, 'fact');

    final chat = ChatSession(
      id: 'sample',
      title: 'Macho makavu',
      createdAt: DateTime(2026, 11, 1),
      updatedAt: DateTime(2026, 11, 1),
      messages: [
        ChatMessage(
          id: 'u1',
          role: 'user',
          text: 'Nifanye nini macho yangu yakiwa makavu wakati wa kazi?',
          createdAt: DateTime(2026, 11, 1),
        ),
        ChatMessage(
          id: 'a1',
          role: 'assistant',
          text:
              'Anza na hatua hizi rahisi:\n\n'
              '**1. Fumba mara kwa mara.** Fumba macho taratibu mara 10; '
              'kufumba kunalowesha uso wa jicho.\n\n'
              '**2. Tumia kanuni ya 20-20-20.** Kila dakika 20, tazama kitu '
              'kilicho mbali kwa sekunde 20.\n\n'
              '**3. Punguza upepo wa kiyoyozi.** Upepo unaokuja moja kwa moja '
              'machoni huongeza ukavu.\n\n'
              'Kama ukavu unaendelea siku nyingi au una maumivu, pima macho '
              'kwa mtaalamu.',
          createdAt: DateTime(2026, 11, 1),
          feedback: 'up',
        ),
      ],
    );
    await tester.pumpWidget(_shot(state, ChatScreen(session: chat)));
    await _settle(tester);
    await _capture(tester, 'chat');

    await tester.pumpWidget(_shot(state, const NotificationsScreen()));
    await _settle(tester);
    await _capture(tester, 'notifications');

    await tester.pumpWidget(
      _shot(state, const PayScreen(amount: 2000, purpose: 'donation')),
    );
    await _settle(tester);
    await _capture(tester, 'payments');

    await tester.pumpWidget(_shot(state, const SettingsScreen()));
    await _settle(tester);
    await _capture(tester, 'settings');

    await tester.pumpWidget(_shot(state, const PrivacyScreen()));
    await _settle(tester);
    await _capture(tester, 'privacy');
  });
}
