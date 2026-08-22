import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/progress/domain/freeze_save_notice.dart';
import 'package:brew_path/features/progress/domain/streak_status.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wednesday, so weekday naming crosses no boundary in the plain cases.
final DateTime wednesday = DateTime(2026, 8, 19);
final int today = epochDay(wednesday);

StreakStatus status({
  Set<int> frozenDays = const {},
  bool freezeHeld = false,
  int? daysToNextFreeze = freezeEarnDays,
}) => StreakStatus(
  streak: 7,
  freezeHeld: freezeHeld,
  daysToNextFreeze: daysToNextFreeze,
  freezesSpent: frozenDays.length,
  frozenDays: frozenDays,
);

void main() {
  group('dueFreezeSaveDay', () {
    test('nothing covered, nothing due', () {
      expect(
        dueFreezeSaveDay(
          activeDays: {today - 1},
          status: status(),
          ackedDay: null,
          today: today,
        ),
        isNull,
      );
    });

    test('a covered yesterday is due, with no days between to check', () {
      expect(
        dueFreezeSaveDay(
          activeDays: const {},
          status: status(frozenDays: {today - 1}),
          ackedDay: null,
          today: today,
        ),
        today - 1,
      );
    });

    test('the newest covered day is the one announced', () {
      expect(
        dueFreezeSaveDay(
          activeDays: {today - 2},
          status: status(frozenDays: {today - 9, today - 1}),
          ackedDay: null,
          today: today,
        ),
        today - 1,
      );
    });

    test('an acknowledged save stays dismissed', () {
      expect(
        dueFreezeSaveDay(
          activeDays: const {},
          status: status(frozenDays: {today - 1}),
          ackedDay: today - 1,
          today: today,
        ),
        isNull,
      );
    });

    test('an older acknowledgement does not silence a newer save', () {
      expect(
        dueFreezeSaveDay(
          activeDays: const {},
          status: status(frozenDays: {today - 9, today - 1}),
          ackedDay: today - 9,
          today: today,
        ),
        today - 1,
      );
    });

    test('a run that broke after the save is not "safe" and stays quiet', () {
      // Covered three days ago, then a miss two days ago: the streak did not
      // survive the save, and reassurance would be a lie.
      expect(
        dueFreezeSaveDay(
          activeDays: {today - 1},
          status: status(frozenDays: {today - 3}),
          ackedDay: null,
          today: today,
        ),
        isNull,
      );
    });

    test('a fully active chain since the save keeps it due', () {
      expect(
        dueFreezeSaveDay(
          activeDays: {today - 2, today - 1},
          status: status(frozenDays: {today - 3}),
          ackedDay: null,
          today: today,
        ),
        today - 3,
      );
    });
  });

  group('freezeSaveNoticeBody', () {
    test('yesterday reads as Yesterday', () {
      expect(
        freezeSaveNoticeBody(
          coveredDay: today - 1,
          status: status(),
          today: wednesday,
        ),
        "Yesterday was covered by a freeze. You'll earn another in 7 days.",
      );
    });

    test('an older day this week is named', () {
      expect(
        freezeSaveNoticeBody(
          coveredDay: today - 2,
          status: status(daysToNextFreeze: 6),
          today: wednesday,
        ),
        "Monday was covered by a freeze. You'll earn another in 6 days.",
      );
    });

    test('naming steps back across the week boundary', () {
      final tuesday = DateTime(2026, 8, 18);
      expect(
        freezeSaveNoticeBody(
          coveredDay: epochDay(tuesday) - 5,
          status: status(daysToNextFreeze: 3),
          today: tuesday,
        ),
        "Thursday was covered by a freeze. You'll earn another in 3 days.",
      );
    });

    test('a save older than a week loses the ambiguous name', () {
      expect(
        freezeSaveNoticeBody(
          coveredDay: today - 8,
          status: status(),
          today: wednesday,
        ),
        'A missed day was covered by a freeze. '
        "You'll earn another in 7 days.",
      );
    });

    test('one day left reads singular', () {
      expect(
        freezeSaveNoticeBody(
          coveredDay: today - 1,
          status: status(daysToNextFreeze: 1),
          today: wednesday,
        ),
        "Yesterday was covered by a freeze. You'll earn another in 1 day.",
      );
    });

    test('a re-earned freeze changes the tail, not the reassurance', () {
      expect(
        freezeSaveNoticeBody(
          coveredDay: today - 1,
          status: status(freezeHeld: true, daysToNextFreeze: null),
          today: wednesday,
        ),
        'Yesterday was covered by a freeze. You already hold the next one.',
      );
    });
  });
}
