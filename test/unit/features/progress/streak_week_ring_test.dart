import 'package:brew_path/features/progress/domain/streak_week.dart';
import 'package:brew_path/features/progress/presentation/streak_ring.dart';
import 'package:flutter_test/flutter_test.dart';

/// The ring fills over the current seven-day week, not toward a badge (#498).
void main() {
  group('streakWeekDay', () {
    test('counts the days into the current week', () {
      expect(streakWeekDay(1), 1);
      expect(streakWeekDay(2), 2);
      // The design's own example: 5 days on a 12-day streak.
      expect(streakWeekDay(12), 5);
    });

    test('a closing day reads seven, not zero', () {
      // Day 7 finishes a week rather than starting an empty one, so the ring
      // closes before it starts over.
      expect(streakWeekDay(7), 7);
      expect(streakWeekDay(14), 7);
      expect(streakWeekDay(8), 1);
    });

    test('no streak is no day', () {
      expect(streakWeekDay(0), 0);
    });
  });

  group('weekRingFraction', () {
    test('spans the week and closes on the seventh day', () {
      expect(weekRingFraction(0), 0);
      expect(weekRingFraction(2), 2 / 7);
      expect(weekRingFraction(7), 1);
      expect(weekRingFraction(8), 1 / 7);
      expect(weekRingFraction(10), 3 / 7);
    });

    test('stays inside the ring, whatever the streak', () {
      for (var streak = 0; streak <= 400; streak++) {
        expect(weekRingFraction(streak), inInclusiveRange(0, 1));
      }
    });
  });

  group('the minimum visible notch', () {
    test('a week that has not started still paints', () {
      // The floor is the drawing's, not the count's: 0/7 is the honest
      // fraction, and the ring rounds it up so a new streak reads as begun.
      expect(weekRingFraction(0), 0);
      expect(StreakRing.paintedFraction(0), StreakRing.minVisibleFraction);
    });

    test('a real fraction is painted as it stands', () {
      expect(StreakRing.paintedFraction(1 / 7), 1 / 7);
      expect(StreakRing.paintedFraction(1), 1);
    });
  });
}
