import 'package:brew_path/features/dictionary/domain/dictionary_derivations.dart';
import 'package:brew_path/shared/models/content/dictionary_category.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:flutter_test/flutter_test.dart';

/// A term with only the fields a derivation reads. Everything the screens
/// render is deliberately absent — these rules never look at it.
DictionaryTerm _term(
  String id, {
  String? lesson,
  String category = 'beans',
  String? name,
  List<String> aliases = const [],
}) => DictionaryTerm(
  id: id,
  term: name ?? id,
  categoryId: category,
  shortExplanation: 'short',
  lessonId: lesson,
  aliases: aliases,
);

const _beans = DictionaryCategory(
  id: 'beans',
  label: 'Beans and Botany',
  glyph: 'cherry',
  summary: 'The plant, the seed, where it grows.',
);
const _trade = DictionaryCategory(
  id: 'trade',
  label: 'Coffee Trade',
  glyph: 'scales',
  summary: 'From farm to roaster.',
);

void main() {
  group('status', () {
    test('a term no lesson teaches is reference, whatever the learner did', () {
      final term = _term('tds');
      expect(dictionaryStatusOf(term, const {}), DictionaryStatus.reference);
      expect(
        dictionaryStatusOf(term, const {'m1l1', 'm5l4'}),
        DictionaryStatus.reference,
        reason: 'no lesson pointer means no lesson can ever complete it',
      );
    });

    test('a term whose lesson is complete is learned', () {
      expect(
        dictionaryStatusOf(_term('arabica', lesson: 'm1l2'), const {'m1l2'}),
        DictionaryStatus.learned,
      );
    });

    test('a term whose lesson is not complete is still to learn', () {
      expect(
        dictionaryStatusOf(_term('crema', lesson: 'm5l7'), const {'m1l1'}),
        DictionaryStatus.toLearn,
        reason: 'the boundary: it has a pointer, the learner has not got there',
      );
    });
  });

  group('search', () {
    final terms = [
      _term('robusta', name: 'Robusta', aliases: ['Canephora']),
      _term('bourbon', name: 'Bourbon', aliases: ['Red Bourbon']),
      _term('geisha', name: 'Gesha', aliases: ['Geisha']),
      _term('tds', name: 'TDS', category: 'trade'),
    ];

    test('an empty query returns everything, unfiltered', () {
      expect(searchDictionary(terms, ''), terms);
      expect(searchDictionary(terms, '   '), terms);
    });

    test('a partial name matches', () {
      expect(
        searchDictionary(terms, 'robu').map((t) => t.id),
        ['robusta'],
      );
    });

    test('an alias matches the term that carries it', () {
      expect(searchDictionary(terms, 'canephora').single.id, 'robusta');
      expect(searchDictionary(terms, 'red bourbon').single.id, 'bourbon');
    });

    test('matching ignores case', () {
      expect(searchDictionary(terms, 'ROBUSTA').single.id, 'robusta');
    });

    test('matching ignores diacritics in both directions', () {
      final accented = [_term('creme', name: 'Crème')];
      expect(searchDictionary(accented, 'creme').single.id, 'creme');
      expect(searchDictionary(accented, 'crème').single.id, 'creme');
    });

    test('a category label matches its terms', () {
      expect(
        searchDictionary(
          terms,
          'trade',
          categories: const [_beans, _trade],
        ).map((t) => t.id),
        ['tds'],
      );
    });

    test('a query matching nothing returns empty, not everything', () {
      expect(searchDictionary(terms, 'zzzz'), isEmpty);
    });
  });

  group('filter and counts', () {
    final terms = [
      _term('a', lesson: 'm1l1'), // learned
      _term('b', lesson: 'm1l2'), // learned
      _term('c', lesson: 'm5l4'), // to learn
      _term('d'), // reference
      _term('e'), // reference
    ];
    const completed = {'m1l1', 'm1l2'};

    test('all keeps every term, reference included', () {
      expect(
        filterDictionary(terms, DictionaryFilter.all, completed).map((t) => t.id),
        ['a', 'b', 'c', 'd', 'e'],
      );
    });

    test('learned keeps only completed-lesson terms', () {
      expect(
        filterDictionary(
          terms,
          DictionaryFilter.learned,
          completed,
        ).map((t) => t.id),
        ['a', 'b'],
      );
    });

    test('to learn excludes reference terms', () {
      expect(
        filterDictionary(
          terms,
          DictionaryFilter.toLearn,
          completed,
        ).map((t) => t.id),
        ['c'],
        reason: 'a reference term is not "not yet" — no lesson will teach it',
      );
    });

    test('the to-learn count excludes reference terms too', () {
      final counts = dictionaryCounts(terms, completed);
      expect(counts.all, 5);
      expect(counts.learned, 2);
      expect(
        counts.toLearn,
        1,
        reason: 'the number in front of the learner must be a promise the '
            'course can keep',
      );
    });

    test('a count agrees with the list its filter produces', () {
      final counts = dictionaryCounts(terms, completed);
      for (final (filter, count) in [
        (DictionaryFilter.all, counts.all),
        (DictionaryFilter.learned, counts.learned),
        (DictionaryFilter.toLearn, counts.toLearn),
      ]) {
        expect(
          filterDictionary(terms, filter, completed).length,
          count,
          reason: 'the count for $filter disagrees with its own list',
        );
      }
    });
  });

  group('grouping', () {
    test('every term lands under its category, exactly once', () {
      final terms = [
        _term('a'),
        _term('b', category: 'trade'),
        _term('c'),
      ];
      final grouped = groupByCategory(terms, const [_beans, _trade]);

      expect(grouped[_beans]!.map((t) => t.id), ['a', 'c']);
      expect(grouped[_trade]!.map((t) => t.id), ['b']);
      expect(
        grouped.values.expand((t) => t).length,
        terms.length,
        reason: 'grouping must not drop or duplicate a term',
      );
    });

    test('a category with no terms is absent, not empty', () {
      final grouped = groupByCategory([_term('a')], const [_beans, _trade]);
      expect(grouped.keys.map((c) => c.id), ['beans']);
    });

    test('categories keep bank order', () {
      final grouped = groupByCategory(
        [_term('b', category: 'trade'), _term('a')],
        const [_beans, _trade],
      );
      expect(grouped.keys.map((c) => c.id), ['beans', 'trade']);
    });
  });
}
