/// Which dictionary terms a set of lessons actually says out loud.
///
/// The rule behind the practice term pool. ADR-0007 fixes the free tier as a
/// named lesson list and rules that everything downstream re-derives from it —
/// so the pool is computed here from the lessons a learner can open, and no
/// count of it is ever written down. `docs/decisions.md` §2 settled *mentioned*
/// over *taught by*: the taught-by reading gives a free learner too few terms
/// to fill a single round, which would make the game unplayable rather than
/// small.
///
/// **A mention is a whole word.** Substring matching reads *scale* as a mention
/// of *SCA* and *atypical* as one of *Typica*, which would quietly enlarge the
/// free pool with terms no lesson says.
library;

import 'package:brew_path/features/dictionary/domain/lesson_visible_text.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/models/lesson_model.dart';

/// Whether [text], already lowercased, says [word] as a whole word.
///
/// Word boundaries are asserted by hand rather than with `\b`, because a term
/// may begin or end with a non-word character — *pour-over* ends in a letter
/// but *V60* does not begin with one, and `\b` before a non-word character
/// matches in the wrong place. Testing the neighbouring characters instead
/// asks the question that is actually meant: is there a letter or digit
/// pressed up against the match?
bool _saysWord(String text, String word) {
  if (word.isEmpty) return false;
  var from = 0;
  while (true) {
    final at = text.indexOf(word, from);
    if (at == -1) return false;
    final before = at == 0 ? null : text.codeUnitAt(at - 1);
    final afterAt = at + word.length;
    final after = afterAt >= text.length ? null : text.codeUnitAt(afterAt);
    if (!_isWordChar(before) && !_isWordChar(after)) return true;
    from = at + 1;
  }
}

/// Whether [code] is a letter or a digit — the characters a word runs on.
bool _isWordChar(int? code) {
  if (code == null) return false;
  const zero = 0x30;
  const nine = 0x39;
  const lowerA = 0x61;
  const lowerZ = 0x7a;
  return (code >= zero && code <= nine) || (code >= lowerA && code <= lowerZ);
}

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
