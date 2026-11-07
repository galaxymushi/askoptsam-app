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
  });

  final String id;
  final FactArt art;
  final String titleSw;
  final String titleEn;
  final String bodySw;
  final String bodyEn;
  final String tipSw;
  final String tipEn;

  String title(String lang) => lang == 'sw' ? titleSw : titleEn;
  String body(String lang) => lang == 'sw' ? bodySw : bodyEn;
  String tip(String lang) => lang == 'sw' ? tipSw : tipEn;
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
      titleSw: 'Kanuni ya 20-20-20',
      titleEn: 'The 20-20-20 rule',
      bodySw:
          'Kila baada ya dakika 20 za kutumia simu au kompyuta, tazama kitu kilicho mbali kwa sekunde 20 — angalau hatua sita (mita sita). Hii inapunguza uchovu wa macho na kukauka kwa uso wa jicho.',
      bodyEn:
          'Every 20 minutes on a phone or computer, look at something far away for 20 seconds — at least six steps (six metres). It eases eye strain and stops the surface of the eye drying out.',
      tipSw: 'Weka kikumbusho cha simu kila dakika 20 badala ya kusubiri macho yakuume.',
      tipEn: 'Set a 20-minute reminder instead of waiting for your eyes to hurt.',
    ),
    EyeFact(
      id: 'blinking',
      art: FactArt.eye,
      titleSw: 'Kufumba na kufumbua',
      titleEn: 'Blinking',
      bodySw:
          'Binadamu hufumba macho wastani wa mara 15–20 kwa dakika, lakini tunapotazama skrini kiwango hicho hupungua karibu nusu. Kufumba kwa makusudi kunalowesha jicho na kuondoa hisia ya mchanga.',
      bodyEn:
          'People blink about 15–20 times a minute, but that rate roughly halves in front of a screen. Deliberate blinking re-wets the eye and clears the gritty feeling.',
      tipSw: 'Ukisikia macho makavu, fumba na fungua mara 10 kwa makusudi.',
      tipEn: 'When your eyes feel dry, blink slowly ten times on purpose.',
    ),
    EyeFact(
      id: 'uv',
      art: FactArt.sun,
      titleSw: 'Jua na miwani',
      titleEn: 'Sun and sunglasses',
      bodySw:
          'Mionzi ya UV ya jua inaweza kuharibu lenzi na retina kwa miaka. Miwani ya jua inayozuia 100% ya UVA na UVB inalinda, hasa mchana, ufukweni au mlimani.',
      bodyEn:
          'UV light from the sun can damage the lens and retina over the years. Sunglasses that block 100% of UVA and UVB protect you, especially at midday, at the beach or in the mountains.',
      tipSw: 'Vaa miwani ya jua hata kukiwa na mawingu — UV hupita mawinguni.',
      tipEn: 'Wear sunglasses even when it is cloudy — UV passes through cloud.',
    ),
    EyeFact(
      id: 'food',
      art: FactArt.food,
      titleSw: 'Chakula cha macho',
      titleEn: 'Food for your eyes',
      bodySw:
          'Mchicha, matembele, karoti, malenge na samaki hutoa vitamini A, C, E na omega-3. Virutubisho hivi husaidia retina na huchelewesha baadhi ya matatizo ya umri.',
      bodyEn:
          'Spinach, leafy greens, carrots, pumpkin and fish supply vitamins A, C, E and omega-3. These nutrients support the retina and slow some age-related problems.',
      tipSw: 'Ongeza mboga za majani kwenye mlo mmoja kila siku.',
      tipEn: 'Add leafy greens to one meal every day.',
    ),
    EyeFact(
      id: 'dry-eye',
      art: FactArt.drop,
      titleSw: 'Macho makavu',
      titleEn: 'Dry eyes',
      bodySw:
          'Vumbi, moto, upepo na muda mrefu mbele ya skrini hupunguza machozi. Dalili ni kuungua, hisia ya mchanga na uoni hafifu kidogo. Punja kwa kitambaa baridi na epuka moshi.',
      bodyEn:
          'Dust, heat, wind and long hours at a screen reduce tears. You feel burning, grit and slightly blurred sight. Use a cool compress and stay away from smoke.',
      tipSw: 'Kunywa maji ya kutosha na usikae mbele ya jiko la kuni kwa muda mrefu.',
      tipEn: 'Drink enough water and avoid sitting in front of a wood fire for long.',
    ),
    EyeFact(
      id: 'checkup',
      art: FactArt.clock,
      titleSw: 'Kipimo cha macho',
      titleEn: 'Eye check-ups',
      bodySw:
          'Watu wazima wenye afya wanashauriwa kupima macho kila miaka 1–2; mtu mwenye kisukari kila mwaka. Matatizo mengi huanza kimya kabla ya dalili kuonekana.',
      bodyEn:
          'Healthy adults should have an eye test every 1–2 years; anyone with diabetes every year. Many problems start silently before symptoms appear.',
      tipSw: 'Weka tarehe ya kipimo cha macho kwenye kalenda yako.',
      tipEn: 'Put your next eye test in your calendar.',
    ),
    EyeFact(
      id: 'sleep',
      art: FactArt.moon,
      titleSw: 'Usingizi na macho',
      titleEn: 'Sleep and your eyes',
      bodySw:
          'Usingizi wa saa 7–9 huruhusu macho kupumzika na kulowesha tena. Kuamka usiku mwingi huongeza ukavu na uchovu wa macho asubuhi.',
      bodyEn:
          'Seven to nine hours of sleep lets the eyes rest and re-wet. Broken sleep increases dryness and tired eyes in the morning.',
      tipSw: 'Weka simu mbali na kitanda dakika 30 kabla ya kulala.',
      tipEn: 'Put the phone away 30 minutes before bed.',
    ),
    EyeFact(
      id: 'smoke',
      art: FactArt.smoke,
      titleSw: 'Moshi na vumbi',
      titleEn: 'Smoke and dust',
      bodySw:
          'Moshi wa kuni, sigara na vumbi la barabara hukera uso wa jicho na kuongeza maambukizi. Jikoni, tumia dirisha au chumba cha moshi kinachotoka nje.',
      bodyEn:
          'Wood smoke, cigarette smoke and road dust irritate the surface of the eye and increase infections. In the kitchen, use a window or a chimney that vents outside.',
      tipSw: 'Usiruhusu moshi wa sigara ndani ya nyumba.',
      tipEn: 'Keep cigarette smoke out of the house.',
    ),
    EyeFact(
      id: 'cataract',
      art: FactArt.eye,
      titleSw: 'Kivimbe cha jicho (cataract)',
      titleEn: 'Cataract',
      bodySw:
          'Ukungu kwenye lenzi hufanya uoni kuwa hafifu na mwanga kuuma. Ni tatizo la kawaida kwa watu wenye umri zaidi ya 50 na hutibiwa kwa upasuaji mdogo.',
      bodyEn:
          'A clouded lens makes sight dim and light painful. It is common after 50 and is treated with a short operation.',
      tipSw: 'Uoni ukionekana kama umepauka, pima macho mapema.',
      tipEn: 'If sight looks washed out, get an eye test early.',
    ),
    EyeFact(
      id: 'glaucoma',
      art: FactArt.eye,
      titleSw: 'Glaucoma (shinikizo la jicho)',
      titleEn: 'Glaucoma',
      bodySw:
          'Huanza kimya bila maumivu na hupunguza uoni wa pembeni kwanza. Ukigundulika mapema, matibabu huzuia upofu.',
      bodyEn:
          'It starts silently without pain and steals side vision first. Found early, treatment prevents blindness.',
      tipSw: 'Wenye umri zaidi ya 40 au familia yenye historia wapime kila mwaka.',
      tipEn: 'After 40, or with a family history, get tested every year.',
    ),
    EyeFact(
      id: 'diabetes',
      art: FactArt.eye,
      titleSw: 'Kisukari na macho',
      titleEn: 'Diabetes and your eyes',
      bodySw:
          'Sukari ya damu isiyodhibitiwa huharibu mishipa midogo ya retina (retinopathy). Mara nyingi hakuna dalili hadi uoni umeathirika.',
      bodyEn:
          'Uncontrolled blood sugar damages the small vessels of the retina (retinopathy). Often there are no symptoms until sight is affected.',
      tipSw: 'Dhibiti sukari na pima retina kila mwaka.',
      tipEn: 'Control your sugar and have your retina checked every year.',
    ),
    EyeFact(
      id: 'distance',
      art: FactArt.screen,
      titleSw: 'Umbali wa skrini',
      titleEn: 'Screen distance',
      bodySw:
          'Simu iwe sentimita 30–40 kutoka macho, kompyuta sentimita 50–70. Skrini kubwa sana au karibu sana huchosha macho haraka.',
      bodyEn:
          'Hold a phone 30–40 cm from your eyes and sit 50–70 cm from a computer. A screen that is too large or too close tires the eyes quickly.',
      tipSw: 'Inua simu hadi usawa wa macho badala ya kuinamisha shingo.',
      tipEn: 'Raise the phone to eye level instead of bending your neck.',
    ),
    EyeFact(
      id: 'children',
      art: FactArt.food,
      titleSw: 'Watoto na kuona mbali',
      titleEn: 'Children and short sight',
      bodySw:
          'Muda mrefu ndani na kuangalia vitu vya karibu huongeza uwezekano wa mtoto kushindwa kuona mbali. Muda wa nje kwenye mwanga wa asili hulinda.',
      bodyEn:
          'Long hours indoors looking at near objects raise a child\'s chance of becoming short-sighted. Time outdoors in daylight protects them.',
      tipSw: 'Mpe mtoto saa moja ya kucheza nje kila siku.',
      tipEn: 'Give a child an hour of outdoor play every day.',
    ),
    EyeFact(
      id: 'contacts',
      art: FactArt.drop,
      titleSw: 'Lenzi za mawasiliano',
      titleEn: 'Contact lenses',
      bodySw:
          'Osha mikono kabla ya kuweka au kutoa lenzi, na usilale nazo. Maji ya kawaida hayafai kuosha lenzi — tumia solution maalum.',
      bodyEn:
          'Wash your hands before putting lenses in or taking them out, and never sleep in them. Tap water is not for lenses — use proper solution.',
      tipSw: 'Badilisha kesi ya lenzi kila miezi mitatu.',
      tipEn: 'Replace the lens case every three months.',
    ),
    EyeFact(
      id: 'hands',
      art: FactArt.eye,
      titleSw: 'Mikono safi',
      titleEn: 'Clean hands',
      bodySw:
          'Macho hupata maambukizi kwa vidole vichafu. Epuka kusugua macho, hasa ukiwa na vumbi au baada ya kushika pesa.',
      bodyEn:
          'Eyes pick up infections from dirty fingers. Avoid rubbing them, especially when dusty or after handling money.',
      tipSw: 'Osha mikono kwa sabuni kabla ya kugusa uso.',
      tipEn: 'Wash your hands with soap before touching your face.',
    ),
    EyeFact(
      id: 'drops',
      art: FactArt.drop,
      titleSw: 'Matone ya macho',
      titleEn: 'Eye drops',
      bodySw:
          'Matone ya kulowesha yasiyo na dawa ni salama kwa muda mfupi, lakini matone yenye steroid yanahitaji ushauri wa daktari. Usiweke dawa za jirani wala mitishamba machoni.',
      bodyEn:
          'Plain lubricating drops are fine for short-term relief, but steroid drops need a doctor. Never put a neighbour\'s medicine or herbal mixtures in your eyes.',
      tipSw: 'Soma lebo: matone yenye preservative hayafai kila siku kwa muda mrefu.',
      tipEn: 'Read the label: drops with preservatives are not for long daily use.',
    ),
    EyeFact(
      id: 'brightness',
      art: FactArt.screen,
      titleSw: 'Mwangaza wa skrini',
      titleEn: 'Screen brightness',
      bodySw:
          'Skrini inayong\'aa zaidi kuliko chumba huchosha macho; ile yenye mwanga hafifu sana pia. Linganisha mwangaza wa skrini na mazingira uliyomo.',
      bodyEn:
          'A screen brighter than the room strains the eyes; so does one that is far too dim. Match screen brightness to the room you are in.',
      tipSw: 'Tumia hali ya usiku jioni na upunguze mwangaza wa skrini.',
      tipEn: 'Use night mode in the evening and lower the brightness.',
    ),
    EyeFact(
      id: 'headache',
      art: FactArt.clock,
      titleSw: 'Maumivu ya kichwa na macho',
      titleEn: 'Headaches and tired eyes',
      bodySw:
          'Uchovu wa macho huleta maumivu ya kichwa, macho makavu na uoni hafifu baada ya muda mrefu. Pumzika na tazama mbali kabla hali haijazidi.',
      bodyEn:
          'Eye strain brings headaches, dryness and slightly blurred sight after long effort. Rest and look into the distance before it worsens.',
      tipSw: 'Ukiona dalili kila siku, pima macho — huenda unahitaji miwani.',
      tipEn: 'If it happens daily, get an eye test — you may need glasses.',
    ),
    EyeFact(
      id: 'night-driving',
      art: FactArt.moon,
      titleSw: 'Kuendesha usiku',
      titleEn: 'Driving at night',
      bodySw:
          'Mwangaza wa gari linalokuja hupunguza uoni kwa sekunde kadhaa. Usiangalie taa moja kwa moja; tazama upande wa kushoto wa barabara yako.',
      bodyEn:
          'Headlights from oncoming cars blind you for a few seconds. Do not stare at them; look towards the left edge of your lane.',
      tipSw: 'Safisha kioo cha gari na usiendeshe ukiwa umechoka.',
      tipEn: 'Clean the windscreen and never drive tired.',
    ),
    EyeFact(
      id: 'vitamin-a',
      art: FactArt.food,
      titleSw: 'Vitamini A na kuona usiku',
      titleEn: 'Vitamin A and night vision',
      bodySw:
          'Upungufu mkubwa wa vitamini A unaweza kusababisha upofu wa usiku, hasa kwa watoto. Mchicha, karoti, malenge na maini ni vyanzo vya bei nafuu.',
      bodyEn:
          'Severe vitamin A deficiency can cause night blindness, especially in children. Greens, carrots, pumpkin and liver are affordable sources.',
      tipSw: 'Watoto wahitaji mlo wenye rangi ya machungwa na kijani kila siku.',
      tipEn: 'Children need orange and green foods every day.',
    ),
    EyeFact(
      id: 'presbyopia',
      art: FactArt.clock,
      titleSw: 'Macho ya karibu baada ya miaka 40',
      titleEn: 'Near vision after 40',
      bodySw:
          'Baada ya miaka 40 kiunzi cha ndani cha jicho kigumu na kushindwa kulegeza kwa karibu — maandishi ya simu yanakuwa magumu. Hali hii huitwa presbyopia na si ugonjwa; miwani ya kusoma hutatua.',
      bodyEn:
          'After 40 the lens inside the eye stiffens and can no longer focus up close — phone text becomes hard to read. This is presbyopia, not a disease; reading glasses fix it.',
      tipSw:
          'Pima macho kabla ya kununua miwani ya kusoma; ile ya sokoni isiopimwa inaweza kuleta maumivu.',
      tipEn:
          'Get your eyes tested before buying reading glasses; an untested market pair can cause pain.',
    ),
    EyeFact(
      id: 'spectacles',
      art: FactArt.eye,
      titleSw: 'Miwani sahihi, kuoni safi',
      titleEn: 'The right prescription',
      bodySw:
          'Miwani iliyonunuliwa bila kupima inaweza kuharibu macho na kuleta maumivu ya kichwa, kuzungukaza na uchovu. Pima macho kwanza, kisha nunua kwa kiasi sahihi.',
      bodyEn:
          'Glasses bought without an eye test can bring headaches, dizziness and strain. Test first, then buy the exact strength you need.',
      tipSw: 'Kila miaka miwili fanya uchunguzi wa macho hata kama unaona vizuri.',
      tipEn: 'Have your eyes checked every two years even if you see well.',
    ),
    EyeFact(
      id: 'self-medication',
      art: FactArt.drop,
      titleSw: 'Usijitibu dawa za macho',
      titleEn: 'Never self-medicate your eyes',
      bodySw:
          'Dawa za steroid (mfano hydrocortisone) zinapotumika bila daktari zinaweza kupandisha shinikizo la jicho, kusababisha katarakti na maambukizi yanayoharibu kuona bila dalili. Dawa ya macho ni dawa ya daktari.',
      bodyEn:
          'Steroid eye drops used without a doctor can raise eye pressure, trigger cataracts and hide an infection that quietly damages sight. Eye medicine is prescription medicine.',
      tipSw: 'Usitumie dawa ya mtu mwingine au iliyobaki kutoka mwaka uliopita.',
      tipEn: 'Never use another person\'s eye drops or leftovers from last year.',
    ),
    EyeFact(
      id: 'conjunctivitis',
      art: FactArt.eye,
      titleSw: 'Jicho nyekundu (conjunctivitis)',
      titleEn: 'Red eye (conjunctivitis)',
      bodySw:
          'Jicho nyekundu lenye uchafu linaweza kuwa maambukizi yanayoenea kwa mikono na taulo. Nawa mikono mara kwa mara, usiguse macho, usishiriki taulo au vipodozi.',
      bodyEn:
          'A red eye with discharge may be an infection that spreads through hands and towels. Wash hands often, don\'t touch your eyes, and never share towels or eye make-up.',
      tipSw:
          'Ukiona macho nyekundu yenye maumivu au kuona hafifu, ona daktari haraka badala ya kusubiri.',
      tipEn:
          'If redness comes with pain or blurred vision, see a doctor quickly instead of waiting.',
    ),
    EyeFact(
      id: 'swimming',
      art: FactArt.drop,
      titleSw: 'Kuogelea na macho',
      titleEn: 'Swimming and your eyes',
      bodySw:
          'Maji ya bwawa na klorini huchoma uso wa jicho na kuleta macho nyekundu. Vaa glasi za kuogelea, na ukiona macho nyekundu kwa siku baada ya kuogelea, ona daktari.',
      bodyEn:
          'Pool water and chlorine irritate the surface of the eye and turn it red. Wear goggles, and if the redness lasts for days afterwards, see a doctor.',
      tipSw: 'Osha macho kwa maji safi baada ya kuogelea na usisugue kwa nguvu.',
      tipEn: 'Rinse your eyes with clean water after swimming and never rub hard.',
    ),
    EyeFact(
      id: 'safety-goggles',
      art: FactArt.eye,
      titleSw: 'Kinga ya macho kwenye kazi',
      titleEn: 'Eye protection at work',
      bodySw:
          'Vumbuli, vipande vya chuma, moshi na kemikali huchoma macho kwa sekunde moja tu. Glasi za kinga za bei ndogo ndizo zinazokuokoa kuoni — kuwa nazo daima, hata kwa kazi fupi.',
      bodyEn:
          'Dust, metal chips, smoke and chemicals can injure an eye in a single second. Cheap safety goggles are what stand between you and blindness — keep them on even for short jobs.',
      tipSw: 'Tumia glasi za kinga hata unapofanya udoka, kusafisha kwa kemikali au kukata nyasi.',
      tipEn: 'Wear safety goggles even when welding, using chemicals or cutting grass.',
    ),
    EyeFact(
      id: 'reading-distance',
      art: FactArt.screen,
      titleSw: 'Umbali wa usomaji',
      titleEn: 'Reading distance',
      bodySw:
          'Kusoma kwa karibu mno hulazimisha misuli ya jicho ikae nyuma muda mrefu na kuleta uchovu. Weka kitabu au simu umbali wa mkono, kisha angalia mbali mara kwa mara.',
      bodyEn:
          'Reading too close keeps the focusing muscle tense for too long and tires the eyes. Hold a book or phone about an arm\'s length away, and look into the distance often.',
      tipSw: 'Watoto wasome kitabu angalau mita moja kutoka uso wao.',
      tipEn: 'Children should read roughly an arm\'s length from the page.',
    ),
    EyeFact(
      id: 'school-vision',
      art: FactArt.clock,
      titleSw: 'Kupima macho shuleni',
      titleEn: 'Vision screening at school',
      bodySw:
          'Mtoto anayeshindwa kusoma ubao mara nyingi si mvivu wa kusoma — anaweza kuhitaji miwani. Upimaji wa macho shuleni hukamata tatizo mapema, kabla halijaharibu masomo yake.',
      bodyEn:
          'A child who cannot copy from the board is often not a slow learner — they may simply need glasses. School vision screening catches the problem before it costs them lessons.',
      tipSw:
          'Uliza shule ya mtoto wako iwapo ina upimaji wa macho, na ukishuku, muone daktari bila kuchelewa.',
      tipEn:
          'Ask your child\'s school about eye screening, and if you suspect a problem, act fast.',
    ),
  ];
}
