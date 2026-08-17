import 'package:brew_path/features/learn/domain/keep_sharp.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const all = {
    PracticeType.miniGames,
    PracticeType.vocabGame,
    PracticeType.flashcards,
    PracticeType.lessonReplay,
  };

  group('keepSharpPick', () {
    test(
      'walks the canonical order day by day when all types are eligible',
      () {
        final picks = [
          for (var day = 0; day < 4; day++)
            keepSharpPick(dayNumber: day, eligible: all),
        ];

        expect(picks, PracticeType.values);
      },
    );

    test('the cycle wraps: day N and day N+4 pick the same type', () {
      expect(
        keepSharpPick(dayNumber: 6, eligible: all),
        keepSharpPick(dayNumber: 2, eligible: all),
      );
    });

    test('an ineligible type is skipped by advancing in rotation order', () {
      const eligible = {PracticeType.miniGames, PracticeType.lessonReplay};

      // Days 1 and 2 land on vocab and flashcards; both skip forward to
      // replay, the next eligible type in order.
      expect(
        keepSharpPick(dayNumber: 1, eligible: eligible),
        PracticeType.lessonReplay,
      );
      expect(
        keepSharpPick(dayNumber: 2, eligible: eligible),
        PracticeType.lessonReplay,
      );
      expect(
        keepSharpPick(dayNumber: 0, eligible: eligible),
        PracticeType.miniGames,
      );
    });

    test(
      'a widened pool changes the pick only where the skip used to fire',
      () {
        const before = {PracticeType.miniGames, PracticeType.lessonReplay};
        final after = {...before, PracticeType.flashcards};

        // Day 0 lands on an always-eligible type: unchanged by the widening.
        expect(
          keepSharpPick(dayNumber: 0, eligible: before),
          keepSharpPick(dayNumber: 0, eligible: after),
        );
        // Day 2 lands on flashcards itself: the skip no longer fires.
        expect(
          keepSharpPick(dayNumber: 2, eligible: after),
          PracticeType.flashcards,
        );
      },
    );

    test('an empty pool yields no recommendation rather than crashing', () {
      expect(keepSharpPick(dayNumber: 5, eligible: const {}), isNull);
    });
  });

  group('keepSharpDailyChoice', () {
    test('is the day-indexed entry, wrapping over the options', () {
      const options = ['a', 'b', 'c'];

      expect(keepSharpDailyChoice(0, options), 'a');
      expect(keepSharpDailyChoice(4, options), 'b');
    });

    test('consecutive days walk the options', () {
      const options = ['a', 'b'];

      expect(
        keepSharpDailyChoice(7, options),
        isNot(keepSharpDailyChoice(8, options)),
      );
    });
  });

  group('keepSharpDayNumber', () {
    test('is stable across one local calendar day', () {
      final morning = DateTime(2026, 8, 17, 0, 1);
      final night = DateTime(2026, 8, 17, 23, 59);

      expect(keepSharpDayNumber(morning), keepSharpDayNumber(night));
    });

    test('advances by exactly one across midnight', () {
      final today = DateTime(2026, 8, 17, 23, 59);
      final tomorrow = DateTime(2026, 8, 18, 0, 1);

      expect(
        keepSharpDayNumber(tomorrow),
        keepSharpDayNumber(today) + 1,
      );
    });
  });

  group('copy table', () {
    test('every practice type carries a title and its completion rule', () {
      for (final type in PracticeType.values) {
        expect(keepSharpCopyFor(type).title, isNotEmpty);
        expect(keepSharpCopyFor(type).rule, isNotEmpty);
      }
    });

    test('the mini-games rule states two different games', () {
      expect(
        keepSharpCopyFor(PracticeType.miniGames).rule,
        contains('two different'),
      );
    });
  });
}
