/// What counts as a whole word when copy is matched against the term bank.
///
/// Boundaries are checked by hand rather than with `\b`: a term may begin or
/// end with a non-word character — *pour-over* ends in a letter, *V60* does
/// not begin with one — and `\b` before such a character matches in the wrong
/// place.
library;

/// A letter or a digit in any script — the characters a word runs on.
///
/// Any script, because ADR-0025 ships term matching with the language: an
/// ASCII-only test reads every Cyrillic letter as a boundary, which made
/// *кавамашына* a mention of *кава*.
final _wordChar = RegExp(r'[\p{L}\p{N}]', unicode: true);

/// Whether [char] is a letter or a digit. A null — the edge of the text — is
/// not.
bool isWordChar(String? char) => char != null && _wordChar.hasMatch(char);

/// Whether the run of [length] characters at [at] in [text] stands as a whole
/// word, judged by the characters on either side of it.
bool standsAlone(String text, int at, int length) {
  final end = at + length;
  return !isWordChar(at == 0 ? null : text[at - 1]) &&
      !isWordChar(end >= text.length ? null : text[end]);
}
