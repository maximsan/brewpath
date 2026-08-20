import 'package:brew_path/features/challenges/domain/challenge_lifecycle.dart';
import 'package:brew_path/shared/models/content/brew_challenge.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/content_fixtures.dart';

/// The rules a Coffee Challenge lives by, with a literal clock and literal
/// sets — no database, no widgets, no mocks.
void main() {
  const now = 1000000000000;
  final window = challengeWindow.inMilliseconds;

  group('challengeOfferable — a capstone', () {
    final capstone = testChallenge(scope: ChallengeScope.module);

    bool offerable(Set<String> completed) => challengeOfferable(
      challenge: capstone,
      moduleLessonIds: const {'m1l1', 'm1l2'},
      completedLessonIds: completed,
    );

    test('is offered once every lesson of its module is finished', () {
      expect(offerable({'m1l1', 'm1l2'}), isTrue);
    });

    test('is not offered while one lesson remains', () {
      expect(offerable({'m1l1'}), isFalse);
    });

    test('is not offered to a learner who has finished nothing', () {
      expect(offerable({}), isFalse);
    });

    test('is not offered by an empty module rather than vacuously true', () {
      expect(
        challengeOfferable(
          challenge: capstone,
          moduleLessonIds: const {},
          completedLessonIds: const {'m1l1'},
        ),
        isFalse,
      );
    });
  });

  group('challengeOfferable — a lesson challenge', () {
    final lessonChallenge = testChallenge(lessonId: 'm1l1');

    test('is offered once its own lesson is finished', () {
      expect(
        challengeOfferable(
          challenge: lessonChallenge,
          moduleLessonIds: const {'m1l1', 'm1l2'},
          completedLessonIds: const {'m1l1'},
        ),
        isTrue,
      );
    });

    test('ignores the rest of the module', () {
      // Its module is unfinished, but the lesson it hangs off is done.
      expect(
        challengeOfferable(
          challenge: lessonChallenge,
          moduleLessonIds: const {'m1l1', 'm1l2'},
          completedLessonIds: const {'m1l1'},
        ),
        isTrue,
      );
    });

    test('is not offered while its lesson is unfinished', () {
      expect(
        challengeOfferable(
          challenge: lessonChallenge,
          moduleLessonIds: const {'m1l1'},
          completedLessonIds: const {'m1l2'},
        ),
        isFalse,
      );
    });

    test('can never be earned when it names no lesson', () {
      expect(
        challengeOfferable(
          challenge: testChallenge(),
          moduleLessonIds: const {'m1l1'},
          completedLessonIds: const {'m1l1'},
        ),
        isFalse,
      );
    });
  });

  group('the 48-hour window', () {
    ActiveChallenge startedAgo(int millis) =>
        ActiveChallenge(id: 'bc-m1', startedAt: now - millis);

    test('is live well inside it', () {
      expect(
        challengeWindowLapsed(startedAgo(window ~/ 2), nowMillis: now),
        isFalse,
      );
    });

    test('is still live exactly at the boundary', () {
      // The boundary belongs to the learner.
      expect(
        challengeWindowLapsed(startedAgo(window), nowMillis: now),
        isFalse,
      );
    });

    test('has lapsed one millisecond past it', () {
      expect(
        challengeWindowLapsed(startedAgo(window + 1), nowMillis: now),
        isTrue,
      );
    });

    test('is 48 hours, not a calendar day', () {
      expect(challengeWindow, const Duration(hours: 48));
    });
  });

  group('liveChallengeId', () {
    test('names the challenge in play', () {
      expect(
        liveChallengeId(
          const ActiveChallenge(id: 'bc-m1', startedAt: now - 1),
          nowMillis: now,
        ),
        'bc-m1',
      );
    });

    test('is null when nothing is in play', () {
      expect(liveChallengeId(null, nowMillis: now), isNull);
    });

    test('is null once the window has lapsed', () {
      expect(
        liveChallengeId(
          ActiveChallenge(id: 'bc-m1', startedAt: now - window - 1),
          nowMillis: now,
        ),
        isNull,
      );
    });

    test('reads without writing — the lapsed pair is left untouched', () {
      // The park is the expiry path's write. If reading cleared the pair,
      // there would be nothing left for it to park.
      final lapsed = ActiveChallenge(id: 'bc-m1', startedAt: now - window - 1);
      liveChallengeId(lapsed, nowMillis: now);

      expect(lapsed.id, 'bc-m1');
      expect(lapsed.startedAt, now - window - 1);
    });
  });

  group('startChallengeTransition', () {
    ChallengeStart start({
      String id = 'bc-m2',
      ActiveChallenge? current,
      Set<String> completed = const {},
    }) => startChallengeTransition(
      id: id,
      current: current,
      completed: completed,
      nowMillis: now,
    );

    test('puts the challenge in play, stamped now', () {
      expect(
        start().active,
        const ActiveChallenge(id: 'bc-m2', startedAt: now),
      );
    });

    test('displaces nothing when nothing was in play', () {
      expect(start().displaced, isNull);
    });

    test('surfaces the challenge it pushed out', () {
      final result = start(
        current: const ActiveChallenge(id: 'bc-m1', startedAt: now - 1),
      );

      expect(result.displaced, 'bc-m1');
      expect(result.active.id, 'bc-m2');
    });

    test('does not displace itself when restarted', () {
      expect(
        start(
          id: 'bc-m1',
          current: const ActiveChallenge(id: 'bc-m1', startedAt: now - 1),
        ).displaced,
        isNull,
      );
    });

    test('restarting resets the clock', () {
      expect(
        start(
          id: 'bc-m1',
          current: const ActiveChallenge(id: 'bc-m1', startedAt: now - 1),
        ).active.startedAt,
        now,
      );
    });

    test('does not re-queue a challenge already finished', () {
      // A replay that gets displaced must not go back into the queue: it
      // would ask the learner to do again what they have already done.
      expect(
        start(
          current: const ActiveChallenge(id: 'bc-m1', startedAt: now - 1),
          completed: const {'bc-m1'},
        ).displaced,
        isNull,
      );
    });

    test('displaces a lapsed challenge just as it does a live one', () {
      // Whether its window ran out is the expiry path's business; from here
      // it is still the thing being pushed out, and still not dropped.
      expect(
        start(
          current: ActiveChallenge(id: 'bc-m1', startedAt: now - window - 1),
        ).displaced,
        'bc-m1',
      );
    });
  });
}
