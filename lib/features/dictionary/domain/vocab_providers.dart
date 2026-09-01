import 'package:brew_path/features/dictionary/domain/vocab_pool.dart';
import 'package:brew_path/features/monetization/domain/course_entitlement.dart';
import 'package:brew_path/features/saved/domain/saved_key.dart';
import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/dictionary_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'vocab_providers.g.dart';

/// Both pools a drill picks from, resolved together.
///
/// One value rather than two providers because the two are read as a pair on
/// every screen the game has — the setup offers a deck by comparing their
/// sizes, and the round generator asks from one while drawing wrong answers
/// from the other. Splitting them would let a screen hold a saved pool from
/// one rebuild beside an accessible pool from the next.
class VocabPools {
  /// Creates a [VocabPools].
  const VocabPools({
    required this.accessible,
    required this.saved,
    this.categoryLabels = const {},
  });

  /// Every term this learner's tier may be drilled on.
  final List<DictionaryTerm> accessible;

  /// The accessible terms they bookmarked — always a subset of [accessible].
  final List<DictionaryTerm> saved;

  /// Category id to its label, for the eyebrow over a question.
  ///
  /// Resolved here rather than watched separately by the screen: a question
  /// showing a stale category beside a fresh term is exactly the split the
  /// one-value rule above exists to prevent.
  final Map<String, String> categoryLabels;
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
  final entitlement = ref.watch(courseEntitlementProvider);

  final accessible = accessibleTerms(
    terms: await termsFuture,
    lessons: await lessonsFuture,
    hasCourse: entitlement.asData?.value ?? false,
  );

  return VocabPools(
    accessible: accessible,
    categoryLabels: {
      for (final category in await categoriesFuture)
        category.id: category.label,
    },
    saved: savedAccessibleTerms(
      accessible: accessible,
      savedTermIds: {
        for (final raw in await savedFuture)
          if (parseSavedKey(raw) case (kind: SavedKind.term, :final id)) id,
      },
    ),
  );
}
