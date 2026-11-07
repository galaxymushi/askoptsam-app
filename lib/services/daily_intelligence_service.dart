import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n.dart';
import 'ai_service.dart';
import 'notification_store.dart';

class DailyBriefing {
  const DailyBriefing({
    required this.dateKey,
    required this.titleSw,
    required this.titleEn,
    required this.bodySw,
    required this.bodyEn,
    required this.actionSw,
    required this.actionEn,
    required this.didYouKnowSw,
    required this.didYouKnowEn,
    required this.questionsSw,
    required this.questionsEn,
    this.aiGenerated = false,
  });

  final String dateKey;
  final String titleSw;
  final String titleEn;
  final String bodySw;
  final String bodyEn;
  final String actionSw;
  final String actionEn;
  final String didYouKnowSw;
  final String didYouKnowEn;
  final List<String> questionsSw;
  final List<String> questionsEn;
  final bool aiGenerated;

  String title(String lang) => lang == 'sw' ? titleSw : titleEn;
  String body(String lang) => lang == 'sw' ? bodySw : bodyEn;
  String action(String lang) => lang == 'sw' ? actionSw : actionEn;
  String didYouKnow(String lang) => lang == 'sw' ? didYouKnowSw : didYouKnowEn;
  List<String> questions(String lang) =>
      lang == 'sw' ? questionsSw : questionsEn;

  String chatPrompt(String lang) => lang == 'sw'
      ? 'Nifafanulie kwa kina kuhusu jambo jipya la leo: "$titleSw". '
            'Ninawezaje kulitekeleza kwenye maisha yangu ya kila siku?'
      : 'Tell me more about today\'s new insight: "$titleEn". '
            'How can I apply it practically every day?';

  Map<String, dynamic> toMap() => {
        'dateKey': dateKey,
        'titleSw': titleSw,
        'titleEn': titleEn,
        'bodySw': bodySw,
        'bodyEn': bodyEn,
        'actionSw': actionSw,
        'actionEn': actionEn,
        'didYouKnowSw': didYouKnowSw,
        'didYouKnowEn': didYouKnowEn,
        'questionsSw': questionsSw,
        'questionsEn': questionsEn,
        'aiGenerated': aiGenerated,
      };

  static DailyBriefing? fromMap(Map<String, dynamic> map, {String? fallbackDateKey}) {
    final titleSw = (map['titleSw'] as String? ?? '').trim();
    final titleEn = (map['titleEn'] as String? ?? '').trim();
    final bodySw = (map['bodySw'] as String? ?? '').trim();
    final bodyEn = (map['bodyEn'] as String? ?? '').trim();
    final actionSw = (map['actionSw'] as String? ?? '').trim();
    final actionEn = (map['actionEn'] as String? ?? '').trim();
    final didYouKnowSw = (map['didYouKnowSw'] as String? ?? '').trim();
    final didYouKnowEn = (map['didYouKnowEn'] as String? ?? '').trim();

    if (titleSw.isEmpty ||
        titleEn.isEmpty ||
        bodySw.isEmpty ||
        bodyEn.isEmpty ||
        actionSw.isEmpty ||
        actionEn.isEmpty) {
      return null;
    }

    final qSw = ((map['questionsSw'] as List?) ?? const [])
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final qEn = ((map['questionsEn'] as List?) ?? const [])
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return DailyBriefing(
      dateKey: (map['dateKey'] as String? ?? fallbackDateKey ?? '').trim(),
      titleSw: titleSw,
      titleEn: titleEn,
      bodySw: bodySw,
      bodyEn: bodyEn,
      actionSw: actionSw,
      actionEn: actionEn,
      didYouKnowSw: didYouKnowSw.isEmpty ? actionSw : didYouKnowSw,
      didYouKnowEn: didYouKnowEn.isEmpty ? actionEn : didYouKnowEn,
      questionsSw: qSw.isEmpty
          ? [
              'Nifanye nini kuhusu $titleSw?',
              'Dalili gani za macho zinahitaji daktari haraka?',
              'Chakula gani kinasaidia macho yangu leo?',
            ]
          : qSw,
      questionsEn: qEn.isEmpty
          ? [
              'What should I do about $titleEn?',
              'Which eye symptoms need a doctor urgently?',
              'What foods best support my eyes today?',
            ]
          : qEn,
      aiGenerated: map['aiGenerated'] as bool? ?? false,
    );
  }
}

/// Autonomous daily intelligence engine. Every calendar day it brings a new
/// bilingual discovery, practical challenge, "Did You Know?" insight and smart
/// starter questions — upgrading deterministically seeded daily content with
/// live generation from AskOptSam's AI brain whenever connected.
class DailyIntelligenceService {
  DailyIntelligenceService._();

  static final DailyIntelligenceService instance = DailyIntelligenceService._();

  static const _cachePrefix = 'asksam_daily_briefing_v1_';
  static const _historyKey = 'asksam_daily_history_v1';

  static String dateKeyFor(DateTime day) {
    final y = day.year.toString().padLeft(4, '0');
    final m = day.month.toString().padLeft(2, '0');
    final d = day.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Deterministic daily synthesis so every calendar day immediately has its
  /// own fresh topic, action challenge and smart questions even offline.
  static DailyBriefing seedForDay(DateTime day, {int variantOffset = 0}) {
    final utcDay = DateTime.utc(day.year, day.month, day.day);
    final dayIndex =
        utcDay.difference(DateTime.utc(2024, 1, 1)).inDays.abs() + variantOffset;
    final seed = _seeds[dayIndex % _seeds.length];
    final secondSeed = _seeds[(dayIndex * 7 + 3) % _seeds.length];
    final thirdSeed = _seeds[(dayIndex * 11 + 5) % _seeds.length];

    final qSw = <String>{
      ...seed.questionsSw,
      secondSeed.questionsSw.first,
      thirdSeed.questionsSw.last,
    }.take(4).toList();

    final qEn = <String>{
      ...seed.questionsEn,
      secondSeed.questionsEn.first,
      thirdSeed.questionsEn.last,
    }.take(4).toList();

    return DailyBriefing(
      dateKey: dateKeyFor(day),
      titleSw: seed.titleSw,
      titleEn: seed.titleEn,
      bodySw: seed.bodySw,
      bodyEn: seed.bodyEn,
      actionSw: seed.actionSw,
      actionEn: seed.actionEn,
      didYouKnowSw: secondSeed.didYouKnowSw,
      didYouKnowEn: secondSeed.didYouKnowEn,
      questionsSw: qSw,
      questionsEn: qEn,
      aiGenerated: false,
    );
  }

  Future<DailyBriefing> loadToday({DateTime? now}) async {
    final day = now ?? DateTime.now();
    final key = dateKeyFor(day);
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_cachePrefix$key');
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = Map<String, dynamic>.from(jsonDecode(raw) as Map);
        final parsed = DailyBriefing.fromMap(decoded, fallbackDateKey: key);
        if (parsed != null) return parsed;
      } catch (_) {}
    }
    return seedForDay(day);
  }

  /// Autonomously generates or refreshes today's briefing using AskOptSam's AI
  /// brain, falling back cleanly to the daily seed if offline.
  Future<DailyBriefing> refreshWithAi({
    DateTime? now,
    bool forceNew = false,
    Future<String> Function(String prompt)? aiCompleter,
  }) async {
    final day = now ?? DateTime.now();
    final key = dateKeyFor(day);
    final prefs = await SharedPreferences.getInstance();

    if (!forceNew) {
      final existingRaw = prefs.getString('$_cachePrefix$key');
      if (existingRaw != null && existingRaw.isNotEmpty) {
        try {
          final decoded =
              Map<String, dynamic>.from(jsonDecode(existingRaw) as Map);
          final existing = DailyBriefing.fromMap(decoded, fallbackDateKey: key);
          if (existing != null && existing.aiGenerated) {
            return existing;
          }
        } catch (_) {}
      }
    }

    final history = prefs.getStringList(_historyKey) ?? <String>[];
    final prompt = _buildAiPrompt(key, history, forceNew: forceNew);

    try {
      String rawReply;
      if (aiCompleter != null) {
        rawReply = await aiCompleter(prompt);
      } else if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) {
        final fallback = forceNew
            ? seedForDay(day, variantOffset: history.length + 1)
            : await loadToday(now: day);
        await _cache(prefs, key, fallback);
        return fallback;
      } else {
        if (!AiService.instance.configured ||
            !await AiService.instance.hasConnection()) {
          final fallback = forceNew
              ? seedForDay(day, variantOffset: DateTime.now().second + 1)
              : await loadToday(now: day);
          await _cache(prefs, key, fallback);
          return fallback;
        }
        rawReply = await AiService.instance
            .completePrompt(prompt, lang: 'sw')
            .timeout(const Duration(seconds: 25));
      }

      final parsed = parseAiResponse(rawReply, dateKey: key);
      if (parsed != null) {
        await _cache(prefs, key, parsed);
        final updatedHistory = <String>{
          parsed.titleSw,
          ...history,
        }.take(25).toList();
        await prefs.setStringList(_historyKey, updatedHistory);
        return parsed;
      }
    } catch (_) {
      // Fallback to deterministic daily seed when offline or AI times out.
    }

    final fallback = forceNew
        ? seedForDay(day, variantOffset: history.length + 1)
        : await loadToday(now: day);
    await _cache(prefs, key, fallback);
    return fallback;
  }

  Future<void> _cache(
    SharedPreferences prefs,
    String key,
    DailyBriefing briefing,
  ) async {
    await prefs.setString('$_cachePrefix$key', jsonEncode(briefing.toMap()));
  }

  /// Syncs today's autonomous discovery into the user's notification feed so
  /// they receive one fresh notification every calendar day.
  Future<DailyBriefing> syncDailyNotice(
    String uid, {
    required String language,
    bool includeDailyTip = true,
    DateTime? now,
    Future<String> Function(String prompt)? aiCompleter,
  }) async {
    final day = now ?? DateTime.now();
    final briefing = await refreshWithAi(now: day, aiCompleter: aiCompleter);
    if (includeDailyTip) {
      final s = Strings(language);
      await NotificationStore().addOnce(
        uid,
        id: 'daily-ai-${briefing.dateKey}',
        kind: NoticeKind.tip,
        title: s.get('noticeDailyAiTitle'),
        body: '${briefing.title(language)} — ${briefing.action(language)}',
        prompt: briefing.chatPrompt(language),
      );
    }
    return briefing;
  }

  static DailyBriefing? parseAiResponse(
    String raw, {
    required String dateKey,
  }) {
    final start = raw.indexOf('{');
    final end = raw.lastIndexOf('}');
    if (start < 0 || end <= start) return null;
    final slice = raw.substring(start, end + 1);
    try {
      final map = Map<String, dynamic>.from(jsonDecode(slice) as Map);
      map['dateKey'] = dateKey;
      map['aiGenerated'] = true;
      return DailyBriefing.fromMap(map, fallbackDateKey: dateKey);
    } catch (_) {
      return null;
    }
  }

  static String _buildAiPrompt(
    String dateKey,
    List<String> recentTitles, {
    bool forceNew = false,
  }) {
    final avoid = recentTitles.isEmpty
        ? 'None'
        : recentTitles.take(10).join('; ');
    return '''
Generate a brand-new daily eye health & vision intelligence briefing for date $dateKey${forceNew ? ' (fresh angle)' : ''}.
Do NOT repeat these recent topics: $avoid.
Return ONLY a valid JSON object with these exact keys (both Kiswahili and English):
{
  "titleSw": "Short catchy Kiswahili title (max 7 words)",
  "titleEn": "Short catchy English title (max 7 words)",
  "bodySw": "2-3 clear, practical sentences in Kiswahili explaining this eye/vision insight for everyday life in East Africa.",
  "bodyEn": "2-3 clear, practical sentences in English explaining this eye/vision insight.",
  "actionSw": "1-sentence practical action challenge the user can do today in Kiswahili.",
  "actionEn": "1-sentence practical action challenge the user can do today in English.",
  "didYouKnowSw": "1 surprising scientific fact about the eye in Kiswahili.",
  "didYouKnowEn": "1 surprising scientific fact about the eye in English.",
  "questionsSw": ["Swali la 1?", "Swali la 2?", "Swali la 3?"],
  "questionsEn": ["Question 1?", "Question 2?", "Question 3?"]
}
''';
  }

  static const _seeds = <DailyBriefing>[
    DailyBriefing(
      dateKey: '',
      titleSw: 'Maji ya mwili na filamu ya machozi',
      titleEn: 'Hydration and your tear film',
      bodySw:
          'Uso wa jicho umefunikwa na tabaka nyembamba la machozi linalolinda kornea na kufanya uoni uwe mkali. Mwili ukipungukiwa maji wakati wa joto, machozi hukauka haraka na kuleta hisia ya mchanga.',
      bodyEn:
          'The surface of your eye is coated by a thin tear film that protects the cornea and keeps vision sharp. When you are dehydrated on hot days, tears evaporate faster and cause a gritty sensation.',
      actionSw:
          'Kunywa glasi moja ya maji kila unapoanza kipindi kirefu cha kutumia simu au kompyuta leo.',
      actionEn:
          'Drink a full glass of water before starting any long phone or computer session today.',
      didYouKnowSw:
          'Filamu ya machozi ina tabaka tatu: mafuta, maji na ute — tabaka la mafuta linazuia machozi yasikauke upeponi.',
      didYouKnowEn:
          'Your tear film has three layers — oil, water and mucus — and the outer oil layer stops tears from evaporating in the wind.',
      questionsSw: [
        'Kwa nini macho yangu yanatoa machozi mengi upeponi?',
        'Dalili za macho makavu ni zipi na yanatibiwaje?',
        'Vinywaji gani vinasaidia afya ya macho?',
      ],
      questionsEn: [
        'Why do my eyes water so much in the wind?',
        'What are the signs of dry eyes and how are they treated?',
        'Which drinks and foods best support tear health?',
      ],
    ),
    DailyBriefing(
      dateKey: '',
      titleSw: 'Mwanga wa asubuhi na mzunguko wa macho',
      titleEn: 'Morning daylight and eye rhythm',
      bodySw:
          'Seli maalum kwenye retina hutambua mwanga wa asili wa asubuhi ili kupanga saa ya mwili na ubora wa usingizi wa usiku. Mwanga wa nje pia husaidia macho kupumzika kutokana na umbali mfupi wa ndani.',
      bodyEn:
          'Special cells in your retina sense natural morning light to calibrate your body clock and night sleep. Outdoor distance viewing also relaxes the focusing muscle inside the eye.',
      actionSw:
          'kaa au tembea nje kwenye mwanga wa asili kwa dakika 10 asubuhi bila kutazama skrini.',
      actionEn:
          'Spend 10 minutes outdoors in natural morning light without looking at a screen.',
      didYouKnowSw:
          'Misuli ya ndani ya jicho (ciliary muscle) inapumzika kabisa tu unapotazama vitu vilivyo mbali zaidi ya mita sita.',
      didYouKnowEn:
          'The focusing muscle inside your eye only relaxes completely when you look at objects more than six metres away.',
      questionsSw: [
        'Mwanga wa jua wa asubuhi unasaidiaje macho ya watoto?',
        'Kwa nini macho huchoka nikiangalia simu kitandani?',
        'Ni muda gani mzuri wa kuvaa miwani ya jua?',
      ],
      questionsEn: [
        'How does morning daylight protect children\'s vision?',
        'Why do my eyes ache when I use my phone in bed?',
        'What time of day are sunglasses most important?',
      ],
    ),
    DailyBriefing(
      dateKey: '',
      titleSw: 'Kiyoyozi, feni na unyevu wa jicho',
      titleEn: 'Airflow, fans and eye moisture',
      bodySw:
          'Upepo wa feni au kiyoyozi unaopiga moja kwa moja usoni huongeza uvukizi wa machozi mara mbili zaidi. Hii huacha jicho likiwa jekundu na lenye uchovu hata kama hulitumii kwa kazi ngumu.',
      bodyEn:
          'Direct airflow from a fan or air-conditioner aimed at your face doubles tear evaporation. That leaves eyes red and tired even during light work.',
      actionSw:
          'Rekebisha feni au kiyoyozi leo ili upepo usipige moja kwa moja usoni au machoni pako.',
      actionEn:
          'Angle fans or air vents away from your face today so air does not blow straight into your eyes.',
      didYouKnowSw:
          'Kufumba macho kwa ukamilifu (kope za juu kugusa za chini) ndiko kunakosambaza mafuta ya kulinda jicho.',
      didYouKnowEn:
          'Only a complete blink — where the upper lid touches the lower lid — spreads protective oils across the eye.',
      questionsSw: [
        'Ninawezaje kulinda macho nikiwa kwenye ofisi yenye AC?',
        'Matone gani ya kulowesha macho ni salama kutumia?',
        'Kwa nini macho yanawasha jioni baada ya kazi?',
      ],
      questionsEn: [
        'How can I protect my eyes in an air-conditioned room?',
        'Which lubricating eye drops are safe for daily use?',
        'Why do my eyes itch in the evening after work?',
      ],
    ),
    DailyBriefing(
      dateKey: '',
      titleSw: 'Rangi za vyakula zinazolinda macula',
      titleEn: 'Colorful foods that shield the macula',
      bodySw:
          'Sehemu ya katikati ya retina (macula) inatumia rangi asilia za lutein na zeaxanthin kama "miwani ya ndani" kuchuja mwanga mkali. Mboga za kijani kibichi, mahindi ya njano na mayai huongeza kinga hii.',
      bodyEn:
          'The center of your retina (the macula) uses natural pigments called lutein and zeaxanthin like internal sunglasses. Dark leafy greens, yellow maize and egg yolks replenish this shield.',
      actionSw:
          'Ongeza mboga za majani za kijani kibichi au yai kwenye mlo wako wa leo.',
      actionEn:
          'Include a serving of dark green leafy vegetables or an egg in your meal today.',
      didYouKnowSw:
          'Mwili wa binadamu hauwezi kutengeneza lutein wenyewe — lazima ipatikane moja kwa moja kwenye chakula.',
      didYouKnowEn:
          'The human body cannot make lutein on its own — it must come entirely from the food you eat.',
      questionsSw: [
        'Vyakula gani vya Tanzania vina lutein nyingi zaidi?',
        'Macula ya jicho ina kazi gani kwenye uoni?',
        'Je, virutubisho vya vitamini vinaweza kurudisha uoni?',
      ],
      questionsEn: [
        'Which everyday local foods are richest in lutein?',
        'What does the macula do for my central vision?',
        'Can vitamin supplements improve eyesight?',
      ],
    ),
    DailyBriefing(
      dateKey: '',
      titleSw: 'Ukubwa wa maandishi na mkazo wa macho',
      titleEn: 'Font size and squinting strain',
      bodySw:
          'Kusoma maandishi madogo sana kwenye simu kunakulazimisha kukaza kope na kusogeza simu karibu mno. Tabia hii huleta maumivu ya paji la uso na uchovu wa misuli ya macho.',
      bodyEn:
          'Reading tiny text on a phone forces you to squint and pull the screen closer. Over an hour, that constant muscle tension triggers forehead headaches and eye fatigue.',
      actionSw:
          'Ongeza ukubwa wa maandishi kwenye simu yako kwa hatua moja leo ili usome bila kukaza macho.',
      actionEn:
          'Increase your phone\'s text size by one step today so you can read comfortably at arm\'s length.',
      didYouKnowSw:
          'Ukijikuta unakunja uso unaposoma simu, ni ishara kwamba maandishi ni madogo au unahitaji kipimo cha miwani.',
      didYouKnowEn:
          'If you catch yourself squinting at your phone, either the text is too small or your eyes need a refraction check.',
      questionsSw: [
        'Dalili zipi zinaonyesha kuwa ninahitaji miwani ya kusomea?',
        'Umbali gani ni sahihi kati ya macho na simu?',
        'Kwa nini kichwa kinauma baada ya kusoma kwenye simu?',
      ],
      questionsEn: [
        'What are the early signs that I need reading glasses?',
        'What is the healthiest distance to hold my phone?',
        'Why do I get a headache after reading on my phone?',
      ],
    ),
    DailyBriefing(
      dateKey: '',
      titleSw: 'Usafi wa kope na tezi za mafuta',
      titleEn: 'Eyelid hygiene and oil glands',
      bodySw:
          'Kwenye kingo za kope kuna tezi ndogo zinazotoa mafuta muhimu kwa machozi. Vumbi, jasho na vipodozi visivyooshwa vizuri vinaweza kuziba tezi hizo na kusababisha uvimbe wa kope (stye).',
      bodyEn:
          'Tiny glands along your eyelid margins secrete the oil that keeps tears stable. Dust, sweat and unwashed cosmetics can clog these glands and trigger styes or dry eyes.',
      actionSw:
          'Unapoosha uso leo usiku, safisha kwa upole kingo za kope kwa maji safi ya uvuguvugu.',
      actionEn:
          'When washing your face tonight, gently rinse your closed eyelids with clean lukewarm water.',
      didYouKnowSw:
          'Kitambaa chenye uvuguvugu juu ya macho yaliyofumbwa kwa dakika 5 husaidia kuyeyusha mafuta yaliyoganda kwenye kope.',
      didYouKnowEn:
          'A warm compress over closed eyes for 5 minutes softens blocked oils in the eyelid glands naturally.',
      questionsSw: [
        'Nifanye nini kope ya jicho ikivimba (stye)?',
        'Kwa nini haifai kutumbua uvimbe kwenye kope?',
        'Ninawezaje kusafisha kope zangu kwa usalama?',
      ],
      questionsEn: [
        'What should I do if I develop a stye on my eyelid?',
        'Why should you never squeeze a bump on your eyelid?',
        'How do I clean my eyelids safely at home?',
      ],
    ),
    DailyBriefing(
      dateKey: '',
      titleSw: 'Ulinzi wa macho wakati wa kazi za nyumbani',
      titleEn: 'Eye safety during everyday tasks',
      bodySw:
          'Majeraha mengi ya kornea hutokea nyumbani wakati wa kukata kuni, kupuliza dawa za wadudu, au kufanya ujenzi mdogo bila miwani ya kinga. Chembe ndogo inayoruka kwa kasi inaweza kukwaruza jicho.',
      bodyEn:
          'Most corneal injuries happen at home while chopping wood, spraying cleaners, or doing small repairs without protective glasses. A single fast-flying particle can scratch the cornea.',
      actionSw:
          'Vaa miwani ya kinga au miwani ya jua unapofagia vumbi kali, kukata miti au kutumia kemikali leo.',
      actionEn:
          'Wear protective glasses whenever sweeping heavy dust, hammering, or handling sprays today.',
      didYouKnowSw:
          'Kornea ndiyo sehemu yenye neva nyingi za hisia kuliko ngozi — ndiyo maana hata chembe ndogo ya vumbi inauma sana.',
      didYouKnowEn:
          'The cornea has hundreds of times more pain receptors per square millimetre than skin — which is why a tiny speck hurts so much.',
      questionsSw: [
        'Huduma ya kwanza ni ipi kitu kikiingia jichoni?',
        'Kwa nini ni hatari kusugua jicho lenye mchanga?',
        'Kemikali ikirukia jichoni nifanye nini haraka?',
      ],
      questionsEn: [
        'What is the right first aid when something gets in my eye?',
        'Why is rubbing a gritty eye dangerous?',
        'What should I do immediately if a chemical splashes in my eye?',
      ],
    ),
    DailyBriefing(
      dateKey: '',
      titleSw: 'Shinikizo la damu na mishipa ya retina',
      titleEn: 'Blood pressure and retinal vessels',
      bodySw:
          'Retina ndiyo sehemu pekee ya mwili ambapo daktari anaweza kuona mishipa ya damu moja kwa moja bila upasuaji. Shinikizo la juu la damu na sukari huathiri mishipa hii kimyakimya.',
      bodyEn:
          'The retina is the only place in the body where blood vessels can be viewed directly without surgery. High blood pressure and blood sugar quietly affect these delicate vessels.',
      actionSw:
          'Punguza chumvi ya ziada mezani leo na fanya matembezi ya dakika 20 kusaidia mzunguko wa damu.',
      actionEn:
          'Skip extra table salt today and take a brisk 20-minute walk to support healthy circulation.',
      didYouKnowSw:
          'Kipimo cha retina kinaweza kuonyesha dalili za shinikizo la damu hata kabla mtu hajapata maumivu yoyote.',
      didYouKnowEn:
          'A retinal exam can reveal signs of high blood pressure before a person feels any symptoms at all.',
      questionsSw: [
        'Shinikizo la damu linaathirije uoni wangu?',
        'Kipimo cha fundus (retina) kinafanywaje?',
        'Mwenye kisukari au presha apime macho mara ngapi?',
      ],
      questionsEn: [
        'How does high blood pressure affect my eyesight?',
        'What happens during a retinal fundus examination?',
        'How often should someone with diabetes or hypertension check their eyes?',
      ],
    ),
    DailyBriefing(
      dateKey: '',
      titleSw: 'Michezo na ulinzi wa macho',
      titleEn: 'Sports and protecting your eyes',
      bodySw:
          'Mpira, kriketi na mikikimiki huweza kugusa jicho kwa nguvu na kusababisha majeraha ya haraka yasiyoonekana mara moja. Glasi za michezo za polycarbonate ni nyepesi na huvunjika kwa shime — ndizo zinazosaidia.',
      bodyEn:
          'A ball, a bat or an elbow can hit the eye with force and cause damage you do not notice straight away. Polycarbonate sports goggles are light and resist impact — that is what protects you.',
      actionSw:
          'Weka glasi za michezo kwenye mfuko wako wiki hii ukiwa na nia ya kucheza mpira au kukata nyasi.',
      actionEn:
          'Pack sports goggles this week if you plan any ball game or garden work.',
      didYouKnowSw:
          'Majeraha ya macho ndiyo sababu kuu ya upofu kwa vijana wanaoshiriki michezo bila kinga.',
      didYouKnowEn:
          'Eye injuries are a leading cause of blindness in young people who play sport without protection.',
      questionsSw: [
        'Glasi gani za michezo zinalinda macho kweli?',
        'Nifanye nini kama mpira unagusa jicho?',
        'Je, miwani ya kawaida inatoshea kucheza mpira?',
      ],
      questionsEn: [
        'Which sports goggles actually protect the eyes?',
        'What should I do if a ball hits me in the eye?',
        'Are ordinary glasses enough for playing ball?',
      ],
    ),
    DailyBriefing(
      dateKey: '',
      titleSw: 'Macho nyesi: msukumo wa allergeni',
      titleEn: 'Watery eyes: when allergies strike',
      bodySw:
          'Vumburi la nyasi, pua za mti na vumbi vya nyumbani huongeza histamine na kuleta macho yenye kuwaka, kusugua na machozi mengi. Kusugua huongeza mzio na kufanya hali kuwa mbaya zaidi.',
      bodyEn:
          'Grass pollen, tree pollen and household dust trigger histamine, which makes eyes burn, itch and stream tears. Rubbing raises the histamine load and makes the flare-up worse.',
      actionSw:
          'Nawa uso wako na macho kwa maji baridi kabla ya kulala leo ili kupunguza vumbi lililoshika macho yako.',
      actionEn:
          'Wash your face and eyes with cool water before bed tonight to clear the dust trapped on them.',
      didYouKnowSw:
          'Machozi yanayotiririka ni njia ya asili ya kuosha vumbi kutoka kwenye uso wa jicho.',
      didYouKnowEn:
          'Tearing up is the eye\'s own natural way of washing dust off its surface.',
      questionsSw: [
        'Kwa nini macho yangu yanajaa machozi wakati wa kupwa?',
        'Naweza kutumia dawa gani za mzio za macho?',
        'Je, mzio wa macho unaweza kuharibu uoni?',
      ],
      questionsEn: [
        'Why do my eyes stream during pollen season?',
        'Which allergy eye drops are safe to use?',
        'Can eye allergies damage my vision?',
      ],
    ),
    DailyBriefing(
      dateKey: '',
      titleSw: 'Usafi wa lenzi za macho',
      titleEn: 'Contact lens hygiene',
      bodySw:
          'Kulala ukiwa na lenzi, kuzioshea kwa maji ya bomba au kuzivaa zaidi ya muda uliopangwa huweza kusababisha maambukizi ya kornea yanayoanza kwa maumivu makali na kuonekana kwa mwanga. Hali hii ni dharura ya macho.',
      bodyEn:
          'Sleeping in lenses, rinsing them with tap water or wearing them past their limit can cause a corneal infection that begins with severe pain and light sensitivity. That is an eye emergency.',
      actionSw:
          'Chukua lenzi kabla ya kulala usiku huu, ukague tarehe ya kuisha zao na ukae bila hizo kwa saa nane angalau.',
      actionEn:
          'Take your lenses off before sleeping tonight, check their expiry date, and keep them out for at least eight hours.',
      didYouKnowSw:
          'Maji ya bomba hutoa ameba ndogo zinazoweza kuingia kwenye jicho na kuharibu kornea haraka.',
      didYouKnowEn:
          'Tap water carries tiny amoebas that can enter the eye and destroy the cornea quickly.',
      questionsSw: [
        'Naweza kulala na lenzi za macho?',
        'Nawaaje na kuhifadhi lenzi za macho?',
        'Dalili gani zinamaanisha lazima nitoe lenzi mara moja?',
      ],
      questionsEn: [
        'Can I sleep in my contact lenses?',
        'How should I clean and store my lenses?',
        'Which symptoms mean I must remove a lens immediately?',
      ],
    ),
    DailyBriefing(
      dateKey: '',
      titleSw: 'Usingizi na skrini kabla ya kulala',
      titleEn: 'Sleep and screens before bed',
      bodySw:
          'Kutazama skrini karibu na muda wa kulala hulazimisha macho kubaki yamefungwa kwa karibu na kupumzika kidogo, huku mwili ukichelewa kutoa melatonin. Hii huleta usingizi dhaifu na macho yaliyokauka asubuhi.',
      bodyEn:
          'Looking at a screen close to bedtime keeps the eyes locked in near focus with little rest, while the body delays melatonin. The result is broken sleep and dry, tired eyes in the morning.',
      actionSw:
          'Weka simu chini dakika 30 kabla ya kulala leo na tazama kitu kilicho mbali kwa dakika chache badala yake.',
      actionEn:
          'Put the phone down 30 minutes before bed tonight and look at something far away instead.',
      didYouKnowSw:
          'Kutazama skrini hupunguza kufunga macho mara nne hadi mara tano, jambo linaloongeza ukauka wa macho.',
      didYouKnowEn:
          'Screen use cuts your blink rate by four to five times, which is a major cause of dryness.',
      questionsSw: [
        'Kwa nini macho yangu ni makavu asubuhi baada ya kusoma simu usiku?',
        'Je, mwanga wa skrini unaharibu usingizi?',
        'Ni muda gani mzuri wa kutumia simu kabla ya kulala?',
      ],
      questionsEn: [
        'Why are my eyes dry in the morning after phone use at night?',
        'Does screen light really damage sleep?',
        'When is the last sensible time to use a phone before bed?',
      ],
    ),
    DailyBriefing(
      dateKey: '',
      titleSw: 'Kuzuia macho kuwa myopia kwa watoto',
      titleEn: 'Preventing short-sightedness in children',
      bodySw:
          'Myopia (kuona mbali kwa vibaya) inaongezeka kwa kasi kwa watoto wanaokaa ndani muda mrefu bila mchezo wa nje. Mwanga wa asili wa nje na kuona mbali mara kwa mara hushusha hatari yake.',
      bodyEn:
          'Myopia (difficulty seeing far away) is rising quickly among children who spend long hours indoors. Natural outdoor light and regular distance viewing lower the risk.',
      actionSw:
          'Toa mtoto wako dakika 30 za kucheza nje bila skrini leo — mchezo wa nje ndio kinga bora zaidi.',
      actionEn:
          'Give your child 30 minutes of screen-free outdoor play today — outdoor time is the best protection we have.',
      didYouKnowSw:
          'Myopia isiyo dhibitiwa inaweza kuongezeka hadi hatari ya kutoa retina na glaucoma miaka baadaye.',
      didYouKnowEn:
          'Untreated myopia keeps progressing and raises the later risk of retinal detachment and glaucoma.',
      questionsSw: [
        'Kwa nini watoto wanaozidi kuwa myopia leo?',
        'Mwanga wa nje unasaidiaje macho ya mtoto?',
        'Myopia inadhibitiwaje?',
      ],
      questionsEn: [
        'Why are more children short-sighted today?',
        'How does outdoor light help a child\'s eyes?',
        'How is myopia controlled as it progresses?',
      ],
    ),
    DailyBriefing(
      dateKey: '',
      titleSw: 'Dalili zinazohitaji daktari mara moja',
      titleEn: 'Warning signs that need a doctor now',
      bodySw:
          'Maumivu ghafla makali, kupoteza kuona ghafu, kivuli kwenye uoni kama kuzuiya dirisha, mabaka yanayotembea mengi yameongezeka au jicho lenye majeraha — dalili hizi si za kusubiri; ni dharura ya macho.',
      bodyEn:
          'Sudden severe pain, a sudden drop in vision, a curtain-like shadow across sight, a jump in flashing floaters or an injured eye — these are not things to wait on; they are eye emergencies.',
      actionSw:
          'Andika kwenye simu yako leo dalili tatu za dharura: maumivu makali, kupoteza kuona ghafu na kivuli kwenye uoni.',
      actionEn:
          'Today, note the three red flags on your phone: severe pain, sudden vision loss and a shadow in the vision.',
      didYouKnowSw:
          'Kupoteza kuona kwa glaucoma huanza kwa kupoteza pembe za nje — mtu haatambui kabla si kupoteza makali.',
      didYouKnowEn:
          'Glaucoma vision loss starts at the edges, so a person rarely notices until it is advanced.',
      questionsSw: [
        'Nini cha kufanya kama najisikia kivuli kwenye uoni?',
        'Je, mabaka yanayotembea ni hatari?',
        'Kupoteza kuona ghafu ni dharura kiasi gani?',
      ],
      questionsEn: [
        'What should I do if I see a shadow in my vision?',
        'Are floating spots dangerous?',
        'How urgent is sudden vision loss?',
      ],
    ),
    DailyBriefing(
      dateKey: '',
      titleSw: 'Kuchagua miwani ya jua',
      titleEn: 'Choosing sunglasses that work',
      bodySw:
          'Miwani ya jua inayozuia UV 100% hulinnda kornea na kuzuia katarakti na makosa ya jua. Rangi nyeusi si alama ya ulinzi — kagua lebo ya UV400, na chagua ile inayofunika pembe za macho.',
      bodyEn:
          'Sunglasses that block 100% of UV rays protect the cornea and help prevent cataracts and sun-related eye damage. Dark lenses are not the guarantee — look for the UV400 label and a wraparound fit.',
      actionSw:
          'Angalia kasha yako la miwani leo: kuna alama ya UV400 au asiyokuwa na maana yoyote kwako?',
      actionEn:
          'Check your sunglass case today: does it carry a real UV400 rating, or is it just dark glass?',
      didYouKnowSw:
          'Macho ya mtoto huchukua UV nyingi mara mbili zaidi ya ya mtu mzima kwa sababu kioo chao kina wazi zaidi.',
      didYouKnowEn:
          'A child\'s eye takes in roughly twice the UV of an adult eye because the lens is far clearer.',
      questionsSw: [
        'Miwani ya jua ya bei nafuu inazuiya UV?',
        'Watoto wanahitaji miwani ya jua?',
        'Kiasi gani cha ulinzi wa UV ndicho cha kweli?',
      ],
      questionsEn: [
        'Do cheap sunglasses really block UV?',
        'Do children need sunglasses too?',
        'What UV protection level is the real one?',
      ],
    ),
    DailyBriefing(
      dateKey: '',
      titleSw: 'Mpangilio wa meza ya kompyuta',
      titleEn: 'Setting up your desk',
      bodySw:
          'Skrini iliyo juu sana au chini sana, umbali mfupi na kuinama mbele hulazimisha shingo na macho kufanya kazi kwa mkazo. Skrini iwe chini kidogo ya macho, umbali wa mkono, na uangalie mbali kila dakika 20.',
      bodyEn:
          'A screen that is too high or too low, sitting too close, and leaning forward all strain the neck and eyes together. Keep the screen slightly below eye level, an arm\'s length away, and look far away every 20 minutes.',
      actionSw:
          'Rekebisha kiti na skrini yako leo hivi: macho yako yawe juu kidogo ya skrini kwa sentensi chache.',
      actionEn:
          'Adjust your chair and screen today: your eyes should sit a few centimetres above the top of the screen.',
      didYouKnowSw:
          'Wanadamu hufanya macho yawe na mkazo zaidi ya dakika 20 mfululizo bila kujua, kwa sababu kufanya kazi hulazimisha kupunguza kupiga macho.',
      didYouKnowEn:
          'Focused work suppresses blinking, and after about 20 minutes the eye surface starts to dry out without you noticing.',
      questionsSw: [
        'Umbali gani sahihi wa skrini kutoka machoni?',
        'Kwa nini shingo yangu huumu nikifanya kazi na kompyuta?',
        'Je, miwani ya kompyuta (anti-fatigue) inasaidia?',
      ],
      questionsEn: [
        'What is the right screen distance from my eyes?',
        'Why does my neck ache at the computer?',
        'Do computer (anti-fatigue) glasses really help?',
      ],
    ),
  ];
}
