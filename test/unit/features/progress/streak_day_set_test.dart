// Assembling the day set, and the backfill that keeps an existing learner's
// streak alive across the move onto it.
import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/progress/domain/streak_day_set.dart';
import 'package:brew_path/shared/storage/snapshot/daily_activity.dart';
import 'package:flutter_test/flutter_test.dart';

String lessonOn(String token) =>
    activityEntry(type: ActivityType.lesson, token: token, subject: 'm1l1');

Set<int> assemble({
  Set<int> activeDays = const {},
  Map<int, Set<String>> dailyActivity = const {},
  Iterable<DateTime> completions = const [],
}) => streakDaySet(
  activeDays: activeDays,
  dailyActivity: dailyActivity,
  // The snapshot stores the day a lesson was finished, not the moment — the
  // helper still takes dates so the cases below read as calendar days.
  firstCompletionDays: completions.map(epochDay),
);

void main() {
  final day = DateTime(2026, 8, 19, 14, 30);
  final index = epochDay(day);

  group('the three sources', () {
    test('nothing anywhere is an empty set', () {
      expect(assemble(), isEmpty);
    });

    test('the stored day set carries on its own', () {
      expect(assemble(activeDays: {index}), {index});
    });

    test('a qualifying activity record adds its day', () {
      expect(
        assemble(
          dailyActivity: {
            index: {lessonOn('a')},
          },
        ),
        {index},
      );
    });

    test('a non-qualifying activity record adds nothing', () {
      expect(
        assemble(
          dailyActivity: {
            index: {
              activityEntry(
                type: ActivityType.miniGame,
                token: 'a',
                subject: 'g-quiz',
              ),
            },
          },
        ),
        isEmpty,
      );
    });

    test('three sources naming the same day still name one day', () {
      expect(
        assemble(
          activeDays: {index},
          dailyActivity: {
            index: {lessonOn('a')},
          },
          completions: [day],
        ),
        {index},
      );
    });
  });

  group('the backfill', () {
    test('a completion older than the day set still counts', () {
      // The case this exists for: a learner who finished lessons before
      // anything wrote a day. An empty day set would zero a real streak.
      final week = [
        for (var back = 6; back >= 0; back--)
          day.subtract(Duration(days: back)),
      ];

      expect(assemble(completions: week), {
        for (var back = 6; back >= 0; back--) index - back,
      });
    });

    test('the time of day is dropped — a day is a day', () {
      expect(
        assemble(
          completions: [
            DateTime(2026, 8, 19, 0, 1),
            DateTime(2026, 8, 19, 23, 59),
          ],
        ),
        {index},
      );
    });

    test('it can only add, never unmark a day the record already holds', () {
      expect(assemble(activeDays: {index}), {index});
    });
  });
}
