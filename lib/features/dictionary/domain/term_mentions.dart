/// Which dictionary terms a set of lessons actually says out loud.
///
/// The rule behind the free practice pool, derived from the lessons a learner
/// can open (ADR-0007; `docs/decisions.md` §2 settled *mentioned* over *taught
/// by*). A mention is a **whole word**: substring matching would read *scale*
/// as a mention of *SCA*, enlarging the pool with terms no lesson says.
library;

import 'package:brew_path/features/dictionary/domain/lesson_visible_text.dart';
import 'package:brew_path/features/dictionary/domain/term_words.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/models/lesson_model.dart';

/// Whether [text], already lowercased, says [word] as a whole word.
bool _saysWord(String text, String word) {
  if (word.isEmpty) return false;
  var from = 0;
  while (true) {
    final at = text.indexOf(word, from);
    if (at == -1) return false;
    if (standsAlone(text, at, word.length)) return true;
    from = at + 1;
  }
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
