// Term of the Day against the bank the app actually ships (#96).
//
// Counts are derived, never quoted: the dictionary keeps being authored, and a
// test pinning "65 free terms" would fail on a new word rather than on a
// defect. What is asserted is what would change meaning — that the pick is a
// function of the date and the tier, that a free learner is never offered a
// term their dictionary does not carry, and that the rotation walks the pool
// instead of sitting on one term.
import 'package:brew_path/features/dictionary/domain/term_of_day.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/repositories/dictionary_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<DictionaryTerm> terms;

  setUpAll(() async {
    terms = await DictionaryRepository().getTerms();
  });

  List<DictionaryTerm> poolFor({required bool hasCourse}) =>
      termOfDayPool(terms: terms, hasCourse: hasCourse);

  group('the pool each tier rotates over', () {
    test('every term in either pool has a full entry to open', () {
      for (final hasCourse in [true, false]) {
        expect(
          poolFor(hasCourse: hasCourse).where(
            (term) => term.deepExplanation == null,
          ),
          isEmpty,
          reason: '"Read the full entry" must never lead to nothing',
        );
      }
    });

    test('a free learner is never offered a reference-only term', () {
      expect(
        poolFor(hasCourse: false).where((term) => term.lessonId == null),
        isEmpty,
        reason: 'their dictionary does not carry it, so they cannot look it up',
      );
    });

    test('Plus rotates over reference terms too', () {
      expect(
        poolFor(hasCourse: true).where((term) => term.lessonId == null),
        isNotEmpty,
      );
    });

    test('the free pool is strictly inside the Plus one', () {
      final free = {for (final term in poolFor(hasCourse: false)) term.id};
      final plus = {for (final term in poolFor(hasCourse: true)) term.id};

      expect(free, isNotEmpty);
      expect(plus.containsAll(free), isTrue);
      expect(
        plus.length,
        greaterThan(free.length),
        reason: 'the tiers differ, which is the whole reason for the split',
      );
    });
  });

  group('the pick', () {
    test('the same day and tier give the same term', () {
      final pool = poolFor(hasCourse: false);
      final date = DateTime(2026, 9, 2);

      expect(
        termOfDay(pool: pool, date: date)!.id,
        termOfDay(pool: pool, date: date)!.id,
      );
    });

    test('the time of day does not move it', () {
      final pool = poolFor(hasCourse: false);

      expect(
        termOfDay(pool: pool, date: DateTime(2026, 9, 2, 0, 1))!.id,
        termOfDay(pool: pool, date: DateTime(2026, 9, 2, 23, 59))!.id,
        reason: 'the day turns at local midnight (#17), not at any other hour',
      );
    });

    test('the two tiers can be offered different terms on one day', () {
      final date = DateTime(2026, 9, 2);
      final free = termOfDay(pool: poolFor(hasCourse: false), date: date);
      final plus = termOfDay(pool: poolFor(hasCourse: true), date: date);

      expect(free, isNotNull);
      expect(plus, isNotNull);
      // Not an assertion that they differ on this date — that is arithmetic,
      // not a rule. What matters is that the pick reads the tier at all, which
      // the pools above already prove differ.
      expect(
        poolFor(hasCourse: false).map((term) => term.id),
        isNot(equals(poolFor(hasCourse: true).map((term) => term.id))),
      );
    });

    test('an empty pool has nothing to offer rather than throwing', () {
      expect(termOfDay(pool: const [], date: DateTime(2026, 9, 2)), isNull);
    });

    test('a date before the epoch still lands inside the pool', () {
      final pool = poolFor(hasCourse: true);

      expect(termOfDay(pool: pool, date: DateTime(1969, 7, 20)), isNotNull);
    });
  });

  group('the rotation', () {
    test('consecutive days give consecutive terms', () {
      final pool = poolFor(hasCourse: false);
      final first = DateTime(2026, 9, 2);
      final second = DateTime(2026, 9, 3);

      final at = pool.indexOf(termOfDay(pool: pool, date: first)!);
      final next = pool.indexOf(termOfDay(pool: pool, date: second)!);

      expect(next, (at + 1) % pool.length);
    });

    test('a full cycle of days uses every term exactly once', () {
      final pool = poolFor(hasCourse: false);
      final start = DateTime(2026, 9, 2);

      final picked = [
        for (var day = 0; day < pool.length; day++)
          termOfDay(
            pool: pool,
            date: DateTime(start.year, start.month, start.day + day),
          )!.id,
      ];

      expect(picked.toSet(), hasLength(pool.length));
    });

    test('nothing repeats within a course-length run of days', () {
      // A course takes 16–32 days (#57). The pool is far longer than that, so
      // no learner meets the same term twice while working through it.
      const courseDays = 32;
      final pool = poolFor(hasCourse: false);
      final start = DateTime(2026, 9, 2);

      final picked = [
        for (var day = 0; day < courseDays; day++)
          termOfDay(
            pool: pool,
            date: DateTime(start.year, start.month, start.day + day),
          )!.id,
      ];

      expect(pool.length, greaterThan(courseDays));
      expect(picked.toSet(), hasLength(courseDays));
    });
  });
}
