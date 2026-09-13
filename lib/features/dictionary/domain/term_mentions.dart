/// Which dictionary terms a set of lessons actually says out loud.
///
/// The rule behind the free practice pool, derived from the lessons a learner
/// can open (ADR-0007; `docs/decisions.md` §2 settled *mentioned* over *taught
/// by*). A mention is a **whole word**: substring matching would read *scale*
/// as a mention of *SCA*, enlarging the pool with terms no lesson says.
library;

import 'package:brew_path/features/dictionary/domain/lesson_visible_text.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/models/lesson_model.dart';

/// Whether [text], already lowercased, says [word] as a whole word.
///
/// Boundaries are checked by hand rather than with `\b`: a term may begin or
/// end with a non-word character — *pour-over* ends in a letter, *V60* does
/// not begin with one — and `\b` before such a character matches in the wrong
/// place.
bool _saysWord(String text, String word) {
  if (word.isEmpty) return false;
  var from = 0;
  while (true) {
    final at = text.indexOf(word, from);
    if (at == -1) return false;
    final before = at == 0 ? null : text[at - 1];
    final afterAt = at + word.length;
    final after = afterAt >= text.length ? null : text[afterAt];
    if (!_isWordChar(before) && !_isWordChar(after)) return true;
    from = at + 1;
  }
}

/// A letter or a digit in any script — the characters a word runs on.
///
/// Any script, because ADR-0025 ships term matching with the language: an
/// ASCII-only test reads every Cyrillic letter as a boundary, which made
/// *кавамашына* a mention of *кава*.
final _wordChar = RegExp(r'[\p{L}\p{N}]', unicode: true);

/// Whether [char] is a letter or a digit.
bool _isWordChar(String? char) => char != null && _wordChar.hasMatch(char);

/// Whether [lessonText] mentions [term] by its name or any of its aliases.
///
/// [lessonText] is expected already lowercased — the caller builds it once for
/// a whole set of lessons rather than folding it per term.
bool lessonTextMentions(String lessonText, DictionaryTerm term) => [
  term.term,
  ...term.aliases,
].any((word) => _saysWord(lessonText, word.toLowerCase()));

/// The ids of the [terms] that [lessons] mention.
///
/// Order follows [terms], so the result reads in bank order wherever it is
/// listed.
Set<String> termsMentionedIn({
  required List<LessonModel> lessons,
  required List<DictionaryTerm> terms,
}) {
  final text = lessons.map(lessonVisibleText).join(' ').toLowerCase();
  return {
    for (final term in terms)
      if (lessonTextMentions(text, term)) term.id,
  };
}
