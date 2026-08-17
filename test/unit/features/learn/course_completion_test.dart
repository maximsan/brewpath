import 'package:brew_path/features/learn/domain/course_completion.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('courseCompletionMomentDue', () {
    test('fires when caught up with completions and no ack', () {
      expect(
        courseCompletionMomentDue(
          caughtUp: true,
          hasCompletedLessons: true,
          acked: false,
        ),
        isTrue,
      );
    });

    test('never fires once acked — the moment is one-off', () {
      expect(
        courseCompletionMomentDue(
          caughtUp: true,
          hasCompletedLessons: true,
          acked: true,
        ),
        isFalse,
      );
    });

    test('never fires mid-course', () {
      expect(
        courseCompletionMomentDue(
          caughtUp: false,
          hasCompletedLessons: true,
          acked: false,
        ),
        isFalse,
      );
    });

    test('never fires on a contentless caught-up state', () {
      // A fresh install with no current lesson derives as caught up; with
      // nothing completed there is nothing to celebrate.
      expect(
        courseCompletionMomentDue(
          caughtUp: true,
          hasCompletedLessons: false,
          acked: false,
        ),
        isFalse,
      );
    });
  });

  test('the ack key is stable — it is a stored, synced identifier', () {
    expect(courseCompleteAckKey, 'courseComplete');
  });
}
