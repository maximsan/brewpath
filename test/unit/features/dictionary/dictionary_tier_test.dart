// The dictionary each tier can see, against the bank the app actually ships
// (`docs/decisions.md` §12).
//
// Counts are derived, never quoted: the bank has grown three times, and a
// test pinning "65 free terms" would fail on authoring rather than on a
// defect. What is asserted is what would change *meaning*: that free is
// exactly the lesson terms, that Plus is everything, and that no reference
// term can be reached from the free shelf by search, by category, by id, or
// as today's term.
import 'package:brew_path/features/dictionary/domain/dictionary_derivations.dart';
import 'package:brew_path/features/dictionary/domain/term_of_day.dart';
import 'package:brew_path/shared/models/content/dictionary_category.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/repositories/dictionary_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<DictionaryTerm> terms;
  late List<DictionaryCategory> categories;

  setUpAll(() async {
    final repository = DictionaryRepository();
    terms = await repository.getTerms();
    categories = await repository.getCategories();
  });

  List<DictionaryTerm> shelfFor({required bool hasCourse}) =>
      visibleTerms(terms: terms, hasCourse: hasCourse);

  Iterable<DictionaryTerm> reference() =>
      terms.where((term) => term.lessonId == null);

  test('the bank still carries reference terms to hide', () {
    // Every assertion below is vacuous without them.
    expect(reference(), isNotEmpty);
  });

  test('Plus sees the whole bank, in bank order', () {
    expect(shelfFor(hasCourse: true), terms);
  });

  test('free sees exactly the lesson terms, in bank order', () {
    final free = shelfFor(hasCourse: false);

    expect(free, terms.where((term) => term.lessonId != null));
    expect(
      free.length + reference().length,
      terms.length,
      reason: 'the two access classes partition the bank',
    );
  });

  test('every free term carries the short explanation it is read by', () {
    for (final term in shelfFor(hasCourse: false)) {
      expect(term.shortExplanation, isNotEmpty, reason: term.id);
    }
  });

  test('no search over the free shelf finds a reference term', () {
    final free = shelfFor(hasCourse: false);
    for (final hidden in reference()) {
      for (final query in [hidden.term, ...hidden.aliases]) {
        expect(
          searchDictionary(free, query, categories: categories),
          isNot(contains(hidden)),
          reason: '"$query" surfaced ${hidden.id} for a free learner',
        );
      }
    }
  });

  test('the free category counts add up to the free shelf', () {
    final free = shelfFor(hasCourse: false);
    final grouped = groupByCategory(free, categories);

    expect(
      grouped.values.fold(0, (total, members) => total + members.length),
      free.length,
    );
    expect(
      grouped.values
          .expand((members) => members)
          .any(
            (term) => term.lessonId == null,
          ),
      isFalse,
    );
  });

  test("a free learner's Term of the Day is always on their shelf", () {
    final free = {for (final term in shelfFor(hasCourse: false)) term.id};
    for (final term in termOfDayPool(terms: terms, hasCourse: false)) {
      expect(free, contains(term.id));
    }
  });
}
