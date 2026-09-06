import 'package:brew_path/features/dictionary/domain/dictionary_derivations.dart';
import 'package:brew_path/features/monetization/domain/course_entitlement.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/shared/models/content/dictionary_category.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/dictionary_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dictionary_providers.g.dart';

/// Everything the dictionary's screens read, resolved once.
///
/// The pieces travel together because every rule needs all of them: a term's
/// status is meaningless without the completed set, a term's home on the grid
/// is meaningless without its category, and which terms exist at all depends
/// on the tier.
class DictionaryView {
  /// Creates a [DictionaryView].
  const DictionaryView({
    required this.terms,
    required this.categories,
    required this.completedLessonIds,
    required this.hasCourse,
  });

  /// Every term this learner's tier may see, in bank order — already
  /// narrowed by [visibleTerms], so a reference term is not here for a free
  /// learner and [termById] cannot hand one over.
  final List<DictionaryTerm> terms;

  /// Whether this learner owns the course, which decides whether an entry
  /// reads whole or stops at its short explanation (`docs/decisions.md` §12).
  final bool hasCourse;

  /// Every category, in bank order.
  final List<DictionaryCategory> categories;

  /// The lessons this learner has finished — the only learner state the
  /// dictionary reads.
  final Set<String> completedLessonIds;

  /// How many terms sit behind each filter chip.
  DictionaryCounts get counts => dictionaryCounts(terms, completedLessonIds);

  /// The term [id] names, or null when the bank has none.
  DictionaryTerm? termById(String id) =>
      terms.where((term) => term.id == id).firstOrNull;

  /// The category [id] names, or null when the bank has none. The term page's
  /// bar reads it for the eyebrow the design puts over the term.
  DictionaryCategory? categoryById(String id) =>
      categories.where((category) => category.id == id).firstOrNull;
}

/// Loads the dictionary, the learner's completed lessons and their tier
/// together.
///
/// **The tier is awaited, not read as it stands.** The shelf is one value
/// that every dictionary surface — and the Saved shelf — resolves once and
/// keeps, so it waits for the answer rather than emitting a free shelf and
/// then a wider one: a paying learner would watch their reference terms
/// arrive a frame late, and a one-shot reader that finished on the first
/// emission would hold the wrong shelf for good. While it waits nothing is
/// shown, which is the same safe direction every gate resolves in.
@riverpod
Future<DictionaryView> dictionaryView(Ref ref) async {
  // Every watch resolved before the first await: a rebuild mid-flight must not
  // find a watch on the far side of an async gap.
  final dictionary = ref.watch(dictionaryRepositoryProvider);
  final termsFuture = dictionary.getTerms();
  final categoriesFuture = dictionary.getCategories();
  final completedFuture = ref.watch(completedLessonsProvider.future);
  final entitlementFuture = ref.watch(courseEntitlementProvider.future);

  final hasCourse = await entitlementFuture;
  return DictionaryView(
    terms: visibleTerms(terms: await termsFuture, hasCourse: hasCourse),
    categories: await categoriesFuture,
    completedLessonIds: {
      for (final record in await completedFuture) record.lessonId,
    },
    hasCourse: hasCourse,
  );
}

/// The title of the lesson [lessonId] names, or null when it names none.
///
/// A term's path block shows the lesson by title, not by id: "Where you
/// learned it → m1l2" is a database row, not an answer.
@riverpod
Future<String?> lessonTitle(Ref ref, String? lessonId) async {
  if (lessonId == null) return null;
  final lesson = await ref
      .watch(contentRepositoryProvider)
      .getLessonById(lessonId);
  return lesson?.title;
}
