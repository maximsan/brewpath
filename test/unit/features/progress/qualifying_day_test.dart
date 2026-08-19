// The §2–§3 qualifying rule, over a day's stored completion entries.
import 'package:brew_path/features/progress/domain/qualifying_day.dart';
import 'package:brew_path/shared/storage/snapshot/daily_activity.dart';
import 'package:flutter_test/flutter_test.dart';

String entryOf(ActivityType type, String token, {String subject = ''}) =>
    activityEntry(type: type, token: token, subject: subject);

void main() {
  group('one completion is enough (§3)', () {
    test('a new lesson', () {
      expect(
        dayQualifies({entryOf(ActivityType.lesson, 'a', subject: 'm1l1')}),
        isTrue,
      );
    });

    test(
      'a completed replay — the rule that lets a streak outlive the course',
      () {
        expect(
          dayQualifies({entryOf(ActivityType.replay, 'a', subject: 'm1l1')}),
          isTrue,
        );
      },
    );

    test('a vocab round', () {
      expect(dayQualifies({entryOf(ActivityType.vocab, 'a')}), isTrue);
    });

    test('a flashcard review', () {
      expect(dayQualifies({entryOf(ActivityType.flashcards, 'a')}), isTrue);
    });
  });

  group('mini-games need two different formats (§5, #59)', () {
    test('one run does not mark the day', () {
      expect(
        dayQualifies({entryOf(ActivityType.miniGame, 'a', subject: 'g-quiz')}),
        isFalse,
      );
    });

    test('the same game twice does not either', () {
      expect(
        dayQualifies({
          entryOf(ActivityType.miniGame, 'a', subject: 'g-quiz'),
          entryOf(ActivityType.miniGame, 'b', subject: 'g-quiz'),
        }),
        isFalse,
      );
    });

    test('two different formats do', () {
      expect(
        dayQualifies({
          entryOf(ActivityType.miniGame, 'a', subject: 'g-quiz'),
          entryOf(ActivityType.miniGame, 'b', subject: 'g-match'),
        }),
        isTrue,
      );
    });

    test('one game beside a lesson qualifies on the lesson', () {
      expect(
        dayQualifies({
          entryOf(ActivityType.miniGame, 'a', subject: 'g-quiz'),
          entryOf(ActivityType.lesson, 'b', subject: 'm1l1'),
        }),
        isTrue,
      );
    });
  });

  group('nothing else marks a day', () {
    test('an empty day does not', () {
      expect(dayQualifies(const <String>[]), isFalse);
    });

    test('an entry from a newer build is carried, not counted', () {
      // §4's exclusions cannot appear at all — they have no ActivityType — so
      // the only unrecognised entry is one a newer build wrote. It marked the
      // day itself, and `activeDays` unions, so the mark arrives without us.
      expect(dayQualifies({'coffeeDuel:token:subject'}), isFalse);
    });
  });

  group('re-deriving the day set from the activity record', () {
    test('keeps the days that qualify and drops the ones that do not', () {
      final record = {
        1: {entryOf(ActivityType.lesson, 'a', subject: 'm1l1')},
        2: {entryOf(ActivityType.miniGame, 'b', subject: 'g-quiz')},
        3: {
          entryOf(ActivityType.miniGame, 'c', subject: 'g-quiz'),
          entryOf(ActivityType.miniGame, 'd', subject: 'g-match'),
        },
        4: <String>{},
      };

      expect(qualifyingDays(record), {1, 3});
    });

    test('an empty record yields no days', () {
      expect(qualifyingDays(const {}), isEmpty);
    });
  });
}
