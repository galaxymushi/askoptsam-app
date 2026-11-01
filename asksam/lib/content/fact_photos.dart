import 'eye_facts.dart';

/// Real, freely licensed photographs for the eye facts. Each file is a
/// downscaled crop (900 px wide) of the original on Wikimedia Commons, and the
/// author plus licence are shown under the picture in the fact screen.
///
/// The map is keyed by `EyeFact.id` on purpose: every fact shows a picture of
/// its own subject (a driver at night, a bright screen in a dark room, a blood
/// sugar test), not a generic picture shared with other facts.
class FactPhoto {
  const FactPhoto({
    required this.asset,
    required this.author,
    required this.license,
    required this.sourceUrl,
  });

  final String asset;
  final String author;
  final String license;
  final String sourceUrl;
}

const Map<String, FactPhoto> factPhotos = {
  'rule-20-20-20': FactPhoto(
    asset: 'assets/images/facts/rule-20-20-20.jpg',
    author: 'Tom Mrazek',
    license: 'CC BY 2.0',
    sourceUrl:
        'https://commons.wikimedia.org/wiki/File:Looking_into_the_Distance_(33017113901).jpg',
  ),
  'blinking': FactPhoto(
    asset: 'assets/images/facts/eye.jpg',
    author: 'Rapidreflex',
    license: 'CC BY-SA 4.0',
    sourceUrl:
        'https://commons.wikimedia.org/wiki/File:Human_eye_close_up,_anterior_view.jpg',
  ),
  'uv': FactPhoto(
    asset: 'assets/images/facts/sun.jpg',
    author: 'Vyacheslav Argenberg',
    license: 'CC BY 4.0',
    sourceUrl:
        'https://commons.wikimedia.org/wiki/File:Koh_Kut,_Thailand,_Sunglasses_2.jpg',
  ),
  'food': FactPhoto(
    asset: 'assets/images/facts/food.jpg',
    author: 'Ivykas',
    license: 'CC BY-SA 4.0',
    sourceUrl:
        'https://commons.wikimedia.org/wiki/File:Carrots_at_the_vegetable_market_place.jpg',
  ),
  'dry-eye': FactPhoto(
    asset: 'assets/images/facts/dry-eye.jpg',
    author: 'Jonathan Trobe, University of Michigan',
    license: 'CC BY 3.0',
    sourceUrl: 'https://commons.wikimedia.org/wiki/File:Dry_eyeKell.jpg',
  ),
  'checkup': FactPhoto(
    asset: 'assets/images/facts/checkup.jpg',
    author: 'Gkbediako',
    license: 'CC BY-SA 4.0',
    sourceUrl:
        'https://commons.wikimedia.org/wiki/File:A_Ghanaian_Optometrist_performing_an_eye_examination_with_a_slit_lamp.jpg',
  ),
  'sleep': FactPhoto(
    asset: 'assets/images/facts/moon.jpg',
    author: 'Rachel Calamusa',
    license: 'CC BY-SA 2.0',
    sourceUrl: 'https://commons.wikimedia.org/wiki/File:Sleeping-girl.jpg',
  ),
  'smoke': FactPhoto(
    asset: 'assets/images/facts/smoke.jpg',
    author: 'Challiyil Eswaramangalath Vipin',
    license: 'CC BY-SA 2.0',
    sourceUrl: 'https://commons.wikimedia.org/wiki/File:Cigarette_smoke.jpg',
  ),
  'cataract': FactPhoto(
    asset: 'assets/images/facts/cataract.jpg',
    author: 'Rakesh Ahuja, MD',
    license: 'CC BY-SA 3.0',
    sourceUrl:
        'https://commons.wikimedia.org/wiki/File:Cataract_in_human_eye.png',
  ),
  'glaucoma': FactPhoto(
    asset: 'assets/images/facts/glaucoma.jpg',
    author: 'Jason7825 at English Wikipedia',
    license: 'CC BY-SA 3.0',
    sourceUrl: 'https://commons.wikimedia.org/wiki/File:Patient_and_tonometer.jpg',
  ),
  'diabetes': FactPhoto(
    asset: 'assets/images/facts/diabetes.jpg',
    author: 'Biswarup Ganguly',
    license: 'CC BY 3.0',
    sourceUrl:
        'https://commons.wikimedia.org/wiki/File:Blood_Glucose_Testing_-_Kolkata_2011-07-25_3975.jpg',
  ),
  'distance': FactPhoto(
    asset: 'assets/images/facts/distance.jpg',
    author: 'Shixart1985',
    license: 'CC BY 2.0',
    sourceUrl:
        'https://commons.wikimedia.org/wiki/File:Young_child_holding_smartphone_while_in_kitchen_with_adult_in_background_during_daytime_activities.jpg',
  ),
  'children': FactPhoto(
    asset: 'assets/images/facts/children.jpg',
    author: 'U.S. Fish and Wildlife Service',
    license: 'Public domain',
    sourceUrl:
        'https://commons.wikimedia.org/wiki/File:Children_playing_outdoors.jpg',
  ),
  'contacts': FactPhoto(
    asset: 'assets/images/facts/contacts.jpg',
    author: 'Reinhard Müller',
    license: 'CC BY-SA 4.0',
    sourceUrl: 'https://commons.wikimedia.org/wiki/File:Eye_with_contact_lens.jpg',
  ),
  'hands': FactPhoto(
    asset: 'assets/images/facts/hands.jpg',
    author: 'Beat Ruest',
    license: 'CC BY-SA 4.0',
    sourceUrl:
        'https://commons.wikimedia.org/wiki/File:Washing_hands_with_soap_(1).jpg',
  ),
  'drops': FactPhoto(
    asset: 'assets/images/facts/drops.jpg',
    author: 'Destiny Deffo',
    license: 'CC BY-SA 4.0',
    sourceUrl:
        'https://commons.wikimedia.org/wiki/File:Application_de_La_goutte_ophtalmique_Pour_Les_Yeux_A_l%27h%C3%B4pital_Laquintinie_de_Douala_13.jpg',
  ),
  'brightness': FactPhoto(
    asset: 'assets/images/facts/brightness.jpg',
    author: 'Beercha',
    license: 'CC BY 2.0',
    sourceUrl:
        'https://commons.wikimedia.org/wiki/File:Woman_in_a_dark_room_looking_to_a_mac_computer.jpg',
  ),
  'headache': FactPhoto(
    asset: 'assets/images/facts/headache.jpg',
    author: 'Jose Navarro',
    license: 'CC BY 2.0',
    sourceUrl:
        'https://commons.wikimedia.org/wiki/File:Headache_touching_forehead.jpg',
  ),
  'night-driving': FactPhoto(
    asset: 'assets/images/facts/night-driving.jpg',
    author: 'Tom Reynolds',
    license: 'CC BY 2.0',
    sourceUrl:
        'https://commons.wikimedia.org/wiki/File:DSC_0037_(1515385856).jpg',
  ),
  'vitamin-a': FactPhoto(
    asset: 'assets/images/facts/vitamin-a.jpg',
    author: 'George Chernilevsky',
    license: 'Public domain',
    sourceUrl: 'https://commons.wikimedia.org/wiki/File:Cucurbita_2011_G1.jpg',
  ),
};

FactPhoto? photoFor(EyeFact fact) => factPhotos[fact.id];
