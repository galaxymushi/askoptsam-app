import 'package:flutter/widgets.dart';

import '../services/color_tools.dart';
import '../theme.dart';

enum AppLanguage { sw, en }

/// All user-facing copy, in Kiswahili (default) and English.
class S {
  const S(this.language);

  final AppLanguage language;

  bool get sw => language == AppLanguage.sw;

  String pick(String swahili, String english) => sw ? swahili : english;

  static S of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LocaleScope>()?.strings ??
        const S(AppLanguage.sw);
  }

  // Brand and common.
  String get appName => 'Eye';
  String get tagline =>
      pick('Tazama dunia kwa sauti', 'See the world by voice');
  String get back => pick('Rudi', 'Back');
  String get tryAgain => pick('Jaribu tena', 'Try again');
  String get listenAgain => pick('Sikiliza tena', 'Listen again');
  String get repeat => pick('Rudia', 'Repeat');
  String get problem => pick('Tatizo', 'Problem');
  String get settingsTitle => pick('Mipangilio', 'Settings');
  String get stopSpeaking => pick('Acha kusema', 'Stop speaking');
  String get silenceHint => pick('Inanyamazisha sauti', 'Silences the voice');
  String get light => pick('Tochi', 'Light');
  String get lightOn => pick('Tochi imewaka', 'Light on');
  String get chooseAction =>
      pick('Chagua unachotaka kufanya', 'Choose what you want to do');
  String get voiceOnNote => pick(
        'Sauti imewashwa · Gusa kitufe kimoja kuanza',
        'Voice is on · Tap one button to start',
      );
  String get voiceOffNote => pick(
        'Sauti imezimwa · Gusa kitufe kimoja kuanza',
        'Voice is off · Tap one button to start',
      );
  String get welcomeSpeak => pick(
        'Eye. Msaidizi wa maono. Nakusaidia kuelewa kilicho mbele yako, '
        'kusoma maandishi, na kujibu maswali kwa sauti. Gusa Anza ili kuanza.',
        'Eye. A vision assistant. I help you understand what is ahead, read '
        'text, and answer questions by voice. Tap Start to begin.',
      );
  String get homeSpeak => pick(
        'Eye. Chagua kimoja: Soma, Uliza, au Elezea.',
        'Eye. Choose one: Read, Ask, or Describe.',
      );
  String get settingsSpeak => pick(
        'Mipangilio. Sauti, ukubwa wa maandishi, na mandhari.',
        'Settings. Voice, text size, and theme.',
      );
  String get openSettings => pick('Mipangilio', 'Settings');
  String get settingsHint => pick(
        'Sauti, maandishi, na mandhari',
        'Voice, text, and theme',
      );
  String get homeNote => pick(
        'Sauti imewashwa · Gusa kitufe kimoja kuanza',
        'Voice is on · Tap one button to start',
      );

  // Onboarding.
  String get onboardingEyebrow => pick(
        'Msaidizi wa maono · Kiswahili kwanza',
        'Vision assistant · Kiswahili first',
      );
  String get onboardingTagline => pick(
        'Nakusaidia kuelewa kilicho mbele yako, kusoma maandishi, na kujibu '
        'maswali kwa sauti.',
        'I help you understand what is ahead, read text, and answer questions '
        'out loud.',
      );
  String get start => pick('Anza', 'Start');
  String get founder => pick('Mwanzilishi · J.M. Samwel', 'Founder · J.M. Samwel');
  String get cofounder => pick(
        'Mwanzilishi mwenza / IT · J.M. Emanueli',
        'Co-founder / IT · J.M. Emanueli',
      );
  String get languageTitle => pick('Lugha', 'Language');
  String get languageNote => pick(
        'Kiswahili ni lugha ya kwanza. Unaweza kubadilisha wakati wowote.',
        'Kiswahili is the default. You can switch at any time.',
      );
  String get swahili => 'Kiswahili';
  String get english => 'English';

  // Home cards.
  String get readTitle => pick('Soma', 'Read');
  String get readHint =>
      pick('Sikiliza maandishi yaliyo mbele yako', 'Hear the text in front of you');
  String get askTitle => pick('Uliza', 'Ask');
  String get askHint => pick(
        'Uliza swali kuhusu unachokiona',
        'Ask a question about what you see',
      );
  String get describeTitle => pick('Elezea', 'Describe');
  String get describeHint =>
      pick('Sikia mazingira yako yakielezwa', 'Hear your surroundings described');
  String get navigateTitle => pick('Njia', 'Navigate');
  String get navigateHint =>
      pick('Maelekezo ya kutembea kwa sauti', 'Walking directions spoken aloud');
  String get colorsTitle => pick('Rangi', 'Colors');
  String get colorsHint =>
      pick('Tambua rangi na usomeke wa maandishi', 'Name colors and check text contrast');

  // Soma.
  String get readCameraHint =>
      pick('Elekeza kamera kwenye maandishi', 'Point the camera at the text');
  String get readResultLabel => pick('Nimesoma:', 'I read:');
  String get readAction => pick('Soma maandishi', 'Read text');
  String get reading => pick('Ninasoma…', 'Reading…');
  String get readAnother => pick('Soma kitu kingine', 'Read something else');
  String get readReadyHint => pick(
        'Shikilia simu utulivu, weka maandishi ndani ya mraba. Tumia tochi '
        'kwenye sehemu yenye giza.',
        'Hold the phone steady and keep the text inside the frame. Use the '
        'light for dark or shiny surfaces.',
      );
  String get noTextFound => pick('Hakuna maandishi.', 'No text found.');

  // Elezea.
  String get describeCameraHint =>
      pick('Elekeza kamera mbele yako', 'Point the camera ahead');
  String get describeResultLabel => pick('Mbele yako:', 'Ahead of you:');
  String get describeAction => pick('Elezea mazingira', 'Describe scene');
  String get describing => pick('Naeleza…', 'Describing…');
  String get describeAgain => pick('Elezea upya', 'Describe again');
  String get describeReadyHint => pick(
        'Utasikia kuhusu vitu vilivyo mbele yako, watu, na njia.',
        'You will hear about obstacles, people, and the path ahead.',
      );
  String get autoOn => pick('Endelea', 'Auto on');
  String get autoOff => pick('Endelea', 'Auto');
  String get autoHint => pick(
        'Hueleza mazingira kila sekunde sita',
        'Describes the scene every six seconds',
      );
  String get autoStarted => pick(
        'Uelezaji unaendelea. Naeleza kila sekunde sita.',
        'Continuous description on. Describing every six seconds.',
      );
  String get autoStopped =>
      pick('Uelezaji wa kuendelea umezimwa.', 'Continuous description off.');

  // Uliza.
  String get askCameraHint =>
      pick('Kamera inaona kitu mbele yako', 'The camera sees something ahead');
  String get askReadyHint => pick(
        'Uliza swali kuhusu unachokiona. Unaweza kuandika au kuzungumza.',
        'Ask a question about what you see. You can type or speak.',
      );
  String get askPlaceholder => pick('Andika swali lako…', 'Type your question…');
  String get askSpeakAction => pick('Gusa uzungumze', 'Tap to speak');
  String get askListening => pick('Nasikiliza…', 'Listening…');
  String get askAction => pick('Tuma swali', 'Ask');
  String get asking => pick('Nafikiri…', 'Thinking…');
  String get askResultLabel => pick('Jibu:', 'Answer:');
  String get askMicDenied => pick(
        'Hakuna ruhusa ya maikrofoni. Andika swali badala yake.',
        'Microphone permission is missing. Type your question instead.',
      );
  String get askEmptyQuestion =>
      pick('Andika swali kwanza.', 'Type a question first.');
  String get askNoSpeech => pick(
        'Sikusikia. Jaribu tena au andika swali.',
        'I did not hear you. Try again or type the question.',
      );
  String get askAnother => pick('Uliza swali lingine', 'Ask another question');
  String get askStopListening => pick('Acha kusikiliza', 'Stop listening');
  String get askQuestionLabel => pick('Swali lako:', 'Your question:');
  String get askSpeakQuestion => pick('Sema swali lako', 'Say your question');

  // Njia (navigation).
  String get navQuestion =>
      pick('Unataka kwenda wapi?', 'Where do you want to go?');
  String get navSearchHint => pick('Anwani au mahali', 'Address or place');
  String get navSearchExample => pick(
        'Kwa mfano, City Hall au Mtaa wa Samora',
        'For example, City Hall or 100 Main Street',
      );
  String get navSearchAction => pick('Tafuta mahali', 'Search places');
  String get navReadyHint => pick(
        'Maelekezo yanasemwa. Pia utasikia mtetemo: mara mbili kushoto, mara '
        'tatu kulia. Shikilia simu mbele yako unapotembea.',
        'Walking directions are spoken. You will also feel vibration cues: two '
        'pulses for left, three for right. Hold the phone in front of you while '
        'walking.',
      );
  String get navChoose => pick('Chagua mahali', 'Choose a destination');
  String navResultLabel(int number, String name) =>
      sw ? 'Tokeo $number. $name' : 'Result $number. $name';
  String get navOpenResult => pick(
        'Gusa mara mbili kupata njia ya kutembea',
        'Double tap to get a walking route',
      );
  String get navNewSearch => pick('Tafuta tena', 'New search');
  String get navRouteReady => pick('Njia iko tayari', 'Route ready');
  String get navStart => pick('Anza uelekezaji', 'Start navigation');
  String get navChangeDestination =>
      pick('Badilisha mahali', 'Change destination');
  String get navRepeat => pick('Rudia maelekezo', 'Repeat instruction');
  String get navStop => pick('Simamisha uelekezaji', 'Stop navigation');
  String get navDone => pick('Sawa', 'Done');
  String get navSomethingWrong =>
      pick('Kuna tatizo', 'Something went wrong');
  String get navOpenSettings =>
      pick('Fungua mipangilio ya mahali', 'Open location settings');
  String get navBackToSearch => pick('Rudi kwenye utafutaji', 'Back to search');
  String get navArrowHint => pick(
        'Mshale unaelekeza kwenye zamu ijayo',
        'The arrow points to your next turn',
      );
  String get navCompassUnavailable => pick(
        'Dira haipatikani. Fuata maelekezo ya sauti.',
        'Compass unavailable. Follow the spoken instruction.',
      );
  String get navContinue =>
      pick('Endelea hadi mahali unapokwenda', 'Continue to your destination');
  String get navLeftRoute =>
      pick('Umeondoka kwenye njia. Ninahesabu upya…', 'You have left the route. Recalculating…');
  String get navIn => pick('baada ya', 'in');
  String get navNow => pick('sasa', 'now');
  String get navDistance => pick('Umbali', 'Distance');
  String get navTime => pick('Muda', 'Time');
  String get navDestination => pick('Mahali', 'Destination');
  String get navCueLeft => pick('Zamu kushoto', 'Turn left');
  String get navCueRight => pick('Zamu kulia', 'Turn right');
  String get navSearchingPlaces =>
      pick('Natafuta mahali…', 'Searching for places…');
  String get navLoadingRoute =>
      pick('Natafuta njia ya kutembea…', 'Getting your walking route…');
  String get navPreparing => pick('Najiandaa…', 'Preparing…');
  String get navArrived => pick('Umefika', 'You have arrived');
  String get navSearchAgain => pick('Tafuta tena', 'Search again');
  String get navNoPlaces => pick(
        'Hakuna mahali palipopatikana. Jaribu anwani iliyo wazi zaidi.',
        'No places found. Try a more specific address.',
      );
  String get navSearchFailed => pick(
        'Imeshindikana kutafuta mahali. Angalia mtandao na ujaribu tena.',
        'Could not search for places. Check your internet and try again.',
      );
  String get navNoRoute => pick(
        'Hakuna njia ya kutembea kwa mahali hapo. Jaribu mahali pengine.',
        'No walking route found. Try a different place.',
      );
  String get navPlacesFound => pick(
        'Mahali kupatikana. Chagua tokeo la kwanza, au tafuta tena.',
        'Places found. Choose the first result, or search again.',
      );
  String get navRouteReadySpeech =>
      pick('Njia ya kutembea iko tayari.', 'Walking route ready.');
  String get navStartSpeech => pick('Uelekezaji umeanza.', 'Navigation started.');
  String navNowSpeech(String instruction) => sw
      ? '$instruction, sasa.'
      : '$instruction, now.';
  String navInSpeech(String distance, String instruction) =>
      sw ? 'Baada ya $distance, $instruction.' : 'In $distance, $instruction.';
  String navThenIn(String distance, String instruction) => sw
      ? 'Kisha baada ya $distance, $instruction.'
      : 'Then, $instruction in $distance.';
  String get navBackOnRoute => pick('Umerudi kwenye njia.', 'Back on route.');
  String get navLeftRouteSpeech => pick(
        'Umeondoka kwenye njia. Ninahesabu upya.',
        'You have left the route. Recalculating.',
      );
  String get navRecalculated =>
      pick('Njia imehesabiwa upya.', 'Route recalculated.');
  String navArrivedSpeech(String place) => sw
      ? 'Umefika $place.'
      : 'You have arrived at $place.';
  String navRemaining(String distance) =>
      sw ? '$distance zimebaki.' : '$distance remaining.';
  String get navLocationOff =>
      pick('Washa huduma ya mahali ili kupata njia.', 'Turn on location services to navigate.');
  String get navLocationBlocked => pick(
        'Mahali pamezuiwa. Ruhusu mahali kwa Eye kwenye mipangilio ya simu, '
        'kisha ujaribu tena.',
        'Location is blocked. Allow location for Eye in system settings, then try again.',
      );
  String get navLocationNeeded =>
      pick('Ruhusa ya mahali inahitajika ili kupata njia.', 'Location permission is needed to navigate.');
  String get navLocationMissing => pick(
        'Sikuweza kupata mahali ulipo. Nenda sehemu iliyo wazi na ujaribu tena.',
        'Could not get your location. Move to an open area and try again.',
      );
  String get navLocationFailed => pick(
        'Sikuweza kupata mahali ulipo. Angalia kama huduma ya mahali imewashwa.',
        'Could not get your location. Check that location services are on.',
      );
  String get navThen => pick('Kisha,', 'Then,');
  String navDistanceSpeech(double meters) {
    if (meters.isNaN || meters.isInfinite) return '';
    if (!sw) {
      if (meters < 12) return '${meters.round()} meters';
      if (meters < 100) return '${(meters / 5).round() * 5} meters';
      if (meters < 1000) return '${(meters / 10).round() * 10} meters';
      final km = meters / 1000;
      return '${km.toStringAsFixed(km < 10 ? 1 : 0)} kilometers';
    }
    if (meters < 12) return 'mita ${meters.round()}';
    if (meters < 100) return 'mita ${(meters / 5).round() * 5}';
    if (meters < 1000) return 'mita ${(meters / 10).round() * 10}';
    final km = meters / 1000;
    return 'kilometa ${km.toStringAsFixed(km < 10 ? 1 : 0)}';
  }

  String navMinutesText(int minutes) =>
      sw ? 'dakika $minutes' : '$minutes minutes';

  String navStepOf(int current, int total) =>
      sw ? 'Hatua $current kati ya $total' : 'Step $current of $total';

  String navToGo(String distance) =>
      sw ? '$distance zimebaki' : '$distance to go';

  /// Localized version of the OSRM maneuver wording used by navigation.
  String navInstruction(String type, String modifier, String name) {
    final onto = name.isEmpty
        ? ''
        : pick(' kwenye $name', ' onto $name');
    final on = name.isEmpty ? '' : pick(' kwenye $name', ' on $name');
    switch (type) {
      case 'depart':
        return name.isEmpty
            ? pick('Anza kutembea', 'Start walking')
            : pick('Anza kutembea kwenye $name', 'Start walking on $name');
      case 'arrive':
        return pick('Fika mahali unapokwenda', 'Arrive at your destination');
      case 'roundabout':
      case 'rotary':
        return pick('Ingia kwenye mzunguko', 'Enter the roundabout');
      case 'end of road':
        if (modifier.contains('left')) {
          return pick(
            'Pinda kushoto mwisho wa barabara$onto',
            'Turn left at the end of the road$onto',
          );
        }
        if (modifier.contains('right')) {
          return pick(
            'Pinda kulia mwisho wa barabara$onto',
            'Turn right at the end of the road$onto',
          );
        }
        return pick(
          'Endelea mwisho wa barabara$on',
          'Continue at the end of the road$on',
        );
    }
    if (modifier.contains('uturn')) return pick('Rudi nyuma', 'Make a U-turn');
    if (modifier.contains('sharp left')) {
      return pick('Pinda kushoto sana$onto', 'Turn sharply left$onto');
    }
    if (modifier.contains('sharp right')) {
      return pick('Pinda kulia sana$onto', 'Turn sharply right$onto');
    }
    if (modifier.contains('slight left')) {
      return pick('Pinda kushoto kidogo$onto', 'Bear left$onto');
    }
    if (modifier.contains('slight right')) {
      return pick('Pinda kulia kidogo$onto', 'Bear right$onto');
    }
    if (modifier.contains('left')) {
      return pick('Pinda kushoto$onto', 'Turn left$onto');
    }
    if (modifier.contains('right')) {
      return pick('Pinda kulia$onto', 'Turn right$onto');
    }
    if (type == 'merge') {
      return name.isEmpty
          ? pick('Ungana na barabara', 'Merge ahead')
          : pick('Ungana na $name', 'Merge onto $name');
    }
    if (type == 'continue' || type == 'new name' || modifier == 'straight') {
      return name.isEmpty
          ? pick('Endelea moja kwa moja', 'Continue straight')
          : pick('Endelea kwenye $name', 'Continue straight on $name');
    }
    return name.isEmpty
        ? pick('Endelea', 'Continue')
        : pick('Endelea kwenye $name', 'Continue on $name');
  }

  // Rangi (colors).
  String get colorsCameraHint => pick(
        'Weka mraba katikati ya rangi',
        'Center the square on a color',
      );
  String get colorsAction => pick('Tambua rangi', 'Identify color');
  String get colorsBusy => pick('Ninaangalia…', 'Checking…');
  String get colorsReadyHint => pick(
        'Haishitaji mtandao. Itakuambia pia kama maandishi meupe au meusi '
        'yatasomeka zaidi kwenye rangi hiyo.',
        'Works without internet. It also tells you whether white or black text '
        'will be easier to read on that color.',
      );
  String get colorsUnavailable =>
      pick('Imeshindikana kusoma rangi. Jaribu tena.', 'Could not read that color. Try again.');

  String colorName(String name) {
    if (!sw) return name;
    const names = {
      'Black': 'Nyeusi',
      'White': 'Nyeupe',
      'Light gray': 'Kijivu hafifu',
      'Silver': 'Fedha',
      'Gray': 'Kijivu',
      'Dark gray': 'Kijivu kizito',
      'Charcoal': 'Makaa',
      'Slate gray': 'Kijivu cha mawe',
      'Navy blue': 'Bluu ya bahari',
      'Dark blue': 'Bluu nzito',
      'Blue': 'Bluu',
      'Royal blue': 'Bluu ya kifalme',
      'Steel blue': 'Bluu ya chuma',
      'Sky blue': 'Bluu ya anga',
      'Light blue': 'Bluu hafifu',
      'Cyan': 'Sian',
      'Turquoise': 'Turquoise',
      'Teal': 'Bluu ya kijani',
      'Dark green': 'Kijani kizito',
      'Forest green': 'Kijani cha msitu',
      'Green': 'Kijani',
      'Lime green': 'Kijani cha chokaa',
      'Lime': 'Chokaa',
      'Sea green': 'Kijani cha bahari',
      'Mint': 'Mnanaa',
      'Olive': 'Zaituni',
      'Yellow': 'Njano',
      'Gold': 'Dhahabu',
      'Amber': 'Kahawia njano',
      'Orange': 'Machungwa',
      'Dark orange': 'Machungwa kizito',
      'Coral': 'Marijani',
      'Tomato': 'Nyanya',
      'Red': 'Nyekundu',
      'Crimson': 'Nyekundu nzito',
      'Dark red': 'Nyekundu kizito',
      'Maroon': 'Maruni',
      'Salmon': 'Samoni',
      'Pink': 'Pink',
      'Hot pink': 'Pink kali',
      'Magenta': 'Majenta',
      'Purple': 'Zambarau',
      'Violet': 'Violeti',
      'Indigo': 'Indigo',
      'Lavender': 'Lavenda',
      'Plum': 'Plum',
      'Brown': 'Kahawia',
      'Saddle brown': 'Kahawia ya ngozi',
      'Chocolate': 'Chokoleti',
      'Tan': 'Kahawia hafifu',
      'Beige': 'Beige',
      'Cream': 'Krimu',
      'Khaki': 'Khaki',
    };
    return names[name] ?? name;
  }

  String colorContrast(ColorReading reading) {
    final foreground = reading.prefersWhiteText
        ? pick('nyeupe', 'white')
        : pick('meusi', 'black');
    final ratio = reading.bestContrast.toStringAsFixed(1);
    if (sw) {
      if (reading.bestContrast >= 7) {
        return 'Utofautishaji mzuri sana na maandishi $foreground, $ratio kwa 1.';
      }
      if (reading.bestContrast >= 4.5) {
        return 'Utofautishaji mzuri na maandishi $foreground, $ratio kwa 1.';
      }
      return 'Utofautishaji hafifu. Ni $ratio kwa 1 tu dhidi ya maandishi '
          '$foreground.';
    }
    if (reading.bestContrast >= 7) {
      return 'Strong contrast with $foreground text, $ratio to 1.';
    }
    if (reading.bestContrast >= 4.5) {
      return 'Good contrast with $foreground text, $ratio to 1.';
    }
    return 'Low contrast. Only $ratio to 1 against $foreground text.';
  }

  String colorSpoken(ColorReading reading) {
    final name = colorName(reading.name);
    final tone = reading.isDark
        ? pick('rangi nzito', 'a dark color')
        : pick('rangi hafifu', 'a light color');
    if (sw) {
      return '$name. Ni $tone. ${colorContrast(reading)} Herufi '
          '${reading.spokenHex}.';
    }
    return '$name. A $tone. ${colorContrast(reading)} Hex '
        '${reading.spokenHex}.';
  }

  // Mipangilio (settings).
  String get voiceTitle => pick('Sauti', 'Voice');
  String get speechSpeed => pick('Mwendo wa sauti', 'Speech speed');
  String percent(int value) =>
      sw ? '$value asilimia' : '$value percent';
  String get speedHelp => pick(
        'Hubadilisha kasi ya sauti ya msaidizi.',
        'Changes how fast the assistant speaks.',
      );
  String get autoSpeak => pick(
        'Sema matokeo kiotomatiki',
        'Speak results automatically',
      );
  String get autoSpeakHelp => pick(
        'Zima ili kusikiliza matokeo tu unapogusa Rudia.',
        'Turn off to hear results only when you tap Repeat.',
      );
  String get voiceSelectLabel => pick('Chagua sauti', 'Choose a voice');
  String get voiceSelectHelp => pick(
        'Chagua sauti unayoipenda kwa msaidizi. Unaweza kuisikiliza kwanza.',
        'Pick the voice you like for the assistant. You can hear it first.',
      );
  String get testing => pick('Inajaribu…', 'Testing…');
  String get testVoice => pick('Sikiliza sauti hii', 'Hear this voice');
  String voiceOk(String voice) => sw
      ? 'Sauti ya msaidizi iko tayari: $voice.'
      : 'Assistant voice is ready: $voice.';
  String get voiceFail => pick(
        'Sauti hii haipatikani kwa sasa. Sauti ya simu itatumika badala yake.',
        'This voice is unavailable right now. Your phone voice will be used '
        'instead.',
      );
  String get voiceTestLine => pick(
        'Hii ni sauti ya msaidizi. Naweza kusoma alama, kueleza mtaa, na '
        'kukuongoza.',
        'This is the assistant voice. I can read signs, describe the street, '
        'and guide you.',
      );
  String get textTitle => pick('Maandishi', 'Text');
  String get textSize => pick('Ukubwa wa maandishi', 'Text size');
  String get themeTitle => pick('Mandhari', 'Theme');
  String get aboutTitle => pick('Kuhusu', 'About');
  String get aboutText => pick(
        'Eye 0.3.3\nMsaidizi wa maono kwa Kiswahili. Kila kitufe kina jina la '
        'sauti na eneo kubwa la kugusa. Inafanya kazi na TalkBack na VoiceOver.',
        'Eye 0.3.3\nA Kiswahili-first vision assistant. Every control has a '
        'spoken label and a large touch target. Works with TalkBack and VoiceOver.',
      );
  String get aboutCredits => pick(
        'Msaidizi huu umeundwa na J.M. Samwel na J.M. Emanueli kwa Optsam Eye '
        'Care, Dar es Salaam.',
        'Built by J.M. Samwel and J.M. Emanueli for Optsam Eye Care, Dar es Salaam.',
      );
  String themeName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.daylight:
        return pick('Nyeupe', 'Light');
      case AppThemeMode.midnight:
        return pick('Usiku', 'Night');
      case AppThemeMode.amber:
        return pick('Utofautishaji mkubwa', 'High contrast');
    }
  }

  String themeDescription(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.daylight:
        return pick('Bluu na nyeupe, kama kwenye picha', 'Blue and white, as designed');
      case AppThemeMode.midnight:
        return pick('Bluu nzito kwa mazingira yenye giza', 'Deep blue for low light');
      case AppThemeMode.amber:
        return pick('Nyeusi na njano kwa utofautishaji mkubwa', 'Black and yellow for maximum contrast');
    }
  }

  // Errors.
  String aiError(String? code) {
    switch (code) {
      case 'no_key':
        return pick(
          'Msaidizi hajaandaliwa vizuri kwenye simu hii. Fungua Mipangilio na '
          'ujaribu tena.',
          'The assistant is not set up on this phone. Open Settings and try again.',
        );
      case 'auth':
        return pick(
            'Msaidizi amezuiwa kwa sasa. Jaribu tena baadaye.',
            'The assistant is blocked right now. Try again later.');
      case 'model':
        return pick('Huduma ya msaidizi haipatikani kwa sasa. Jaribu tena.',
            'The assistant service is unavailable right now. Try again.');
      case 'quota':
        return pick(
            'Msaidizi amefikia kikomo kwa sasa. Subiri dakika moja na ujaribu tena.',
            'The assistant is temporarily over its limit. Wait a minute and try again.');
      case 'server':
        return pick('Huduma ya msaidizi ina tatizo. Jaribu tena baada ya muda.',
            'The assistant service had a problem. Try again in a moment.');
      case 'bad_request':
        return pick('Ombi halikufanikiwa. Jaribu tena.',
            'The request was rejected. Try again.');
      case 'network':
        return pick('Hakuna mtandao. Angalia muunganisho wako na ujaribu tena.',
            'No internet connection. Check your network and try again.');
      case 'timeout':
        return pick('Msaidizi amechelewa kujibu. Angalia mtandao na ujaribu tena.',
            'The assistant took too long to answer. Check your connection and try again.');
      case 'blocked':
        return pick('Msaidizi haikuweza kuchambua picha hii. Jaribu mwonekano mwingine.',
            'The assistant could not analyse this image. Try again with a different view.');
      case 'empty':
        return pick('Hakuna jibu lililopatikana. Jaribu tena.',
            'No answer came back. Try again.');
      default:
        return pick('Imeshindikana kufikia msaidizi. Angalia mtandao na ujaribu tena.',
            'Could not reach the assistant. Check your network and try again.');
    }
  }

  String get cameraDenied => pick(
        'Kamera imezuiwa. Fungua mipangilio ya simu, ruhusu kamera kwa Eye, '
        'kisha gusa Jaribu tena.',
        'Camera access is blocked. Open your phone settings, allow camera access '
        'for Eye, then tap Try again.',
      );
  String cameraStartFailed(String code) => pick(
        'Kamera haikuanza ($code). Gusa Jaribu tena.',
        'The camera could not start ($code). Tap Try again.',
      );
  String get cameraGeneric => pick(
        'Kamera haikuanza. Gusa Jaribu tena.',
        'The camera could not start. Tap Try again.',
      );
  String get noCamera =>
      pick('Hakuna kamera kwenye simu hii.', 'No camera was found on this device.');
  String get cameraNotAvailable =>
      pick('Kamera haipatikani.', 'The camera is not available.');
  String get startingCamera => pick('Inaanzisha kamera…', 'Starting camera…');
  String get cameraPictureFailed => pick(
        'Kamera haikuweza kupiga picha. Jaribu tena.',
        'The camera could not take a picture. Try again.',
      );
  String get cameraImageFailed => pick(
        'Imeshindikana kusoma picha ya kamera. Jaribu tena.',
        'Could not read the camera image. Try again.',
      );
  String get noFlash =>
      pick('Kamera hii haina tochi.', 'This camera does not have a flashlight.');
}

class LocaleScope extends InheritedWidget {
  const LocaleScope({super.key, required this.strings, required super.child});

  final S strings;

  static S of(BuildContext context) => S.of(context);

  @override
  bool updateShouldNotify(LocaleScope oldWidget) =>
      oldWidget.strings.language != strings.language;
}
