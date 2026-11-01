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
      lang == 'sw' ? '1 Novemba 2026' : '1 November 2026';

  static String intro(String lang) => lang == 'sw'
      ? 'AskOptSam ni msaidizi wa afya ya macho. Hati hii inaeleza taarifa '
            'gani tunahifadhi, kwa nini tunazihifadhi, na masharti ya kutumia '
            'programu. Tumejaribu kuandika kwa lugha rahisi. Jambo lisiloeleweka? '
            'Tuandikie kupitia Msaada na maoni.'
      : 'AskOptSam is an eye-health assistant. This document explains what '
            'information we keep, why we keep it, and the rules for using the '
            'app. We have tried to write it in plain language. If something is '
            'unclear, write to us through Help and feedback.';

  static const privacy = <LegalSection>[
    LegalSection(
      titleSw: 'Taarifa tunazohifadhi',
      titleEn: 'Information we keep',
      bodySw:
          'Jina na barua pepe unazotoa ukitengeneza akaunti, au akaunti ya '
          'kifaa hiki ikiwa hukutumia barua pepe. Pia huhifadhi mazungumzo '
          'yako, lugha, mpangilio wa arifa na kumbukumbu ya malipo pale '
          'unapotuma risiti. Hatuombi namba yako ya siri (PIN), OTP wala '
          'taarifa za kadi.',
      bodyEn:
          'The name and email you give when creating an account, or a '
          'device account if you did not use email. We also store your chats, '
          'language, notification choices and a payment reference when you '
          'send a receipt. We never ask for your PIN, OTP or card details.',
    ),
    LegalSection(
      titleSw: 'Kwa nini tunazitumia',
      titleEn: 'Why we use it',
      bodySw:
          'Taarifa hizi hutumika kukujibu, kuhifadhi mazungumzo kwenye '
          'Maktaba, kutuma arifa ulizoziamua, kukusaidia ukipata tatizo, na '
          'kuboresha huduma. Hatuzitumii kukutambua kwa matangazo ya watu '
          'wengine wala kuziuza.',
      bodyEn:
          'We use this information to answer you, save chats in the '
          'Library, send the notifications you enabled, help when something '
          'goes wrong, and improve the service. We do not use it for other '
          'people\'s advertising and we do not sell it.',
    ),
    LegalSection(
      titleSw: 'Majibu ya AI',
      titleEn: 'AI answers',
      bodySw:
          'Swali lako, pamoja na sehemu fupi ya mazungumzo ya awali, '
          'hutumwa kwa huduma ya AI ili kupata jibu. Usiandike taarifa nyeti '
          'kama namba ya kitambulisho, namba ya benki au historia ya matibabu. '
          'Majibu yanaweza kuwa si sahihi kabisa — hakikisha na mtaalamu wa '
          'macho kwa maamuzi ya afya.',
      bodyEn:
          'Your question, together with a short part of the earlier '
          'conversation, is sent to an AI service to produce an answer. Do not '
          'type sensitive details such as ID numbers, bank numbers or medical '
          'records. Answers can be incomplete or wrong — confirm health '
          'decisions with an eye specialist.',
    ),
    LegalSection(
      titleSw: 'Hifadhi kwenye simu',
      titleEn: 'Storage on your phone',
      bodySw:
          'Mazungumzo huhifadhiwa kwenye simu hii. Ukiingia kwa akaunti ya '
          'wingu, yanasawazishwa ili uyapate ukipata simu nyingine. Mtu '
          'mwingine anaweza kuyaona ikiwa atatumia simu yako bila kufunga '
          'akaunti, kwa hivyo tumia PIN au alama ya kufungua simu.',
      bodyEn:
          'Chats are stored on this phone. If you sign in with a cloud '
          'account they are synced so you can reach them on another phone. '
          'Someone else could read them if they use your phone without signing '
          'out, so keep a PIN or screen lock on the device.',
    ),
    LegalSection(
      titleSw: 'Malipo',
      titleEn: 'Payments',
      bodySw:
          'Malipo hufanywa wewe mwenyewe kwa Airtel Money au M-Pesa kwa '
          'namba zinazoonekana kwenye programu. Hatuoni PIN yako. Tunapokea '
          'kumbukumbu ya muamala na risiti unayotuma ili kuthibitisha malipo. '
          'Michango ni ya hiari isipokuwa huduma maalum zinazoelezwa wazi.',
      bodyEn:
          'You make payments yourself with Airtel Money or M-Pesa to the '
          'numbers shown in the app. We never see your PIN. We receive the '
          'transaction reference and the receipt you send so we can verify the '
          'payment. Contributions are voluntary unless a specific service is '
          'clearly described otherwise.',
    ),
    LegalSection(
      titleSw: 'Kushiriki taarifa',
      titleEn: 'Sharing',
      bodySw:
          'Hatuuzi taarifa zako. Tunashiriki kiasi kinachohitajika tu na '
          'watoa huduma wanaotusaidia kuendesha programu, kama seva na huduma '
          'ya AI, au pale sheria inahitaji. Watoa huduma hao wanapaswa '
          'kulinda taarifa hizo.',
      bodyEn:
          'We do not sell your information. We share only what is needed '
          'with providers who help run the app, such as hosting and the AI '
          'service, or where the law requires it. Those providers are expected '
          'to protect the information.',
    ),
    LegalSection(
      titleSw: 'Kuhifadhi na kufuta',
      titleEn: 'Retention and deletion',
      bodySw:
          'Mazungumzo hubaki hadi uyafute kwenye Maktaba. Kufuta '
          'mazungumzo huyafutia mbali na simu yako. Kufuta programu kunaondoa '
          'nakala ya simu; kama unatumia akaunti ya wingu, tuandikie ili '
          'tufute akaunti na data yake.',
      bodyEn:
          'Chats stay until you delete them in the Library. Deleting a chat '
          'removes it from your phone. Uninstalling the app removes the phone '
          'copy; if you use a cloud account, write to us so we can delete the '
          'account and its data.',
    ),
    LegalSection(
      titleSw: 'Usalama',
      titleEn: 'Security',
      bodySw:
          'Tunatumia hatua za kawaida kulinda data, lakini hakuna mfumo '
          'unaoweza kuahidi usalama kamili. Linda simu yako kwa PIN au alama, '
          'na usishiriki nenosiri lako na mtu yeyote.',
      bodyEn:
          'We use standard safeguards to protect data, but no system can '
          'promise complete security. Lock your phone with a PIN or pattern '
          'and never share your password with anyone.',
    ),
    LegalSection(
      titleSw: 'Watoto',
      titleEn: 'Children',
      bodySw:
          'Programu hii ni kwa watu wa miaka 13 na zaidi. Mtoto chini ya '
          'umri huo anapaswa kuitumia akiwa na mzazi au mlezi. Maswali kuhusu '
          'macho ya mtoto yajibiwe na mtu mzima, na matibabu yafanywe na '
          'mtaalamu.',
      bodyEn:
          'The app is for people aged 13 and over. A younger child should '
          'use it with a parent or guardian. Questions about a child\'s eyes '
          'should be handled by an adult, and treatment by a professional.',
    ),
    LegalSection(
      titleSw: 'Haki zako',
      titleEn: 'Your rights',
      bodySw:
          'Unaweza kuona na kufuta mazungumzo yako, kubadilisha lugha au '
          'kuzima arifa, na kuomba nakala au kufutwa kwa akaunti kwa kuandikia '
          'kupitia Msaada na maoni. Tutajibu ombi lako ndani ya muda mfupi '
          'iwezekanavyo.',
      bodyEn:
          'You can view and delete your chats, change the language or turn '
          'notifications off, and ask for a copy or deletion of your account by '
          'writing through Help and feedback. We will answer as soon as we can.',
    ),
    LegalSection(
      titleSw: 'Mabadiliko ya sera',
      titleEn: 'Changes to this policy',
      bodySw:
          'Tunaweza kusasisha hati hii kadri huduma inavyobadilika. Toleo '
          'jipya litaonekana hapa na tarehe mpya juu ya ukurasa. Kuendelea '
          'kutumia programu baada ya mabadiliko kunamaanisha unakubali hati '
          'mpya.',
      bodyEn:
          'We may update this document as the service changes. The new '
          'version will appear here with a new date at the top. Continuing to '
          'use the app after a change means you accept the updated document.',
    ),
  ];

  static const terms = <LegalSection>[
    LegalSection(
      titleSw: 'Matumizi ya programu',
      titleEn: 'Using the app',
      bodySw:
          'Programu hii ni kwa matumizi yako binafsi ya kujifunza na '
          'kupata mwongozo kuhusu afya ya macho. Usitumie kuharibu, kudukua, '
          'kunakili kwa faida ya biashara, au kusambaza maudhui yasiyofaa.',
      bodyEn:
          'The app is for your own learning and eye-health guidance. Do '
          'not use it to damage, hack, copy for commercial gain, or spread '
          'harmful content.',
    ),
    LegalSection(
      titleSw: 'Akaunti yako',
      titleEn: 'Your account',
      bodySw:
          'Wewe unahusika na usiri wa nenosiri lako na shughuli '
          'zinazofanyika kwenye akaunti yako. Akaunti ni ya mtu mmoja; '
          'usishiriki kifaa na wengine bila kufunga akaunti.',
      bodyEn:
          'You are responsible for keeping your password private and for '
          'activity on your account. An account belongs to one person; do not '
          'share a device without signing out.',
    ),
    LegalSection(
      titleSw: 'Elimu, si utambuzi',
      titleEn: 'Education, not diagnosis',
      bodySw:
          'Taarifa zote kuhusu macho ni elimu ya jumla, si utambuzi wa '
          'ugonjwa wala mapishi ya dawa. Kama una maumivu makali, uoni '
          'unapotea ghafla, au jicho limeumia, nenda hospitalini mara moja. '
          'Usisubiri jibu la programu.',
      bodyEn:
          'All eye information is general education, not a diagnosis or a '
          'prescription. If you have severe pain, sudden loss of sight or an '
          'injured eye, go to hospital at once. Do not wait for an app reply.',
    ),
    LegalSection(
      titleSw: 'Majibu ya AI',
      titleEn: 'AI answers',
      bodySw:
          'AI inaweza kukosea, kukosa taarifa, au kuelewa vibaya swali '
          'lako. Hakikisha taarifa muhimu na mtaalamu wa macho. Usitumie jibu '
          'la AI kama badala ya kipimo cha macho au ushauri wa daktari.',
      bodyEn:
          'AI can be wrong, leave things out or misunderstand your '
          'question. Check important information with an eye specialist. Do '
          'not use an AI answer in place of an eye test or a doctor\'s advice.',
    ),
    LegalSection(
      titleSw: 'Maudhui unayotuma',
      titleEn: 'Content you send',
      bodySw:
          'Maudhui unayotuma yanabaki mali yako. Unatupa ruhusa ya '
          'kuyachakata na kuyahifadhi kwa ajili ya kukujibu na kuendesha '
          'huduma. Usitume maudhui haramu, ya ubaguzi, au ya mtu mwingine bila '
          'ruhusa.',
      bodyEn:
          'Content you send stays yours. You give us permission to process '
          'and store it to answer you and run the service. Do not send illegal '
          'or hateful content, or another person\'s content without permission.',
    ),
    LegalSection(
      titleSw: 'Malipo ya hiari',
      titleEn: 'Voluntary payments',
      bodySw:
          'Michango na kahawa ni ya hiari na haibadilishi huduma ya msingi. '
          'Malipo huthibitishwa kwa risiti unayotuma. Kama umelipa mara mbili '
          'kwa hitilafu, tuandikie na tutakagua marejesho.',
      bodyEn:
          'Contributions and coffee are voluntary and do not change the '
          'core service. Payments are verified with the receipt you send. If '
          'you paid twice by mistake, write to us and we will review a refund.',
    ),
    LegalSection(
      titleSw: 'Mali miliki',
      titleEn: 'Ownership',
      bodySw:
          'Jina AskOptSam, alama, michoro na maudhui ya programu ni mali ya '
          'wamiliki wake. Huruhusiwi kuzinakili au kuzitumia kwa biashara bila '
          'idhini ya maandishi.',
      bodyEn:
          'The AskOptSam name, logo, artwork and app content belong to '
          'their owners. You may not copy or use them commercially without '
          'written permission.',
    ),
    LegalSection(
      titleSw: 'Uwajibikaji',
      titleEn: 'Liability',
      bodySw:
          'Huduma hutolewa kama ilivyo. Tunafanya bidii kufanya majibu '
          'yawe sahihi, lakini hatuwajibiki kwa maamuzi unayofanya kutokana na '
          'majibu hayo, kwa kadri sheria inavyoruhusu. Hii haiondoi haki zako '
          'za kisheria.',
      bodyEn:
          'The service is provided as it is. We work hard to keep answers '
          'accurate, but we are not liable for decisions you make from those '
          'answers, as far as the law allows. This does not remove your legal '
          'rights.',
    ),
    LegalSection(
      titleSw: 'Kusimamisha matumizi',
      titleEn: 'Suspending use',
      bodySw:
          'Tunaweza kuzuia au kusimamisha akaunti inayotumika kwa madhara, '
          'udukuzi au kukiuka masharti haya. Utapata taarifa pale '
          'inapowezekana.',
      bodyEn:
          'We may block or suspend an account used to cause harm, to hack, '
          'or to break these terms. We will tell you where possible.',
    ),
    LegalSection(
      titleSw: 'Sheria na mabadiliko',
      titleEn: 'Law and changes',
      bodySw:
          'Masharti haya yanaongozwa na sheria za Jamhuri ya Muungano wa '
          'Tanzania. Tunaweza kuyabadilisha; toleo jipya litaonekana hapa na '
          'tarehe mpya. Kuendelea kutumia programu kunamaanisha unakubali '
          'masharti mapya.',
      bodyEn:
          'These terms are governed by the laws of the United Republic of '
          'Tanzania. We may change them; the new version will appear here with '
          'a new date. Continuing to use the app means you accept the new '
          'terms.',
    ),
  ];
}
