enum FactArt { eye, screen, sun, food, drop, clock, moon, smoke }

class EyeFact {
  const EyeFact({
    required this.id,
    required this.art,
    required this.titleSw,
    required this.titleEn,
    required this.bodySw,
    required this.bodyEn,
    required this.tipSw,
    required this.tipEn,
    this.explanationSw,
    this.explanationEn,
    this.symptomsSw,
    this.symptomsEn,
    this.actionsSw,
    this.actionsEn,
    this.whenToSeeDoctorSw,
    this.whenToSeeDoctorEn,
  });

  final String id;
  final FactArt art;
  final String titleSw;
  final String titleEn;
  final String bodySw;
  final String bodyEn;
  final String tipSw;
  final String tipEn;
  final String? explanationSw;
  final String? explanationEn;
  final List<String>? symptomsSw;
  final List<String>? symptomsEn;
  final List<String>? actionsSw;
  final List<String>? actionsEn;
  final String? whenToSeeDoctorSw;
  final String? whenToSeeDoctorEn;

  String title(String lang) => lang == 'sw' ? titleSw : titleEn;
  String body(String lang) => lang == 'sw' ? bodySw : bodyEn;
  String tip(String lang) => lang == 'sw' ? tipSw : tipEn;
  String? explanation(String lang) =>
      lang == 'sw' ? explanationSw : explanationEn;
  List<String>? symptoms(String lang) =>
      lang == 'sw' ? symptomsSw : symptomsEn;
  List<String>? actions(String lang) => lang == 'sw' ? actionsSw : actionsEn;
  String? whenToSeeDoctor(String lang) =>
      lang == 'sw' ? whenToSeeDoctorSw : whenToSeeDoctorEn;
}

class EyeFacts {
  EyeFacts._();

  /// One fact per calendar day, so the Library changes every morning.
  static EyeFact forDay(DateTime day) {
    final today = DateTime.utc(day.year, day.month, day.day);
    final days = today.difference(DateTime.utc(2020, 1, 1)).inDays;
    return all[days % all.length];
  }

  /// The facts after today's, in the same daily rotation.
  static List<EyeFact> afterToday(DateTime day, {int count = 6}) {
    final start = all.indexOf(forDay(day));
    return [
      for (var i = 1; i <= count && i < all.length; i++)
        all[(start + i) % all.length],
    ];
  }

  static const all = <EyeFact>[
    EyeFact(
      id: 'rule-20-20-20',
      art: FactArt.screen,
      titleSw: 'Kanuni ya 20-20-20 na Uchovu wa Skrini',
      titleEn: 'The 20-20-20 Rule & Digital Eye Strain',
      bodySw:
          'Kila baada ya dakika 20 za kutumia simu au kompyuta, tazama kitu kilicho umbali wa angalau mita 6 (futi 20) kwa sekunde 20. Hii huilegeza misuli ya ndani ya jicho na kuzuia ukavu na maumivu ya kichwa.',
      bodyEn:
          'Every 20 minutes on a phone or computer, look at something at least 6 metres (20 feet) away for 20 seconds. This releases your focusing muscles and prevents eye dryness and headaches.',
      tipSw: 'Weka kikumbusho cha kengele kila dakika 20 badala ya kusubiri hadi macho yakuume.',
      tipEn: 'Set a 20-minute timer instead of waiting for your eyes to start aching.',
      explanationSw:
          'Unapotazama skrini ya simu au kompyuta, misuli midogo ya jicho (ciliary muscles) inalazimika kukaza bila kupumzika ili picha iwe wazi. Hali hii pia inapunguza kiwango cha kufumba macho kutoka mara 18 kwa dakika hadi mara 6 tu, na kusababisha machozi kukauka kwa kasi mno.',
      explanationEn:
          'When focusing on screens, the internal ciliary muscles stay continually contracted. In addition, your blink rate plummets from 18 times per minute to under 6, causing rapid tear evaporation.',
      symptomsSw: [
        'Macho kuwasha, kuchoma, au kuwa mekundu baada ya muda mrefu wa skrini',
        'Ukungu wa muda unaotokea unapoangalia mbali baada ya kusoma',
        'Maumivu ya paji la uso au shingo',
        'Hisia ya mchanga au jicho kuwa zito na kavu',
      ],
      symptomsEn: [
        'Burning, irritation, or redness after extended screen use',
        'Transient blurred vision when looking up into the distance',
        'Tension headaches across the brow or neck',
        'Gritty, dry, or fatigued feeling in both eyes',
      ],
      actionsSw: [
        'Shikilia simu umbali usiopungua sentimita 35-40 kutoka usoni',
        'Punguza mwangaza wa skrini ili usizidi mwangaza wa chumba ulichomo',
        'Tumia kanuni ya 20-20-20 kila siku bila kuruka',
      ],
      actionsEn: [
        'Hold phones at least 35-40 cm away from your face',
        'Balance screen brightness with ambient room illumination',
        'Practice the 20-20-20 pause consistently throughout your day',
      ],
      whenToSeeDoctorSw:
          'Macho yakibaki na ukungu hata baada ya kupumzika, au maumivu ya kichwa yakirudia kila siku, pima macho kwa daktari kwani unaweza kuhitaji miwani ya kompyuta.',
      whenToSeeDoctorEn:
          'If blurred vision lingers after resting or daily headaches persist, consult an optometrist as you may need dedicated computer lenses.',
    ),
    EyeFact(
      id: 'blinking',
      art: FactArt.eye,
      titleSw: 'Kufumba na Kufumbua Macho',
      titleEn: 'The Physiology of Blinking',
      bodySw:
          'Binadamu hufumba macho wastani wa mara 15–20 kwa dakika. Kufumba kunasambaza safu safi ya machozi juu ya mboni na kuisafisha dhidi ya vumbi na vijidudu.',
      bodyEn:
          'Humans naturally blink 15–20 times a minute. Each blink distributes a fresh tear film over the cornea, lubricating it and washing away debris and microbes.',
      tipSw: 'Ukisikia macho yamekauka au yanachoma, fanya zoezi la kufumba taratibu mara 10 mfululizo.',
      tipEn: 'When eyes feel dry or burning, deliberately blink fully and gently ten times in a row.',
      explanationSw:
          'Kila unapofumba jicho, tezi za kope zinakamua kiasi kidogo cha mafuta asili yanayozuia machozi yasikauke hewani. Kufumba nusu nusu (involuntary incomplete blinks) wakati wa kusoma au skrini husababisha jicho kubaki wazi chini na kukauka vibaya.',
      explanationEn:
          'Every full blink pumps tiny amounts of lipid from the meibomian glands, sealing tears and preventing evaporation. Partial blinking during intense focus leaves the lower cornea dangerously dry.',
      symptomsSw: [
        'Hisia ya changarawe au mchanga machoni',
        'Machozi kutiririka bila sababu (reflex tearing kutokana na ukavu)',
        'Macho kuwasha na kuwa mekundu mchana kutwa',
      ],
      symptomsEn: [
        'Gritty sensation like sand in the eyes',
        'Excessive watering triggered as a reflex to extreme dryness',
        'Chronic redness and irritation throughout the day',
      ],
      actionsSw: [
        'Zingatia kufumba macho kikamilifu (kope za juu ziguse za chini)',
        'Usielekeze feni au upepo wa kiyoyozi moja kwa moja usoni mwako',
      ],
      actionsEn: [
        'Practice complete blinks where top and bottom eyelids meet fully',
        'Avoid pointing fans or air conditioning vents directly at your face',
      ],
      whenToSeeDoctorSw:
          'Ukiona machozi yanashindwa kabisa kuzalishwa au kope zinajikunja na kusugua mboni, muone daktari wa macho mara moja.',
      whenToSeeDoctorEn:
          'If dry discomfort does not improve with conscious blinking or artificial tears, schedule a dry eye evaluation.',
    ),
    EyeFact(
      id: 'uv',
      art: FactArt.sun,
      titleSw: 'Mionzi ya Jua na Miwani ya Kinga',
      titleEn: 'Ultraviolet Radiation & Sunglasses',
      bodySw:
          'Mionzi ya jua ya UV (UVA na UVB) huharibu lenzi ya jicho na sehemu nyeti ya retina kwa miaka mingi. Miwani yenye kinga ya 100% ya UV inalinda uoni wako dhidi ya mtoto wa jicho.',
      bodyEn:
          'Ultraviolet radiation (UVA and UVB) silently damages the eye lens and delicate retina over the years. Sunglasses with 100% UV protection protect your sight from cataracts and tissue damage.',
      tipSw: 'Vaa miwani ya jua hata kukiwa na mawingu; mionzi ya UV hupenya mawinguni hadi asilimia 80.',
      tipEn: 'Wear sunglasses even on overcast days; up to 80% of UV rays penetrate cloud cover.',
      explanationSw:
          'Kupigwa na jua kali bila kinga husababisha ukuaji usio wa kawaida wa kinyama chekundu kwenye kona ya jicho (Pterygium), huongeza hatari ya mtoto wa jicho (Cataract) mapema, na huharibu macula inayohusika na kusoma maandishi madogo.',
      explanationEn:
          'Unprotected solar exposure accelerates pterygium growth (fleshy tissue over the white of the eye), early cataract formation, and photochemical damage to the macular reading center.',
      symptomsSw: [
        'Macho kuuma na kutoa machozi mengi unapokuwa kwenye jua kali',
        'Macho kuwa mekundu sana baada ya kutoka nje',
        'Kukua kwa kinyama au utando kwenye sehemu nyeupe ya jicho',
      ],
      symptomsEn: [
        'Eye soreness and reflex watering under strong sunlight',
        'Severe bloodshot appearance following outdoor activities',
        'Visible fleshy membrane growing across the sclera toward the cornea',
      ],
      actionsSw: [
        'Nunua miwani ya jua yenye lebo halisi ya UV400 au 100% UV Protection',
        'Vaa kofia pana unapotembea au kufanya kazi juani mchana',
      ],
      actionsEn: [
        'Purchase polarized sunglasses verified for UV400 or 100% UV protection',
        'Wear wide-brimmed hats when outdoors during peak sunlight hours',
      ],
      whenToSeeDoctorSw:
          'Ukiona kinyama kinachoota kwenye jicho kinaanza kuelekea kwenye mboni nyeusi, fanya uchunguzi mapema kabla hakijaharibu kioo cha jicho.',
      whenToSeeDoctorEn:
          'If any growth on the eye starts advancing toward the central dark cornea, see an eye specialist without delay.',
    ),
    EyeFact(
      id: 'food',
      art: FactArt.food,
      titleSw: 'Lishe na Vyakula vya Kuimarisha Macho',
      titleEn: 'Nutrition & Eye Health',
      bodySw:
          'Mchicha, matembele, karoti, maboga na samaki hutoa vitamini A, C, E, lutein na omega-3. Virutubisho hivi huilinda retina na kuchelewesha matatizo ya umri.',
      bodyEn:
          'Dark leafy greens, carrots, pumpkin, and fish provide vitamins A, C, E, lutein, and omega-3s. These nutrients fortify the retina and delay age-related vision degeneration.',
      tipSw: 'Weka mboga za majani au vyakula vyenye rangi ya machungwa kwenye mlo wako wa kila siku.',
      tipEn: 'Incorporate deep greens or orange-colored vegetables into at least one meal every day.',
      explanationSw:
          'Vitamini A inatengeneza pigmenti ya rhodopsin inayotuwezesha kuona gizani. Lutein na Zeaxanthin hufanya kazi kama miwani ya ndani ya jicho inayochuja mwanga hatari wa bluu na kuzuia kuzeeka kwa seli za retina.',
      explanationEn:
          'Vitamin A synthesizes rhodopsin pigment needed for low-light vision. Lutein and zeaxanthin act as internal sunglasses, filtering harmful high-energy blue light and guarding retinal cells.',
      symptomsSw: [
        'Kushindwa kuona vizuri jioni au kwenye giza hafifu (nyctalopia)',
        'Ukavu mkali na hisia za macho kuchoka haraka',
      ],
      symptomsEn: [
        'Difficulty adjusting to low light or night blindness (nyctalopia)',
        'Chronic dry eyes and frequent visual exhaustion',
      ],
      actionsSw: [
        'Tumia mboga za asili: mchicha, kisamvu, matembele na mnavu',
        'Kula karoti, maembe, papai na mayai yenye kiini cha njano',
        'Kula samaki (kama dagaa au sato) angalau mara mbili kwa wiki',
      ],
      actionsEn: [
        'Eat indigenous greens: spinach, amaranth, sweet potato leaves',
        'Enjoy orange foods: carrots, sweet potatoes, papaya, and egg yolks',
        'Consume oily fish (sardines, salmon, mackerel) twice weekly for omega-3s',
      ],
      whenToSeeDoctorSw:
          'Mtoto akishindwa kuona vizuri jioni au akiwa na madoa meupe yenye ukavu kwenye jicho (Bitot spots), anahitaji matibabu ya haraka ya vitamini A.',
      whenToSeeDoctorEn:
          'If a child stumbles in dim lighting or develops dry triangular foamy spots on the conjunctiva, seek medical care immediately.',
    ),
    EyeFact(
      id: 'dry-eye',
      art: FactArt.drop,
      titleSw: 'Ugonjwa wa Macho Makavu (Dry Eye Syndrome)',
      titleEn: 'Dry Eye Syndrome & Tear Film Health',
      bodySw:
          'Vumbi, upepo, kiyoyozi na muda mrefu mbele ya skrini hupunguza unyevu wa macho. Macho makavu huleta hisia ya mchanga, kuwaka moto na uoni wa ukungu unaobadilika.',
      bodyEn:
          'Dust, wind, air conditioning, and continuous screen gaze deplete ocular hydration. Dry eye leads to grittiness, burning, and fluctuating blur.',
      tipSw: 'Kunywa maji ya kutosha (lita 2–3) na weka kitambaa cha vuguvugu machoni kwa dakika 5 jioni.',
      tipEn: 'Drink plenty of water (2–3 liters daily) and apply a warm compress over closed eyes for 5 minutes.',
      explanationSw:
          'Safu ya machozi inaundwa na tabaka tatu: mafuta, maji, na uteute. Tezi za kope (Meibomian glands) zikiziba na vumbi au uchafu, safu ya mafuta hupungua na maji ya jicho huvukizwa mara moja na upepo au skrini.',
      explanationEn:
          'The tear film has three layers: oil, water, and mucin. When meibomian glands clog, the protective lipid layer fails, causing instant tear evaporation and painful corneal friction.',
      symptomsSw: [
        'Hisia ya mchanga au kuungua machoni',
        'Macho kutoa machozi mengi yanayotiririka (machozi ya kureact na ukavu)',
        'Macho kuwa mekundu na kushindwa kuangalia mwanga mkali',
      ],
      symptomsEn: [
        'Stinging, burning, or gritty sensation in eyes',
        'Reflex watery tearing when exposed to air or reading',
        'Red eyes and hypersensitivity to room light',
      ],
      actionsSw: [
        'Osha kope kwa maji safi ya uvuguvugu kuondoa uchafu kwenye matundu ya tezi',
        'Tumia matone ya kulowesha (lubricant drops) yasiyo na vihifadhi (preservatives)',
        'Kunywa maji ya kutosha siku nzima',
      ],
      actionsEn: [
        'Clean lid margins gently with warm water to clear blocked gland orifices',
        'Use preservative-free lubricating artificial tears for comfort',
        'Hydrate adequately with plain water throughout the day',
      ],
      whenToSeeDoctorSw:
          'Ikiwa ukavu unaambatana na maumivu makali, usaha, au mboni kuanza kuwa na kovu jeupe, mwone daktari mara moja.',
      whenToSeeDoctorEn:
          'If symptoms escalate to intense pain, purulent discharge, or a cloudy white spot on the cornea, visit an eye specialist promptly.',
    ),
    EyeFact(
      id: 'checkup',
      art: FactArt.clock,
      titleSw: 'Umuhimu wa Vipimo vya Macho vya Mara kwa Mara',
      titleEn: 'Comprehensive Eye Examinations',
      bodySw:
          'Watu wazima wanashauriwa kupima macho kila miaka 1–2, na kila mwaka kwa mwenye kisukari au shinikizo la damu. Magonjwa mengi hatari ya macho huanza kimya bila maumivu.',
      bodyEn:
          'Healthy adults should undergo an eye check every 1–2 years, and annually if living with diabetes or hypertension. Many vision-threatening conditions start with zero pain.',
      tipSw: 'Weka tarehe ya kipimo cha macho kwenye kalenda ya simu yako kama unavyoweka shughuli zingine muhimu.',
      tipEn: 'Schedule your comprehensive eye exam in your calendar just like any other priority appointment.',
      explanationSw:
          'Kipimo cha macho sio tu cha kuona kama unahitaji miwani ya kusoma. Daktari anachunguza ndani ya jicho kwa vifaa maalum ili kuangalia shinikizo la jicho (glaucoma), mshipa wa fahamu wa kuona, na mishipa midogo ya damu ambayo inaweza kuonyesha dalili za kisukari na shinikizo la damu mapema kabisa.',
      explanationEn:
          'A clinical eye examination goes far beyond reading letters on a chart. It evaluates intraocular pressure, optic nerve health, and microvascular circulation, frequently detecting diabetes and hypertension before symptoms show.',
      symptomsSw: [
        'Kupoteza uoni kidogo kidogo bila kuhisi maumivu yoyote',
        'Kupungua kwa uoni wa pembeni bila kugundua mapema',
        'Ugumu wa kusoma herufi ndogo au kuendesha gari usiku',
      ],
      symptomsEn: [
        'Gradual loss of sight without any sensation of pain',
        'Subtle narrowing of peripheral visual fields',
        'Struggling with small print or seeing pedestrians in low light',
      ],
      actionsSw: [
        'Pima macho kila mwaka ukiwa na zaidi ya miaka 40 au historia ya glaucoma kwenye ukoo',
        'Pima watoto kabla hawajaanza masomo ya darasani',
      ],
      actionsEn: [
        'Get screened every year if you are over 40 or have a family history of glaucoma',
        'Have children’s vision evaluated before entering formal schooling',
      ],
      whenToSeeDoctorSw:
          'Usisubiri hadi jicho lianze kuuma au uoni ukapotea ndipo uende hospitali; pima mara kwa mara kuzuia uharibifu wa kudumu.',
      whenToSeeDoctorEn:
          'Never postpone testing until vision declines or pain starts; regular clinical screening is the only safeguard against irreversible vision loss.',
    ),
    EyeFact(
      id: 'sleep',
      art: FactArt.moon,
      titleSw: 'Usingizi, Pumziko na Afya ya Macho',
      titleEn: 'Sleep Quality & Ocular Recovery',
      bodySw:
          'Usingizi wa saa 7–9 huruhusu macho kupumzika na kujisafisha vizuri. Kukosa usingizi wa kutosha husababisha macho kukauka, kuwasha na kuwa mekundu asubuhi.',
      bodyEn:
          'Seven to nine hours of quality sleep allows the eyes to lubricate, rest, and repair cellular tissue. Chronic sleep deprivation leads to morning dryness, redness, and strain.',
      tipSw: 'Weka simu mbali na kitanda angalau dakika 30 kabla ya kulala ili kuruhusu ubongo kutoa homoni ya usingizi.',
      tipEn: 'Put all electronic devices away 30 minutes before sleep to allow your brain to release melatonin naturally.',
      explanationSw:
          'Wakati wa usingizi, kope zikifunga kwa saa kadhaa zinaruhusu seli za kioo cha mbele cha jicho (corneal epithelium) kujijenga upya baada ya vumbi na hewa kavu ya mchana. Mwanga wa bluu kutoka skrini usiku unachanganya homoni ya melatonin na kuvuruga mzunguko wa usingizi mnono.',
      explanationEn:
          'During sleep, the closed eyelid chamber provides constant lubrication, allowing corneal epithelial cells to regenerate after daytime exposure. Screen blue light late at night suppresses melatonin and disrupts deep sleep cycles.',
      symptomsSw: [
        'Macho kuwa mekundu na kuvimba asubuhi unapoamka',
        'Misuli ya kope kupiga piga yenyewe (eyelid myokymia/twitches)',
        'Macho kuchoka haraka sana mara tu unapoanza kazi asubuhi',
      ],
      symptomsEn: [
        'Puffy, bloodshot eyes upon waking',
        'Involuntary muscle twitching in the eyelids (myokymia)',
        'Premature eye fatigue early in your working day',
      ],
      actionsSw: [
        'Lala saa 7 hadi 8 kila usiku kwenye chumba chenye giza na hewa safi',
        'Washa hali ya giza (Night mode) kwenye simu yako kuanzia jioni',
      ],
      actionsEn: [
        'Aim for 7 to 8 hours of uninterrupted sleep in a dark, quiet room',
        'Enable warm night mode or blue light filters on all screens by sunset',
      ],
      whenToSeeDoctorSw:
          'Ikiwa kope zinapiga piga mfululizo kwa wiki nzima bila kukoma au unaona ukungu wa kudumu, wasiliana na daktari.',
      whenToSeeDoctorEn:
          'If persistent eyelid spasms last over a week or accompany facial spasms, seek an eye specialist assessment.',
    ),
    EyeFact(
      id: 'cataract',
      art: FactArt.eye,
      titleSw: 'Mtoto wa Jicho (Katarakti / Cataract)',
      titleEn: 'Cataracts & Lens Clouding',
      bodySw:
          'Mtoto wa jicho ni tatizo la lenzi ya asili ya jicho kupoteza uwazi wake na kuwa na ukungu. Ni tatizo la kawaida kwa watu wa miaka 50+, na hutibiwa kwa upasuaji mdogo wa kisasa unaorudisha uoni.',
      bodyEn:
          'A cataract is the gradual clouding of the eye’s natural crystalline lens. It is common as we age past 50 and is safely cured with modern outpatient surgery restoring clear sight.',
      tipSw: 'Kumbuka: Hakuna matone ya macho au dawa ya asili inayotibu katarakti; upasuaji mdogo ndiyo tiba pekee inayotambuliwa duniani.',
      tipEn: 'Remember: No eye drops or herbal remedies cure cataracts; brief modern surgery is the only scientifically proven cure.',
      explanationSw:
          'Lenzi ya jicho imeundwa kwa protini na maji. Kadiri umri unavyoongezeka, protini hizo zinaanza kugandana pamoja na kufanya lenzi iwe na mawingu kama dirisha lililopigwa na mvuke. Miale ya mwanga inashindwa kupenya moja kwa moja kwenye retina, na kufanya uoni wote uwe na ukungu.',
      explanationEn:
          'The human crystalline lens is made of transparent water and proteins. Over decades, oxidative stress causes these proteins to clump, scattering incoming light and obscuring the retinal image like frosted glass.',
      symptomsSw: [
        'Uoni wa ukungu au moshi ambao haubadiliki ukisafisha miwani',
        'Mwangaza wa taa za magari usiku kuwa mkali kupita kiasi na kutoa miale (halos)',
        'Rangi za vitu kuonekana zimepauka au kugeuka njano',
        'Kuhitaji kubadilisha miwani mara kwa mara bila mafanikio',
      ],
      symptomsEn: [
        'Cloudy, blurred, or dimmed vision that does not improve with lens cleaning',
        'Intolerable glare and halos around oncoming headlights at night',
        'Faded colors appearing yellowed or brownish',
        'Frequent changes in eyeglass prescriptions without satisfactory clarity',
      ],
      actionsSw: [
        'Vaa miwani ya kuzuia mionzi ya jua (UV) kulinda lenzi yako mapema',
        'Dhibiti kiwango cha sukari mwilini kama una kisukari',
        'Usisite kwenda hospitali kufanya upasuaji unapoona ukungu unakuzuia kuona',
      ],
      actionsEn: [
        'Wear UV-rated sunglasses throughout life to slow lens protein aggregation',
        'Maintain tight blood glucose control if diabetic',
        'Consult an ophthalmologist once cataract clouding affects daily tasks',
      ],
      whenToSeeDoctorSw:
          'Ukiona ukungu unakuzuia kusoma, kutembea salama, au kutambua watu mitaani, mwone daktari wa macho kwa ushauri wa upasuaji.',
      whenToSeeDoctorEn:
          'Seek an ophthalmology consultation as soon as cataract fog interferes with reading, driving, or personal independence.',
    ),
    EyeFact(
      id: 'glaucoma',
      art: FactArt.eye,
      titleSw: 'Glaucoma: Shinikizo la Ndani ya Jicho',
      titleEn: 'Glaucoma: The Silent Sight Thief',
      bodySw:
          'Glaucoma huanza kimya bila maumivu na kuua polepole nyuzi za mshipa wa fahamu wa kuona. Ukigundulika mapema kwa kupima shinikizo, matone huzuia upofu kabisa.',
      bodyEn:
          'Glaucoma silently damages optic nerve fibers, stealing peripheral vision without pain. Early detection through regular eye pressure checks prevents blindness.',
      tipSw: 'Mtu yeyote mwenye zaidi ya miaka 40 au mwenye ndugu wa karibu mwenye glaucoma anapaswa kupima shinikizo la jicho kila mwaka.',
      tipEn: 'Anyone aged 40+ or with a direct family history of glaucoma must undergo annual eye pressure tonometry.',
      explanationSw:
          'Jicho linazalisha majimaji maalum (aqueous humor) yanayozunguka na kutoka kupitia mifereji midogo ya ndani. Mifereji hii ikiziba, shinikizo la ndani linapanda (high IOP) na kubana mshipa mkuu wa fahamu (optic nerve). Nyuzi zikifa, uoni wa pembeni unapotea taratibu hadi unabaki kama unatazama kupitia bomba (tunnel vision).',
      explanationEn:
          'The eye secretes clear aqueous fluid that drains through delicate trabecular meshwork. If drainage slows, intraocular pressure mounts and crushes fragile optic nerve axons, starting with peripheral vision and leading to permanent tunnel sight if unmanaged.',
      symptomsSw: [
        'Hakuna maumivu wala dalili zozote katika hatua za mwanzo (hatari kubwa)',
        'Kupoteza uoni wa pembeni bila kujua (kujikwaa pembeni)',
        'Kwenye aina ya ghafla (angle-closure): Maumivu makali sana ya jicho, jicho kuwa jekundu mno, kichefuchefu na kutapika',
      ],
      symptomsEn: [
        'Complete absence of pain or warnings in early open-angle stages',
        'Gradual, unnoticed loss of peripheral visual field (bumping into objects)',
        'Acute angle-closure: Sudden agonizing eye and head pain, extreme redness, nausea, and colored halos',
      ],
      actionsSw: [
        'Fanya kipimo cha shinikizo la jicho (tonometry) kila unapoenda hospitali',
        'Kama umepewa matone ya glaucoma, yatumie kila siku kwa muda uliopangwa bila kukosa hata siku moja',
      ],
      actionsEn: [
        'Request tonometry pressure testing during every clinical eye visit',
        'If prescribed pressure-lowering drops, take them daily without skipping a single dose',
      ],
      whenToSeeDoctorSw:
          'Dharura ya haraka: Ukipata maumivu makali sana ya jicho ghafla yanayoambatana na kichefuchefu na kuona taa zenye miduara ya rangi, nenda chumba cha dharura mara moja.',
      whenToSeeDoctorEn:
          'Immediate emergency: If you experience sudden intense eye pain accompanied by severe nausea, vomiting, or halos around lights, visit an emergency eye clinic immediately.',
    ),
    EyeFact(
      id: 'diabetes',
      art: FactArt.eye,
      titleSw: 'Kisukari na Retina (Diabetic Retinopathy)',
      titleEn: 'Diabetic Retinopathy & Vision Protection',
      bodySw:
          'Kiwango cha juu cha sukari mwilini hudhoofisha mishipa midogo ya damu ya retina na kuanza kuvujisha damu. Mara nyingi hakuna dalili za mapema hadi uoni unapoanza kupotea.',
      bodyEn:
          'Elevated blood sugar weakens the microvascular walls of the retina, causing leaking or micro-aneurysms. Often there are zero symptoms until irreversible damage begins.',
      tipSw: 'Pima sehemu ya nyuma ya jicho (dilated retina exam) kila mwaka ikiwa una kisukari.',
      tipEn: 'Receive a dilated retinal examination at least once a year if you live with diabetes.',
      explanationSw:
          'Sukari nyingi kwenye damu huharibu kuta za mishipa inayolisha retina ya jicho. Mishipa hiyo inapovuja maji au damu (edema), macula inavimba na kusababisha maandishi kupinda pinda au kuwa na ukungu. Katika hatua za juu, mishipa mipya hafifu huota na kupasuka na kusababisha jicho kujaa damu ghafla.',
      explanationEn:
          'Chronic hyperglycemia destroys micro-capillaries supplying the neuro-retina. Leakage induces macular edema (swelling that warps sharp vision). In proliferative stages, fragile new blood vessels sprout and bleed freely into the vitreous gel.',
      symptomsSw: [
        'Madoa meusi au nyuzi zinazoelea machoni (floaters)',
        'Uoni kubadilika badilika: leo unaona vizuri, kesho ukungu',
        'Sehemu tupu au giza katikati ya uoni unaposoma',
      ],
      symptomsEn: [
        'Dark spots, cobwebs, or floating strings in your visual field',
        'Fluctuating vision clarity from morning to evening',
        'Blank or dark patches obstructing the center of your sight',
      ],
      actionsSw: [
        'Dhibiti kiwango cha sukari ya damu (HbA1c chini ya 7%)',
        'Dhibiti shinikizo la damu na lehemu (cholesterol)',
        'Fanya mazoezi na zingatia lishe ya kitaalamu kila siku',
      ],
      actionsEn: [
        'Maintain tight glycemic control (HbA1c target under 7% under medical guidance)',
        'Control systemic blood pressure and lipid levels strictly',
        'Engage in regular physical activity and follow dietary recommendations',
      ],
      whenToSeeDoctorSw:
          'Kama una kisukari na ukaona uoni unabadilika ghafla au madoa meusi yakiongezeka kwa wingi, muone daktari wa retina haraka.',
      whenToSeeDoctorEn:
          'If you live with diabetes and notice sudden flashes of light, a surge in floating specks, or a dark curtain, see a retina specialist urgently.',
    ),
    EyeFact(
      id: 'presbyopia',
      art: FactArt.clock,
      titleSw: 'Macho ya Karibu Baada ya Miaka 40 (Presbyopia)',
      titleEn: 'Age-Related Near Vision (Presbyopia)',
      bodySw:
          'Baada ya miaka 40, lenzi ya ndani ya jicho hupoteza uwezo wa kujipinda ili kulenga vitu vya karibu, na kufanya maandishi ya simu na vitabu kutoonekana vizuri. Hii si ugonjwa bali ni mabadiliko ya kawaida ya umri.',
      bodyEn:
          'After age 40, the crystalline lens naturally stiffens and loses elasticity, making small phone text and reading difficult up close. This is not a pathology; it is standard presbyopia, readily solved by tailored glasses.',
      tipSw: 'Pima macho kwanza upate namba sahihi; kuepuka miwani ya barabarani isiyolingana na macho yako.',
      tipEn: 'Have your refraction tested by an eye professional rather than picking arbitrary unverified reading glasses from street vendors.',
      explanationSw:
          'Ukiwa kijana, lenzi ya jicho ni laini kama mpira unaovutika, na inabadilika umbo mara moja unapoangalia kitu cha karibu. Kuanzia miaka 40 na kuendelea, lenzi inakuwa ngumu kiasi kwamba misuli inashindwa kuibadilisha umbo. Matokeo yake, ili usome lazima unyoshe mkono mbali.',
      explanationEn:
          'In youth, the crystalline lens is supple and accommodates instantly for near focal points. With age, nuclear sclerosis reduces lens deformability. The eye’s focal point recedes, forcing adults to hold reading material at arm’s length.',
      symptomsSw: [
        'Kuhitaji kurefusha mkono mbali ili kuona maandishi ya simu au kitabu',
        'Herufi kuonekana ndogo au zenye ukungu ukiwa umeshika karibu',
        'Maumivu ya paji la uso au maumivu ya macho baada ya kusoma kwa dakika chache',
        'Kuhitaji mwangaza mkali sana kuliko kawaida ili uweze kusoma',
      ],
      symptomsEn: [
        'Holding reading material at arm’s length to bring text into focus',
        'Blurry text at normal viewing distance (30-40 cm)',
        'Eyestrain, fatigue, or frontal brow-aches after short periods of reading',
        'Requiring substantially brighter lighting to distinguish fine details',
      ],
      actionsSw: [
        'Fanya kipimo rasmi cha kuona kwa daktari wa macho au optometrist',
        'Pata miwani iliyotengenezwa kulingana na umbali wako wa kazi (reading glasses au progressive lenses)',
      ],
      actionsEn: [
        'Undergo professional refraction to determine your precise add power',
        'Choose customized single-vision reading glasses, office lenses, or progressives suited to your workflow',
      ],
      whenToSeeDoctorSw:
          'Mara tu unapoanza kupata maumivu ya kichwa unaposoma au unapoanza kushindwa kusoma maandishi ya kila siku.',
      whenToSeeDoctorEn:
          'Schedule an eye check as soon as reading strain interferes with work, study, or daily mobile usage.',
    ),
    EyeFact(
      id: 'conjunctivitis',
      art: FactArt.eye,
      titleSw: 'Jicho Jekundu (Conjunctivitis / Pink Eye)',
      titleEn: 'Conjunctivitis: Red & Pink Eye Infections',
      bodySw:
          'Jicho jekundu lenye uchafu linaweza kuwa maambukizi ya virusi au bakteria yanayoenea kwa haraka kupitia mikono na taulo. Nawa mikono kwa sabuni mara kwa mara na usishiriki taulo au vipodozi.',
      bodyEn:
          'A bloodshot eye with sticky discharge is usually conjunctivitis (viral or bacterial) spread through hand-to-eye contact and shared linens. Practice strict hygiene and never share towels.',
      tipSw: 'Usisugue jicho unapowashwa; tumia kitambaa safi kilicholowa maji baridi kukituliza.',
      tipEn: 'Do not rub itchy eyes; apply a clean cool damp cloth over closed lids for relief.',
      explanationSw:
          'Conjunctiva ni ngozi nyembamba yenye mishipa midogo inayofunika sehemu nyeupe ya jicho. Maambukizi ya virusi (mfano Adenovirus) au bakteria yanasababisha mishipa hiyo kutanuka na jicho kuonekana jekundu kama damu. Ni ugonjwa unaoambukiza sana darasani au maofisini.',
      explanationEn:
          'The conjunctiva is the clear mucous membrane overlying the sclera. Pathogenic infection (viral adenoviruses or bacteria) provokes intense vascular dilatation and inflammatory exudate, making the eye intensely red and contagious.',
      symptomsSw: [
        'Sehemu nyeupe ya jicho kubadilika kuwa nyekundu au pinki',
        'Kope kugandana na kuwa na uchafu mzito wa manjano au kijani asubuhi',
        'Machozi mengi, kuwasha sana, na hisia ya kuungua moto',
      ],
      symptomsEn: [
        'Diffuse redness or pink discoloration across the white of the eye',
        'Crusted eyelids stuck shut upon waking from yellow or green discharge',
        'Watery tearing, burning sensation, and moderate grittiness',
      ],
      actionsSw: [
        'Nawa mikono mara kwa mara kwa maji yanayotiririka na sabuni',
        'Tenga taulo yako binafsi na ubadilishe foronya ya mto mara kwa mara',
        'Kama unatumia lenzi za macho, zitoe mara moja hadi daktari athibitishe kupona',
      ],
      actionsEn: [
        'Wash hands thoroughly and often with running water and soap',
        'Use dedicated personal towels and wash pillowcases in hot water',
        'Immediately discontinue contact lens wear until medically cleared',
      ],
      whenToSeeDoctorSw:
          'Ikiwa jicho lina maumivu makali ya ndani, uoni unakuwa hafifu, au unashindwa kufungua jicho mwangazani, ona daktari mara moja ili kutofautisha na kidonda cha mboni (corneal ulcer).',
      whenToSeeDoctorEn:
          'Seek urgent medical review if you experience deep orbital pain, diminished visual acuity, or extreme light aversion.',
    ),
    EyeFact(
      id: 'self-medication',
      art: FactArt.drop,
      titleSw: 'Hatari ya Kujitibu Dawa za Macho Bila Ushauri',
      titleEn: 'The Hazards of Ocular Self-Medication',
      bodySw:
          'Kutumia matone ya macho ya mtu mwingine au ya steroid bila kipimo kunaweza kupandisha shinikizo la jicho, kusababisha mtoto wa jicho, na kufanya maambukizi kuwa mabaya zaidi. Dawa ya macho ni dawa ya daktari.',
      bodyEn:
          'Using leftover eye drops or unsupervised steroid solutions can skyrocket eye pressure, induce cataracts, and worsen infections. Eye drops are prescription medicine, not general cosmetics.',
      tipSw: 'Kamwe usiweke maziwa ya mama, mate, mkojo, au mitishamba ndani ya jicho; huleta bakteria hatari na upofu.',
      tipEn: 'Never instill breast milk, saliva, urine, or herbal infusions into eyes; they introduce virulent pathogens and cause blinding ulcers.',
      explanationSw:
          'Matone mengi yanayotuliza uwekundu haraka yana steroids au vasoconstrictors. Steroids zinapowekwa kwenye jicho lenye maambukizi ya virusi (kama herpes simplex) au fangasi, zinaondoa kinga ya asili ya jicho na kusababisha kioo cha jicho (cornea) kuyeyuka na kutoboka.',
      explanationEn:
          'Over-the-counter drops promising instant whitening often harbor steroids or harsh vasoconstrictors. Steroids placed onto a fungal or herpes keratitis suppress immune defenses, allowing microbes to rapidly perforate the cornea.',
      symptomsSw: [
        'Jicho kuwa jekundu zaidi siku chache baada ya kuanza matone ya kienyeji',
        'Kupungua kwa uoni na kutokea kwa doa jeupe kwenye mboni',
        'Maumivu kuongezeka badala ya kupungua',
      ],
      symptomsEn: [
        'Escalating eye redness days after starting unsupervised drops',
        'Blurring vision or the development of a white spot on the clear cornea',
        'Worsening pain and severe light sensitivity',
      ],
      actionsSw: [
        'Tumia tu dawa zilizoandikwa rasmi na mtaalamu wa macho baada ya kukuchunguza',
        'Tupa chupa yoyote ya matone ya macho baada ya siku 28 tangu kuifungua',
      ],
      actionsEn: [
        'Use only ophthalmic solutions formally prescribed following biomicroscopic examination',
        'Discard open eye drop bottles after 28 days to prevent bacterial contamination',
      ],
      whenToSeeDoctorSw:
          'Ukiweka dawa yoyote na jicho likaanza kuwaka moto au kuona ukungu, osha jicho kwa maji safi mengi na nenda hospitali mara moja.',
      whenToSeeDoctorEn:
          'If adverse irritation or visual darkening follows any instillation, flush with clean water and seek emergency ophthalmic evaluation.',
    ),
    EyeFact(
      id: 'safety-goggles',
      art: FactArt.eye,
      titleSw: 'Miwani ya Kinga Kazini na Kuzuia Majeraha',
      titleEn: 'Workplace Eye Safety & Injury Prevention',
      bodySw:
          'Vipande vya chuma, kemikali, misumari, vumbi la mawe na moto huchoma jicho kwa sekunde moja tu. Glasi imara za kinga (safety goggles) huokoa asilimia 90 ya majeraha ya macho.',
      bodyEn:
          'Metal shavings, chemicals, flying nails, and welding sparks can blind an eye in a split second. Certified safety goggles prevent over 90% of all occupational eye injuries.',
      tipSw: 'Vaa miwani ya kinga hata unapofanya kazi ndogo ya dakika 2 nyumbani kama kukata nyasi au kuchomelea chuma.',
      tipEn: 'Wear impact-rated safety goggles even for 2-minute household chores like lawn mowing, drilling, or painting.',
      explanationSw:
          'Kioo cha jicho (cornea) kikiingiliwa na kipande cha chuma au kemikali kali kama chokaa au asidi ya betri, kinapata kovu la kudumu linaloziba uoni au kuyeyusha tishu. Zaidi ya asilimia 90 ya majeraha haya yangeweza kuzuilika kwa kuvaa miwani ya kinga ya polycarbonate.',
      explanationEn:
          'Corneal foreign bodies, metallic rust rings, and alkaline or acid chemical burns inflict scarring or rupture. More than 90% of occupational ocular emergencies are entirely preventable with polycarbonate safety eyewear.',
      symptomsSw: [
        'Hisia kali ya kitu chenye ncha kali kukwama machoni',
        'Machozi mengi na kushindwa kabisa kufumbua jicho',
        'Kutokwa na damu ndani ya sehemu nyeupe au nyeusi ya jicho',
      ],
      symptomsEn: [
        'Intense sharp foreign body sensation after hammering or grinding',
        'Severe involuntary blepharospasm (inability to open the eyelid)',
        'Visible hemorrhage or blood pooling inside the anterior chamber (hyphema)',
      ],
      actionsSw: [
        'Weka miwani ya kinga kwenye boksi lako la vifaa vya kazi',
        'Kemikali ikiingia machoni: Osha jicho kwa maji mengi yanayotiririka kwa dakika 15 mfululizo kabla ya kukimbia hospitali',
        'Kamwe usijaribu kutoa kipande cha chuma kwa sindano au pini ya nguo',
      ],
      actionsEn: [
        'Keep certified safety goggles with your primary tool kit at all times',
        'Chemical exposure: Copiously irrigate the eye with clean flowing water for 15 minutes before transit',
        'Never attempt to remove an embedded foreign body with pins, needles, or magnets at home',
      ],
      whenToSeeDoctorSw:
          'Kipande cha chuma, kemikali au kitu chochote chenye kasi kikiingia jichoni, hii ni dharura kubwa ya matibabu inayohitaji mtaalamu mara moja.',
      whenToSeeDoctorEn:
          'Any high-speed projectile impact, embedded fragment, or chemical burn is an immediate medical emergency requiring urgent specialist attention.',
    ),
  ];
}
