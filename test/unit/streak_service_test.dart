import 'package:brew_path/features/progress/domain/streak_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = StreakService();
  final now = DateTime(2026, 5, 17, 14, 30);

  group('StreakService', () {
    test('first ever completion starts the streak at 1', () {
      final r = service.onLessonCompleted(
        currentStreak: 0,
        lastActivityDate: null,
        now: now,
      );
      expect(r.streakDays, 1);
      expect(r.lastActivityDate, DateTime(2026, 5, 17));
    });

    test('second lesson same day does not change the streak', () {
      final r = service.onLessonCompleted(
        currentStreak: 4,
        lastActivityDate: DateTime(2026, 5, 17, 8),
        now: now,
      );
      expect(r.streakDays, 4);
    });

    test('completing the next day increments the streak', () {
      final r = service.onLessonCompleted(
        currentStreak: 4,
        lastActivityDate: DateTime(2026, 5, 16, 22),
        now: now,
      );
      expect(r.streakDays, 5);
    });

    test('a missed day resets the streak to 1', () {
      final r = service.onLessonCompleted(
        currentStreak: 9,
        lastActivityDate: DateTime(2026, 5, 15),
        now: now,
      );
      expect(r.streakDays, 1);
    });

    test('returned lastActivityDate is time-stripped', () {
      final r = service.onLessonCompleted(
        currentStreak: 0,
        lastActivityDate: null,
        now: now,
      );
      expect(r.lastActivityDate.hour, 0);
      expect(r.lastActivityDate.minute, 0);
    });
  });
}
