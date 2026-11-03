import 'package:asksam/content/citations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('source markers never reach the reader', () {
    expect(stripCitations('Ninabaki salama [S1].'), 'Ninabaki salama.');
    expect(
      stripCitations(
        'Taarifa za WHO [S1, S2] na NHS [S3] zinathibitisha hili.',
      ),
      'Taarifa za WHO na NHS zinathibitisha hili.',
    );
    expect(stripCitations('Aliunga mkono [S1][S2].'), 'Aliunga mkono.');
  });

  test('a marker that is still streaming in stays hidden', () {
    expect(stripCitations('Jibu la mwisho [S1'), 'Jibu la mwisho');
    expect(stripCitations('Jibu la mwisho [S'), 'Jibu la mwisho');
  });

  test('ordinary text and brackets are left exactly as they are', () {
    expect(stripCitations(''), '');
    expect(stripCitations('Hakuna alama hapa.'), 'Hakuna alama hapa.');
    expect(
      stripCitations('Soma [mwongozo](https://example.com) kwanza.'),
      'Soma [mwongozo](https://example.com) kwanza.',
    );
    expect(stripCitations('  nafasi  '), '  nafasi  ');
  });
}
