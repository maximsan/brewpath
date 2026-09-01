/// The terms a learner may be drilled on — the accessible set.
///
/// The ruling this file is: **a practice pool is whatever the learner's tier
/// can reach.** Plus reaches the whole glossary, reference terms included;
/// free reaches the terms its free lessons mention. Recorded as ADR-0014,
/// which #97 inherits — flashcards intersect their saved shelf with the same
/// set rather than deciding it again.
///
/// The dictionary itself is *not* gated: every learner may read every entry
/// (#20). This is only about what a drill may ask, which is a different
/// question — quizzing someone on a word the course never taught them is not
/// a lock, it is an exam for a class they could not attend.
library;

import 'package:brew_path/features/dictionary/domain/term_mentions.dart';
import 'package:brew_path/features/dictionary/domain/vocab_round.dart';
import 'package:brew_path/features/monetization/domain/free_tier.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/models/lesson_model.dart';

/// The terms [hasCourse] can be drilled on, in bank order.
///
/// **Nothing here counts anything.** ADR-0007 rules that every tier-dependent
/// quantity re-derives from the free lesson list, so widening the free tier is
/// a change to that list and to nothing else — least of all to a number
/// written down beside it. The figure the design documents ("12") was measured
/// on the two-lesson tier that ADR-0007 replaced, and it is exactly the kind
/// of quantity that goes stale in a document while the code stays right.
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
  return [
    for (final term in eligible)
      if (mentioned.contains(term.id)) term,
  ];
}

/// The accessible terms the learner has bookmarked, in bank order.
///
/// An intersection, never a filter of the shelf: a saved term outside the
/// accessible set would otherwise walk straight back into a free learner's
/// drill through the Saved deck, past the rule the All deck honours.
List<DictionaryTerm> savedAccessibleTerms({
  required List<DictionaryTerm> accessible,
  required Set<String> savedTermIds,
}) => [
  for (final term in accessible)
    if (savedTermIds.contains(term.id)) term,
];
