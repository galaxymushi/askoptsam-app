import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:asksam/app_state.dart';
import 'package:asksam/content/eye_facts.dart';
import 'package:asksam/content/fact_photos.dart';
import 'package:asksam/content/legal_text.dart';
import 'package:asksam/l10n.dart';
import 'package:asksam/models.dart';
import 'package:asksam/screens/chat_screen.dart';
import 'package:asksam/screens/library_screen.dart';
import 'package:asksam/screens/notifications_screen.dart';
import 'package:asksam/screens/pay_screen.dart';
import 'package:asksam/screens/privacy_screen.dart';
import 'package:asksam/screens/settings_screen.dart';
import 'package:asksam/services/auth_service.dart';
import 'package:asksam/services/chat_store.dart';
import 'package:asksam/services/daily_intelligence_service.dart';
import 'package:asksam/services/notification_store.dart';
import 'package:asksam/services/payment_service.dart';
import 'package:asksam/services/settings_controller.dart';
import 'package:asksam/services/update_service.dart';

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
      await store.addOnce(
        'tester',
        id: 'welcome',
        kind: NoticeKind.welcome,
        title: 'Karibu',
        body: 'Habari',
      ),
      isTrue,
    );
    expect(
      await store.addOnce(
        'tester',
        id: 'welcome',
        kind: NoticeKind.welcome,
        title: 'Karibu',
        body: 'Habari',
      ),
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

  testWidgets('library shows today\'s fact, the info rail and the bell', (
    tester,
  ) async {
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

  testWidgets('notification screen lists notices and clears the unread badge', (
    tester,
  ) async {
    final store = NotificationStore();
    await store.addOnce(
      'tester',
      id: 'welcome',
      kind: NoticeKind.welcome,
      title: 'Karibu AskOptSam',
      body: 'Uliza chochote kuhusu macho yako.',
    );

    await tester.pumpWidget(_app(await _state(), const NotificationsScreen()));
    await _settle(tester);

    expect(find.text('Karibu AskOptSam'), findsOneWidget);
    expect(find.text('Soma zote'), findsOneWidget);

    await tester.tap(find.text('Soma zote'));
    await _settle(tester);
    expect(await store.unread('tester'), 0);
    expect(find.text('Soma zote'), findsNothing);
  });

  testWidgets('payment screen offers Airtel and M-Pesa numbers only', (
    tester,
  ) async {
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

  testWidgets('settings dark-mode switch really flips and persists', (
    tester,
  ) async {
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

  test('message feedback survives a save and reload', () {
    final message = ChatMessage(
      id: 'm1',
      role: 'assistant',
      text: 'Jibu',
      createdAt: DateTime(2026, 11, 1),
      feedback: 'up',
    );
    final restored = ChatMessage.fromMap(message.toMap());
    expect(restored.feedback, 'up');

    final plain = ChatMessage(
      id: 'm2',
      role: 'user',
      text: 'Swali',
      createdAt: DateTime(2026, 11, 1),
    );
    expect(plain.toMap().containsKey('feedback'), isFalse);
    expect(ChatMessage.fromMap(plain.toMap()).feedback, isNull);
  });

  test('every eye fact has its own licensed real photograph', () {
    expect(factPhotos.length, EyeFacts.all.length);
    final assets = <String>{};
    for (final fact in EyeFacts.all) {
      final photo = factPhotos[fact.id];
      expect(photo, isNotNull, reason: '${fact.id} has no photo');
      expect(photo!.asset, startsWith('assets/images/facts/'));
      expect(photo.asset, endsWith('.jpg'));
      expect(photo.author.trim(), isNotEmpty);
      expect(photo.license.trim(), isNotEmpty);
      expect(
        photo.sourceUrl,
        startsWith('https://commons.wikimedia.org/wiki/File:'),
      );
      assets.add(photo.asset);
    }
    // Only a handful of closely related facts may share a file; the rest must
    // be their own picture so a fact never shows an unrelated subject.
    expect(assets.length, greaterThanOrEqualTo(16));
  });

  test('privacy and terms documents are complete in both languages', () {
    expect(LegalText.privacy.length, greaterThanOrEqualTo(8));
    expect(LegalText.terms.length, greaterThanOrEqualTo(8));
    for (final section in [...LegalText.privacy, ...LegalText.terms]) {
      for (final lang in ['sw', 'en']) {
        expect(section.title(lang).trim(), isNotEmpty);
        expect(section.body(lang).trim().length, greaterThan(80));
      }
    }
    for (final lang in ['sw', 'en']) {
      expect(LegalText.intro(lang).trim().length, greaterThan(120));
      expect(LegalText.updated(lang).trim(), isNotEmpty);
    }
  });

  testWidgets('chat bubbles offer copy, feedback and resend', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final store = _MemoryChatStore();
    final state = AppState(
      settings: SettingsController(prefs),
      auth: LocalAuthService(),
      store: store,
    )..user = _user;

    final assistant = ChatMessage(
      id: 'a1',
      role: 'assistant',
      text: 'Fumba macho mara kumi kila baada ya dakika 20.',
      createdAt: DateTime(2026, 11, 1),
    );
    final user = ChatMessage(
      id: 'u1',
      role: 'user',
      text: 'Nifanye nini macho yakiwa makavu?',
      createdAt: DateTime(2026, 11, 1),
    );
    final session = ChatSession(
      id: 's1',
      title: 'Macho makavu',
      createdAt: DateTime(2026, 11, 1),
      updatedAt: DateTime(2026, 11, 1),
      messages: [user, assistant],
    );

    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );

    await tester.pumpWidget(_app(state, ChatScreen(session: session)));
    await _settle(tester);

    expect(find.byIcon(Icons.copy_rounded), findsNWidgets(2));
    expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
    expect(find.byIcon(Icons.thumb_up_off_alt_rounded), findsOneWidget);
    expect(find.byIcon(Icons.thumb_down_off_alt_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.copy_rounded).first);
    await _settle(tester);
    expect(copied, isNotNull);
    expect(find.text('Imenakiliwa'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.thumb_up_off_alt_rounded));
    await _settle(tester);

    expect(assistant.feedback, 'up');
    expect(find.byIcon(Icons.thumb_up_alt_rounded), findsOneWidget);
    expect(store.sessions.any((s) => s.id == 's1'), isTrue);

    await tester.tap(find.byIcon(Icons.thumb_up_alt_rounded));
    await _settle(tester);
    expect(assistant.feedback, isNull);
  });

  testWidgets('privacy screen shows the full policy and terms', (tester) async {
    await tester.pumpWidget(_app(await _state(), const PrivacyScreen()));
    await _settle(tester);

    expect(find.text('Sera na masharti'), findsWidgets);
    expect(find.text('TAARIFA ZAKO'), findsOneWidget);
    expect(find.text('Taarifa tunazohifadhi'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('MASHARTI YA MATUMIZI'), 300);
    expect(find.text('MASHARTI YA MATUMIZI'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Fungua msaada'), 300);
    expect(find.text('Fungua msaada'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('update service detects newer versions and creates download notices', () async {
    expect(UpdateService.isNewerVersion('v2.3.0', '2.2.0'), isTrue);
    expect(UpdateService.isNewerVersion('2.3.1', '2.3.0+6'), isTrue);
    expect(UpdateService.isNewerVersion('2.3.0', '2.3.0'), isFalse);
    expect(UpdateService.isNewerVersion('2.1.0', '2.3.0'), isFalse);

    final mockClient = MockClient((request) async {
      return http.Response(
        jsonEncode({
          'tag_name': 'v2.4.0',
          'name': 'AskOptSam 2.4.0',
          'body': '- Arifa za toleo jipya\n- AI ya kila siku',
          'html_url':
              'https://github.com/galaxymushi/askoptsam-app/releases/tag/v2.4.0',
          'assets': [
            {
              'name': 'app-release.apk',
              'browser_download_url':
                  'https://github.com/galaxymushi/askoptsam-app/releases/download/v2.4.0/app-release.apk',
            },
          ],
        }),
        200,
      );
    });

    final release = await UpdateService.instance.syncUpdateNotice(
      'tester',
      language: 'sw',
      installedVersion: '2.3.0',
      client: mockClient,
    );

    expect(release, isNotNull);
    expect(release!.version, '2.4.0');
    expect(
      release.downloadUrl,
      'https://github.com/galaxymushi/askoptsam-app/releases/download/v2.4.0/app-release.apk',
    );

    final notices = await NotificationStore().load('tester');
    final updateNotice = notices.firstWhere((n) => n.kind == NoticeKind.update);
    expect(updateNotice.title, contains('2.4.0'));
    expect(updateNotice.actionUrl, release.downloadUrl);
  });

  test('autonomous daily intelligence generates and caches daily AI insight', () async {
    final day1 = DateTime(2026, 11, 1);
    final day2 = DateTime(2026, 11, 2);

    final seed1 = DailyIntelligenceService.seedForDay(day1);
    final seed2 = DailyIntelligenceService.seedForDay(day2);
    expect(seed1.titleSw, isNot(seed2.titleSw));
    expect(seed1.questionsSw, isNotEmpty);
    expect(seed1.questionsEn, isNotEmpty);

    final aiBriefing = await DailyIntelligenceService.instance.syncDailyNotice(
      'tester',
      language: 'sw',
      now: day1,
      aiCompleter: (_) async => jsonEncode({
        'titleSw': 'Kulinda macho wakati wa joto kali',
        'titleEn': 'Protecting eyes during intense heat',
        'bodySw':
            'Upepo mkavu na joto huongeza uvukizi wa machozi. Kunywa maji na vaa miwani.',
        'bodyEn':
            'Dry wind and heat speed up tear evaporation. Stay hydrated and wear sunglasses.',
        'actionSw': 'Kunywa glasi mbili za maji kabla ya saa sita mchana leo.',
        'actionEn': 'Drink two glasses of water before noon today.',
        'didYouKnowSw': 'Kornea hupata oksijeni moja kwa moja kutoka hewani.',
        'didYouKnowEn': 'The cornea gets oxygen directly from the air.',
        'questionsSw': [
          'Joto linaathirije macho?',
          'Miwani gani inafaa kwenye jua?',
        ],
        'questionsEn': [
          'How does heat affect the eyes?',
          'Which sunglasses are best in strong sun?',
        ],
      }),
    );

    expect(aiBriefing.aiGenerated, isTrue);
    expect(aiBriefing.titleSw, 'Kulinda macho wakati wa joto kali');

    final cached = await DailyIntelligenceService.instance.loadToday(now: day1);
    expect(cached.aiGenerated, isTrue);
    expect(cached.titleSw, 'Kulinda macho wakati wa joto kali');

    final notices = await NotificationStore().load('tester');
    expect(
      notices.any(
        (n) =>
            n.id == 'daily-ai-2026-11-01' &&
            n.prompt != null &&
            n.prompt!.isNotEmpty,
      ),
      isTrue,
    );
  });
}
