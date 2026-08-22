import 'package:brew_path/features/dictionary/domain/dictionary_derivations.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/shared/models/content/dictionary_category.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/repositories/dictionary_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dictionary_providers.g.dart';

/// Everything the dictionary's screens read, resolved once.
///
/// The three pieces travel together because every rule needs all three: a
/// term's status is meaningless without the completed set, and a term's home
/// on the grid is meaningless without its category.
class DictionaryView {
  /// Creates a [DictionaryView].
  const DictionaryView({
    required this.terms,
    required this.categories,
    required this.completedLessonIds,
  });

  /// Every term, in bank order.
  final List<DictionaryTerm> terms;

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
}

/// Loads the dictionary and the learner's completed lessons together.
@riverpod
Future<DictionaryView> dictionaryView(Ref ref) async {
  final dictionary = ref.watch(dictionaryRepositoryProvider);
  final completed = await ref.watch(completedLessonsProvider.future);

  return DictionaryView(
    terms: await dictionary.getTerms(),
    categories: await dictionary.getCategories(),
    completedLessonIds: {for (final record in completed) record.lessonId},
  );
}
