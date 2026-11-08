/// Long-form privacy and terms copy, kept out of the UI string table so the
/// policy can be read and reviewed like a document.
class LegalSection {
  const LegalSection({
    required this.titleSw,
    required this.titleEn,
    required this.bodySw,
    required this.bodyEn,
  });

  final String titleSw;
  final String titleEn;
  final String bodySw;
  final String bodyEn;

  String title(String lang) => lang == 'sw' ? titleSw : titleEn;
  String body(String lang) => lang == 'sw' ? bodySw : bodyEn;
}

class LegalText {
  LegalText._();

  static String updated(String lang) =>
      lang == 'sw' ? '8 Novemba 2026' : '8 November 2026';

  static String intro(String lang) => lang == 'sw'
      ? 'AskOptSam (ikiwemo Eye · Msaidizi wa Maono) ni msaidizi wa elimu ya '
            'afya ya macho na uoni uliojengwa kwa kuzingatia Sheria ya Ulinzi '
            'wa Taarifa Binafsi ya Tanzania (Personal Data Protection Act, '
            '2022) na viwango vya kimataifa vya faragha. Hati hii inaeleza kwa '
            'uwazi taarifa tunazokusanya, jinsi tunavyozilinda kwenye simu na '
            'kwenye wingu, mipaka ya uwajibikaji wa kitabibu na kisheria, na '
            'haki zako kamili juu ya data yako.'
      : 'AskOptSam (including Eye · Vision Assistant) is an eye-health '
            'education and low-vision accessibility assistant built in '
            'accordance with the Tanzania Personal Data Protection Act, 2022 '
            '(PDPA) and international privacy standards. This document '
            'explains what data we collect, how we protect it on-device and in '
            'the cloud, medical and legal disclaimers, and your full rights '
            'over your personal data.';

  static const privacy = <LegalSection>[
    LegalSection(
      titleSw: 'Taarifa tunazohifadhi',
      titleEn: 'Information we keep',
      bodySw:
          'Tunafuata kanuni ya ukusanyaji mdogo wa data: tunahifadhi tu jina '
          'na barua pepe unayotoa ukitengeneza akaunti, nywila iliyosimbwa '
          'kwa usalama (hashed/encrypted), mazungumzo yako ya maandishi kwenye '
          'Maktaba, lugha uliyochagua, na mipangilio ya arifa. Hatuombi wala '
          'kuhifadhi namba ya kitambulisho cha taifa (NIDA), PIN za benki, '
          'OTP, alama za kibayometria za macho (iris scan), wala eneo lako '
          '(GPS).',
      bodyEn:
          'We practice strict data minimization: we store only the name and '
          'email address you provide when creating an account, your securely '
          'hashed password, your saved text chats in the Library, your chosen '
          'language, and notification preferences. We never ask for or store '
          'national ID numbers, bank PINs, OTPs, biometric iris scans, or GPS '
          'location data.',
    ),
    LegalSection(
      titleSw: 'Picha za Kamera na Sauti kwenye Eye (Hazihifadhiwi)',
      titleEn: 'Eye Camera Images and Voice Audio (Zero Retention)',
      bodySw:
          'Unapotumia sehemu ya Eye (Soma, Uliza, au Elezea), picha inayopigwa '
          'na kamera na sauti ya swali lako vinatumwa kwa muda mfupi tu '
          '(transient processing) kupitia muunganisho uliosimbwa (HTTPS/TLS) '
          'kwenda kwenye injini ya AI ili kusomwa au kuelezwa papo hapo. '
          'AskOptSam HAIHIFADHI picha za kamera yako wala rekodi za sauti yako '
          'kwenye hifadhidata yetu ya wingu, na faili za sauti za muda kwenye '
          'simu hufutwa moja kwa moja.',
      bodyEn:
          'When you use the Eye module (Read, Ask, or Describe), camera frames '
          'and spoken questions are transmitted transiently over encrypted '
          'HTTPS/TLS solely to generate an immediate reading or scene '
          'description. AskOptSam DOES NOT store your camera photos or voice '
          'recordings in our cloud database, and temporary audio cache files '
          'on your phone are automatically overwritten and purged.',
    ),
    LegalSection(
      titleSw: 'Kwa nini tunatumia taarifa na Marufuku ya Kuuza Data',
      titleEn: 'Why we use data & Strict No-Sale Guarantee',
      bodySw:
          'Taarifa zako hutumika pekee kukuwezesha kuingia kwenye akaunti '
          'yako, kukujibu maswali yako, kusawazisha mazungumzo yako kwenye '
          'Maktaba, na kukutumia kiungo cha kubadili nywila ukisahau. '
          'HATUUZI, hatukodishi, wala kubadilishana taarifa zako binafsi au '
          'historia ya mazungumzo yako na makampuni ya matangazo, madalali wa '
          'data (data brokers), au bima za afya.',
      bodyEn:
          'Your information is used strictly to authenticate your account, '
          'answer your questions, sync your saved Library chats, and send '
          'password-reset links when requested. We NEVER sell, rent, or trade '
          'your personal data or chat history to advertisers, data brokers, or '
          'insurance companies.',
    ),
    LegalSection(
      titleSw: 'Majibu ya AI na Tahadhari ya Taarifa Nyeti',
      titleEn: 'AI Processing and Sensitive Information Warning',
      bodySw:
          'Swali lako pamoja na muktadha mfupi wa mazungumzo hutumwa kwa '
          'huduma ya AI ili kutengeneza jibu. Usiandike taarifa za siri kama '
          'namba za kadi za malipo, nywila, au majina na namba za simu za '
          'watu wengine ndani ya kisanduku cha mazungumzo. Majibu ya AI ni ya '
          'kielimu na yanaweza kukosea — lazima yahakikiwe na daktari au '
          'mtaalamu wa macho (Optometrist/Ophthalmologist).',
      bodyEn:
          'Your question and recent conversation context are sent to our AI '
          'service to generate a reply. Do not enter confidential data such as '
          'payment card numbers, passwords, or third-party personal details in '
          'chat prompts. AI outputs are educational and may contain errors — '
          'always verify clinical decisions with a licensed eye specialist.',
    ),
    LegalSection(
      titleSw: 'Hifadhi kwenye Simu na Usawazishaji wa Wingu (Cloud Sync)',
      titleEn: 'On-Device Storage and Cloud Synchronization',
      bodySw:
          'Mazungumzo yako yanahifadhiwa kwenye simu yako na pia '
          'yanasawazishwa kwenye hifadhidata salama ya wingu (Google Firebase '
          'Authentication & Cloud Firestore) chini ya kitambulisho chako '
          'maalum (UID). Sheria za usalama za seva zinahakikisha kuwa ni '
          'akaunti yako pekee inayoweza kusoma au kufuta mazungumzo yako. '
          'Weka PIN au alama ya kidole kwenye simu yako kuzuia mtu mwingine '
          'asiyekuwa na ruhusa kufungua programu.',
      bodyEn:
          'Your chats are saved locally on your phone and synchronized to '
          'secure cloud storage (Google Firebase Authentication & Cloud '
          'Firestore) isolated under your unique user ID (UID). Strict '
          'server-side security rules ensure only your authenticated account '
          'can read or delete your chats. Keep a PIN or biometric lock on your '
          'phone to prevent unauthorized physical access.',
    ),
    LegalSection(
      titleSw: 'Kushiriki Taarifa na Watoa Huduma wa Kiufundi',
      titleEn: 'Third-Party Infrastructure Processors',
      bodySw:
          'Tunashirikisha tu kiasi kidogo kinachohitajika cha data na watoa '
          'huduma wa miundombinu wanaoaminika (Google Cloud / Firebase kwa '
          'uthibitishaji na hifadhi ya wingu, na Google Gemini / Vercel kwa '
          'uchakataji wa AI) chini ya mikataba mikali ya ulinzi wa data. '
          'Hatuna vifuatiliaji vya matangazo (ad trackers) ndani ya programu.',
      bodyEn:
          'We share only the minimum technical data required with trusted '
          'infrastructure processors (Google Cloud / Firebase for '
          'authentication and cloud storage, and Google Gemini / Vercel for AI '
          'inference) under strict data-processing terms. The app contains '
          'zero third-party advertising SDKs or trackers.',
    ),
    LegalSection(
      titleSw: 'Kuhifadhi na Kufuta Data Moja kwa Moja (Right to Erasure)',
      titleEn: 'Data Retention and Instant Deletion (Right to Erasure)',
      bodySw:
          'Una udhibiti kamili wa data yako: ukifuta mazungumzo moja au '
          'ukibonyeza "Futa historia ya mazungumzo" kwenye Mipangilio, '
          'mazungumzo hayo yanafutwa mara moja kwenye simu yako na kwenye '
          'wingu (Cloud Firestore). Unaweza pia kuomba akaunti yako yote '
          'ifutwe kabisa wakati wowote kupitia sehemu ya Msaada na maoni.',
      bodyEn:
          'You have full control over your data: deleting a chat or tapping '
          '"Delete all chats" in Settings permanently deletes those records '
          'both from your phone and from Cloud Firestore. You may also request '
          'complete account deletion at any time via Help and feedback.',
    ),
    LegalSection(
      titleSw: 'Usalama wa Mtandao na Taarifa ya Uvunjifu wa Usalama',
      titleEn: 'Cybersecurity and Breach Notification',
      bodySw:
          'Mawasiliano yote kati ya programu na seva zetu husimbwa kwa '
          'TLS/HTTPS na nywila hazihifadhiwi kama maandishi wazi (plaintext). '
          'Endapo kutatokea uvunjifu wowote wa usalama wa data unaoathiri '
          'taarifa zako, tutachukua hatua za haraka na kutoa taarifa kwa '
          'mujibu wa Sheria ya Ulinzi wa Taarifa Binafsi ya Tanzania (PDPA).',
      bodyEn:
          'All communication between the app and our servers is encrypted via '
          'TLS/HTTPS and passwords are never stored in plaintext. In the '
          'unlikely event of a data breach affecting your personal data, we '
          'will take immediate containment steps and notify affected users in '
          'accordance with the Tanzania Personal Data Protection Act (PDPA).',
    ),
    LegalSection(
      titleSw: 'Ulinzi wa Watoto (Umri wa Miaka 13+)',
      titleEn: 'Children\'s Privacy (Age 13+)',
      bodySw:
          'Programu hii imekusudiwa watu wenye umri wa miaka 13 na kuendelea. '
          'Hatukusanyi kwa makusudi taarifa binafsi za watoto walio chini ya '
          'miaka 13 bila ridhaa ya mzazi au mlezi. Ikiwa mzazi atagundua mtoto '
          'amefungua akaunti bila ruhusa, anaweza kuwasiliana nasi na '
          'tutaifuta mara moja.',
      bodyEn:
          'The app is intended for users aged 13 and older. We do not '
          'knowingly collect personal data from children under 13 without '
          'parental consent. If a parent or guardian learns that a child has '
          'created an account without consent, contact us and we will delete '
          'it promptly.',
    ),
    LegalSection(
      titleSw: 'Haki Zako za Kisheria na Mawasiliano ya Afisa Faragha',
      titleEn: 'Your Legal Data Rights and Privacy Contact',
      bodySw:
          'Chini ya sheria za ulinzi wa data, una haki ya: (a) kujua data '
          'tuliyo nayo kukuhusu, (b) kusahihisha jina au taarifa zako kwenye '
          'Wasifu, (c) kuondoa ridhaa yako wakati wowote kwa kufuta mazungumzo '
          'au akaunti, na (d) kuwasilisha malalamiko au maulizo kupitia '
          'optsamtz@gmail.com au sehemu ya Msaada na maoni.',
      bodyEn:
          'Under applicable data-protection law, you have the right to: (a) '
          'access the personal data we hold about you, (b) rectify your name '
          'or profile details, (c) withdraw consent at any time by deleting '
          'your chats or account, and (d) contact our privacy team at '
          'optsamtz@gmail.com or via Help and feedback.',
    ),
  ];

  static const terms = <LegalSection>[
    LegalSection(
      titleSw: 'Kukubali Masharti na Leseni ya Matumizi',
      titleEn: 'Acceptance of Terms and Limited License',
      bodySw:
          'Kwa kufungua akaunti au kutumia AskOptSam na Eye, unakubali '
          'kufungwa na masharti haya. Tunakupa leseni binafsi, isiyo ya '
          'kibiashara, inayoweza kubatilishwa ya kutumia programu hii kwa '
          'elimu ya afya ya macho na usaidizi wa kuona. Marufuku kufanya '
          'udukuzi, uhandisi wa kinyume (reverse engineering), au kuitumia '
          'kwa shughuli haramu.',
      bodyEn:
          'By creating an account or using AskOptSam and Eye, you agree to be '
          'bound by these terms. We grant you a personal, non-commercial, '
          'revocable license to use the app for eye-health education and '
          'visual assistance. Reverse engineering, scraping, automated abuse, '
          'or unlawful use is strictly prohibited.',
    ),
    LegalSection(
      titleSw: 'Kanusho la Kitabibu — Si Daktari wala Uchunguzi wa Kliniki',
      titleEn: 'Medical Disclaimer — Not Medical Advice or Diagnosis',
      bodySw:
          'AskOptSam si kifaa cha kitabibu kilichoidhinishwa kutoa utambuzi wa '
          'magonjwa (medical diagnostic device) wala haichukui nafasi ya '
          'daktari wa macho. Matumizi ya programu hii hayatengenezi uhusiano '
          'wa daktari na mgonjwa. Endapo una maumivu makali ya jicho, kemikali '
          'imeingia jichoni, uoni umepotea ghafla, au jicho limejeruhiwa, '
          'NENDA HOSPITALINI MARA MOJA bila kusubiri jibu la programu.',
      bodyEn:
          'AskOptSam is NOT a certified medical diagnostic device and does not '
          'replace a licensed optometrist or ophthalmologist. Using the app '
          'does not create a doctor-patient relationship. If you experience '
          'severe eye pain, chemical exposure, sudden vision loss, or ocular '
          'trauma, SEEK EMERGENCY MEDICAL CARE IMMEDIATELY.',
    ),
    LegalSection(
      titleSw: 'Usalama wa Kutembea kwa Watumiaji wa Eye (Msaidizi wa Maono)',
      titleEn: 'Mobility & Physical Safety Disclaimer for Eye Users',
      bodySw:
          'Sehemu ya Eye (Soma, Uliza, Elezea, na Endelea) ni chombo cha '
          'kusaidia tu. Kamera na AI vinaweza kukosa kuona ngazi, mashimo, '
          'magari yanayokuja kwa kasi, nyaya, au vikwazo kutokana na mwanga '
          'hafifu au ucheleweshaji wa mtandao. KAMWE usitegemee Eye pekee '
          'unapotembea barabarani au sehemu hatarishi — endelea kutumia fimbo '
          'nyeupe (white cane), mbwa mwongoza, au msaidizi wa binadamu.',
      bodyEn:
          'The Eye module (Read, Ask, Describe, and Continuous mode) is a '
          'supplementary aid only. Camera vision and AI may fail to detect '
          'stairs, drop-offs, moving vehicles, overhead obstacles, or hazards '
          'due to lighting, camera angle, or network latency. NEVER rely '
          'solely on Eye for navigation or street crossing — always use a '
          'white cane, guide dog, or human sighted guide.',
    ),
    LegalSection(
      titleSw: 'Mipaka ya Usahihi wa AI (Hallucinations & OCR Errors)',
      titleEn: 'AI & OCR Accuracy Limitations',
      bodySw:
          'Teknolojia ya AI inaweza kusoma maandishi vibaya (hasa kwenye '
          'chupa za dawa, risiti zilizofifia, au mwandiko wa mkono) au kutoa '
          'maelezo yasiyo sahihi. Mtumiaji ana jukumu la kuhakiki majina na '
          'vipimo vya dawa kwa mfamasia, daktari, au mtu anayeona vizuri '
          'kabla ya kumeza au kuweka dawa yoyote machoni.',
      bodyEn:
          'AI and optical character recognition (OCR) can misread text '
          '(especially on medicine labels, faded print, or handwriting) or '
          'produce inaccurate descriptions. You must verify medication names '
          'and dosages with a pharmacist, physician, or sighted person before '
          'taking or applying any medication.',
    ),
    LegalSection(
      titleSw: 'Usalama wa Akaunti Yako',
      titleEn: 'Account Responsibility',
      bodySw:
          'Una jukumu la kutunza siri ya nywila yako na shughuli zote '
          'zinazofanyika kupitia akaunti yako. Toa taarifa za kweli wakati wa '
          'kujisajili na utoke kwenye akaunti (Log out) ukitumia kifaa '
          'cha kushirikiana.',
      bodyEn:
          'You are responsible for maintaining the confidentiality of your '
          'password and for all activity under your account. Provide accurate '
          'registration details and sign out when using a shared device.',
    ),
    LegalSection(
      titleSw: 'Maudhui Unayotuma na Marufuku ya Matumizi Mabaya',
      titleEn: 'User Content and Acceptable Use',
      bodySw:
          'Maudhui unayouliza yanabaki kuwa yako, na unatupa ruhusa ndogo ya '
          'kuyachakata ili kukupa jibu na kuyahifadhi kwenye Maktaba yako. '
          'Ni marufuku kutumia programu kupiga picha za kuingilia faragha ya '
          'watu wengine bila ridhaa yao au kutuma maudhui yanayokiuka sheria.',
      bodyEn:
          'Your prompts remain yours, and you grant us a limited license to '
          'process them to deliver answers and store your Library history. You '
          'must not use the app to capture images that violate others\' '
          'privacy or to transmit unlawful content.',
    ),
    LegalSection(
      titleSw: 'Haki Miliki (Intellectual Property)',
      titleEn: 'Intellectual Property',
      bodySw:
          'Jina AskOptSam, Optsam Eye Care, Eye (Msaidizi wa Maono), nembo, '
          'msimbo wa programu, na muundo wake ni mali miliki inayolindwa '
          'kisheria. Picha za elimu kwenye Maktaba zinatoka Wikimedia Commons '
          'chini ya leseni husika za waandishi wake.',
      bodyEn:
          'The AskOptSam, Optsam Eye Care, and Eye names, logos, software '
          'code, and interface designs are protected intellectual property. '
          'Educational photographs in the Library are sourced from Wikimedia '
          'Commons under their respective open licenses.',
    ),
    LegalSection(
      titleSw: 'Ukomo wa Uwajibikaji wa Kisheria na Fidia (Limitation of Liability)',
      titleEn: 'Limitation of Liability and Indemnification',
      bodySw:
          'Kwa kiwango cha juu kinachoruhusiwa na sheria, AskOptSam, Optsam '
          'Eye Care, waanzilishi, na washirika wake HAWATAWAJIBIKA kwa madhara '
          'yoyote ya moja kwa moja au yasiyo ya moja kwa moja, ajali, jeraha '
          'la mwili au macho, au hasara inayotokana na kutegemea majibu ya AI, '
          'ucheleweshaji wa mtandao, au kushindwa kufuata ushauri wa daktari. '
          'Unakubali kutetea na kuondoa hatia (indemnify) AskOptSam dhidi ya '
          'madai yanayotokana na ukiukaji wako wa masharti haya.',
      bodyEn:
          'To the fullest extent permitted by law, AskOptSam, Optsam Eye Care, '
          'its founders, and affiliates SHALL NOT BE LIABLE for any direct, '
          'indirect, incidental, or consequential damages, personal or ocular '
          'injury, or loss arising from reliance on AI outputs, network '
          'delays, or failure to seek professional medical care. You agree to '
          'indemnify and hold AskOptSam harmless from claims arising out of '
          'your misuse of the app or violation of these terms.',
    ),
    LegalSection(
      titleSw: 'Sheria Inayoongoza na Utatuzi wa Migogoro',
      titleEn: 'Governing Law and Dispute Resolution',
      bodySw:
          'Sera na Masharti haya yanaongozwa na kutafsiriwa kwa mujibu wa '
          'sheria za Jamhuri ya Muungano wa Tanzania. Mgogoro wowote '
          'utakaotokea utatatuliwa kwanza kwa majadiliano ya amani kupitia '
          'optsamtz@gmail.com, na ikishindikana utawasilishwa kwenye mahakama '
          'zenye mamlaka nchini Tanzania.',
      bodyEn:
          'These Privacy Policy and Terms are governed by the laws of the '
          'United Republic of Tanzania. Any dispute shall first be addressed '
          'through good-faith resolution via optsamtz@gmail.com, and if '
          'unresolved, submitted to the competent courts of Tanzania.',
    ),
  ];
}
