import 'package:brew_path/features/dictionary/domain/vocab_pool.dart';
import 'package:brew_path/features/dictionary/domain/vocab_round.dart';
import 'package:brew_path/features/dictionary/domain/vocab_setup.dart';
import 'package:brew_path/features/monetization/domain/course_entitlement.dart';
import 'package:brew_path/features/saved/domain/saved_key.dart';
import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/dictionary_repository.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/storage/snapshot/term_miss.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'vocab_providers.g.dart';

/// Every term the learner has answered, with the stamps that decide whether
/// it is still owed a review.
///
/// Its own provider, like [savedKeysProvider]: it is the seam a drill
/// invalidates after logging an answer, and an inline snapshot read would
/// leave a second future in flight that nothing awaits.
@riverpod
Future<Map<String, TermMiss>> vocabAnswers(Ref ref) async =>
    (await ref.watch(snapshotRepositoryProvider).read())
        .clearedByReset
        .termAnswers;

/// Both pools a drill picks from, resolved together.
///
/// One value, not two providers: every screen reads them as a pair — setup
/// compares their sizes, the round generator asks from one and draws wrong
/// answers from the other. Split, a screen could hold a saved pool from one
/// rebuild beside an accessible pool from the next.
class VocabPools {
  /// Creates a [VocabPools].
  const VocabPools({
    required this.accessible,
    required this.saved,
    required this.savedEligible,
    required this.missed,
    this.categoryLabels = const {},
    this.hasCourse = false,
  });

  /// Every term this learner's tier may be drilled on.
  final List<DictionaryTerm> accessible;

  /// The accessible terms they bookmarked — always a subset of [accessible].
  final List<DictionaryTerm> saved;

  /// The accessible terms they owe a review — also a subset of [accessible].
  ///
  /// Required, like [saved]: an empty deck and a deck nobody remembered to
  /// pass read identically at every call site, and the first is a state the
  /// setup screen must draw honestly.
  final List<DictionaryTerm> missed;

  /// How many bookmarks are words a drill could ask about at all, before the
  /// tier narrows it — **not** the raw count of saved keys.
  ///
  /// A term the bank dropped, or one authored without the short explanation a
  /// question needs, is drillable on no tier; counting those would make the
  /// copy promise the course puts them in reach. Required, not defaulted.
  final int savedEligible;

  /// Whether they saved words a drill could ask about, and their tier reaches
  /// none of them.
  ///
  /// Every clause is load-bearing: this turns on copy saying the *free
  /// lessons* do not cover what they saved and the full course would, which a
  /// paid learner — reaching every eligible word — cannot honestly be told.
  bool get savedIsOutOfReach =>
      !hasCourse && saved.isEmpty && savedEligible > 0;

  /// Category id to its label, for the eyebrow over a question.
  ///
  /// Resolved here rather than watched separately by the screen: a question
  /// showing a stale category beside a fresh term is exactly the split the
  /// one-value rule above exists to prevent.
  final Map<String, String> categoryLabels;

  /// Whether this learner owns the course — the All deck names itself for
  /// what it actually holds, and "the whole glossary" is a claim only one
  /// tier can make.
  final bool hasCourse;

  /// The terms [deck] can ask about.
  List<DictionaryTerm> forDeck(VocabDeck deck) => switch (deck) {
    VocabDeck.saved => saved,
    VocabDeck.misses => missed,
    VocabDeck.all => accessible,
  };
}

/// The learner's drill pools, tier-scoped.
///
/// **Unresolved entitlement reads as free**, the direction every other gate in
/// the app resolves it: showing a free learner the whole glossary for a frame
/// is the leak, and showing a paying learner a small pool for a frame is a
/// rebuild away from being right.
@riverpod
Future<VocabPools> vocabPools(Ref ref) async {
  // Every watch resolved before the first await: a rebuild mid-flight must not
  // find a watch on the far side of an async gap.
  final dictionary = ref.watch(dictionaryRepositoryProvider);
  final termsFuture = dictionary.getTerms();
  final categoriesFuture = dictionary.getCategories();
  final lessonsFuture = ref.watch(contentRepositoryProvider).getLessons();
  final savedFuture = ref.watch(savedKeysProvider.future);
  final answersFuture = ref.watch(vocabAnswersProvider.future);
  final entitlement = ref.watch(courseEntitlementProvider);

  final hasCourse = entitlement.asData?.value ?? false;
  final terms = await termsFuture;
  final accessible = accessibleTerms(
    terms: terms,
    lessons: await lessonsFuture,
    hasCourse: hasCourse,
  );

  final savedTermIds = {
    for (final raw in await savedFuture)
      if (parseSavedKey(raw) case (kind: SavedKind.term, :final id)) id,
  };

  return VocabPools(
    accessible: accessible,
    hasCourse: hasCourse,
    missed: missedAccessibleTerms(
      accessible: accessible,
      answers: await answersFuture,
    ),
    // Intersected with every drillable word rather than counted off the keys:
    // a bookmark no drill could ever ask about is not one the course unlocks.
    savedEligible: savedAccessibleTerms(
      accessible: vocabEligible(terms),
      savedTermIds: savedTermIds,
    ).length,
    categoryLabels: {
      for (final category in await categoriesFuture)
        category.id: category.label,
    },
    saved: savedAccessibleTerms(
      accessible: accessible,
      savedTermIds: savedTermIds,
    ),
  );
}
