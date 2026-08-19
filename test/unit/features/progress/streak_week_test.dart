// The week strip's seven cells. The point of every case below is that a cell
// is read from the active-day set rather than counted back from the streak.
import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/progress/domain/streak_engine.dart';
import 'package:brew_path/features/progress/domain/streak_status.dart';
import 'package:brew_path/features/progress/domain/streak_week.dart';
import 'package:flutter_test/flutter_test.dart';

/// A Friday, matching the day the prototype's clock is frozen on — so the
/// cases below can be read against its rendering directly.
final DateTime friday = DateTime(2026, 8, 21, 14, 30);

int dayOf(DateTime date) => epochDay(date);

List<StreakDayMark> marksFor(Set<int> activeDays, StreakStatus status) =>
    weekStrip(activeDays: activeDays, status: status, today: friday)
        .map((cell) => cell.mark)
        .toList();

void main() {
  final monday = DateTime(2026, 8, 17);
  final week = [
    for (var offset = 0; offset < daysPerWeek; offset++)
      dayOf(DateTime(monday.year, monday.month, monday.day + offset)),
  ];

  group('the window', () {
    test('runs Monday to Sunday around today, whatever the time of day', () {
      final strip = weekStrip(
        activeDays: const {},
        status: StreakStatus.idle,
        today: friday,
      );

      expect(strip, hasLength(daysPerWeek));
      expect(strip.map((cell) => cell.day), week);
    });

    test('marks exactly one cell as today', () {
      final strip = weekStrip(
        activeDays: const {},
        status: StreakStatus.idle,
        today: friday,
      );

      expect(strip.where((cell) => cell.isToday).map((cell) => cell.day), [
        dayOf(friday),
      ]);
    });

    test('a Sunday still sees the Monday that started its week', () {
      final sunday = DateTime(2026, 8, 23);
      final strip = weekStrip(
        activeDays: const {},
        status: StreakStatus.idle,
        today: sunday,
      );

      expect(strip.first.day, dayOf(monday));
      expect(strip.last.isToday, isTrue);
    });

    test('a Monday is the first cell, not the last', () {
      final strip = weekStrip(
        activeDays: const {},
        status: StreakStatus.idle,
        today: monday,
      );

      expect(strip.first.isToday, isTrue);
    });
  });

  group('the three states', () {
    test('a fresh account shows an empty week, today included', () {
      expect(
        marksFor(const {}, StreakStatus.idle),
        List.filled(daysPerWeek, StreakDayMark.empty),
      );
    });

    test('active days read done and the rest of the week reads empty', () {
      final active = {week[0], week[1]};

      expect(marksFor(active, StreakStatus.idle), [
        StreakDayMark.done,
        StreakDayMark.done,
        StreakDayMark.empty,
        StreakDayMark.empty,
        StreakDayMark.empty,
        StreakDayMark.empty,
        StreakDayMark.empty,
      ]);
    });

    test('a day ahead of today reads empty, whatever the set says', () {
      // A peer whose clock runs ahead writes one. `deriveStreak` discards it,
      // so a strip that painted it done would credit a day the count does not.
      expect(marksFor({week[5], week[6]}, StreakStatus.idle), [
        StreakDayMark.empty,
        StreakDayMark.empty,
        StreakDayMark.empty,
        StreakDayMark.empty,
        StreakDayMark.empty,
        StreakDayMark.empty,
        StreakDayMark.empty,
      ]);
    });

    test('today itself still reads done once it qualifies', () {
      expect(marksFor({week[4]}, StreakStatus.idle)[4], StreakDayMark.done);
    });

    test('a covered day reads frozen, never done', () {
      final status = StreakStatus(
        streak: 3,
        freezeHeld: false,
        daysToNextFreeze: freezeEarnDays,
        freezesSpent: 1,
        frozenDays: {week[2]},
      );

      expect(marksFor({week[0], week[1], week[3]}, status)[2],
          StreakDayMark.frozen);
    });
  });

  // The defect #26 found in the prototype's derivation, pinned as a test.
  group('a freeze inside the visible week does not erase Monday', () {
    test('Mon, Tue, Thu, Fri active with Wednesday covered', () {
      // Seven earlier days earn the freeze that covers Wednesday, so the
      // status here is the engine's own and not a fixture.
      final earlier = {
        for (var back = 7; back >= 1; back--) week[0] - back,
      };
      final activeDays = {...earlier, week[0], week[1], week[3], week[4]};
      final status = deriveStreak(
        activeDays: activeDays,
        today: dayOf(friday),
      );

      expect(status.frozenDays, {week[2]});
      expect(
        status.streak,
        11,
        reason: 'a covered day preserves the run without raising it',
      );
      expect(marksFor(activeDays, status), [
        StreakDayMark.done,
        StreakDayMark.done,
        StreakDayMark.frozen,
        StreakDayMark.done,
        StreakDayMark.done,
        StreakDayMark.empty,
        StreakDayMark.empty,
      ]);
    });

    test('an active day outside the current run is still shown as earned', () {
      // Monday active, Tuesday missed with no freeze, Wed–Fri active. The
      // streak is 3; counting back three cells would deny Monday.
      final activeDays = {week[0], week[2], week[3], week[4]};
      final status = deriveStreak(
        activeDays: activeDays,
        today: dayOf(friday),
      );

      expect(status.streak, 3);
      expect(marksFor(activeDays, status).first, StreakDayMark.done);
    });
  });
}
