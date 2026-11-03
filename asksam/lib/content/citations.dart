// The hosted AskOptSam assistant cites its sources inline — `[S1]`, `[S2]`,
// `[S1, S2]` … The app shows no source list next to a chat bubble, so those
// markers only confuse the reader. Everything the user sees is filtered
// through [stripCitations] before it reaches the screen or storage.

/// A complete marker such as `[S1]` or `[S1, S2]`.
final RegExp _completeCitation = RegExp(r'\[\s*S\d+(?:\s*,\s*S?\d+)*\s*\]');

/// A marker that is still being streamed in, i.e. the text currently ends
/// with `[S1`. Hidden while it arrives so no half-finished code flashes.
final RegExp _partialCitation = RegExp(r'\[\s*S[\d,\s]*$');

/// Spaces left behind after a marker was removed.
final RegExp _repeatedSpaces = RegExp(r'[ \t]{2,}');

/// A space left in front of punctuation (`… kitaalamu [S1].` → `… kitaalamu.`).
final RegExp _spaceBeforePunctuation = RegExp(r'[ \t]+([.,;:!?])');

/// Removes source markers from [text] and tidies the gaps they leave behind.
/// Cheap enough to run on every streamed chunk: text without a bracket — or
/// without a marker — comes back untouched, formatting included.
String stripCitations(String text) {
  if (text.isEmpty || !text.contains('[')) return text;

  var out = text.replaceAll(_completeCitation, '');

  final partial = _partialCitation.firstMatch(out);
  if (partial != null) out = out.substring(0, partial.start);

  if (out == text) return text; // Nothing was a marker: leave the text alone.

  return out
      .replaceAll(_repeatedSpaces, ' ')
      .replaceAllMapped(_spaceBeforePunctuation, (m) => m.group(1) ?? '')
      .trimRight();
}
