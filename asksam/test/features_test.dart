import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:asksam/app_state.dart';
import 'package:asksam/content/eye_facts.dart';
import 'package:asksam/l10n.dart';
import 'package:asksam/models.dart';
import 'package:asksam/screens/library_screen.dart';
import 'package:asksam/screens/notifications_screen.dart';
import 'package:asksam/screens/pay_screen.dart';
import 'package:asksam/screens/settings_screen.dart';
import 'package:asksam/services/auth_service.dart';
import 'package:asksam/services/chat_store.dart';
import 'package:asksam/services/notification_store.dart';
import 'package:asksam/services/payment_service.dart';
import 'package:asksam/services/settings_controller.dart';

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
  Future<void> rename(String uid, String sessionId, String title) async {}
}

Future<AppState> _state() async {
  final prefs = await SharedPreferences.getInstance();
  return AppState(
    settings: SettingsController(prefs),
    auth: LocalAuthService(),
    store: _MemoryChatStore(),
  )..user = _user;
}

Widget _app(AppState state, Widget home, {String lang = 'sw'}) {
  return MaterialApp(
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: true),
      child: child!,
    ),
    home: AppScope(
      state: state,
      child: L10nScope(strings: Strings(lang), child: home),
    ),
  );
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('one eye fact per day, rotating and complete in both languages', () {
    final today = DateTime(2026, 10, 31);
    expect(
      EyeFacts.forDay(today).id,
      EyeFacts.forDay(DateTime(2026, 10, 31, 23, 59)).id,
    );
    expect(
      EyeFacts.forDay(today).id,
      isNot(EyeFacts.forDay(DateTime(2026, 11, 1)).id),
    );

    final rail = EyeFacts.afterToday(today, count: 6);
    expect(rail, hasLength(6));
    expect(rail.map((f) => f.id).toSet(), hasLength(6));
    expect(rail.any((f) => f.id == EyeFacts.forDay(today).id), isFalse);

    for (final fact in EyeFacts.all) {
      for (final lang in ['sw', 'en']) {
        expect(fact.title(lang).trim(), isNotEmpty);
        expect(fact.body(lang).trim(), isNotEmpty);
        expect(fact.tip(lang).trim(), isNotEmpty);
      }
    }
  });

  test('notification feed dedupes, counts unread and marks read', () async {
    final store = NotificationStore();
    expect(
      await store.addOnce('tester',
          id: 'welcome',
          kind: NoticeKind.welcome,
          title: 'Karibu',
          body: 'Habari'),
      isTrue,
    );
    expect(
      await store.addOnce('tester',
          id: 'welcome',
          kind: NoticeKind.welcome,
          title: 'Karibu',
          body: 'Habari'),
      isFalse,
    );
    expect(await store.load('tester'), hasLength(1));
    expect(await store.unread('tester'), 1);

    await NotificationStore().markAllRead('tester');
    expect(await store.unread('tester'), 0);
  });

  test('only the two real mobile-money channels are offered', () {
    final channels = PaymentService.channels();
    expect(channels.map((c) => c.id).toList(), ['airtel', 'mpesa']);
    expect(channels[0].account, '0698383923');
    expect(channels[1].account, '0726460872');
  });

  test('settings persist and start in Kiswahili with tips on', () async {
    final first = SettingsController(await SharedPreferences.getInstance());
    expect(first.language, 'sw');
    expect(first.notifyTips, isTrue);
    expect(first.notifyReplies, isTrue);

    first.setLanguage('en');
    first.setNotifyTips(false);
    first.setDark(true);

    final again = SettingsController(await SharedPreferences.getInstance());
    expect(again.language, 'en');
    expect(again.notifyTips, isFalse);
    expect(again.isDark, isTrue);
  });

  testWidgets('library shows today\'s fact, the info rail and the bell',
      (tester) async {
    await tester.pumpWidget(_app(await _state(), const LibraryScreen()));
    await _settle(tester);

    final fact = EyeFacts.forDay(DateTime.now());
    expect(find.text('TAARIFA YA LEO'), findsOneWidget);
    expect(find.text(fact.titleSw), findsWidgets);
    expect(find.text('TAARIFA ZA MACHO'), findsOneWidget);
    expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);

    final notices = await NotificationStore().load('tester');
    expect(notices.any((n) => n.kind == NoticeKind.welcome), isTrue);
    expect(
      notices.any((n) => n.kind == NoticeKind.tip && n.body == fact.titleSw),
      isTrue,
    );
  });

  testWidgets('notification screen lists notices and clears the unread badge',
      (tester) async {
    final store = NotificationStore();
    await store.addOnce('tester',
        id: 'welcome',
        kind: NoticeKind.welcome,
        title: 'Karibu AskOptSam',
        body: 'Uliza chochote kuhusu macho yako.');

    await tester.pumpWidget(_app(await _state(), const NotificationsScreen()));
    await _settle(tester);

    expect(find.text('Karibu AskOptSam'), findsOneWidget);
    expect(find.text('Soma zote'), findsOneWidget);

    await tester.tap(find.text('Soma zote'));
    await _settle(tester);
    expect(await store.unread('tester'), 0);
    expect(find.text('Soma zote'), findsNothing);
  });

  testWidgets('payment screen offers Airtel and M-Pesa numbers only',
      (tester) async {
    await tester.pumpWidget(
      _app(await _state(), const PayScreen(amount: 2000, purpose: 'donation')),
    );
    await _settle(tester);

    expect(find.text('Airtel Money'), findsOneWidget);
    expect(find.text('M-Pesa (Vodacom)'), findsOneWidget);
    expect(find.text('0698383923'), findsOneWidget);
    expect(find.text('0726460872'), findsOneWidget);
    expect(find.textContaining('CRDB'), findsNothing);
    expect(find.textContaining('Tigo'), findsNothing);
    expect(find.textContaining('Halopesa'), findsNothing);
  });

  testWidgets('settings dark-mode switch really flips and persists',
      (tester) async {
    final state = await _state();
    await tester.pumpWidget(_app(state, const SettingsScreen()));
    await _settle(tester);

    expect(state.settings.isDark, isFalse);
    await tester.tap(find.byType(Switch));
    await _settle(tester);
    expect(state.settings.isDark, isTrue);

    final persisted = SettingsController(await SharedPreferences.getInstance());
    expect(persisted.isDark, isTrue);
  });
}
