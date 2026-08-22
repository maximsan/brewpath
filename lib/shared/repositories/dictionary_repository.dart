import 'package:brew_path/shared/models/content/dictionary_category.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/repositories/bank_loader.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dictionary_repository.g.dart';

/// The dictionary's two banks, loaded off the bundled assets and cached.
///
/// Its own repository rather than two more methods on `ContentRepository`:
/// the dictionary is the one content family with derivations of its own, and
/// the course repository was already at its method budget. Loading goes
/// through the same [loadBank] helper every other bank uses, so nothing about
/// how content reaches the app is special here.
class DictionaryRepository {
  List<DictionaryTerm>? _terms;
  List<DictionaryCategory>? _categories;

  /// Loads and caches every term, in bank order.
  ///
  /// Terms carry no learner state: whether one is learned is derived from its
  /// lesson pointer against completed lessons, never stored.
  Future<List<DictionaryTerm>> getTerms() async {
    _terms ??= await loadBank(
      'assets/content/generated/dictionary_terms.json',
      DictionaryTerm.fromJson,
    );
    return _terms!;
  }

  /// Loads and caches every category, in bank order.
  Future<List<DictionaryCategory>> getCategories() async {
    _categories ??= await loadBank(
      'assets/content/generated/dictionary_categories.json',
      DictionaryCategory.fromJson,
    );
    return _categories!;
  }
}

/// The app-wide [DictionaryRepository].
@riverpod
DictionaryRepository dictionaryRepository(Ref ref) => DictionaryRepository();
