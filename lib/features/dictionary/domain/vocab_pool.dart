/// The terms a learner may be drilled on — the accessible set (ADR-0014).
///
/// Not a gate on the dictionary, which shows every entry to everyone (#20):
/// only on what a drill may ask. #97 reads the same set.
library;

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
  return [
    for (final term in eligible)
      if (mentioned.contains(term.id)) term,
  ];
}

/// The accessible terms the learner has bookmarked, in bank order.
///
/// An intersection, never a filter of the shelf: a term saved from the
/// ungated dictionary would otherwise walk back into a free learner's drill
/// through the Saved deck.
List<DictionaryTerm> savedAccessibleTerms({
  required List<DictionaryTerm> accessible,
  required Set<String> savedTermIds,
}) => [
  for (final term in accessible)
    if (savedTermIds.contains(term.id)) term,
];
