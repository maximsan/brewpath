import 'package:brew_path/features/progress/domain/streak_milestones.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isMilestone', () {
    test('the early schedule lands, its neighbours do not', () {
      expect(isMilestone(3), isTrue);
      expect(isMilestone(4), isFalse);
      expect(isMilestone(365), isTrue);
      expect(isMilestone(0), isFalse);
    });

    test('the every-thirty tail starts after the schedule, not inside it', () {
      expect(isMilestone(390), isTrue);
      // 360 is a multiple of thirty but still inside the early schedule's
      // range, where only listed values count.
      expect(isMilestone(360), isFalse);
    });
  });

  group('milestoneCelebrationDue', () {
    const day = 20654;

    test('a milestone day with no acknowledgement is due', () {
      expect(
        milestoneCelebrationDue(streak: 7, ackedDay: null, today: day),
        isTrue,
      );
    });

    test('an off-milestone count is never due', () {
      expect(
        milestoneCelebrationDue(streak: 8, ackedDay: null, today: day),
        isFalse,
      );
    });

    test('the same day never celebrates twice', () {
      expect(
        milestoneCelebrationDue(streak: 7, ackedDay: day, today: day),
        isFalse,
      );
    });

    test('a lapse and re-climb celebrates again', () {
      // Acknowledged day 7 long ago; the streak broke, the learner climbed
      // back to seven — today is later than the acknowledgement, so the
      // comeback gets its moment.
      expect(
        milestoneCelebrationDue(streak: 7, ackedDay: day - 40, today: day),
        isTrue,
      );
    });
  });
}
