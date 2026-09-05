/// Which words a practice game may ask a learner about (ADR-0014).
///
/// Not the same question as which words the dictionary shows them — that is
/// `docs/decisions.md` §12, and it lives in `visibleTerms`. #97 reads this
/// set too.
library;

import 'package:brew_path/features/dictionary/domain/dictionary_derivations.dart';
import 'package:brew_path/features/dictionary/domain/term_mentions.dart';
import 'package:brew_path/features/dictionary/domain/vocab_round.dart';
import 'package:brew_path/features/monetization/domain/free_tier.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/models/lesson_model.dart';

/// The terms [hasCourse] can be drilled on, in bank order.
///
/// Derived from the free lesson list on every read and never counted into a
/// constant, which is what makes ADR-0007's promise true: widening the free
/// tier is a change to that list and to nothing else.
List<DictionaryTerm> accessibleTerms({
  required List<DictionaryTerm> terms,
  required List<LessonModel> lessons,
  required bool hasCourse,
}) {
  final eligible = vocabEligible(terms);
  if (hasCourse) return eligible;

  final mentioned = termsMentionedIn(
    lessons: [
      for (final lesson in lessons)
        if (isLessonFree(lesson.id)) lesson,
    ],
    terms: eligible,
  );
  // The free shelf, narrowed to what the free lessons mention: a reference
  // term stays paid-only whatever mentions it, and that is the shelf's rule
  // rather than a second one written here.
  return [
    for (final term in visibleTerms(terms: eligible, hasCourse: false))
      if (mentioned.contains(term.id)) term,
  ];
}

/// The accessible terms the learner has bookmarked, in bank order.
///
/// An intersection, not a filter of the shelf: a word saved before the course
/// reached it would otherwise come back through the Saved deck.
List<DictionaryTerm> savedAccessibleTerms({
  required List<DictionaryTerm> accessible,
  required Set<String> savedTermIds,
}) => [
  for (final term in accessible)
    if (savedTermIds.contains(term.id)) term,
];
