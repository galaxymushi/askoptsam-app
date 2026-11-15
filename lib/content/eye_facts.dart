// Content for AskOptSam Eye Facts Library.
//
// 28 evidence-based clinical eye topics written with comprehensive medical accuracy
// in both Kiswahili and English.
//
// Each fact features:
// 1. Overview & body
// 2. What it is & biology (whatIsIt)
// 3. Numbered Causes (causes)
// 4. Clinical Symptoms (symptoms)
// 5. Avoidance Guide / What to STOP doing (avoid)
// 6. Actionable Care & Prevention steps (actions)
// 7. Emergency Alert / When to see doctor (whenToSeeDoctor)
// 8. Actionable quick tip (tip)

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
    this.whatIsItSw,
    this.whatIsItEn,
    this.causesSw,
    this.causesEn,
    this.explanationSw,
    this.explanationEn,
    this.symptomsSw,
    this.symptomsEn,
    this.avoidSw,
    this.avoidEn,
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
  final String? whatIsItSw;
  final String? whatIsItEn;
  final List<String>? causesSw;
  final List<String>? causesEn;
  final String? explanationSw;
  final String? explanationEn;
  final List<String>? symptomsSw;
  final List<String>? symptomsEn;
  final List<String>? avoidSw;
  final List<String>? avoidEn;
  final List<String>? actionsSw;
  final List<String>? actionsEn;
  final String? whenToSeeDoctorSw;
  final String? whenToSeeDoctorEn;

  String title(String lang) => lang == 'sw' ? titleSw : titleEn;
  String body(String lang) => lang == 'sw' ? bodySw : bodyEn;
  String tip(String lang) => lang == 'sw' ? tipSw : tipEn;
  String? whatIsIt(String lang) =>
      lang == 'sw' ? (whatIsItSw ?? explanationSw) : (whatIsItEn ?? explanationEn);
  List<String>? causes(String lang) => lang == 'sw' ? causesSw : causesEn;
  String? explanation(String lang) =>
      lang == 'sw' ? (explanationSw ?? whatIsItSw) : (explanationEn ?? whatIsItEn);
  List<String>? symptoms(String lang) =>
      lang == 'sw' ? symptomsSw : symptomsEn;
  List<String>? avoid(String lang) => lang == 'sw' ? avoidSw : avoidEn;
  List<String>? actions(String lang) => lang == 'sw' ? actionsSw : actionsEn;
  String? whenToSeeDoctor(String lang) =>
      lang == 'sw' ? whenToSeeDoctorSw : whenToSeeDoctorEn;
}

class EyeFacts {
  EyeFacts._();

  static EyeFact forDay(DateTime day) {
    final today = DateTime.utc(day.year, day.month, day.day);
    final days = today.difference(DateTime.utc(2020, 1, 1)).inDays;
    return all[days % all.length];
  }

  static List<EyeFact> afterToday(DateTime day, {int count = 6}) {
    final start = all.indexOf(forDay(day));
    return [
      for (var i = 1; i <= count && i < all.length; i++)
        all[(start + i) % all.length],
    ];
  }

  static const all = <EyeFact>[
    // 1. The 20-20-20 Rule & Digital Eye Strain
    EyeFact(
      id: 'rule-20-20-20',
      art: FactArt.screen,
      titleSw: 'Kanuni ya 20-20-20 na Uchovu wa Skrini',
      titleEn: 'The 20-20-20 Rule & Digital Eye Strain',
      bodySw: 'Kila baada ya dakika 20 za kutumia simu au kompyuta, tazama kitu kilicho umbali wa angalau mita 6 (futi 20) kwa sekunde 20. Hii huilegeza misuli ya ndani ya jicho na kuzuia ukavu na maumivu ya kichwa.',
      bodyEn: 'Every 20 minutes on a phone or computer, look at something at least 6 metres (20 feet) away for 20 seconds. This releases your focusing muscles and prevents eye dryness and headaches.',
      tipSw: 'Weka kikumbusho cha kengele kila dakika 20 badala ya kusubiri hadi macho yakuume.',
      tipEn: 'Set a 20-minute timer instead of waiting for your eyes to start aching.',
      whatIsItSw: 'Unapotazama skrini ya simu au kompyuta, misuli midogo ya jicho (ciliary muscles) inalazimika kukaza bila kupumzika ili picha iwe wazi. Hali hii pia inapunguza kiwango cha kufumba macho kutoka mara 18 kwa dakika hadi mara 6 tu, na kusababisha machozi kukauka kwa kasi mno.',
      whatIsItEn: 'When focusing on screens, internal ciliary muscles stay continually contracted. In addition, your blink rate plummets from 18 times per minute to under 6, causing rapid tear evaporation.',
      causesSw: [
        '1. Kufanya kazi mfululizo kwenye kompyuta, laptop, au iPad kwa saa kadhaa bila kupumzika.',
        '2. Kuteleza kwenye mitandao ya kijamii (social media) kwenye simu bila kuinua macho.',
        '3. Skrini kuwa na mwangaza mkali sana au kuakisi mwanga wa taa na madirisha.',
      ],
      causesEn: [
        '1. Prolonged computer, tablet, or monitor use without structured visual pauses.',
        '2. Endless mobile social media scrolling without looking up.',
        '3. Harsh screen glare, reflection, or uncalibrated display brightness.',
      ],
      symptomsSw: [
        'Macho kuwasha, kuchoma, au kuwa mekundu baada ya muda mrefu wa skrini.',
        'Ukungu wa muda unaotokea unapoangalia mbali baada ya kusoma.',
        'Maumivu ya paji la uso au shingo.',
        'Hisia ya mchanga au jicho kuwa zito na kavu.',
      ],
      symptomsEn: [
        'Burning, irritation, or redness after extended screen use.',
        'Transient blurred vision when looking up into the distance.',
        'Tension headaches across the brow or neck.',
        'Gritty, dry, or fatigued feeling in both eyes.',
      ],
      avoidSw: [
        '1. Acha kuendelea kutumia skrini zaidi ya dakika 30 bila kuinua macho kuangalia mbali.',
        '2. Acha kutumia simu chumbani kukiwa giza totoro kwani inalazimisha jicho kufungua mboni huku mwangaza ukichoma.',
        '3. Acha kuweka simu karibu sana na uso (chini ya sentimita 30).',
      ],
      avoidEn: [
        '1. Avoid continuous screen sessions exceeding 30 minutes without a distant visual break.',
        '2. Never use phones in pitch-dark bedrooms where dilated pupils receive high concentrated contrast.',
        '3. Avoid reading devices closer than 30 cm from your face.',
      ],
      actionsSw: [
        '1. Fuata kanuni: Kila dakika 20, angalia dirishani au kitu kilicho mita 6 mbali kwa sekunde 20 kamili.',
        '2. Fumba macho mara tatu taratibu ili kusambaza machozi upya.',
        '3. Weka umbali wa skrini ya kompyuta kuwa sentimita 50-70 kutoka machoni.',
        '4. Hakikisha taa za chumba hazisababishi kioo kuakisi mwanga (glare).',
      ],
      actionsEn: [
        '1. Follow the rule: Every 20 minutes, gaze out of a window or across a 6m room for 20 seconds.',
        '2. Blink deliberately 3 times to evenly redistribute fresh tear film.',
        '3. Position desktop displays 50–70 cm away with the top of the monitor at eye level.',
        '4. Eliminate harsh glare and reflections from lamps or windows on your screen.',
      ],
      whenToSeeDoctorSw: 'Ikiwa ukungu wa macho au maumivu ya kichwa hayaondoki hata ukipumzika, unaweza kuwa na uhitaji wa miwani ya kukinga au ya kurekebisha kuona.',
      whenToSeeDoctorEn: 'If eyestrain, blurred sight, or persistent headaches do not resolve after resting, schedule an optometric evaluation for refractive correction.',
    ),

    // 2. Conscious Blinking & Corneal Moisture
    EyeFact(
      id: 'blinking',
      art: FactArt.eye,
      titleSw: 'Kufumba na Kufumbua Macho kwa Ufasaha',
      titleEn: 'Conscious Blinking & Corneal Moisture',
      bodySw: 'Kufumba macho mara 15 hadi 20 kwa dakika husambaza machozi safi, husafisha vumbi dogo na huleta hewa ya oksijeni kwenye kioo cha jicho. Skrini hupunguza kufumba huku kwa zaidi ya nusu.',
      bodyEn: 'Blinking 15 to 20 times per minute distributes fresh tears, washes away micro-particles, and delivers oxygen to the cornea. Screens reduce this natural rate by over half.',
      tipSw: 'Fanya mazoezi ya kufumba macho taratibu kope la juu likigusa la chini mara 10 unapokuwa kwenye kompyuta.',
      tipEn: 'Practice 10 full, slow blinks with upper eyelid gently touching lower eyelid whenever using screens.',
      whatIsItSw: 'Kila unapofumba jicho (blink), kope zako hufanya kazi kama kifutio cha gari (wiper): husukuma matone mapya kutoka tezi ya machozi, huyaeneza sawa kwenye kioo cha jicho (cornea), na kufinya tezi za kope ili kutoa mafuta asili yanayozuia machozi yasivukie hewani.',
      whatIsItEn: 'Every blink acts like a windshield wiper: it sweeps fresh lacrimal fluid across the cornea, clears away debris, and squeezes meibomian glands along eyelid margins to release a protective lipid shield.',
      causesSw: [
        '1. Kuzingatia sana kusoma au kucheza magemu kwenye skrini (cognitive absorption).',
        '2. Kufumba nusu (incomplete blinking) ambapo kope la juu haligusani na la chini.',
        '3. Mazingira yenye hewa kavu sana au feni inayopuliza moja kwa moja usoni.',
      ],
      causesEn: [
        '1. Intense cognitive focus when gaming, coding, or reading long documents.',
        '2. Incomplete blinking habits where the upper lid never fully touches the bottom lid.',
        '3. Arid environments, forced air heaters, or direct overhead fans.',
      ],
      symptomsSw: [
        'Macho kuanza kuuma, kuchoma au kuwasha katikati ya kazi.',
        'Jicho kutoa machozi mengi gafla (reflex tearing).',
        'Kuhisi kama macho yako kavu na yana kibanzi kisichoonekana.',
      ],
      symptomsEn: [
        'Sudden stinging, burning, or itchiness during tasks.',
        'Reflexive watery eyes that paradoxically signal surface dryness.',
        'Feeling an invisible speck of dirt or dry patch on the eye.',
      ],
      avoidSw: [
        '1. Acha kukaza macho kwenye skrini bila kufumba kwa dakika kadhaa mfululizo.',
        '2. Acha kufanya nusu-kufumba (kufumba haraka haraka bila kope kugusana).',
        '3. Acha kupuuza hisia ya macho kuanza kuwaka moto ukiwa kwenye simu au kompyuta.',
      ],
      avoidEn: [
        '1. Avoid staring unblinkingly at digital screens for prolonged periods.',
        '2. Avoid partial or incomplete blinking where lid margins do not make contact.',
        '3. Never ignore burning signals while on screens — your cornea is drying out.',
      ],
      actionsSw: [
        '1. Fanya zoezi: Fumba macho, pumzika kwa sekunde 2, fungua. Rudia mara 5 kila nusu saa.',
        '2. Weka stika ndogo pembeni mwa kompyuta yenye neno "Fumba Macho" kama kikumbusho.',
        '3. Tumia matone ya maji ya machozi (lubricating eye drops) ikiwa kazi yako inahitaji skrini masaa 8+.',
      ],
      actionsEn: [
        '1. Blink exercise: Close softly, pause for 2 seconds, reopen gently. Repeat 5 times every 30 minutes.',
        '2. Place a small sticky note reading "Blink!" on the bezel of your workstation screen.',
        '3. Use preservative-free lubricating drops if your profession demands 8+ hours of screen focus.',
      ],
      whenToSeeDoctorSw: 'Ikiwa kope hazifungi vizuri (lagophthalmos) au unahisi machozi hayasaidii kabisa na jicho linaendelea kuuma, onana na daktari wa macho.',
      whenToSeeDoctorEn: 'Consult an eye care professional if eyelids fail to close completely during sleep or if severe burning persists despite blinking exercises.',
    ),

    // 3. Solar UV Radiation & UV400 Protection
    EyeFact(
      id: 'uv',
      art: FactArt.sun,
      titleSw: 'Mionzi Mikali ya Jua na Miwani ya UV400',
      titleEn: 'Solar UV Radiation & UV400 Protection',
      bodySw: 'Mionzi ya ultraviolet (UV-A na UV-B) kutoka juani huharakisha mtoto wa jicho (cataract), huunguza retina na husababisha uoto kwenye jicho (pterygium). Miwani yenye kinga ya UV400 hulinda macho yako.',
      bodyEn: 'Ultraviolet rays (UV-A and UV-B) accelerate cataract formation, damage retinal cells, and cause fleshy growths (pterygium). True UV400 sunglasses provide essential protection.',
      tipSw: 'Hakikisha miwani ya jua unayonunua ina lebo ya "UV400" au "100% UV Protection" na siyo tu vioo vyenye giza.',
      tipEn: 'Verify your sunglasses carry a certified "UV400" or "100% UV Protection" label, not just dark tinted glass.',
      whatIsItSw: 'Mionzi ya ultraviolet (UV) haionekani kwa macho lakini ina nguvu kubwa ya nishati. Kioo cha jicho na lenzi ya ndani hunyonya mionzi hii, na baada ya miaka mingi ya kupigwa na jua, protini za lenzi huharibika na kufanya mtoto wa jicho, au tishu za pembeni kukua na kuingia kwenye kioo (pterygium/nyama ya jicho).',
      whatIsItEn: 'Ultraviolet radiation is invisible high-energy light. The cornea and crystalline lens absorb these photons; over years of unprotected sun exposure, cumulative photochemical damage denatures lens proteins (cataracts) and triggers pinguecula and pterygium growths.',
      causesSw: [
        '1. Kutembea, kuendesha gari au kufanya kazi juani bila miwani ya jua au kofia.',
        '2. Mwanga wa jua unaoakisiwa kutoka kwenye maji, mchanga au lami nyeupe.',
        '3. Kuvaa miwani ya giza feki isiyo na kinga ya UV (inapanua mboni na kuruhusu mionzi hatari kuingia zaidi).',
      ],
      causesEn: [
        '1. Outdoor labor, sports, or transit under direct tropical sun without eye protection.',
        '2. High-albedo UV reflection from water surfaces, sand, or white concrete.',
        '3. Wearing cheap dark novelty glasses without UV blockers (dilates pupils and floods the retina with UV).',
      ],
      symptomsSw: [
        'Macho kuwa mekundu na kuwasha baada ya kukaa juani.',
        'Kuhisi kama kuna mchanga au nyama inakua kutoka kona ya jicho kuelekea katikati.',
        'Macho kushindwa kuvumilia mwanga mkali wa mchana (photophobia).',
      ],
      symptomsEn: [
        'Persistent redness and sandy irritation following prolonged outdoor exposure.',
        'Visible raised yellowish or pinkish tissue growing from the corner toward the cornea.',
        'Intense intolerance and squinting in bright daylight (photophobia).',
      ],
      avoidSw: [
        '1. Acha kabisa kuvaa miwani ya jua ya barabarani isiyo na uthibitisho wa UV400 (ni hatari zaidi kuliko kutovaa).',
        '2. Acha kutazama jua moja kwa moja – hata wakati wa kupatwa kwa jua (solar eclipse) kwani huchoma retina (solar retinopathy) na kusababisha upofu wa kudumu.',
        '3. Acha kufanya kazi za juani kati ya saa 4 asubuhi hadi saa 10 jioni bila kinga ya macho.',
      ],
      avoidEn: [
        '1. Never wear uncertified street sunglasses lacking UV400 ratings — dark tint without UV filters dilates pupils, inviting massive UV damage.',
        '2. Never stare directly at the sun, especially during eclipses, which causes permanent photochemical retinal burns (solar retinopathy).',
        '3. Avoid prolonged mid-day sun exposure between 10 AM and 4 PM without head and eye shade.',
      ],
      actionsSw: [
        '1. Vaa miwani halisi ya jua yenye alama ya UV400 inayofunika vizuri macho yako yote.',
        '2. Vaa kofia pana (broad-brimmed hat) inayozuia mionzi inayotoka juu.',
        '3. Wape watoto pia miwani ya UV wakiwa kwenye michezo ya jua kali kwani lenzi zao ni safi na hupitisha mionzi mingi zaidi.',
      ],
      actionsEn: [
        '1. Wear verified UV400 wrap-around sunglasses that block peripheral reflected light.',
        '2. Wear a wide-brimmed sun hat to shade upper visual angles.',
        '3. Provide UV-protective eyewear for children whose young, crystal-clear lenses transmit more UV to the retina.',
      ],
      whenToSeeDoctorSw: 'Ukiona ukungu ghafla baada ya kutazama jua, au ukiona nyama inaanza kukua kwenye jicho, muone daktari wa macho kabla haijafika kwenye mboni.',
      whenToSeeDoctorEn: 'Consult an eye specialist promptly if you notice a central blind spot after sun gazing, or progressive tissue growth crossing into the clear cornea.',
    ),

    // 4. Nutrition for Vision: Lutein, Zeaxanthin & Antioxidants
    EyeFact(
      id: 'food',
      art: FactArt.food,
      titleSw: 'Lishe Bora kwa Afya ya Macho: Lutein na Vitamini',
      titleEn: 'Nutrition for Vision: Lutein, Zeaxanthin & Antioxidants',
      bodySw: 'Mboga za majani ya kijani kibichi (mchicha, tembele, sukuma wiki), karoti, machungwa na samaki huipatia retina virutubisho vya kuzuia uharibifu wa seli za kuona kadiri umri unavyosonga.',
      bodyEn: 'Dark leafy greens (spinach, kales), carrots, citrus fruits, and oily fish deliver vital carotenoids and micronutrients that defend retinal macula cells against age-related degeneration.',
      tipSw: 'Ongeza mboga za majani na nusu karoti kwenye mlo wako wa mchana angalau mara 4 kwa wiki.',
      tipEn: 'Incorporate dark greens and carrots into your meals at least 4 times per week.',
      whatIsItSw: 'Retina ya jicho, hasa eneo la kati liitwalo Macula, lina viwango vikubwa vya virutubisho vya Lutein na Zeaxanthin. Virutubisho hivi hufanya kazi kama miwani ya ndani ya jicho inayochuja mwanga hatari wa bluu na kuzuia seli zisife kutokana na umri (Macular Degeneration).',
      whatIsItEn: 'The central retina (macula) depends on high concentrations of dietary carotenoids — lutein and zeaxanthin. These function as internal blue-light filters and antioxidants, protecting photoreceptors against oxidative cellular breakdown.',
      causesSw: [
        '1. Kula mara kwa mara vyakula vilivyosindikwa vyenye mafuta mabaya bila mboga za majani.',
        '2. Upungufu wa matunda na mboga za asili kwenye mlo wa kila siku.',
        '3. Kutokunywa maji ya kutosha na ukosefu wa vyakula vyenye madini ya zinki na Omega-3.',
      ],
      causesEn: [
        '1. Chronic consumption of ultra-processed foods deficient in micronutrients and bioflavonoids.',
        '2. Inadequate intake of fresh local vegetables, greens, and whole fruits.',
        '3. Insufficient dietary intake of zinc, vitamin C, vitamin E, and essential Omega-3 fatty acids.',
      ],
      symptomsSw: [
        'Kushindwa kuona vizuri jioni au kwenye mwanga hafifu (nyctalopia).',
        'Macho kuchoka haraka na kupoteza uwezo wa kutofautisha rangi vizuri.',
        'Kuhisi macho hayana unyevu wa kutosha licha ya kutotumia skrini sana.',
      ],
      symptomsEn: [
        'Difficulty adapting and seeing clearly in low twilight conditions.',
        'Visual fatigue and subtle decreases in contrast sensitivity.',
        'Chronic surface irritation and dry eye symptoms related to lipid layer deficiency.',
      ],
      avoidSw: [
        '1. Acha kupitisha siku nzima bila kula mboga za majani au tunda hata moja.',
        '2. Acha kutegemea chipsi, vyakula vya kukaanga na soda kama mlo mkuu wa kila siku.',
        '3. Acha kutumia virutubisho vya madukani (supplements) bila ushauri wa kitaalamu.',
      ],
      avoidEn: [
        '1. Avoid letting entire days pass without consuming dark green vegetables or fresh fruit.',
        '2. Avoid relying on deep-fried junk food and sugary sodas as dietary staples.',
        '3. Avoid taking mega-dose synthetic dietary supplements without medical guidance.',
      ],
      actionsSw: [
        '1. Kula mboga za kijani kibichi kama mchicha, tembele, na sukuma wiki mara kwa mara.',
        '2. Kula karoti, maboga, na papai vyenye beta-carotene inayobadilishwa kuwa Vitamini A.',
        '3. Kula samaki wenye mafuta (kama vile dagaa au sato) kupata Omega-3 kwa wingi.',
        '4. Kunywa juisi ya machungwa au kula matunda ya jamii ya machungwa kupata Vitamini C.',
      ],
      actionsEn: [
        '1. Eat leafy dark greens (spinach, kale, sweet potato leaves) several times weekly.',
        '2. Include orange vegetables and fruits (carrots, pumpkin, papaya) rich in beta-carotene.',
        '3. Enjoy oily fish (sardines, tilapia, mackerel) rich in DHA and EPA Omega-3 fats.',
        '4. Consume citrus fruits, guavas, and bell peppers rich in vitamin C.',
      ],
      whenToSeeDoctorSw: 'Ukiona mistari iliyonyooka inaanza kuonekana imepinda katikati, au unashindwa kutambua sura za watu, pima retina kwa daktari wa macho.',
      whenToSeeDoctorEn: 'If straight lines appear wavy or distorted, or if central details become smudged, request a dilated retinal exam immediately.',
    ),

    // 5. Dry Eye Syndrome & Tear Film Health
    EyeFact(
      id: 'dry-eye',
      art: FactArt.drop,
      titleSw: 'Ugonjwa wa Macho Makavu (Dry Eye Syndrome)',
      titleEn: 'Dry Eye Syndrome & Tear Film Health',
      bodySw: 'Macho makavu ni hali inayotokea pale machozi yanaposhindwa kulowesha jicho ipasavyo au yanapokauka kwa kasi mno, hali inayoleta hisia ya kuungua, mchanga na uoni hafifu.',
      bodyEn: 'Dry eye syndrome happens when your eyes cannot produce enough quality tears or when tears evaporate too fast, resulting in burning, grittiness, and unstable sight.',
      tipSw: 'Weka kitambaa safi cha maji ya vuguvugu machoni kwa dakika 5 kila jioni ili kufungua tezi za mafuta kwenye kope.',
      tipEn: 'Apply a clean warm compress over your eyelids for 5 minutes each evening to unblock meibomian oil glands.',
      whatIsItSw: 'Machozi ya binadamu sio maji tu; yana tabaka tatu muhimu: mafuta (lipid), maji (aqueous), na uteute (mucin). Macho makavu hutokea pale: 1) Tezi za kope zinapoziba na kukosa mafuta ya kuzuia mvukizo, 2) Tezi za machozi zinapopunguza kiasi cha maji, au 3) Uso wa jicho unapopata michubuko midogo kutokana na ukavu.',
      whatIsItEn: 'Human tears consist of three balanced layers: lipid (oil), aqueous (water), and mucin (mucus). Dry eye develops when: 1) Eyelid oil glands clog up, 2) Lacrimal glands produce insufficient water, or 3) Friction causes micro-abrasions on the cornea.',
      causesSw: [
        '1. Kutumia simu au kompyuta kwa saa nyingi bila mapumziko (hupunguza kufumba macho kwa 60%).',
        '2. Mazingira yenye upepo, vumbi, moshi au kiyoyozi na feni inayopuliza moja kwa moja usoni.',
        '3. Upungufu wa unywaji maji mwilini na mabadiliko ya homoni kadiri umri unavyosonga.',
        '4. Matumizi ya baadhi ya dawa (kama vile za shinikizo la damu, allergy, na vidonge vya usingizi).',
      ],
      causesEn: [
        '1. Prolonged screen engagement without blinking pauses (reduces blink rate by over 60%).',
        '2. Environmental exposure to wind, dry air conditioning, dust, or direct fan drafts.',
        '3. Systemic dehydration, hormonal shifts, and biological aging past 40.',
        '4. Side effects from common medications (antihistamines, decongestants, blood pressure pills).',
      ],
      symptomsSw: [
        'Hisia kali ya kuwa na mchanga au kibanzi machoni kila unapofumba.',
        'Macho kuwaka moto, kuuma, au kuwa mekundu hasa kuelekea jioni.',
        'Macho kutoa machozi mengi mfululizo (machozi ya kureact na ukavu).',
        'Uoni kuwa hafifu lakini unarudi kuwa mzuri unapofumba macho kwa nguvu.',
      ],
      symptomsEn: [
        'Persistent gritty, sandy, or scratching sensation under eyelids.',
        'Burning, aching pain, or redness peaking in late afternoon or evening.',
        'Paradoxical excessive tearing triggered as an emergency reflex to surface dryness.',
        'Intermittent visual blur that clears temporarily immediately after a firm blink.',
      ],
      avoidSw: [
        '1. Acha kusugua macho kwa mikono – kusugua kunachana kioo cha jicho na kuingiza bakteria.',
        '2. Acha kukaa moja kwa moja mbele ya upepo wa feni au kiyoyozi unaopiga usoni.',
        '3. Acha kutumia dawa za matone za steroids au zenye kemikali ya kufanya jicho jeupe bila cheti cha daktari.',
        '4. Acha kutumia simu gizani kitandani kabla ya kulala.',
        '5. Acha kuvuta sigara au kukaa karibu na moshi wa kuni au sigara.',
      ],
      avoidEn: [
        '1. Never rub your eyes with bare hands — rubbing shears the epithelial surface and spreads microbes.',
        '2. Avoid direct drafts from fans, blowers, or air conditioners aimed at your face.',
        '3. Stop using over-the-counter redness-relief drops or unsupervised steroid solutions.',
        '4. Avoid long smartphone scrolling in total darkness before sleep.',
        '5. Avoid smoke from cigarettes, charcoal fires, and open burning areas.',
      ],
      actionsSw: [
        '1. Kunywa maji ya kutosha (lita 2 hadi 3 kwa siku) ili kuupa mwili unyevu asili.',
        '2. Fuata kanuni ya 20-20-20: kila dakika 20, tazama kitu cha mbali kwa sekunde 20.',
        '3. Fanya zoezi la kufumba macho kikamilifu na taratibu mara 10 kila unaposoma.',
        '4. Tumia matone ya kulowesha (Artificial Tears) yasiyo na vihifadhi (preservative-free).',
        '5. Kula vyakula vyenye Omega-3 kama samaki (dagaa, sato) au mbegu za chia na maboga.',
      ],
      actionsEn: [
        '1. Maintain daily systemic hydration with 2 to 3 liters of clean water.',
        '2. Practice the 20-20-20 visual rule throughout computer and mobile device use.',
        '3. Perform deliberate, complete blinks (upper lid touching lower lid) 10 times consecutively.',
        '4. Use preservative-free lubricating drops (Artificial Tears) as advised by your optometrist.',
        '5. Enrich your diet with Omega-3 fatty acids from fish (sardines, tilapia) or chia and pumpkin seeds.',
      ],
      whenToSeeDoctorSw: 'Ukiona maumivu makali yasiyotulia, uoni ukianza kupungua, au jicho likitoa usaha mzito, muone daktari wa macho (optometrist au ophthalmologist) mara moja.',
      whenToSeeDoctorEn: 'Seek an immediate eye examination if you experience persistent sharp pain, noticeable vision drop, light sensitivity, or thick discharge.',
    ),

    // 6. Comprehensive Annual Eye Examinations
    EyeFact(
      id: 'checkup',
      art: FactArt.clock,
      titleSw: 'Umuhimu wa Kupima Macho Mara kwa Mara',
      titleEn: 'Comprehensive Annual Eye Examinations',
      bodySw: 'Magonjwa mengi ya macho kama Glaucoma na uharibifu wa kisukari huanza kimyakimya bila maumivu yoyote. Kupima macho angalau mara moja kwa mwaka ndiyo njia pekee ya kuyagundua mapema.',
      bodyEn: 'Sight-threatening conditions like glaucoma and diabetic retinopathy advance silently without pain or early symptoms. Annual comprehensive eye examinations are the only way to catch them early.',
      tipSw: 'Weka miadi ya kupima macho kila mwaka hata kama unaona vizuri kabisa leo.',
      tipEn: 'Schedule a comprehensive eye exam annually even if your current vision feels perfectly clear.',
      whatIsItSw: 'Kipimo cha macho sio kusoma herufi kwenye ubao pekee (Visual Acuity). Daktari wa macho huchunguza: 1) Shinikizo la ndani ya jicho (IOP), 2) Mshipa wa kuona (optic nerve), 3) Retina na mishipa ya damu, 4) Afya ya kioo cha jicho, na 5) Uwezo wa macho kulenga pamoja.',
      whatIsItEn: 'A comprehensive eye checkup extends far beyond an eye chart. Your eye care provider assesses intraocular pressure, the optic nerve head, peripheral visual fields, retinal vasculature, and binocular alignment.',
      causesSw: [
        '1. Kudhani kwamba kwa sababu unaona mbali vizuri basi huna tatizo lolote la macho.',
        '2. Kusubiri hadi macho yakuume au uoni upungue ndipo uende hospitali.',
        '3. Kutojua historia ya kifamilia ya magonjwa ya macho kama vile glaucoma au mtoto wa jicho.',
      ],
      causesEn: [
        '1. Assuming that 20/20 clarity rules out serious hidden ocular disease.',
        '2. Waiting until severe pain or noticeable vision loss strikes before consulting an eye clinic.',
        '3. Unawareness of family history regarding glaucoma, macular disease, or high myopia.',
      ],
      symptomsSw: [
        'Kupoteza uwezo wa kuona pembeni (tunnel vision) bila hata kutambua.',
        'Kuona duara za mwanga zenye rangi (halos) kuzunguka taa usiku.',
        'Macho kuchoka mara kwa mara unaposoma vitabu au skrini.',
      ],
      symptomsEn: [
        'Subtle, unnoticed peripheral vision fading (tunnel vision).',
        'Rainbow halos around streetlights and headlights at night.',
        'Recurrent visual fatigue during reading or detailed near work.',
      ],
      avoidSw: [
        '1. Acha tabia ya kununua miwani ya kusomea barabarani bila kupimwa na daktari wa macho.',
        '2. Acha kuruka vipimo vya macho vya kila mwaka hasa kama una umri zaidi ya miaka 40.',
        '3. Acha kutumia miwani ya mtu mwingine kisa inakusaidia kuona.',
      ],
      avoidEn: [
        '1. Avoid purchasing unverified street ready-readers without a professional prescription check.',
        '2. Never skip annual eye evaluations, especially if you are over 40 or have a family risk history.',
        '3. Never borrow someone else’s eyeglasses simply because they seem to clear your view.',
      ],
      actionsSw: [
        '1. Pima macho kwa mtaalamu (Optometrist au Ophthalmologist) mara moja kila mwaka.',
        '2. Watu wenye kisukari au shinikizo la damu wanapaswa kupimwa retina kila baada ya miezi 6 hadi 12.',
        '3. Wapeleke watoto kupima macho kabla ya kuanza shule ya msingi.',
        '4. Hifadhi rekodi zako za vipimo vya awali ili kufuatilia mabadiliko ya afya ya jicho.',
      ],
      actionsEn: [
        '1. Schedule an annual comprehensive eye exam with a licensed optometrist or ophthalmologist.',
        '2. Individuals with diabetes or hypertension must receive annual dilated fundus examinations.',
        '3. Have children screened prior to entering primary school to catch amblyopia early.',
        '4. Keep previous prescription records to help track optical stability over time.',
      ],
      whenToSeeDoctorSw: 'Nenda mara moja ukiona giza ghafla, miale ya mwanga (flashes), au utando mweusi unateremka mbele ya jicho lako.',
      whenToSeeDoctorEn: 'Seek emergency care immediately if you notice sudden dark curtains falling across vision, shower of floaters, or flashing lights.',
    ),

    // 7. Restorative Sleep & Ocular Healing
    EyeFact(
      id: 'sleep',
      art: FactArt.moon,
      titleSw: 'Usingizi Mnono na Ukarabati wa Macho',
      titleEn: 'Restorative Sleep & Ocular Healing',
      bodySw: 'Unapolala, macho yako hupumzika kikamilifu, hupata unyevu bila kukatizwa, na seli za nje ya kioo cha jicho hufanya ukarabati wa seli zilizochakaa mchana. Saa 7 hadi 8 za usingizi ni tiba kwa macho.',
      bodyEn: 'During deep sleep, your eyes enjoy continuous lubrication, muscular release, and epithelial cell turnover. Getting 7 to 8 hours of uninterrupted sleep actively repairs ocular tissues.',
      tipSw: 'Zima skrini zote dakika 30 kabla ya kulala ili kutoa nafasi kwa macho na ubongo kupumzika.',
      tipEn: 'Power off all digital screens 30 minutes before bedtime to allow biological melatonin release.',
      whatIsItSw: 'Kioo cha jicho (cornea) hakina mishipa ya damu; kinapata oksijeni kutoka hewani mchana na kutoka kwenye utando wa kope unapolala. Usingizi mdogo huzuia seli hizi za nje kujitengeneza upya, na kusababisha jicho kuwaka moto, kupasuka mishipa midogo ya damu, na kope kutetemeka (myokymia).',
      whatIsItEn: 'The avascular cornea relies on tears and palpebral conjunctiva for nocturnal oxygenation and stem-cell epithelial repair. Sleep deprivation impairs tissue regeneration, producing bloodshot eyes, dry patches, and eyelid twitching (myokymia).',
      causesSw: [
        '1. Kulala masaa machache mno (chini ya masaa 6 kwa usiku) kwa muda mrefu.',
        '2. Kutumia simu kitandani gizani hadi usiku wa manane.',
        '3. Msongo wa mawazo unaozuia usingizi mzito na unaofanya ubongo kuwa macho.',
      ],
      causesEn: [
        '1. Chronic sleep restriction under 6 hours per night.',
        '2. Late-night phone scrolling in bed under high-contrast blue wavelengths.',
        '3. High psychological stress that fragments deep restorative sleep cycles.',
      ],
      symptomsSw: [
        'Macho kuwa mekundu sana yenye mishipa ya damu iliyotanuka asubuhi.',
        'Kope kutetemeka zenyewe bila kudhibitiwa (eyelid twitching / myokymia).',
        'Miduara meusi au mifuko chini ya macho (dark circles & puffiness).',
        'Ukungu wa muda na maumivu ya kope asubuhi unapoamka.',
      ],
      symptomsEn: [
        'Noticeably bloodshot, glassy eyes upon waking.',
        'Involuntary eyelid twitching or fluttering (ocular myokymia).',
        'Periorbital puffiness and dark under-eye circles.',
        'Morning ocular dryness and slight visual haze.',
      ],
      avoidSw: [
        '1. Acha kulala ukiwa umewasha taa kali au TV inayobadilika mwanga chumbani.',
        '2. Acha tabia ya kuangalia simu mara tu unapoamka katikati ya usiku.',
        '3. Acha kunywa kahawa au vinywaji vyenye kafeini masaa 4 kabla ya kulala.',
      ],
      avoidEn: [
        '1. Avoid sleeping with bright overhead lights or flickering TVs active.',
        '2. Avoid checking notifications if you awaken in the middle of the night.',
        '3. Avoid consuming caffeinated beverages or stimulants within 4 hours of bedtime.',
      ],
      actionsSw: [
        '1. Pata masaa 7 hadi 8 ya usingizi mnono kila usiku.',
        '2. Weka chumba chako kuwa chenye giza na hewa safi inayopita vizuri.',
        '3. Ikiwa kope inatetemeka, ongeza mapumziko, kunywa maji, na punguza kafeini.',
        '4. Osha uso kwa maji ya uvuguvugu kabla ya kulala ili kulegeza misuli ya uso.',
      ],
      actionsEn: [
        '1. Commit to 7–8 hours of consistent, quality nightly sleep.',
        '2. Keep your sleep environment dark, quiet, and well-ventilated.',
        '3. If eyelid twitches develop, prioritize sleep, hydration, and reduce stimulant intake.',
        '4. Wash your face with lukewarm water before bedtime to relax facial muscles.',
      ],
      whenToSeeDoctorSw: 'Ikiwa kope inatetemeka bila kuacha kwa zaidi ya wiki mbili au uso mzima unavutika, muone daktari kwa uchunguzi wa neva.',
      whenToSeeDoctorEn: 'If eyelid twitching spreads to facial muscles or lasts continuously beyond two weeks, seek neurological and eye care consultation.',
    ),

    // 8. Smoke, Tobacco Toxins & Retinal Health
    EyeFact(
      id: 'smoke',
      art: FactArt.smoke,
      titleSw: 'Moshi, Sigara na Uharibifu wa Retina',
      titleEn: 'Smoke, Tobacco Toxins & Retinal Health',
      bodySw: 'Uvutaji wa sigara huongeza hatari ya upofu kutokana na uharibifu wa seli za retina (AMD) mara mbili hadi tatu zaidi, na moshi wa kuni huchoma uso wa jicho na kuharibu tabaka la machozi.',
      bodyEn: 'Tobacco smoking multiplies your risk of permanent blindness from macular degeneration by 200–300%, while biomass fire smoke severely inflames ocular tissues.',
      tipSw: 'Kaa mbali na moshi wa jikoni wa kuni na epuka kabisa uvutaji wa sigara na shisha.',
      tipEn: 'Stay clear of indoor biomass cooking smoke and steer completely clear of tobacco and shisha.',
      whatIsItSw: 'Kemikali zenye sumu zilizomo kwenye moshi wa sigara huingia kwenye mzunguko wa damu na kubana mishipa midogo ya damu inayoilisha retina. Hii husababisha seli za macula kufa kwa kukosa hewa safi na lishe, na kusababisha mtoto wa jicho kukua kwa kasi ya ajabu.',
      whatIsItEn: 'Combustion toxins enter systemic circulation, inducing vasoconstriction and severe oxidative stress across the choroidal blood vessels that sustain the retina. This starves the macula and accelerates nuclear cataract formation.',
      causesSw: [
        '1. Uvutaji wa sigara, sigara pepe (vape), au shisha.',
        '2. Kupumua moshi wa sigara unaovutwa na watu waliopo karibu nawe (secondhand smoke).',
        '3. Kupika kwa kuni au mkaa kwenye vyumba visivyo na madirisha au mabomba ya kutolea moshi.',
      ],
      causesEn: [
        '1. Active smoking of cigarettes, cigars, electronic vaporizers, or hookahs.',
        '2. Chronic passive exposure to secondhand smoke in enclosed spaces.',
        '3. Indoor cooking with firewood or charcoal without adequate ventilation chimneys.',
      ],
      symptomsSw: [
        'Macho kuwasha sana, kuchoma, na kuwa mekundu mara kwa mara.',
        'Kuhisi moshi unachoma kope na kusababisha machozi yasiyo na kikomo.',
        'Kuanza kupoteza uwezo wa kuona katikati ya kitu (central vision loss) kadiri miaka inavyoenda.',
      ],
      symptomsEn: [
        'Chronic stinging, conjunctival hyperaemia, and gritty inflammation.',
        'Heavy lacrimation and photophobia during smoke contact.',
        'Gradual onset of central dark blurs or wavy vision later in life.',
      ],
      avoidSw: [
        '1. Acha kabisa kuvuta sigara au kutumia shisha – hakuna kiwango salama cha moshi kwa macho yako.',
        '2. Acha kukaa jikoni kwenye moshi wa kuni bila hewa ya kutosha.',
        '3. Acha kuwasogeza watoto wadogo au wazee karibu na mapishi yenye moshi mzito.',
      ],
      avoidEn: [
        '1. Cease all tobacco and nicotine smoking immediately — there is no safe threshold for ocular microvasculature.',
        '2. Never cook in closed indoor spaces with biomass wood or charcoal fires without extraction flues.',
        '3. Keep infants and elders away from dense smoke zones.',
      ],
      actionsSw: [
        '1. Ikiwa unavuta sigara, tafuta msaada wa kiafya ili kuacha leo; uamuzi huo huokoa uoni wako.',
        '2. Tumia majiko sanifu yasiyo na moshi au yenye bomba la kutoa moshi nje ya nyumba.',
        '3. Kila unapokumbana na moshi, osha uso na kope kwa maji safi na tumia matone ya kulowesha macho.',
      ],
      actionsEn: [
        '1. Seek cessation support to stop smoking today — quitting immediately halts escalating macular risk.',
        '2. Adopt clean energy or improved cookstoves equipped with chimneys.',
        '3. Rinse your eyes with cool clean water and use lubricating drops after involuntary smoke exposure.',
      ],
      whenToSeeDoctorSw: 'Ukiona uoni wa kati unatiwa giza au unapoteza rangi za vitu, fika kituo cha macho haraka kwa uchunguzi wa retina.',
      whenToSeeDoctorEn: 'If central vision dims or contrast fades, see an ophthalmologist for optical coherence tomography (OCT) imaging of your macula.',
    ),

    // 9. Cataracts: Causes, Symptoms & Modern Surgery
    EyeFact(
      id: 'cataract',
      art: FactArt.eye,
      titleSw: 'Mtoto wa Jicho (Cataract) na Tiba Yake',
      titleEn: 'Cataracts: Causes, Symptoms & Modern Surgery',
      bodySw: 'Mtoto wa jicho ni kufifia au kuwa na ukungu kwa lenzi ya asili ya jicho inayokaa nyuma ya mboni. Hali hii hufanya vitu kuonekana kama unatazama dirisha lenye ukungu au moshi.',
      bodyEn: 'A cataract is the progressive clouding of the clear natural crystalline lens behind your pupil, making the world look hazy, washed out, or like looking through a frosted window.',
      tipSw: 'Mtoto wa jicho hautibiwi kwa matone ya dawa bali kwa upasuaji mdogo wa kisasa unaochukua dakika 15 tu.',
      tipEn: 'Cataracts cannot be cured with eye drops; modern 15-minute outpatient surgery cleanly restores clear vision.',
      whatIsItSw: 'Lenzi ya asili ya jicho imeundwa kwa maji na protini zilizopangwa vizuri ili mwanga upite bila kizuizi. Kadiri umri unavyoongezeka, mionzi ya jua au kisukari husababisha protini hizi kugandana na kutengeneza ukungu unaozidi kuwa mzito na kuzuia mwanga kufika kwenye retina.',
      whatIsItEn: 'The crystalline lens is composed of water and crystalline proteins arranged with precision for optical clarity. Aging, UV exposure, and systemic diabetes cause these proteins to aggregate into cloudy clumps that block light transmission to the retina.',
      causesSw: [
        '1. Kuzeeka kwa kawaida (hasa baada ya miaka 55 na kuendelea).',
        '2. Ugonjwa wa kisukari usiodhibitiwa vizuri na shinikizo la damu.',
        '3. Kupigwa na jua kali la kitropiki kwa miaka mingi bila miwani ya UV.',
        '4. Jeraha la jicho lililowahi kutokea zamani au matumizi ya dawa za steroids bila uangalizi.',
      ],
      causesEn: [
        '1. Natural biological aging (prevalence accelerates notably past age 55).',
        '2. Uncontrolled diabetes mellitus inducing sorbitol buildup in the lens.',
        '3. Lifelong unprotected exposure to ambient tropical UV radiation.',
        '4. Ocular trauma or prolonged, unmonitored corticosteroid medication use.',
      ],
      symptomsSw: [
        'Ukungu unaozidi kuongezeka taratibu bila maumivu yoyote ya jicho.',
        'Kushindwa kuona vizuri usiku na taa za magari kuleta miale mikali inayozuia kuona.',
        'Rangi za vitu kuonekana zimefifia au kuwa za njano.',
        'Miwani yako ya kawaida kuacha kusaidia ghafla.',
      ],
      symptomsEn: [
        'Painless, gradual, progressive blurring of visual detail.',
        'Significant glare and blinding halos around oncoming vehicle headlamps at night.',
        'Colors appearing faded, washed out, or tinged yellow.',
        'Frequent changes in eyeglass prescriptions that no longer provide clarity.',
      ],
      avoidSw: [
        '1. Acha kuamini imani potofu kwamba mtoto wa jicho anaweza kuyeyushwa kwa asali, mkojo, au maji ya ndimu.',
        '2. Acha kutumia matone ya macho ya kienyeji au dawa za kemikali bila maagizo ya daktari.',
        '3. Acha kuvuta sigara na epuka jua kali bila miwani ya UV.',
      ],
      avoidEn: [
        '1. Never use folk home remedies like honey, lime juice, or herbal concoctions inside the eye.',
        '2. Avoid unverified over-the-counter eye drops claiming to dissolve cataracts.',
        '3. Avoid smoking and unprotected sun exposure which speed up lens opacification.',
      ],
      actionsSw: [
        '1. Fika hospitali ya macho ili daktari akague kiwango cha ukungu wa lenzi.',
        '2. Ikiwa mtoto wa jicho unazuia shughuli zako za kila siku, fanya upasuaji mdogo ambapo lenzi iliyozeeka inatolewa na kuwekwa lenzi mpya safi ya kudumu (IOL).',
        '3. Dhibiti kiwango cha sukari mwilini ikiwa una ugonjwa wa kisukari.',
        '4. Vaa miwani ya UV400 kila unapokuwa nje juani.',
      ],
      actionsEn: [
        '1. Visit an eye hospital for slit-lamp biomicroscopy and cataract grading.',
        '2. When cataracts impede daily work or driving, schedule modern sutureless phacoemulsification with intraocular lens (IOL) implantation.',
        '3. Maintain tight glycemic control if you live with diabetes.',
        '4. Wear UV400 certified sunglasses whenever outdoors.',
      ],
      whenToSeeDoctorSw: 'Ukiona uoni unazidi kuwa mweupe au huwezi tena kutambua nyuso za watu, nenda kwa daktari wa macho kwa ushauri wa upasuaji salama.',
      whenToSeeDoctorEn: 'Schedule a surgical consultation when blurry vision prevents safe driving, reading, or independent daily living.',
    ),

    // 10. Glaucoma: The Silent Thief of Sight
    EyeFact(
      id: 'glaucoma',
      art: FactArt.eye,
      titleSw: 'Glaucoma (Shinikizo la Jicho): Mwizi wa Kuona Kimyakimya',
      titleEn: 'Glaucoma: The Silent Thief of Sight',
      bodySw: 'Glaucoma ni kundi la magonjwa yanayoharibu mshipa mkuu wa kuona (optic nerve) mara nyingi kutokana na kupanda kwa shinikizo la ndani ya jicho. Huharibu uoni kuanzia pembeni bila kutoa onyo.',
      bodyEn: 'Glaucoma is a group of eye diseases that damage the optic nerve, typically driven by elevated intraocular pressure. It erodes peripheral vision silently without early warning symptoms.',
      tipSw: 'Ikiwa una umri wa miaka 40 au una ndugu mwenye glaucoma, pima shinikizo la macho kila mwaka.',
      tipEn: 'If you are over 40 or have a family history of glaucoma, have your eye pressure tested annually.',
      whatIsItSw: 'Ndani ya jicho kuna maji maalum (aqueous humor) yanayozalishwa na kutoka kupitia mifereji midogo. Mifereji hiyo ikiziba, maji hujaa na kuongeza mgandamizo (shinikizo) ndani ya jicho. Mgandamizo huu husukuma na kuua nyuzi za mshipa wa fahamu wa kuona, na uoni ukishapotea hauwezi kurudishwa tena.',
      whatIsItEn: 'Ciliary processes continuously produce aqueous humor which drains through the trabecular meshwork. If drainage pathways become restricted, intraocular pressure (IOP) rises, mechanically compressing and destroying fragile optic nerve fibers, leading to irreversible blindness.',
      causesSw: [
        '1. Kurithi: Kuwa na mzazi au ndugu wa damu aliyewahi kuwa na glaucoma au aliyepoteza uoni uzeeni.',
        '2. Umri mkubwa (hasa kuanzia miaka 40 na kuendelea).',
        '3. Asili ya mwili: Watu wa asili ya Kiafrika wako kwenye hatari kubwa zaidi ya kupata glaucoma katika umri mdogo.',
        '4. Matumizi ya muda mrefu ya dawa zenye steroids (za kupaka, matone, au kumeza) bila udhibiti wa daktari.',
      ],
      causesEn: [
        '1. Heredity: Strong familial genetic predisposition in first-degree relatives.',
        '2. Advancing age (risk rises sharply past 40).',
        '3. African ancestry: Higher statistical prevalence and earlier, more aggressive onset.',
        '4. Long-term unsupervised use of topical, inhaled, or systemic corticosteroid medications.',
      ],
      symptomsSw: [
        'Glaucoma ya kawaida (Open-Angle) HAINAGA DALILI YOYOTE mwanzoni – hakuna maumivu wala jicho kuwa jekundu.',
        'Uoni wa pembeni kuanza kufutika taratibu kana kwamba unatazama kupitia bomba (tunnel vision).',
        'Katika Glaucoma ya ghafla (Angle-Closure): Maumivu makali sana ya jicho, kichefuchefu, kutapika, na kuona duara za rangi kuzunguka taa.',
      ],
      symptomsEn: [
        'Primary open-angle glaucoma produces ZERO early symptoms — no pain, no redness, no early blur.',
        'Gradual peripheral visual field loss narrowing into tunnel vision.',
        'In acute angle-closure: Sudden excruciating ocular pain, severe headaches, nausea, vomiting, and colored halos.',
      ],
      avoidSw: [
        '1. Acha kabisa kusubiri hadi uanze kuona vibaya ndipo ukapime macho – glaucoma ikianza kuonekana kwenye uoni, ule uliopotea haurudi kamwe.',
        '2. Acha kuacha kutumia matone uliyopewa na daktari kisa "macho yameshapona" (matone ya glaucoma ni ya kudhibiti maisha yote).',
        '3. Acha kutumia dawa za steroids bila ushauri wa daktari wa macho.',
      ],
      avoidEn: [
        '1. Never postpone eye exams until vision degrades — damaged optic nerve fibers can never be regenerated.',
        '2. Never discontinue prescribed pressure-lowering drops because your eyes feel fine.',
        '3. Avoid self-administering steroid eye drops or skin creams around the eyes.',
      ],
      actionsSw: [
        '1. Pima shinikizo la jicho (IOP) na kuangaliwa mshipa wa kuona angalau mara moja kwa mwaka.',
        '2. Ikiwa uligundulika kuwa na glaucoma, weka matone yako ya jicho kila siku kwa wakati uliopangiwa.',
        '3. Wajulishe ndugu zako wa damu (watoto, kaka, dada) kuwa wapime macho kwani wako kwenye hatari kubwa ya urithi.',
      ],
      actionsEn: [
        '1. Undergo annual tonometry, pachymetry, and optic nerve evaluations.',
        '2. If diagnosed, adhere strictly to your daily hypotensive drop regimen without skipping doses.',
        '3. Encourage first-degree blood relatives to undergo comprehensive glaucoma screening.',
      ],
      whenToSeeDoctorSw: 'Ukipata maumivu makali ya ghafla ya jicho yanayoambatana na maumivu ya kichwa, kichefuchefu na ukungu, nenda hospitali ya dharura haraka sana.',
      whenToSeeDoctorEn: 'Rush to an emergency eye center if you experience sudden unbearable eye ache paired with nausea and cloudy vision (acute angle closure).',
    ),

    // 11. Diabetes & Diabetic Retinopathy Prevention
    EyeFact(
      id: 'diabetes',
      art: FactArt.eye,
      titleSw: 'Ugonjwa wa Kisukari na Macho (Diabetic Retinopathy)',
      titleEn: 'Diabetes & Diabetic Retinopathy Prevention',
      bodySw: 'Kiwango cha juu cha sukari kwenye damu huharibu mishipa midogo ya damu ya retina, na kusababisha kuvuja kwa damu na maji na kuleta upofu unaoweza kuzuilika.',
      bodyEn: 'Elevated blood glucose damages the delicate micro-vessels nourishing the retina, causing fluid leaks, swelling, hemorrhages, and avoidable vision loss.',
      tipSw: 'Wagonjwa wote wa kisukari wanatakiwa kupimwa retina kupitia mboni iliyopanuliwa (Dilated Fundus Exam) kila mwaka.',
      tipEn: 'Every person diagnosed with diabetes must undergo an annual dilated retinal examination.',
      whatIsItSw: 'Mishipa midogo inayolisha retina hupoteza uimara kutokana na sukari nyingi (hyperglycemia). Mishipa hii huanza kuvuja damu na maji (macular edema). Jicho linapokosa damu, hujaribu kukuza mishipa mipya dhaifu (neovascularization) inayoweza kupasuka na kufunika jicho lote kwa damu (vitreous hemorrhage) au kuvuta retina ikabanduka.',
      whatIsItEn: 'Chronic hyperglycemia weakens retinal micro-capillaries, leading to microaneurysms, vascular leakage, and diabetic macular edema. Retinal ischemia triggers abnormal, fragile new vessel growth that easily tears, bleeds into the vitreous gel, or leads to tractional retinal detachment.',
      causesSw: [
        '1. Kuwa na ugonjwa wa kisukari (Aina ya 1 au 2) kwa miaka mingi.',
        '2. Sukari ya damu kutodhibitiwa ipasavyo (HbA1c kuwa zaidi ya 7%).',
        '3. Kuwa na shinikizo la juu la damu (BP) au lehemu (cholesterol) nyingi pamoja na kisukari.',
        '4. Uvutaji wa sigara unaoongeza uharibifu wa mishipa ya damu.',
      ],
      causesEn: [
        '1. Living with type 1 or type 2 diabetes over prolonged durations.',
        '2. Inadequate glycemic control with an HbA1c consistently above 7%.',
        '3. Co-existing hypertension or hyperlipidemia accelerating microvascular breakdown.',
        '4. Cigarette smoking which worsens tissue hypoxia.',
      ],
      symptomsSw: [
        'Mwanzoni mgonjwa HASIKII chochote na uoni unaendelea kuwa safi kabisa.',
        'Kuona madoa meusi au utando unaoelea machoni (floaters).',
        'Uoni kubadilika-badilika (asubuhi unaona vizuri, jioni ukungu mkubwa).',
        'Kupoteza ghafla uwezo wa kuona katikati au kuona kiza totoro.',
      ],
      symptomsEn: [
        'Early diabetic retinopathy presents NO warning symptoms or pain.',
        'Dark floating spots, threads, or cobwebs drifting across your field of view.',
        'Fluctuating vision clarity correlated with shifts in blood sugar levels.',
        'Sudden profound loss of central vision from vitreous hemorrhage.',
      ],
      avoidSw: [
        '1. Acha kabisa kusubiri hadi uoni uharibike ndipo ukapime macho – uharibifu wa kisukari ukifika mbali ni mgumu kuurudisha.',
        '2. Acha kula vyakula vya sukari, wanga mweupe mwingi, na vinywaji vyenye sukari ya bandia.',
        '3. Acha kuruka dawa zako za kisukari au kuacha kupima kiwango chako cha sukari nyumbani.',
      ],
      avoidEn: [
        '1. Never wait for vision symptoms before visiting an ophthalmologist.',
        '2. Avoid consuming sugary sodas, refined starches, and ultra-processed sweets.',
        '3. Never miss diabetes medication doses or neglect regular glucose self-monitoring.',
      ],
      actionsSw: [
        '1. Pima retina kwa daktari wa macho kila mwaka kwa kupanua mboni kwa matone.',
        '2. Dhibiti kiwango cha sukari: pima mara kwa mara na weka kiwango cha HbA1c chini ya 7%.',
        '3. Dhibiti shinikizo la damu (BP chini ya 130/80) na fanya mazoezi ya wastani kila siku.',
        '4. Kula lishe kamili ya mboga za asili, vyakula vya nafaka zisizokobolewa na protini safi.',
      ],
      actionsEn: [
        '1. Schedule an annual dilated fundus evaluation or retinal photo screening.',
        '2. Maintain strict glycemic targets aiming for an HbA1c under 7.0%.',
        '3. Manage blood pressure (under 130/80 mmHg) and lipid levels.',
        '4. Exercise moderately for 30 minutes daily and eat fiber-rich whole foods.',
      ],
      whenToSeeDoctorSw: 'Ukiona madoa meusi yanayoongezeka ghafla au kiza kinachofunika jicho, fika hospitali ya macho mara moja.',
      whenToSeeDoctorEn: 'If you notice a sudden wave of dark floaters or a shadow over vision, visit an emergency retinal specialist immediately.',
    ),

    // 12. Optimal Screen Distances & Ergonomics
    EyeFact(
      id: 'distance',
      art: FactArt.screen,
      titleSw: 'Umbali Sahihi wa Skrini za Simu na Kompyuta',
      titleEn: 'Optimal Screen Distances & Ergonomics',
      bodySw: 'Simu inapaswa kuwa umbali wa sentimita 35–40 kutoka usoni, na kompyuta sentimita 50–70. Kuweka skrini karibu mno huchosha misuli ya jicho haraka sana na huongeza tatizo la kutokuona mbali.',
      bodyEn: 'Smartphones belong 35–40 cm from your eyes, and computer monitors 50–70 cm. Holding screens too close forces excessive muscle accommodation and accelerates myopia.',
      tipSw: 'Inua simu juu hadi usawa wa macho badala ya kuinamisha shingo na kuibana karibu na uso.',
      tipEn: 'Raise the phone up toward eye level rather than bending your neck and hunching close.',
      whatIsItSw: 'Kila unaposogeza kitu karibu na macho, nguvu ya kulenga (accommodation) inatakiwa iongezeke mara dufu. Kitu kikiwa sentimita 20 badala ya 40, misuli ya jicho inafanya kazi mara mbili zaidi ya kawaida, na kusababisha jicho kurefuka kuelekea nyuma (myopia progression) hasa kwa vijana na watoto.',
      whatIsItEn: 'Optical accommodation demands are inversely proportional to distance. Decreasing distance from 40 cm to 20 cm doubles dioptric stress on the ciliary muscle and stimulates axial elongation in children and young adults.',
      causesSw: [
        '1. Mazoea ya kusoma simu ukiwa umelala au ukiwa kwenye mwanga hafifu.',
        '2. Maandishi madogo sana ya mfumo yanayokulazimisha kusogeza skrini karibu.',
      ],
      causesEn: [
        '1. Reading small screens while reclining in poor ambient illumination.',
        '2. Microscopic system font settings that encourage extreme close viewing.',
      ],
      symptomsSw: [
        'Macho kuuma, kuchoka na kuvimba baada ya muda mfupi wa kutumia simu.',
        'Maumivu ya shingo, mabega na paji la uso kutokana na mkao mbovu.',
      ],
      symptomsEn: [
        'Premature eye ache, burning, and heaviness after short screen sessions.',
        'Cervical neck, trapezius shoulder tension, and tension headaches from tech-neck posture.',
      ],
      avoidSw: [
        '1. Acha kusoma simu umbali wa chini ya sentimita 30 kutoka usoni.',
        '2. Acha kutumia kompyuta huku kioo chake kikiwa juu kuliko usawa wa macho yako (inaongeza ukavu).',
      ],
      avoidEn: [
        '1. Never hold hand-held screens closer than 30–35 cm from your eyes.',
        '2. Avoid monitors positioned above eye level which increases exposed corneal surface area.',
      ],
      actionsSw: [
        '1. Shika simu umbali wa sentimita 35-40 (takriban urefu wa kutoka kiwiko hadi kwenye ngumi ya mkono wako).',
        '2. Weka kompyuta umbali wa urefu kamili wa mkono wako (sentimita 50-70).',
        '3. Ongeza ukubwa wa maneno kwenye simu kupitia mipangilio ya Display.',
      ],
      actionsEn: [
        '1. Maintain the Harmon distance (elbow-to-knuckle distance, ~35-40 cm) for phones.',
        '2. Keep desktop displays at an arm’s length (50–70 cm) with screen top slightly below eye level.',
        '3. Adjust system font sizing to large for effortless legibility.',
      ],
      whenToSeeDoctorSw: 'Kama unajikuta kila mara unalazimika kusogeza vitu karibu sana ili uone, pima macho kupata miwani inayofaa.',
      whenToSeeDoctorEn: 'If you find yourself reflexively dragging reading material closer to decode words, schedule a comprehensive refraction exam.',
    ),

    // 13. Pediatric Vision & Outdoor Natural Light
    EyeFact(
      id: 'children',
      art: FactArt.food,
      titleSw: 'Macho ya Watoto, Michezo ya Nje na Kuzuia Myopia',
      titleEn: 'Pediatric Vision & Outdoor Natural Light',
      bodySw: 'Kutumia saa 2 kila siku nje kwenye mwanga wa asili wa jua husaidia kuzuia macho ya watoto kurefuka kupita kiasi, na hivyo kuzuia tatizo la kutoona mbali (myopia) linalosababishwa na skrini za mapema.',
      bodyEn: 'Two hours of daily outdoor play under natural sunlight stimulates retinal dopamine, halting excessive eyeball elongation and preventing childhood nearsightedness (myopia).',
      tipSw: 'Wape watoto muda wa kucheza nje ya nyumba kila siku badala ya kuwaachia simu au kompyuta siku nzima.',
      tipEn: 'Encourage children to play outdoors daily rather than keeping them glued to handheld tablets all day.',
      whatIsItSw: 'Mwangaza mkali wa asili wa jua huchochea utengenezwaji wa dopamine ndani ya retina. Dopamine hii hufanya kazi kama breki inayozuia mboni ya jicho isirefuke kuelekea nyuma. Mtoto anapokaa ndani akitazama skrini za karibu, breki hii haifanyi kazi, na jicho linarefuka haraka, na kumfanya ashindwe kuona ubaoni shuleni.',
      whatIsItEn: 'Natural bright daylight triggers retinal dopamine release, which acts as a physiological brake preventing excessive axial elongation of the growing sclera. Near-work indoors starves this pathway, leading to severe myopia progression.',
      causesSw: [
        '1. Watoto kupewa simu na vichezeo vya video wakiwa na umri wa chini ya miaka 5.',
        '2. Kukaa ndani ya nyumba siku nzima bila kucheza nje kwenye mwanga wa jua.',
        '3. Kusoma au kutumia skrini umbali wa chini ya sentimita 20.',
      ],
      causesEn: [
        '1. Early childhood exposure to digital tablets and smartphones under age 5.',
        '2. Sedentary indoor confinement without outdoor playtime.',
        '3. Chronic ultra-close visual tasks held within 20 cm.',
      ],
      symptomsSw: [
        'Mtoto kubana au kukonyeza macho (squinting) anapotaka kutazama televisheni au ubao.',
        'Kusogeza vitabu au simu karibu sana na pua.',
        'Kushuka kwa ufaulu shuleni na kulalamika maumivu ya kichwa baada ya masomo.',
      ],
      symptomsEn: [
        'Squinting or craning the neck when looking at the board or television.',
        'Holding reading books, coloring pads, or phones right against the face.',
        'Unexplained drop in academic performance and frequent complaints of headaches.',
      ],
      avoidSw: [
        '1. Acha kuwapa watoto wa chini ya miaka miwili simu kama njia ya kuwatuliza wanapolia.',
        '2. Acha mtoto atumie simu au kompyuta kitandani usiku kabla ya kulala.',
        '3. Acha mtoto asome vitabu au simu akiwa amelala chali au kifudifudi.',
      ],
      avoidEn: [
        '1. Never use mobile phones as a digital babysitter for infants and toddlers under 2.',
        '2. Avoid screen exposure for children within 1 hour before bedtime.',
        '3. Do not permit reading or screen gaming while lying face-down in bed.',
      ],
      actionsSw: [
        '1. Hakikisha mtoto anatumia angalau saa 1.5 hadi 2 kila siku akicheza nje kwenye mazingira salama.',
        '2. Weka kikomo cha saa 1 kwa siku kwa matumizi ya burudani ya skrini kwa watoto wa miaka 2 hadi 6.',
        '3. Mpeleke mtoto kupima macho kabla ya kuanza darasa la kwanza au anapoanza kulalamika.',
        '4. Hakikisha chumba anachosomea kina taa nzuri na mkao sahihi wa dawati.',
      ],
      actionsEn: [
        '1. Guarantee 90–120 minutes of outdoor recreational play in natural daylight every day.',
        '2. Limit recreational screen entertainment to 1 hour daily for children aged 2 to 6.',
        '3. Arrange pediatric eye exams prior to school entry and at regular developmental stages.',
        '4. Ensure good study lighting and an ergonomic desk setup at home.',
      ],
      whenToSeeDoctorSw: 'Ukiona jicho moja linapinda (strabismus/chongo), mtoto anafumba jicho moja kusoma, au anasema haoni ubaoni, mpeleke kwa daktari wa macho haraka.',
      whenToSeeDoctorEn: 'Seek prompt optometric care if an eye turns inward/outward (strabismus), if the child closes one eye to see, or reports inability to see the blackboard.',
    ),

    // 14. Contact Lens Hygiene & Acanthamoeba Risk
    EyeFact(
      id: 'contacts',
      art: FactArt.drop,
      titleSw: 'Usafi na Matumizi Sahihi ya Lenzi (Contact Lenses)',
      titleEn: 'Contact Lens Hygiene & Acanthamoeba Risk',
      bodySw: 'Lenzi za macho zinahitaji usafi wa hali ya juu. Kulala nazo, kuogelea nazo, au kuzisafisha kwa maji ya bomba kunaweza kusababisha vidonda hatari kwenye kioo cha jicho na upofu ndani ya saa 24.',
      bodyEn: 'Contact lenses demand rigorous hygiene. Sleeping, showering, or swimming in contacts introduces fatal amoebic infections (Acanthamoeba) that can destroy cornea tissue within 24 hours.',
      tipSw: 'Osha mikono kwa sabuni na kausha kabisa kabla ya kushika lenzi zako, na kamwe usilale ukiwa umezivaa.',
      tipEn: 'Wash and completely dry hands before touching lenses, and never sleep wearing daytime contacts.',
      whatIsItSw: 'Lenzi hukaa moja kwa moja juu ya kioo cha jicho (cornea), ambacho kinahitaji hewa ya oksijeni ili kiendelee kuwa salama. Kulala na lenzi au kuziwekea maji ya kawaida huweka mazingira ya wadudu hatari (bakteria na ameba) kuingia kwenye kioo na kula tabaka la jicho (corneal ulcer).',
      whatIsItEn: 'Contact lenses rest on the corneal epithelium, which depends on atmospheric oxygen. Overnight wear or tap water contact creates a warm, hypoxic breeding environment for Pseudomonas and Acanthamoeba to invade corneal stroma, causing devastating microbial keratitis.',
      causesSw: [
        '1. Kulala na lenzi za macho ambazo hazikutengenezwa kwa ajili ya kulala.',
        '2. Kuosha lenzi au kisanduku chake kwa maji ya bomba, mate, au maji ya chupa badala ya dawa maalum ya lenzi (solution).',
        '3. Kuogelea au kuoga bwawani na bafuni ukiwa umevaa lenzi.',
        '4. Kuvaa lenzi zaidi ya muda uliopangwa (kwa mfano kuvaa lenzi ya mwezi mmoja kwa miezi mitatu).',
      ],
      causesEn: [
        '1. Sleeping in contact lenses not FDA-approved for extended wear.',
        '2. Rinsing lenses or lens cases with tap water, saliva, or bottled water instead of sterile multipurpose solution.',
        '3. Swimming, showering, or hot-tubbing while wearing contact lenses.',
        '4. Wearing lenses beyond their manufacturer replacement schedule.',
      ],
      symptomsSw: [
        'Jicho kuwa jekundu sana, kuuma sana, na kushindwa kutazama mwanga wowote (photophobia).',
        'Kuhisi kama kuna kitu kikubwa kinachochoma ndani ya jicho.',
        'Kioo cha jicho kuonekana na kidoti cheupe au ukungu wa ghafla.',
        'Machozi mengi na usaha unaotoka machoni.',
      ],
      symptomsEn: [
        'Severe pain, intense redness, and acute light sensitivity (photophobia).',
        'Foreign body sensation that worsens with blinking.',
        'A visible cloudy white dot or ulcer on the clear cornea.',
        'Copious tearing and purulent discharge.',
      ],
      avoidSw: [
        '1. Acha kabisa kugusisha maji ya bomba kwenye lenzi au boksi la lenzi – maji yana ameba hatari.',
        '2. Acha kulala na lenzi hata kama ni kwa ajili ya kusinzia nusu saa tu mchana.',
        '3. Acha kutumia tena (re-use) dawa ya lenzi iliyobaki kwenye boksi; mwaga yote kila siku.',
        '4. Acha kuazima au kubadilishana lenzi za urembo na mtu mwingine.',
      ],
      avoidEn: [
        '1. Never expose contacts or storage cases to tap water or unsterile fluids.',
        '2. Never sleep or take power-naps in contact lenses unless specifically prescribed.',
        '3. Never "top off" old solution in the case; dump it and refill with fresh solution each time.',
        '4. Never share colored cosmetic lenses with friends.',
      ],
      actionsSw: [
        '1. Osha mikono vizuri kwa sabuni na uikaushe kwa kitambaa kisicho na nyuzi kabla ya kushika lenzi.',
        '2. Tumia dawa maalum ya kusafisha lenzi (multipurpose contact lens solution) pekee.',
        '3. Badilisha kisanduku cha kuhifadhia lenzi kila baada ya miezi 3.',
        '4. Vua lenzi mara moja jicho likianza kuwa jekundu na uvae miwani ya kawaida hadi upimwe.',
      ],
      actionsEn: [
        '1. Wash hands with soap and dry with a lint-free towel before handling lenses.',
        '2. Use fresh multipurpose disinfectant solution every single day.',
        '3. Replace your lens storage case every 3 months to prevent biofilm buildup.',
        '4. Remove lenses immediately upon any redness or discomfort, switch to spectacles, and call your optometrist.',
      ],
      whenToSeeDoctorSw: 'Ukivua lenzi na jicho bado likawa linauma, kuwa jekundu, au kuona kidoti cheupe kwenye kioo, hii ni dharura ya haraka inayohitaji kuonwa na daktari wa macho.',
      whenToSeeDoctorEn: 'If an eye remains red, painful, or photophobic after lens removal, see an eye doctor immediately — corneal ulcers can progress to perforation within 48 hours.',
    ),

    // 15. Hand Hygiene & Preventing Ocular Infections
    EyeFact(
      id: 'hands',
      art: FactArt.eye,
      titleSw: 'Usafi wa Mikono na Kuzuia Maambukizi ya Machoni',
      titleEn: 'Hand Hygiene & Preventing Ocular Infections',
      bodySw: 'Mikono yetu hubeba mamilioni ya bakteria na virusi kutoka kwenye simu, fedha na milango. Kusugua macho kwa mikono michafu ndiyo chanzo kikuu cha maambukizi ya jicho jekundu na michubuko.',
      bodyEn: 'Our hands harbor millions of environmental pathogens from doorknobs, banknotes, and touchscreens. Rubbing eyes with unwashed hands is the primary vector for bacterial and viral conjunctivitis.',
      tipSw: 'Osha mikono yako kwa sabuni na maji yanayotiririka kabla ya kugusa uso au kuweka matone ya jicho.',
      tipEn: 'Wash hands thoroughly with soap and running water before touching your face or instilling eye drops.',
      whatIsItSw: 'Uso wa jicho umefunikwa na utando mwembamba wa conjunctiva wenye unyevu, ambao ni mazingira rahisi kwa virusi (kama adenovirus) na bakteria (kama staphylococcus) kuzaliana wanapoingizwa na vidole.',
      whatIsItEn: 'The warm, moist conjunctival mucosa offers an optimal transmission surface for adenoviruses, bacteria, and allergens transferred directly by fingertip contact, breaching natural antimicrobial tear enzymes.',
      causesSw: [
        '1. Mazoea ya kusugua macho kwa vidole kila unapojisikia uchovu au usingizi.',
        '2. Kushika simu, vitasa vya milango au pesa kisha kugusa macho mara moja.',
        '3. Kushiriki taulo za uso au mito ya kulalia na mtu mwenye jicho jekundu.',
      ],
      causesEn: [
        '1. Habitual subconscious eye-rubbing when fatigued or stressed.',
        '2. Touching smartphones, door hardware, or currency notes followed immediately by eye contact.',
        '3. Sharing facial towels, makeup, or pillows with an infected household member.',
      ],
      symptomsSw: [
        'Macho kuanza kuwasha, kutoa uteute na kuwa mekundu.',
        'Kope kugandana asubuhi unapoamka kutokana na ukoko mkavu.',
        'Michubuko midogo kwenye ngozi ya kope.',
      ],
      symptomsEn: [
        'Pruritic itching, discharge, and conjunctival injection.',
        'Crusted eyelids matted shut upon morning awakening.',
        'Follicular reaction and local periorbital irritation.',
      ],
      avoidSw: [
        '1. Acha kabisa kusugua macho kwa nguvu kwa kutumia vidole au ngumi.',
        '2. Acha kutumia kitambaa cha mfukoni (handkerchief) kilichotumika kupangusia macho.',
        '3. Acha kusalimiana kwa kushikana mikono ikiwa wewe au mwenzako ana ugonjwa wa jicho jekundu (pink eye).',
      ],
      avoidEn: [
        '1. Never vigorously rub your eyes with bare knuckles or fingers.',
        '2. Avoid using reused cloth handkerchiefs to wipe your eyelids.',
        '3. Avoid handshakes when dealing with an active pink-eye outbreak.',
      ],
      actionsSw: [
        '1. Ikiwa jicho linawasha, tumia kitambaa safi chenye maji ya baridi kukandamiza kope kwa nje badala ya kusugua.',
        '2. Osha mikono mara kwa mara kwa sabuni na maji yanayotiririka kwa angalau sekunde 20.',
        '3. Safisha kioo cha simu yako kwa kitambaa chenye pombe (alcohol wipe) mara kwa mara.',
      ],
      actionsEn: [
        '1. If your eyes itch, press a clean cool damp cloth over closed lids instead of rubbing.',
        '2. Cleanse hands with soap and flowing water for at least 20 seconds.',
        '3. Sanitize smartphone screens regularly with disinfectant wipes.',
      ],
      whenToSeeDoctorSw: 'Ukiona usaha unazidi kuwa mzito wa njano au kijani, au kope zimevimba na kufunga kabisa, onana na daktari wa macho.',
      whenToSeeDoctorEn: 'Consult an eye doctor if you observe copious yellow-green discharge or marked eyelid swelling that limits eye opening.',
    ),

    // 16. Proper Eye Drop Instillation Technique
    EyeFact(
      id: 'drops',
      art: FactArt.drop,
      titleSw: 'Jinsi ya Kuweka Matone ya Macho kwa Usahihi',
      titleEn: 'Proper Eye Drop Instillation Technique',
      bodySw: 'Tone moja tu linatosha kwa jicho moja kwa wakati mmoja; tone la pili humwagika nje bure. Usiguse ncha ya chupa kwenye jicho au kope ili kuepusha kuchafua dawa yote.',
      bodyEn: 'A single eye drop holds double the capacity of your tear sac; instilling multiple drops only spills them. Never touch the dropper tip against your eye or eyelashes to prevent bottle contamination.',
      tipSw: 'Bonyeza kona ya ndani ya jicho karibu na pua kwa dakika 1 baada ya kuweka tone ili kuzuia dawa kumezwa kooni.',
      tipEn: 'Gently press the inner corner of your eye (punctum) for 1 minute post-instillation to stop systemic absorption.',
      whatIsItSw: 'Mfuko wa chini wa jicho una uwezo wa kushikilia ujazo wa mikrolita 10 hadi 15 tu za kioevu, wakati tone moja la dawa lina mikrolita 30 hadi 50. Kwa hiyo, kuweka matone mawili au matatu kwa wakati mmoja hakusaidii zaidi, bali kunapoteza dawa na kuongeza hatari ya dawa kuingia kwenye mzunguko wa damu kupitia mrija wa pua (nasolacrimal duct).',
      whatIsItEn: 'The lower fornix accommodates only 10–15 microliters of fluid, while an average ophthalmic dropper emits 30–50 microliters. Multiple successive drops overflow and drain down the nasolacrimal duct into the throat, increasing unwanted systemic side effects.',
      causesSw: [
        '1. Kuweka matone huku ncha ya chupa ikigusa kope, machozi, au vidole.',
        '2. Kuweka matone mawili tofauti ya dawa mfululizo bila kusubiri dakika 5 katikati.',
        '3. Kutumia dawa ya matone iliyofunguliwa zaidi ya siku 28 zilizopita.',
      ],
      causesEn: [
        '1. Touching the dropper tip directly to eyelashes, cornea, or fingertips.',
        '2. Administering two different prescribed drops back-to-back without a 5-minute spacing window.',
        '3. Using an opened eye-drop bottle beyond its 28-day sterility limit.',
      ],
      symptomsSw: [
        'Kuhisi ladha chungu ya dawa kooni baada ya kuweka tone machoni.',
        'Dawa zote kumwagika kwenye mashavu badala ya kubaki jichoni.',
        'Jicho kuwasha zaidi kutokana na bakteria walioingia kwenye chupa ya dawa.',
      ],
      symptomsEn: [
        'Bitter medication taste in the back of the throat.',
        'Wasted medication washing down your cheeks.',
        'Secondary bacterial irritation due to contaminated dropper nozzles.',
      ],
      avoidSw: [
        '1. Acha kugusisha ncha ya chupa ya dawa kwenye jicho, kope, au ngozi yako.',
        '2. Acha kutumia chupa moja ya matone kati ya watu wawili – hii hueneza maambukizi kwa kasi.',
        '3. Acha kutumia dawa za matone zilizopitisha mwezi mmoja tangu zilipofunguliwa.',
      ],
      avoidEn: [
        '1. Never allow the bottle dropper tip to touch ocular tissue, eyelids, or fingers.',
        '2. Never share personal eye drop bottles between family members or colleagues.',
        '3. Never use an opened medication bottle older than 28–30 days.',
      ],
      actionsSw: [
        '1. Inamisha kichwa nyuma, vuta kope la chini kwa upole kutengeneza mfuko mdogo.',
        '2. Shikilia chupa juu ya jicho, dondosha tone moja pekee ndani ya mfuko huo.',
        '3. Fumba jicho taratibu na ukandamize kona ya ndani ya jicho (karibu na pua) kwa dakika 1.',
        '4. Ikiwa una dawa mbili tofauti, subiri angalau dakika 5 kabla ya kuweka dawa ya pili.',
      ],
      actionsEn: [
        '1. Tilt head backward, gently draw down the lower lid to create a small pocket.',
        '2. Hold the dropper above the eye and release exactly ONE drop into the pocket.',
        '3. Close eyelids gently and occlude the tear duct at the inner corner with your finger for 1 minute.',
        '4. When using multiple medications, wait 5 full minutes between bottles.',
      ],
      whenToSeeDoctorSw: 'Ukihisi mzio mkali, ngozi ya kope kuvimba, au maumivu yakiongezeka baada ya kuweka dawa, wasiliana na daktari aliyekupatia dawa hiyo mara moja.',
      whenToSeeDoctorEn: 'Contact your prescribing doctor if eye drops trigger immediate swelling, worsening pain, or localized allergic reactions.',
    ),

    // 17. Display Brightness & Nocturnal Blue Light
    EyeFact(
      id: 'brightness',
      art: FactArt.screen,
      titleSw: 'Mwangaza wa Skrini na Mwanga wa Bluu Usiku',
      titleEn: 'Display Brightness & Nocturnal Blue Light',
      bodySw: 'Kutumia skrini yenye mwangaza mkali chumbani kukiwa na giza hufanya mboni kutanuka na kupokea mwanga mkali wa bluu unaoharibu homoni ya usingizi (melatonin) na kuongeza uchovu wa jicho.',
      bodyEn: 'Using high-brightness screens in pitch-dark bedrooms dilates pupils, flooding photoreceptors with intense high-energy blue wavelengths that suppress melatonin and amplify eyestrain.',
      tipSw: 'Washa "Night Light" au "Eye Comfort Shield" kwenye simu na kompyuta kuanzia saa 12 jioni.',
      tipEn: 'Enable "Night Light" or "Eye Comfort" warm modes on your devices from 6 PM onward.',
      whatIsItSw: 'Mwanga wa bluu (blue light) wenye urefu wa wimbi wa nanometer 415-455 hutawanyika kwa urahisi ndani ya jicho na kupunguza utofautishaji wa picha (contrast). Pia huchochea seli maalum za retina (ipRGCs) zinazoambia ubongo kuwa bado ni mchana, na kuzuia uzalishaji wa melatonin.',
      whatIsItEn: 'Short-wavelength blue-violet photons (415–455 nm) scatter within ocular media, degrading contrast and inducing chromatic aberration. They also stimulate intrinsically photosensitive retinal ganglion cells (ipRGCs), tricking circadian pacemakers and halting melatonin.',
      causesSw: [
        '1. Kusoma simu kitandani taa zote za chumbani zikiwa zimezimwa.',
        '2. Kuweka mwangaza wa skrini kuwa 100% ukiwa ndani ya chumba chenye mwanga hafifu.',
        '3. Kutumia mandhari meupe (White background) badala ya Dark Mode wakati wa usiku.',
      ],
      causesEn: [
        '1. Late-night smartphone reading in a completely darkened room.',
        '2. Display brightness maxed out in low-light interior environments.',
        '3. Reading white backgrounds at night without Dark Mode or blue light filtering.',
      ],
      symptomsSw: [
        'Kushindwa kupata usingizi licha ya kuhisi umechoka sana.',
        'Macho kuwaka moto na maumivu ya paji la uso unapoamka usiku.',
        'Macho kutoa machozi na kutoona vizuri asubuhi inayofuata.',
      ],
      symptomsEn: [
        'Difficulty falling asleep despite pronounced physical exhaustion.',
        'Ocular burning sensations and frontal brow ache.',
        'Morning photosensitivity, dry discomfort, and mild visual blur.',
      ],
      avoidSw: [
        '1. Acha kutumia simu chumbani kukiwa giza totoro – kama lazima utumie, washa taa ya kando ya kitanda (bedside lamp).',
        '2. Acha mwangaza wa skrini uwe unang\'aa kuliko chumba ulichomo.',
        '3. Acha kuweka simu karibu sana na macho gizani.',
      ],
      avoidEn: [
        '1. Never use mobile devices in a pitch-black bedroom without soft ambient bias lighting.',
        '2. Never keep displays significantly brighter than ambient room illumination.',
        '3. Avoid bringing screens close to your face in darkness.',
      ],
      actionsSw: [
        '1. Rekebisha mwangaza wa skrini ulingane sawa na mwanga wa chumba.',
        '2. Washa mfumo wa Dark Mode na kioo chenye mwanga wa njano (Warm/Night Light) ifikapo jioni.',
        '3. Weka simu mbali na kitanda nusu saa kabla ya kulala ili upate usingizi bora.',
      ],
      actionsEn: [
        '1. Calibrate screen luminance to harmonize with ambient room light.',
        '2. Activate Dark Mode and warm color temperatures (Night Shift / Eye Comfort) after dusk.',
        '3. Keep smartphones off your bed 30 minutes before sleep.',
      ],
      whenToSeeDoctorSw: 'Ukiona maumivu ya kichwa na macho hayakomi licha ya kubadilisha mwangaza, pima macho kuona kama unahitaji miwani ya kuzuia mwanga wa bluu au ya kurekebisha kuona.',
      whenToSeeDoctorEn: 'If eyestrain and sleep disruption persist, visit your optometrist for an evaluation of refractive state and specialized blue-filtering lenses.',
    ),

    // 18. Asthenopia & Refractive Headaches
    EyeFact(
      id: 'headache',
      art: FactArt.clock,
      titleSw: 'Maumivu ya Kichwa Yanayosababishwa na Macho',
      titleEn: 'Asthenopia & Refractive Headaches',
      bodySw: 'Maumivu ya paji la uso, maumivu ya nyuma ya macho au shingo yanayotokea baada ya kusoma au kutumia skrini mara nyingi husababishwa na misuli ya jicho kukaza kwa nguvu ili kufidia tatizo la uoni.',
      bodyEn: 'Headaches centered over brow arches, behind the globes, or along the cervical spine during near work frequently stem from ciliary muscles straining to compensate for uncorrected refractive errors.',
      tipSw: 'Ikiwa maumivu ya kichwa hutokea mara kwa mara unaposoma au mchana, pima macho kwanza kabla ya kumeza dawa za maumivu kila siku.',
      tipEn: 'If headaches reliably emerge after reading or screen work, get an eye exam before relying on daily painkillers.',
      whatIsItSw: 'Jicho likiwa na tatizo la kuona (kama vile astigmatism, hyperopia, au presbyopia), misuli ya ndani ya jicho inalazimika kufanya kazi bila kupumzika ili picha iwe wazi. Msuguano huu wa misuli hutuma ishara za maumivu kupitia neva ya trigeminal na kuleta maumivu ya paji la uso na kichwa (ocular asthenopia).',
      whatIsItEn: 'Uncorrected refractive anomalies (hyperopia, astigmatism, binocular phorias) force ciliary and extraocular muscles into sustained spasms. Sensory afferents from the ophthalmic branch of the trigeminal nerve refer this tension as frontal headaches and brow fatigue.',
      causesSw: [
        '1. Kuwa na tatizo la kutoona vizuri bila kuvaa miwani sahihi.',
        '2. Kuvaa miwani iliyopitwa na wakati au isiyo na vipimo sahihi vya jicho lako.',
        '3. Kusoma kwenye mwanga hafifu sana au unaometa (flickering light).',
      ],
      causesEn: [
        '1. Uncorrected low-to-moderate hyperopia, astigmatism, or convergence insufficiency.',
        '2. Wearing outdated eyeglass prescriptions with displaced optical centers.',
        '3. Working in dim or flickering lighting requiring chronic squinting.',
      ],
      symptomsSw: [
        'Maumivu ya paji la uso au maeneo ya juu ya nyusi yanayoanza mchana baada ya kusoma.',
        'Kuhisi macho kuwa mazito na kutaka kuyafumba.',
        'Kupoteza uwezo wa kulenga herufi (herufi kuanza kucheza au kuwa mbili).',
        'Maumivu kuondoka baada ya kulala au kupumzika mwishoni mwa wiki.',
      ],
      symptomsEn: [
        'Dull aching brow ache or retrobulbar pressure developing after prolonged reading.',
        'Heavy eyelid sensation and reluctance to continue visual tasks.',
        'Transient double vision or dancing letters due to muscle exhaustion.',
        'Headache relief on weekends or after sound restful sleep.',
      ],
      avoidSw: [
        '1. Acha kumeza dawa za kutuliza maumivu (kama Panadol au Diclofenac) kila siku bila kuchunguza chanzo cha maumivu.',
        '2. Acha kulazimisha kusoma maandishi madogo ukiwa umechoka.',
        '3. Acha kutumia miwani ya kusomea ya kuazima kutoka kwa mtu mwingine.',
      ],
      avoidEn: [
        '1. Avoid masking recurring daily headaches with analgesics without diagnosing the underlying etiology.',
        '2. Avoid forcing prolonged near focus through severe fatigue.',
        '3. Never use borrowed glasses whose pupillary distance does not match yours.',
      ],
      actionsSw: [
        '1. Fanya uchunguzi kamili wa kuona (refraction test) kwa daktari wa macho.',
        '2. Pata miwani sahihi iliyotengenezwa kulingana na umbali wa mboni zako (pupillary distance - PD).',
        '3. Hakikisha una mwanga wa kutosha unaotoka juu au pembeni na si unaopiga moja kwa moja usoni.',
        '4. Tumia kanuni ya 20-20-20 ili kuilegeza misuli ya ndani ya jicho.',
      ],
      actionsEn: [
        '1. Complete a comprehensive subjective and objective refraction exam with an optometrist.',
        '2. Obtain custom lenses made with precise optical centering to avoid prism-induced eyestrain.',
        '3. Provide even, diffuse workstation lighting without direct glare.',
        '4. Apply 20-20-20 pauses to permit ciliary muscle relaxation throughout the day.',
      ],
      whenToSeeDoctorSw: 'Ikiwa maumivu ya kichwa yanafuatana na kuona vitu viwili (diplopia), kizunguzungu kikali, au kutapika, fika kituo cha matibabu haraka.',
      whenToSeeDoctorEn: 'Seek emergency evaluation if headaches are accompanied by sudden double vision (diplopia), vomiting, or neurological weakness.',
    ),

    // 19. Night Driving Vision, Glare & Anti-Reflective Lenses
    EyeFact(
      id: 'night-driving',
      art: FactArt.moon,
      titleSw: 'Kuona Usiku na Kuendesha Gari kwa Usalama',
      titleEn: 'Night Driving Vision, Glare & Anti-Reflective Lenses',
      bodySw: 'Miale mikali ya taa za magari yanayokuja mbele na mionzi ya taa za barabarani inaweza kumfanya dereva apoteze uoni kwa sekunde kadhaa. Miwani yenye koti ya Anti-Reflective (AR) huondoa miale hii.',
      bodyEn: 'Blinding glare from oncoming LED headlights and street lamps can temporarily white out a driver’s vision for crucial seconds. Anti-Reflective (AR) coatings effectively tame this reflection.',
      tipSw: 'Weka kioo cha mbele cha gari kikiwa safi kabisa ndani na nje; michirizi ya mafuta na vumbi huongeza miale ya mwanga mara dufu.',
      tipEn: 'Keep windshield glass spotless inside and outside; oily films and microscopic dust scatter light exponentially.',
      whatIsItSw: 'Wakati wa usiku, mboni ya jicho hupanuka (mydriasis) ili kupitisha mwanga mwingi zaidi. Mboni ikiwa pana, kasoro ndogo za uoni (aberrations) huonekana zaidi, na kusababisha taa za magari kuonekana kama mionzi mikubwa ya nyota (starbursts) na duara za mwanga (halos) zinazopofusha dereva kwa sekunde kadhaa (glare disability).',
      whatIsItEn: 'In dark environments, physiological pupil dilation exposes peripheral lens aberrations. Incoming high-intensity vehicle LEDs scatter across the ocular media, causing debilitating starbursts, halos, and profound loss of contrast sensitivity.',
      causesSw: [
        '1. Kuwa na upungufu mdogo wa kuona mbali (astigmatism au myopia) usiopimwa au usiotibiwa.',
        '2. Mtoto wa jicho (cataract) anayeanza kufifiza lenzi ya jicho.',
        '3. Kioo cha mbele cha gari kuwa na uchafu au michubuko midogo inayosambaza mwanga.',
        '4. Kuvaa miwani isiyo na koti ya kuzuia miale (Anti-Reflective Coating).',
      ],
      causesEn: [
        '1. Subtle uncorrected refractive astigmatism or night myopia.',
        '2. Early nuclear or cortical cataracts that scatter incoming light.',
        '3. Scratched or greasy windshield glass refracting direct beams.',
        '4. Untreated spectacle lenses that lack anti-reflective coating.',
      ],
      symptomsSw: [
        'Kushindwa kuona mistari ya barabara au watembea kwa miguu gari linapokaribia.',
        'Kuona miale mirefu inayotoka kwenye taa za magari usiku (starbursts).',
        'Kuhisi woga na wasiwasi mkubwa wa kuendesha gari wakati wa giza au mvua.',
      ],
      symptomsEn: [
        'Temporary total loss of road markings and pedestrian silhouettes during oncoming passes.',
        'Massive starburst flares and rainbow halos surrounding headlamps.',
        'Anxiety, reluctance, or refusal to operate motor vehicles after dark.',
      ],
      avoidSw: [
        '1. Acha kutazama moja kwa moja taa za gari linalokuja mbele; badala yake tazama mstari mweupe wa upande wa kushoto wa barabara.',
        '2. Acha kuvaa miwani ya jua yenye giza usiku – inapunguza mwanga unaohitajika kuona.',
        '3. Acha kuendesha gari kwa kasi usiku ikiwa unajua uoni wako si thabiti gizani.',
      ],
      avoidEn: [
        '1. Avoid staring straight into oncoming headlamps; track the white shoulder line on your near-side lane.',
        '2. Never wear dark sunglasses at night — they starve the retina of necessary photons.',
        '3. Never speed in low-contrast night conditions with compromised night vision.',
      ],
      actionsSw: [
        '1. Pima macho upate miwani yenye koti halisi ya Anti-Reflective (AR) inayozuia miale ya mwanga.',
        '2. Safisha kioo cha mbele cha gari ndani na nje kwa kitambaa safi cha microfiber kila wiki.',
        '3. Ikiwa una miaka zaidi ya 50 na unaona miale inazidi, fanya uchunguzi wa mtoto wa jicho kwa daktari wa macho.',
        '4. Hakikisha taa za gari lako zenyewe zimelingana vizuri (calibrated) ili zisiwaumize wengine.',
      ],
      actionsEn: [
        '1. Equip your prescription spectacles with premium multi-layer anti-reflective (AR) coatings.',
        '2. Clean your vehicle windshield internally and externally with a clean microfiber towel.',
        '3. If you are over 50 and glare is worsening, have an ophthalmologist evaluate for cataracts.',
        '4. Ensure your own vehicle headlights are aimed correctly to avoid blinding oncoming traffic.',
      ],
      whenToSeeDoctorSw: 'Ukiona ghafla huwezi kabisa kuona usiku (night blindness) au taa zote zina ukungu mkubwa, fika kituo cha macho haraka kwa uchunguzi wa retina.',
      whenToSeeDoctorEn: 'Consult an eye doctor if night blindness appears suddenly, which may signify retinal degeneration or significant lens changes.',
    ),

    // 20. Vitamin A, Rhodopsin & Night Blindness Prevention
    EyeFact(
      id: 'vitamin-a',
      art: FactArt.food,
      titleSw: 'Vitamini A na Kuzuia Upofu wa Usiku (Nyctalopia)',
      titleEn: 'Vitamin A, Rhodopsin & Night Blindness Prevention',
      bodySw: 'Vitamini A ni kiungo muhimu katika kutengeneza rhodopsin, kemikali inayowezesha seli za jicho kuona kwenye giza. Upungufu wake huleta upofu wa usiku na vidonda kwenye kioo cha jicho.',
      bodyEn: 'Vitamin A is an indispensable precursor to rhodopsin, the biological pigment enabling vision in low light. Deficiency causes night blindness and destructive corneal ulceration (xerophthalmia).',
      tipSw: 'Wape watoto matone ya Vitamini A kwenye vituo vya afya na uwape vyakula vya asili vya njano na kijani.',
      tipEn: 'Ensure children receive periodic Vitamin A supplementation at primary clinics alongside carotene-rich foods.',
      whatIsItSw: 'Seli za retina zinazotambua giza (rod cells) zinahitaji Vitamini A ili kutengeneza rangi ya rhodopsin. Mwili ukikosa Vitamini A, mtu anapoteza uwezo wa kuona mara tu jua linapozama (nyctalopia), na hatua ya baadaye inakausha kabisa jicho (xerophthalmia) na kutoboa kioo cha jicho.',
      whatIsItEn: 'Retinal rod photoreceptors require Vitamin A (retinol) to synthesize rhodopsin. Deficiency impairs dark adaptation (nyctalopia); unchecked progression results in conjunctival Bitot spots, severe corneal xerosis, and melting keratomalacia.',
      causesSw: [
        '1. Upungufu wa vyakula vyenye Vitamini A na mafuta kwenye mlo wa watoto na wajawazito.',
        '2. Magonjwa ya utumbo yanayozuia mwili kufyonza virutubisho na mafuta vizuri.',
        '3. Watoto kukosa matone ya dozi ya Vitamini A yanayotolewa kliniki kila baada ya miezi 6.',
      ],
      causesEn: [
        '1. Malnutrition lacking animal vitamin A (retinol) or plant beta-carotene.',
        '2. Malabsorption syndromes (celiac, chronic diarrheal disease) limiting lipid uptake.',
        '3. Missing public health periodic high-dose Vitamin A pediatric capsules.',
      ],
      symptomsSw: [
        'Mtoto au mtu mzima kuanza kujikwaa au kushindwa kutembea ifikapo saa 12 jioni.',
        'Macho kutoa povu jeupe au doa kavu lenye umbo la pembe tatu kwenye uteupe wa jicho (Bitot’s spots).',
        'Kioo cha jicho kuwa kavu, kupoteza ung\'avu na kuanza kupata ukungu mweupe.',
      ],
      symptomsEn: [
        'Child stumbling, groping for objects, or freezing as evening twilight sets in.',
        'Triangular, foamy, pearly patches on the bulbar conjunctiva (Bitot’s spots).',
        'Cornea losing its glossy luster, becoming dull, dry, and hazy.',
      ],
      avoidSw: [
        '1. Acha kuruka chanjo na matone ya Vitamini A yanayotolewa na serikali kwenye vituo vya watoto.',
        '2. Acha tabia ya kutowapa watoto mboga za majani kwa madai kuwa ni chakula cha watu wazima.',
        '3. Acha kutumia dawa za kienyeji jichoni mtoto anapoanza kuonyesha dalili za upofu wa usiku.',
      ],
      avoidEn: [
        '1. Never skip routine national vitamin A supplementation campaigns for under-5s.',
        '2. Never exclude leafy greens or eggs from toddlers’ daily meals.',
        '3. Never place herbal concoctions in an eye showing signs of xerophthalmic ulceration.',
      ],
      actionsSw: [
        '1. Kula vyakula vyenye Vitamini A kwa wingi: ini, mayai, samaki, maziwa, karoti, maboga, na mboga za majani ya kijani.',
        '2. Hakikisha watoto wote wenye umri chini ya miaka 5 wanapata matone ya Vitamini A kila baada ya miezi 6 kliniki.',
        '3. Pika mboga za majani na mafuta kidogo safi ili kusaidia Vitamini A kufyonzwa vizuri mwilini.',
      ],
      actionsEn: [
        '1. Consume natural Vitamin A sources: beef liver, egg yolks, carrots, sweet potatoes, papaya, and greens.',
        '2. Ensure all infants receive semi-annual high-dose Vitamin A capsules from 6 to 59 months.',
        '3. Prepare greens with a splash of healthy cooking oil to facilitate fat-soluble carotene absorption.',
      ],
      whenToSeeDoctorSw: 'Mtoto akishindwa kuona jioni au ukiona doa lenye povu jichoni, mpeleke hospitali mara moja; hii ni dharura ya kuokoa uoni na maisha.',
      whenToSeeDoctorEn: 'If a child exhibits night blindness or foamy dry spots on the eye, seek medical care immediately — high-dose therapeutic vitamin A is urgently required.',
    ),

    // 21. Presbyopia: Natural Near-Focus Changes Past 40
    EyeFact(
      id: 'presbyopia',
      art: FactArt.clock,
      titleSw: 'Macho ya Karibu Baada ya Miaka 40 (Presbyopia)',
      titleEn: 'Presbyopia: Natural Near-Focus Changes Past 40',
      bodySw: 'Kufikia umri wa miaka 40 hadi 45, lenzi ya asili ya jicho huanza kupoteza unyumbufu wake, na kufanya iwe vigumu kusoma herufi ndogo au simu bila kusogeza mikono mbali.',
      bodyEn: 'Around age 40 to 45, your eye’s natural crystalline lens gradually loses flexibility, making it difficult to read fine text or decode your phone without holding it farther away.',
      tipSw: 'Usione aibu kupima miwani ya kusomea (reading glasses); ni mabadiliko ya kawaida ya mwili kama vile nywele za mvi.',
      tipEn: 'Do not hesitate to obtain reading spectacles; it is an entirely normal physiological milestone like graying hair.',
      whatIsItSw: 'Ukiwa kijana, lenzi ya ndani ya jicho ni laini kama jeli na hubadilika sura kwa urahisi ili uone karibu. Kadiri miaka inavyofika 40+, protini za lenzi hukakamaa, na misuli ya jicho inashindwa kuikunja ili kulenga vitu vya karibu (Presbyopia). Hili si ugonjwa, bali ni mabadiliko ya kawaida ya kibiolojia.',
      whatIsItEn: 'During youth, the crystalline lens is remarkably supple and dynamically increases convexity to focus near objects. With age, the lens nucleus naturally compacts and hardens. By age 40+, the ciliary muscle can no longer bend the lens into close focus, a condition called presbyopia.',
      causesSw: [
        '1. Kuzeeka kwa kawaida kwa lenzi ya asili ya jicho (kutokea kwa kila binadamu kuanzia miaka 40).',
        '2. Kupungua kwa nguvu ya unyumbufu wa kapsuli ya lenzi.',
        '3. Kufanya kazi nyingi za karibu (simu, kompyuta, kusoma vitabu, kushona) ambazo zinafichua tatizo hili haraka.',
      ],
      causesEn: [
        '1. Universal biological aging and hardening of the crystalline lens matrix.',
        '2. Gradual loss of zonular elasticity and capsule deformability.',
        '3. High near-visual demands that make the deficiency noticeable.',
      ],
      symptomsSw: [
        'Kulazimika kunyoosha mikono mbali ili kusoma ujumbe wa simu au biblia/kitabu.',
        'Maandishi madogo kuonekana yenye ukungu hasa kwenye mwanga hafifu au jioni.',
        'Kuhisi maumivu ya paji la uso na macho kuchoka haraka unaposoma vitu vya karibu.',
        'Kuhitaji mwanga mkali zaidi ili uweze kusoma.',
      ],
      symptomsEn: [
        'Extending your arms to read WhatsApp messages, invoices, or fine book print.',
        'Near print blurring, especially under dim evening light.',
        'Frontal headaches, heavy eyelids, and fatigue after 10 minutes of reading.',
        'Needing unusually bright direct light to distinguish letters.',
      ],
      avoidSw: [
        '1. Acha tabia ya kununua miwani ya kusomea ya barabarani kiholela bila daktari kupima umbali wa mboni zako (PD) – miwani hiyo inaweza kuongeza kizunguzungu na maumivu ya kichwa.',
        '2. Acha kulazimisha kusoma kwa kukaza macho bila miwani (inachosha misuli ya uso bila faida).',
        '3. Acha kuazima miwani ya kusomea ya mkeo au mwenzako kwani kila mtu ana kiwango chake cha nguvu (diopter).',
      ],
      avoidEn: [
        '1. Avoid purchasing cheap, ready-made street reading glasses without checking your exact pupillary distance.',
        '2. Avoid chronic squinting and brow tension to read without appropriate optical correction.',
        '3. Never share reading glasses with partners — individual refractive powers and astigmatism vary.',
      ],
      actionsSw: [
        '1. Fanya kipimo cha macho kwa Optometrist ili kubaini kiwango kamili cha nguvu ya ziada (Add power) unachohitaji.',
        '2. Chagua aina ya miwani inayofaa mtindo wako wa maisha: Miwani ya kusomea tu (Single Vision), Miwani ya vipande viwili (Bifocal), au Miwani ya kisasa isiyo na mstari inayokuruhusu kuona umbali wote (Progressive Lenses).',
        '3. Hakikisha eneo lako la usomaji lina mwanga mzuri wa kutosha.',
        '4. Badilisha au kagua miwani yako ya kusomea kila baada ya miaka miwili kwani presbyopia huongezeka taratibu hadi miaka 60.',
      ],
      actionsEn: [
        '1. Have a comprehensive near-point refraction performed by a qualified optometrist.',
        '2. Choose the right lens solution for your lifestyle: Reading spectacles, Bifocals, or seamless Progressive Addition Lenses (PALs).',
        '3. Use well-directed reading task lighting positioned over your shoulder.',
        '4. Re-evaluate your reading power every 2 years as presbyopia naturally progresses until age ~60.',
      ],
      whenToSeeDoctorSw: 'Ukiona huwezi tena kusoma kazi zako au simu kwa raha, panga miadi na daktari wa macho upate miwani safi.',
      whenToSeeDoctorEn: 'Visit your eye clinic when near blur interferes with productivity, work screens, or daily reading enjoyment.',
    ),

    // 22. Accurate Optical Prescriptions vs Over-the-Counter Glasses
    EyeFact(
      id: 'spectacles',
      art: FactArt.eye,
      titleSw: 'Miwani Sahihi ya Macho na Madhara ya Kukisia',
      titleEn: 'Accurate Optical Prescriptions vs Over-the-Counter Glasses',
      bodySw: 'Kuvaa miwani isiyo sahihi au ya kubahatisha ya barabarani husababisha maumivu ya kichwa, kizunguzungu na uchovu wa macho. Miwani inayofaa hutengenezwa kulingana na muundo halisi wa macho yako yote mawili.',
      bodyEn: 'Wearing inaccurate or generic street spectacles triggers persistent headaches, dizziness, and eye strain. Tailored prescription lenses match the unique optics and pupillary spacing of each eye.',
      tipSw: 'Pima macho kwanza upate cheti cha daktari (prescription) kabla ya kutengeneza au kubadilisha miwani yako.',
      tipEn: 'Obtain an official clinical prescription before ordering or replacing your corrective eyewear.',
      whatIsItSw: 'Kila jicho la binadamu ni la pekee: lina nguvu yake ya uoni (sphere), umbo la kioo (cylinder/astigmatism), mwelekeo wake (axis), na umbali sahihi kati ya kitovu cha mboni ya kulia na ya kushoto (Pupillary Distance - PD). Miwani ya barabarani ina nguvu sawa kwa macho yote na haina marekebisho ya astigmatism, jambo linalolazimisha ubongo kufanya kazi ya ziada na kuleta kizunguzungu.',
      whatIsItEn: 'Every human eye is optically unique: each possesses individual spherical power, cylinder (astigmatism), cylinder axis, and precise pupillary distance (PD). Generic off-the-rack spectacles assume both eyes are identical with zero astigmatism and average centering, creating unwanted prismatic displacement and binocular strain.',
      causesSw: [
        '1. Kununua miwani ya bei nafuu kwa wachuuzi wa mitaani bila kupimwa.',
        '2. Kuendelea kuvaa miwani ya zamani ya miaka mitatu iliyopita ambayo nguvu zake zimeshabadilika.',
        '3. Kutumia miwani yenye mikwaruzo mikubwa kwenye lenzi.',
      ],
      causesEn: [
        '1. Buying cheap ready-made spectacles from street vendors without a test.',
        '2. Clinging to years-old spectacles despite gradual vision shifts.',
        '3. Wearing heavily scratched lenses that degrade contrast and scatter light.',
      ],
      symptomsSw: [
        'Kizunguzungu na hisia ya ardhi kuinuka au kutikisika unapotembea na miwani.',
        'Maumivu makali ya paji la uso baada ya kuvaa miwani kwa dakika chache.',
        'Kufumba jicho moja ili uweze kusoma vizuri zaidi.',
      ],
      symptomsEn: [
        'Motion sickness, spatial disorientation, or feeling off-balance when walking with spectacles.',
        'Sharp frontal headaches within minutes of donning eyewear.',
        'Instinctively closing one eye to achieve comfortable focus.',
      ],
      avoidSw: [
        '1. Acha kabisa kununua miwani ya macho bila cheti rasmi cha daktari wa macho aliyesajiliwa.',
        '2. Acha kusafisha lenzi za miwani kwa shati au taulo kavu yenye vumbi – inaleta mikwaruzo ya kudumu.',
        '3. Acha kuweka miwani chini kioo kikiwa kinagusa meza.',
      ],
      avoidEn: [
        '1. Never purchase corrective eyeglasses without an individualized clinical prescription.',
        '2. Never clean lenses using clothing tails or rough tissues — embedded grit creates permanent scratches.',
        '3. Never lay eyeglasses face-down on hard tables.',
      ],
      actionsSw: [
        '1. Pima macho kwa Optometrist aliyethibitishwa ili upate kipimo kamili cha macho yako.',
        '2. Hakikisha fundi miwani anapima umbali wa mboni zako (PD) kwa mashine kabla ya kuweka vioo kwenye fremu.',
        '3. Safisha miwani yako kwa maji ya bomba na sabuni ya maji au dawa maalum ya miwani na kausha kwa kitambaa cha microfiber.',
        '4. Kagua miwani yako mara moja kila mwaka.',
      ],
      actionsEn: [
        '1. Undergo full visual refraction with a licensed optometrist.',
        '2. Ensure your pupillary distance (PD) is measured accurately to align optical centers with your visual axes.',
        '3. Wash spectacles under running water using mild dish soap, drying with a clean microfiber cloth.',
        '4. Have your prescription reassessed annually.',
      ],
      whenToSeeDoctorSw: 'Ikiwa miwani yako mpya inakuletea kizunguzungu kinachodumu zaidi ya siku tatu, irudishe kwa daktari wako wa macho kwa marekebisho.',
      whenToSeeDoctorEn: 'If newly dispensed eyeglasses cause disorientation lasting over 3 days, return to your clinic for a prescription and alignment recheck.',
    ),

    // 23. Dangers of Self-Medicating Eye Conditions
    EyeFact(
      id: 'self-medication',
      art: FactArt.drop,
      titleSw: 'Hatari ya Kujinunulia Dawa za Matone Bila Ushauri',
      titleEn: 'Dangers of Self-Medicating Eye Conditions',
      bodySw: 'Kujinunulia dawa za matone madukani bila uchunguzi kunaweza kusababisha upofu wa kudumu. Matone mengi ya madukani yana steroids au kemikali zinazopandisha shinikizo la jicho na kufanya vidonda kwenye kioo cha jicho.',
      bodyEn: 'Self-prescribing over-the-counter eye drops carries severe risks of irreversible blindness. Many generic drops contain steroids that trigger steroid glaucoma or worsen hidden viral ulcers.',
      tipSw: 'Kamwe usitumie dawa ya jicho ya rafiki au ndugu hata kama dalili zenu zinafanana kabisa.',
      tipEn: 'Never borrow someone else’s eye drops, even if their symptoms appear completely identical.',
      whatIsItSw: 'Magonjwa mengi ya macho (mzio, bakteria, virusi kama herpes, na ukavu) yote huanza kwa dalili moja tu: "jicho kuwa jekundu". Ukitumia tone lenye steroid kwenye jicho lenye virusi vya herpes, steroid inaua kinga ya mwili na kufanya virusi hivyo vitoboe kioo cha jicho (corneal perforation), au ipandishe shinikizo la jicho na kusababisha glaucoma ya steroids.',
      whatIsItEn: 'Diverse ocular conditions (allergic conjunctivitis, bacterial infection, Herpes Simplex keratitis, dry eye) manifest with the identical sign: conjunctival redness. Instilling topical steroids onto an undiagnosed herpes dendrite accelerates corneal perforation and triggers steroid-induced ocular hypertension.',
      causesSw: [
        '1. Mazoea ya kukimbilia duka la dawa (pharmacy) na kuomba "matone ya jicho lolote linalowasha".',
        '2. Kutumia dawa za macho zilizobaki kwenye kabati tangu ugonjwa uliopita.',
        '3. Kutumia maziwa ya mama, mate, mkojo, au chai kwenye jicho kama tiba ya kienyeji.',
      ],
      causesEn: [
        '1. Rushing to pharmacies to request generic "redness relief" or "itchy eye drops" without examination.',
        '2. Reusing old opened medication bottles preserved in medicine cabinets from past illnesses.',
        '3. Applying harmful traditional folk remedies (breast milk, saliva, urine, tea bags) into the eye.',
      ],
      symptomsSw: [
        'Jicho kuwa jeupe kwa siku mbili kisha kuwa jekundu zaidi kuliko mwanzo.',
        'Kuanza kuona ukungu mkubwa baada ya kutumia dawa ya matone.',
        'Shinikizo la jicho kupanda kimyakimya na kuharibu mshipa wa kuona.',
      ],
      symptomsEn: [
        'Transient whitening followed by severe rebound rebound hyperaemia.',
        'Vision deteriorating following drop instillation.',
        'Insidious, unmonitored intraocular pressure spikes eroding optic nerve fibers.',
      ],
      avoidSw: [
        '1. Acha kabisa kutumia matone yenye dawa za "Dexamethasone", "Betamethasone", au "Prednisolone" bila cheti cha daktari wa macho.',
        '2. Acha kuweka vitu vya kienyeji au kemikali zisizothibitishwa jichoni.',
        '3. Acha kutumia dawa za jicho za kuondoa wekundu (redness relievers) kwa zaidi ya siku tatu mfululizo.',
      ],
      avoidEn: [
        '1. Never use topical corticosteroid drops (Dexamethasone, Prednisolone) without strict ophthalmologist supervision.',
        '2. Never put traditional home concoctions into the eye.',
        '3. Avoid decongestant vasoconstrictor drops for more than 3 consecutive days to prevent rebound hyperaemia.',
      ],
      actionsSw: [
        '1. Jicho likiwa jekundu, muone daktari wa macho (Optometrist au Ophthalmologist) ili achunguze kiini hasa cha ugonjwa kupitia darubini maalum (slit lamp).',
        '2. Dawa pekee iliyo salama kutumia nyumbani kabla ya kumuona daktari ni matone ya kulowesha macho (Lubricating Tears) yasiyo na vihifadhi.',
        '3. Maliza dozi uliyopewa na daktari na tupa mabaki ya dawa mwezi mmoja baada ya kuifungua.',
      ],
      actionsEn: [
        '1. Visit an eye care specialist for a slit-lamp biomicroscopy exam whenever an eye turns persistently red.',
        '2. The only safe over-the-counter home remedy is preservative-free artificial tear drops.',
        '3. Complete prescribed courses and discard residual solutions 28 days post-opening.',
      ],
      whenToSeeDoctorSw: 'Ukiona maumivu yanazidi, uoni unashuka, au jicho linaogopa mwanga baada ya kutumia dawa yoyote, nenda hospitali ya macho mara moja.',
      whenToSeeDoctorEn: 'Seek urgent ophthalmic care if ocular pain intensifies, photophobia sets in, or vision clouds after taking any eye drops.',
    ),

    // 24. Conjunctivitis: Types, Hygiene & Transmission
    EyeFact(
      id: 'conjunctivitis',
      art: FactArt.eye,
      titleSw: 'Jicho Nyekundu (Conjunctivitis / Pink Eye)',
      titleEn: 'Conjunctivitis: Types, Hygiene & Transmission',
      bodySw: 'Jicho nyekundu husababishwa na virusi, bakteria, au mzio (allergy). Ugonjwa unaosababishwa na virusi huambukiza kwa kasi sana kupitia kugusa mikono, taulo na vitasa vya milango.',
      bodyEn: 'Conjunctivitis ("pink eye") stems from viral, bacterial, or allergic causes. Viral conjunctivitis is intensely contagious, spreading rapidly through hand contact, contaminated towels, and door handles.',
      tipSw: 'Osha mikono yako mara kwa mara kwa sabuni na usishiriki taulo au foronya za mito na mtu yeyote mwenye jicho jekundu.',
      tipEn: 'Wash hands frequently with soap and never share towels, washcloths, or pillows with an infected person.',
      whatIsItSw: 'Conjunctiva ni utando mwembamba ulio wazi unaofunika uteupe wa jicho na sehemu ya ndani ya kope. Utando huu ukivamiwa na virusi au bakteria, mishipa yake ya damu hutanuka na kutoa rangi nyekundu. Aina ya virusi (viral pink eye) hupona yenyewe ndani ya siku 7 hadi 14 bila kuhitaji antibayotiki, lakini inahitaji usafi mkubwa kuzuia kuambukiza wengine.',
      whatIsItEn: 'The conjunctiva is the transparent mucous membrane lining the sclera and internal lids. When inflamed by viruses, bacteria, or allergens, micro-capillaries engorge. Viral conjunctivitis (typically adenovirus) is self-limiting over 7–14 days and unresponsive to antibiotics, requiring strict barrier hygiene.',
      causesSw: [
        '1. Virusi vya Adenovirus (chanzo kikuu cha mlipuko wa jicho jekundu kwenye jamii).',
        '2. Bakteria (hutoa usaha mzito wa njano au kijani unaogandisha kope).',
        '3. Mzio (allergy) wa vumbi, chavua za maua, au manukato (huleta muwasho mkali lakini hauambukizi).',
        '4. Kemikali au moshi uliopenya jichoni.',
      ],
      causesEn: [
        '1. Adenoviral infection (the primary culprit behind explosive community outbreaks).',
        '2. Bacterial colonization producing sticky mucopurulent discharge that mats lids.',
        '3. Allergic hypersensitivity to environmental dust, pollen, or pet dander (itchy, non-contagious).',
        '4. Direct chemical or smoke irritants.',
      ],
      symptomsSw: [
        'Jicho kuwa jekundu au waridi linaloambatana na hisia ya mchanga.',
        'Kope kugandana asubuhi kutokana na ukoko mkavu.',
        'Macho kutoa machozi mengi au usaha.',
        'Kuwasha sana (hasa kwenye jicho jekundu la mzio).',
      ],
      symptomsEn: [
        'Diffuse pink or fiery red scleral injection paired with a gritty sensation.',
        'Crusted eyelids stuck together upon waking.',
        'Watery or thick purulent discharge.',
        'Intense, frustrating pruritic itching (cardinal sign of allergic forms).',
      ],
      avoidSw: [
        '1. Acha kusugua macho – kusugua hueneza maambukizi kwenye jicho la pili na kuchubua kioo cha jicho.',
        '2. Acha kutumia antibiotics za matone kwa jicho la virusi – hazisaidii na zinazalisha usugu wa vimelea.',
        '3. Acha kwenda shuleni au ofisini ukiwa na jicho jekundu linalotoa majimaji hadi daktari athibitishe si la kuambukiza.',
        '4. Acha kuvaa lenzi za macho hadi jicho lipone kabisa.',
      ],
      avoidEn: [
        '1. Never rub inflamed eyes — rubbing inoculates the unaffected fellow eye and risks corneal abrasions.',
        '2. Avoid indiscriminate antibiotic eye drops for self-limiting viral episodes.',
        '3. Avoid attending school or crowded workspaces while active weeping discharge persists.',
        '4. Stop wearing contact lenses until all inflammatory signs have completely resolved.',
      ],
      actionsSw: [
        '1. Weka kitambaa safi kilicholowa maji ya baridi (cold compress) juu ya kope zilizofumba kwa dakika 5 ili kupunguza muwasho na maumivu.',
        '2. Tumia matone ya maji ya machozi (Artificial Tears) yasiyo na vihifadhi kusafisha uteute na kutuliza macho.',
        '3. Osha mikono mara kwa mara na badilisha foronya ya mto kila siku wakati wa maambukizi.',
        '4. Tupa vifaa vyote vya kupaka rangi machoni (eye makeup/mascara) vilivyotumika wakati wa maambukizi.',
      ],
      actionsEn: [
        '1. Apply cool, clean damp compresses over closed eyelids for 5 minutes to relieve itching and edema.',
        '2. Use preservative-free lubricating tears to flush irritants and soothe conjunctival friction.',
        '3. Wash hands frequently and change pillowcases daily throughout the contagious window.',
        '4. Discard all eye cosmetics and mascaras used immediately prior to the infection.',
      ],
      whenToSeeDoctorSw: 'Ukianza kuona ukungu, maumivu makali ndani ya jicho, jicho kutovumilia mwanga kabisa, au mtoto mchanga akiwa na jicho nyekundu, nenda hospitali mara moja.',
      whenToSeeDoctorEn: 'Rush to an eye clinic if you experience marked visual blur, severe deep pain, extreme photophobia, or if an infant develops red, swollen eyes.',
    ),

    // 25. Swimming Eye Protection: Chlorine & Pathogens
    EyeFact(
      id: 'swimming',
      art: FactArt.drop,
      titleSw: 'Kuogelea na Kinga dhidi ya Kemikali za Dimbwi',
      titleEn: 'Swimming Eye Protection: Chlorine & Pathogens',
      bodySw: 'Maji ya mabwawa ya kuogelea (swimming pools) yana kemikali ya chlorine inayochoma tabaka la machozi, na maji ya maziwa na mito hubeba vimelea hatari vya ameba. Vaa miwani ya kuogelea (swimming goggles).',
      bodyEn: 'Chlorine in treated swimming pools strips away tear film protection, while untreated freshwater lakes and rivers harbor deadly amoebic parasites. Always wear fitted swimming goggles.',
      tipSw: 'Kamwe usiogelee ukiwa umevaa lenzi za macho (contact lenses), na vaa miwani ya kuogelea inayoziba maji vizuri.',
      tipEn: 'Never swim wearing contact lenses, and wear watertight swimming goggles whenever submerging.',
      whatIsItSw: 'Chlorine inayowekwa kwenye mabwawa huungana na jasho na uchafu kutengeneza chloramines, ambazo huyeyusha mafuta ya machozi na kusababisha jicho kuwaka moto na kuwa jekundu. Kwenye maziwa au bahari, bakteria na Acanthamoeba hupenya kwenye kioo cha jicho, hasa kama una michubuko midogo au umevaa lenzi.',
      whatIsItEn: 'Pool chlorine binds organic matter forming chloramines that strip tear lipid barriers, producing chemical conjunctivitis. In open freshwaters, Acanthamoeba and bacterial pathogens exploit micro-abrasions, rapidly infecting cornea tissue under contact lenses.',
      causesSw: [
        '1. Kufumbua macho ndani ya maji ya bwawa bila miwani ya kuogelea.',
        '2. Kuogelea ukiwa umevaa lenzi za macho (contact lenses).',
        '3. Kuogelea kwenye mabwawa yasiyotibiwa vizuri kwa kemikali au mito yenye maji yaliyotuama.',
      ],
      causesEn: [
        '1. Opening bare eyes underwater in chlorinated swimming pools.',
        '2. Swimming while wearing contact lenses.',
        '3. Submerging in poorly chlorinated public pools or stagnant freshwater ponds.',
      ],
      symptomsSw: [
        'Macho kuwaka moto, kuchoma na kuwa mekundu mara tu baada ya kutoka kwenye maji.',
        'Kuona ukungu kama kuna moshi (chemical halo) unaozunguka taa.',
        'Macho kutoa machozi mengi mfululizo.',
      ],
      symptomsEn: [
        'Immediate chemical burning, redness, and stinging upon exiting pool water.',
        'Foggy, foggy halos around lights due to transient corneal epithelial edema.',
        'Heavy involuntary tearing and photophobia.',
      ],
      avoidSw: [
        '1. Acha kabisa kuvaa lenzi za kawaida za macho wakati wa kuogelea au kuoga bwawani.',
        '2. Acha kufumbua macho ndani ya maji bila miwani ya kinga ya kuogelea.',
        '3. Acha kusugua macho baada ya kuogelea – kemikali zilizobaki zitachoma zaidi kioo cha jicho.',
      ],
      avoidEn: [
        '1. Never wear daily or extended-wear contact lenses into swimming pools, lakes, or oceans.',
        '2. Avoid opening unprotected bare eyes beneath treated or natural waters.',
        '3. Avoid rubbing irritated eyes post-swim — residual chloramines will further irritate the cornea.',
      ],
      actionsSw: [
        '1. Vaa miwani halisi ya kuogelea (swimming goggles) inayobana vizuri usoni bila kupitisha maji.',
        '2. Osha uso na macho kwa maji safi ya bomba yanayotiririka mara tu baada ya kutoka kwenye bwawa.',
        '3. Tumia matone ya maji ya machozi ya kulowesha (Artificial Tears) kutuliza muwasho baada ya kuogelea.',
        '4. Ikiwa unahitaji miwani ya kuona wakati wa kuogelea, agiza miwani maalum ya kuogelea yenye nguvu za macho (Prescription Swim Goggles).',
      ],
      actionsEn: [
        '1. Wear airtight, leak-proof swimming goggles designed for competitive or recreational swimming.',
        '2. Thoroughly rinse your face and eyelids with fresh, clean tap water immediately after swimming.',
        '3. Instill lubricating artificial tears to flush residual chemical traces and replenish hydration.',
        '4. Opt for custom prescription swimming goggles if you require optical vision correction underwater.',
      ],
      whenToSeeDoctorSw: 'Ukiona maumivu makali, jicho kuwa jekundu sana au kutoona vizuri siku moja baada ya kuogelea (hasa kama ulivaa lenzi), nenda kwa daktari wa macho mara moja.',
      whenToSeeDoctorEn: 'Seek emergency eye care if persistent eye ache, increasing redness, or worsening vision follows swimming, especially if lenses were worn.',
    ),

    // 26. Workplace Eye Safety & Protective Goggles
    EyeFact(
      id: 'safety-goggles',
      art: FactArt.eye,
      titleSw: 'Miwani ya Kinga Kazini na Shughuli za Hatari',
      titleEn: 'Workplace Eye Safety & Protective Goggles',
      bodySw: 'Zaidi ya 90% ya majeraha ya macho kazini (uchomeleaji, gereji, ujenzi, ukataji nyasi na kilimo) yanaweza kuzuilika kwa kuvaa miwani imara ya kinga (Polycarbonate Safety Goggles).',
      bodyEn: 'Over 90% of all occupational and home-workshop ocular trauma can be prevented by wearing certified impact-resistant polycarbonate safety goggles.',
      tipSw: 'Usiwahi kuanza kuchomelea, kusaga vyuma au kufyeka majani bila kuvaa miwani ya kinga kwanza.',
      tipEn: 'Never weld, grind metal, or operate weed-whackers without wearing certified safety eyewear.',
      whatIsItSw: 'Kioo cha jicho kina unene wa nusu millimeter tu (milimita 0.5). Cheche ya moto, kipande kidogo cha chuma kinachoruka kwa kasi kutoka kwenye mashine ya kukata chuma (grinder), au jiwe dogo kutoka kwenye mashine ya kukata nyasi linaweza kutoboa jicho zima ndani ya sehemu ya sekunde moja (globe rupture) na kusababisha upofu wa moja kwa moja.',
      whatIsItEn: 'The central human cornea is only 0.5 mm thick. High-velocity metallic projectiles from grinders, shattering masonry chisels, or ricocheting stones from lawnmowers can pierce the entire globe within a millisecond, causing catastrophic globe rupture and permanent loss of sight.',
      causesSw: [
        '1. Kuchomelea vyuma bila taji la kinga (welding shield) au miwani ya chuma.',
        '2. Kusaga chuma (grinding) au kukata mbao bila miwani ya kinga.',
        '3. Kukata nyasi kwa mashine (brush cutter) bila kinga ya uso mzima.',
        '4. Kufanya kazi na kemikali kali za viwandani au betri za magari bila miwani ya kufunika kando.',
      ],
      causesEn: [
        '1. Arc welding without proper auto-darkening helmets or shade filters.',
        '2. Grinding metal, chiseling concrete, or sawing wood without ballistic shields.',
        '3. Trimming brush and lawns with string trimmers without a full-face polycarbonate visor.',
        '4. Handling concentrated acids, caustic alkalis, or automotive batteries without splash goggles.',
      ],
      symptomsSw: [
        'Kuhisi kitu kimepiga au kuingia ndani ya jicho kwa kasi.',
        'Maumivu makali, machozi mengi na kutoweza kufungua jicho.',
        'Damu kuonekana ndani ya jicho (hyphema) au jicho kubadilika umbo.',
        'Kuungua kwa kope na kioo cha jicho (arc eye/flash burn).',
      ],
      symptomsEn: [
        'High-velocity impact sensation followed by immediate ocular distress.',
        'Severe intractable pain, blepharospasm, and copious lacrimation.',
        'Blood pooling in the anterior chamber (hyphema) or pupil distortion.',
        'Severe photophobia and burning hours after welding exposure (photokeratitis).',
      ],
      avoidSw: [
        '1. Acha kabisa kufanya kazi za hatari ukivaa miwani ya kawaida ya kusomea (vioo vyake vinaweza kupasuka na kukata jicho).',
        '2. Acha kujaribu kutoa kipande cha chuma kilichoingia jichoni kwa kutumia pini, sindano, au sumaku.',
        '3. Acha kusugua jicho ikiwa unahisi kuna kitu kimeingia ndani yake.',
      ],
      avoidEn: [
        '1. Never substitute ordinary dress spectacles for safety goggles — standard mineral glass or thin plastic can shatter into ocular lacerations.',
        '2. Never attempt to dislodge an embedded corneal foreign body with pins, needles, or magnets.',
        '3. Never rub your eye following high-speed projectile impact.',
      ],
      actionsSw: [
        '1. Vaa miwani ya kinga iliyotengenezwa kwa Polycarbonate yenye viwango vya usalama (kama ANSI Z87.1 au EN166).',
        '2. Kemikali ikiingia machoni: Osha jicho haraka kwa maji mengi safi yanayotiririka kwa dakika 15 mfululizo kabla ya kukimbia hospitali.',
        '3. Kipande kikiingia jichoni: Funika jicho kwa kikombe kidogo bila kulibana, na nenda hospitali ya macho mara moja.',
        '4. Weka vifaa vya huduma ya kwanza na maji safi ya kuoshea macho kwenye karakana au kiwanda chako.',
      ],
      actionsEn: [
        '1. Equip workers with ANSI Z87.1 / EN166 certified polycarbonate safety goggles with side shields.',
        '2. Chemical burns: Copiously irrigate the open eye under continuous running water for 15 minutes before transit.',
        '3. Penetrating trauma: Protect the globe with a rigid shield (or bottom of a paper cup) without pressure and seek emergency surgery.',
        '4. Maintain functional eyewash stations in every garage, workshop, and chemical lab.',
      ],
      whenToSeeDoctorSw: 'Kipande cha chuma, kemikali, au kitu chenye ncha kali kikiingia jichoni, hii ni dharura kubwa ya upasuaji inayohitaji mtaalamu wa macho mara moja.',
      whenToSeeDoctorEn: 'Any high-speed projectile impact, intraocular foreign body, or chemical injury is a surgical medical emergency requiring immediate specialist management.',
    ),

    // 27. Ergonomic Reading Distances & Reading Posture
    EyeFact(
      id: 'reading-distance',
      art: FactArt.screen,
      titleSw: 'Umbali na Mkao Sahihi Wakati wa Kusoma Vitabu',
      titleEn: 'Ergonomic Reading Distances & Reading Posture',
      bodySw: 'Kusoma kitabu kikiwa umbali wa chini ya sentimita 30 huongeza shinikizo kwenye misuli ya jicho na husababisha uoni hafifu wa mbali. Umbali sahihi ni sentimita 35 hadi 40.',
      bodyEn: 'Reading books closer than 30 cm forces extreme ciliary accommodation and accelerates near-work myopic progression. The optimal ergonomic reading distance is 35 to 40 cm.',
      tipSw: 'Weka kitabu kwenye mwelekeo wa nyuzi 45 (angled bookstand) badala ya kukiweka kikiwa kimelala kabisa mezani.',
      tipEn: 'Prop your reading book on a 45-degree angled stand instead of lying it completely flat on a desk.',
      whatIsItSw: 'Kusoma kunahitaji macho mawili kulenga kitu kimoja kwa pamoja (convergence) na kugeuza lenzi ya jicho iwe nene (accommodation). Kila unaposogeza kitabu karibu zaidi, nguvu inayohitajika huongezeka kwa kiwango cha kipeo, na misuli huchoka haraka, na kuleta msongo wa mawazo kwenye fuvu la kichwa.',
      whatIsItEn: 'Reading demands simultaneous ocular convergence and optical accommodation. Shortening reading distance below 33 cm exponentially spikes vergence stress, placing biomechanical tension on the sclera and fostering myopic drift.',
      causesSw: [
        '1. Mazoea ya kusoma vitabu au daftari ukiwa umelala kitandani au sakafuni.',
        '2. Kusoma kwenye mwanga hafifu wa taa au mshumaa.',
        '3. Madawati na viti vya shule visivyoendana na kimo cha msomaji, vinavyomfanya ainame kupita kiasi.',
      ],
      causesEn: [
        '1. Reading books while sprawled out flat on a bed or floor.',
        '2. Reading in sub-optimal ambient lighting or under weak candlelight.',
        '3. Non-ergonomic desks and chairs forcing deep spinal flexion and extreme close viewing.',
      ],
      symptomsSw: [
        'Macho kuanza kuuma na kuona ukungu baada ya kusoma kurasa chache tu.',
        'Kuhisi usingizi mzito mara tu unapoanza kusoma (kutokana na uchovu wa misuli ya macho).',
        'Maumivu ya shingo, mgongo na mabega.',
      ],
      symptomsEn: [
        'Premature ocular fatigue and intermittent blur after only a few pages.',
        'Sudden intense drowsiness triggered directly by ocular muscle exhaustion.',
        'Cervical spine discomfort, neck spasms, and upper back tightness.',
      ],
      avoidSw: [
        '1. Acha kusoma huku umelala kifudifudi au ukiwa umeweka kitabu karibu mno na pua yako.',
        '2. Acha kusoma kwenye gari linalotikisika – mtikisiko unalazimisha macho kulenga upya kila sekunde na kuleta kichefuchefu.',
        '3. Acha kutumia chumba chenye giza huku ukiangazia taa ndogo moja tu kwenye kitabu.',
      ],
      avoidEn: [
        '1. Never read while lying prone on your stomach with the book pinned near your face.',
        '2. Avoid reading inside moving, vibrating vehicles — vestibular-ocular mismatch causes motion sickness.',
        '3. Avoid reading in an otherwise dark room with only a pin-spot book light.',
      ],
      actionsSw: [
        '1. Shikilia kitabu umbali wa sentimita 35 hadi 40 (takriban urefu wa kutoka kiwiko hadi kwenye kifundo cha mkono).',
        '2. Kaa kwenye kiti chenye usaidizi mzuri wa mgongo, miguu ikigusa sakafu sawa.',
        '3. Hakikisha mwanga unatoka juu au pembeni na kuangaza kurasa vizuri bila kutengeneza vivuli vya mikono yako.',
        '4. Fuata kanuni ya 20-20-20: pumzisha macho kwa sekunde 20 kila baada ya kurasa chache.',
      ],
      actionsEn: [
        '1. Maintain the Harmon reading distance (~35–40 cm, elbow-to-knuckle span).',
        '2. Sit upright in a supportive chair with feet flat on the floor.',
        '3. Ensure uniform ambient lighting illuminates pages evenly without cast hand shadows.',
        '4. Pause every 20 minutes to gaze across the room for 20 seconds.',
      ],
      whenToSeeDoctorSw: 'Ukiona unalazimika kusogeza kitabu mbali sana au karibu sana ili uone herufi, pima macho kupata miwani sahihi ya usomaji.',
      whenToSeeDoctorEn: 'If decoding print demands shifting books continuously closer or farther away, schedule a refraction assessment with an optometrist.',
    ),

    // 28. School-Age Vision Screening & Amblyopia Prevention
    EyeFact(
      id: 'school-vision',
      art: FactArt.clock,
      titleSw: 'Upimaji wa Macho kwa Watoto wa Shule',
      titleEn: 'School-Age Vision Screening & Amblyopia Prevention',
      bodySw: 'Zaidi ya 80% ya mambo anayojifunza mtoto shuleni hupitia machoni. Mtoto asiyeona vizuri mara nyingi hawezi kueleza tatizo hilo bali huonekana kama mjinga, mzembe au asiyetulia darasani.',
      bodyEn: 'Over 80% of classroom learning is visually mediated. Children with undetected visual impairment rarely complain; instead, they are mistakenly labeled slow, lazy, or distracted.',
      tipSw: 'Pima macho ya mtoto wako kabla ya kuanza shule ya awali au darasa la kwanza, na kurudia kila baada ya miaka 2.',
      tipEn: 'Have your child’s vision screened before preschool or primary grade 1, repeating every 2 years.',
      whatIsItSw: 'Ubongo wa mtoto hujifunza kuona kuanzia kuzaliwa hadi takriban umri wa miaka 8. Ikiwa jicho moja lina tatizo la kutoona vizuri au linapinda (strabismus) na halijatibiwa kabla ya umri wa miaka 8, ubongo huanza kulipuuza jicho hilo na kusababisha ulemavu wa kudumu wa kuona ujulikanao kama "Jicho Linalolala" (Amblyopia / Lazy Eye).',
      whatIsItEn: 'Visual neuro-pathways mature between infancy and approximately 8 years of age. If one eye suffers uncorrected refractive blur, ptosis, or strabismus during this critical neuroplasticity window, the cortex suppresses its inputs, causing irreversible Amblyopia (Lazy Eye). Early diagnosis reverses this deficit.',
      causesSw: [
        '1. Matatizo ya kutoona mbali au karibu (Myopia, Hyperopia, Astigmatism) yasiyotambuliwa.',
        '2. Tofauti kubwa ya nguvu ya uoni kati ya jicho la kulia na la kushoto (Anisometropia).',
        '3. Macho kupinda au kutotazama upande mmoja (Strabismus/Squint).',
        '4. Mtoto kutowahi kufanyiwa uchunguzi wowote wa macho tangu azaliwe.',
      ],
      causesEn: [
        '1. Undiagnosed childhood refractive errors (high hyperopia, myopia, astigmatism).',
        '2. Marked refractive disparity between right and left eyes (Anisometropia).',
        '3. Binocular ocular misalignment or micro-strabismus.',
        '4. Absence of formal pediatric visual acuity screening in nursery and primary schools.',
      ],
      symptomsSw: [
        'Mtoto kuinamisha kichwa upande mmoja au kufumba jicho moja anapotazama ubao.',
        'Kushindwa kunakili maswali kutoka ubaoni kwa wakati na kupata alama za chini.',
        'Kusugua macho sana, macho kuwa mekundu mara kwa mara au kulalamika maumivu ya kichwa baada ya shule.',
        'Kukosa utulivu darasani na kupoteza umakini haraka.',
      ],
      symptomsEn: [
        'Tilting the head sideways or closing one eye when focusing on the front board.',
        'Chronic delays in copying notes from the board paired with falling grades.',
        'Frequent eye rubbing, redness, tearing, or post-school headache complaints.',
        'Restlessness, short attention span, and behavioral disruption during reading periods.',
      ],
      avoidSw: [
        '1. Acha tabia ya kumhukumu mtoto kuwa mvivu au hana akili darasani kabla hujapima macho yake.',
        '2. Acha kupuuza jicho la mtoto likiwa linapinda kidogo (hakuna mtoto anayekua akaziacha chongo yenyewe bila tiba).',
        '3. Acha kuahirisha kumpatia mtoto miwani aliyoandikiwa na daktari kwa hofu potofu kwamba "miwani itaharibu macho yake zaidi".',
      ],
      avoidEn: [
        '1. Never reprimand a struggling student as lazy or unintelligent before verifying their visual acuity.',
        '2. Never ignore an inward or outward drifting eye — children never "grow out" of strabismus on their own.',
        '3. Never withhold prescribed pediatric eyeglasses under the false myth that glasses "weaken" young eyes.',
      ],
      actionsSw: [
        '1. Mpeleke mtoto kwenye kliniki ya macho kwa ajili ya kipimo cha picha na herufi (Visual Acuity Screening).',
        '2. Ikiwa daktari ameandika miwani au matibabu ya kufunga jicho zuri kwa saa kadhaa (Eye Patching) ili kuamsha jicho lililolala, fuata ushauri huo kwa ukamilifu kabla mtoto hajafikisha miaka 8.',
        '3. Waambie walimu wa darasa wamweke mtoto kwenye madawati ya mbele karibu na ubao ikiwa ana upungufu wa kuona.',
        '4. Hakikisha mtoto anavaa miwani yake imara ya lenzi za polycarbonate shuleni kila siku.',
      ],
      actionsEn: [
        '1. Take your child to an optometrist for pediatric visual acuity testing (using Lea symbols or Snellen charts).',
        '2. If amblyopia is diagnosed, adhere strictly to patching therapy or corrective lens regimens before age 8.',
        '3. Liaise with class teachers to seat the child in front-row desks until vision is corrected.',
        '4. Provide sturdy, impact-resistant polycarbonate frames suited for active schoolyard play.',
      ],
      whenToSeeDoctorSw: 'Ukiona mtoto ana ugumu wowote wa kuona ubao, anakonyeza macho, au jicho linapinda kuelekea ndani au nje, mpeleke kwa daktari wa macho mara moja.',
      whenToSeeDoctorEn: 'Book an immediate pediatric eye appointment if your child squints, turns their head sideways to read, or has any visible eye misalignment.',
    ),

  ];
}
