import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/progress/domain/freeze_status_line.dart';
import 'package:brew_path/features/progress/domain/streak_status.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wednesday, mid-week, so the strip has days on both sides of today.
final DateTime wednesday = DateTime(2026, 8, 19);
final int mondayIndex = epochDay(DateTime(2026, 8, 17));

StreakStatus status({
  bool freezeHeld = false,
  int? daysToNextFreeze = freezeEarnDays,
  Set<int> frozenDays = const {},
}) => StreakStatus(
  streak: 5,
  freezeHeld: freezeHeld,
  daysToNextFreeze: daysToNextFreeze,
  freezesSpent: frozenDays.length,
  frozenDays: frozenDays,
);

void main() {
  test('a day covered this week is named', () {
    expect(
      freezeStatusLine(
        status: status(frozenDays: {mondayIndex + 2}),
        today: wednesday,
      ),
      'Wednesday was covered by a freeze',
    );
  });

  test('the most recent covered day wins', () {
    expect(
      freezeStatusLine(
        status: status(frozenDays: {mondayIndex, mondayIndex + 1}),
        today: wednesday,
      ),
      'Tuesday was covered by a freeze',
    );
  });

  test('a covered day outranks a held freeze', () {
    expect(
      freezeStatusLine(
        status: status(
          frozenDays: {mondayIndex + 1},
          freezeHeld: true,
          daysToNextFreeze: null,
        ),
        today: wednesday,
      ),
      'Tuesday was covered by a freeze',
    );
  });

  test('a day covered before this week falls through to the countdown', () {
    expect(
      freezeStatusLine(
        status: status(frozenDays: {mondayIndex - 3}, daysToNextFreeze: 4),
        today: wednesday,
      ),
      'Next freeze in 4 days',
    );
  });

  test('a held freeze reads singular, with no countdown', () {
    expect(
      freezeStatusLine(
        status: status(freezeHeld: true, daysToNextFreeze: null),
        today: wednesday,
      ),
      '1 freeze held · covers a missed day',
    );
  });

  test('the idle countdown reads the full seven days', () {
    expect(
      freezeStatusLine(status: StreakStatus.idle, today: wednesday),
      'Next freeze in 7 days',
    );
  });

  test('one day left reads singular', () {
    expect(
      freezeStatusLine(status: status(daysToNextFreeze: 1), today: wednesday),
      'Next freeze in 1 day',
    );
  });

  test('a Sunday covered on a Sunday still lands inside the week', () {
    final sunday = DateTime(2026, 8, 23);
    expect(
      freezeStatusLine(
        status: status(frozenDays: {epochDay(sunday)}),
        today: sunday,
      ),
      'Sunday was covered by a freeze',
    );
  });
}
