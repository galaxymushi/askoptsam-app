import 'eye_facts.dart';

/// Real, freely licensed photographs for the eye facts. Each file is a
/// downscaled crop (900 px wide) of the original on Wikimedia Commons, and the
/// author plus licence are shown under the picture in the fact screen.
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

const Map<FactArt, FactPhoto> factPhotos = {
  FactArt.eye: FactPhoto(
    asset: 'assets/images/facts/eye.jpg',
    author: 'Rapidreflex',
    license: 'CC BY-SA 4.0',
    sourceUrl: 'https://commons.wikimedia.org/wiki/File:Human_eye_close_up,_anterior_view.jpg',
  ),
  FactArt.screen: FactPhoto(
    asset: 'assets/images/facts/screen.jpg',
    author: 'ResDigital18',
    license: 'CC BY-SA 4.0',
    sourceUrl: 'https://commons.wikimedia.org/wiki/File:Person_typing_at_keyboard_with_screen_overlays.jpg',
  ),
  FactArt.sun: FactPhoto(
    asset: 'assets/images/facts/sun.jpg',
    author: 'Vyacheslav Argenberg',
    license: 'CC BY 4.0',
    sourceUrl: 'https://commons.wikimedia.org/wiki/File:Koh_Kut,_Thailand,_Sunglasses_2.jpg',
  ),
  FactArt.food: FactPhoto(
    asset: 'assets/images/facts/food.jpg',
    author: 'Ivykas',
    license: 'CC BY-SA 4.0',
    sourceUrl: 'https://commons.wikimedia.org/wiki/File:Carrots_at_the_vegetable_market_place.jpg',
  ),
  FactArt.drop: FactPhoto(
    asset: 'assets/images/facts/drop.jpg',
    author: 'National Eye Institute',
    license: 'CC BY 2.0',
    sourceUrl: 'https://commons.wikimedia.org/wiki/File:Eye_drop.jpg',
  ),
  FactArt.clock: FactPhoto(
    asset: 'assets/images/facts/clock.jpg',
    author: 'Beendy234',
    license: 'CC0',
    sourceUrl:
        'https://commons.wikimedia.org/wiki/File:Reading_Snellen_Chart.jpg',
  ),
  FactArt.moon: FactPhoto(
    asset: 'assets/images/facts/moon.jpg',
    author: 'Rachel Calamusa',
    license: 'CC BY-SA 2.0',
    sourceUrl: 'https://commons.wikimedia.org/wiki/File:Sleeping-girl.jpg',
  ),
  FactArt.smoke: FactPhoto(
    asset: 'assets/images/facts/smoke.jpg',
    author: 'Challiyil Eswaramangalath Vipin',
    license: 'CC BY-SA 2.0',
    sourceUrl: 'https://commons.wikimedia.org/wiki/File:Cigarette_smoke.jpg',
  ),
};
