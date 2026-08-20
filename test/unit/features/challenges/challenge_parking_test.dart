import 'package:brew_path/features/challenges/domain/challenge_lifecycle.dart';
import 'package:brew_path/features/challenges/domain/challenge_parking.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const now = 1000000000000;
  final window = challengeWindow.inMilliseconds;

  ActiveChallenge lapsed({String id = 'bc-m1'}) =>
      ActiveChallenge(id: id, startedAt: now - window - 1);
  ActiveChallenge live({String id = 'bc-m1'}) =>
      ActiveChallenge(id: id, startedAt: now - 1);

  group('parkChallenge', () {
    test('adds the challenge to the queue', () {
      expect(parkChallenge(const {}, 'bc-m1'), {'bc-m1'});
    });

    test('is idempotent', () {
      expect(parkChallenge(const {'bc-m1'}, 'bc-m1'), {'bc-m1'});
    });

    test('keeps what was already queued', () {
      expect(parkChallenge(const {'bc-m2'}, 'bc-m1'), {'bc-m2', 'bc-m1'});
    });
  });

  group('unparkChallenge', () {
    test('removes just that challenge', () {
      expect(unparkChallenge(const {'bc-m1', 'bc-m2'}, 'bc-m1'), {'bc-m2'});
    });

    test('is a no-op for one that is not queued', () {
      expect(unparkChallenge(const {'bc-m2'}, 'bc-m1'), {'bc-m2'});
    });

    test('does not mutate the set it was given', () {
      final original = {'bc-m1'};
      unparkChallenge(original, 'bc-m1');
      expect(original, {'bc-m1'});
    });
  });

  group('expiryPark', () {
    ExpiryPark? park({
      ActiveChallenge? active,
      Set<String> saved = const {},
      Set<String> completed = const {},
      int at = now,
    }) => expiryPark(
      active: active,
      saved: saved,
      completed: completed,
      nowMillis: at,
    );

    test('owes nothing when nothing is in play', () {
      expect(park(), isNull);
    });

    test('owes nothing while the window is live', () {
      expect(park(active: live()), isNull);
    });

    test('parks a lapsed challenge and clears the pair', () {
      final result = park(active: lapsed());

      expect(result?.saved, {'bc-m1'});
      expect(result?.active, isNull);
    });

    test('clears a lapsed challenge already logged without re-queueing it', () {
      // A replay does not re-queue: the learner has already done this one.
      final result = park(active: lapsed(), completed: const {'bc-m1'});

      expect(result?.saved, isEmpty);
      expect(result?.active, isNull);
    });

    test('keeps whatever else was queued', () {
      expect(park(active: lapsed(), saved: const {'bc-m2'})?.saved, {
        'bc-m2',
        'bc-m1',
      });
    });

    test('owes nothing the second time — the check is idempotent', () {
      final first = park(active: lapsed())!;
      final second = park(active: first.active, saved: first.saved);

      expect(second, isNull);
    });

    test('two devices past the window compute the same value', () {
      // They differ only in when they stamped it, and last-writer-wins over
      // two equal values converges to that value whichever stamp wins.
      final deviceA = park(active: lapsed());
      final deviceB = park(active: lapsed(), at: now + window);

      expect(deviceA?.saved, deviceB?.saved);
      expect(deviceA?.active, deviceB?.active);
    });
  });

  group('visibleSavedChallenges', () {
    List<String> visible({
      Set<String> saved = const {'bc-m1', 'bc-m2'},
      String? activeId,
      Set<String> completed = const {},
      bool Function(String id)? isOfferable,
    }) => visibleSavedChallenges(
      saved: saved,
      activeId: activeId,
      completed: completed,
      bankOrder: const ['bc-m1', 'bc-m2', 'bc-m3'],
      isOfferable: isOfferable ?? (_) => true,
    );

    test('lists the queue in bank order, not insertion order', () {
      expect(visible(saved: const {'bc-m2', 'bc-m1'}), ['bc-m1', 'bc-m2']);
    });

    test('excludes the one in play', () {
      expect(visible(activeId: 'bc-m1'), ['bc-m2']);
    });

    test('excludes one already logged', () {
      expect(visible(completed: const {'bc-m2'}), ['bc-m1']);
    });

    test('excludes one whose lesson the learner has not reached', () {
      // A queue advertising work locked behind content is worse than none.
      expect(visible(isOfferable: (id) => id != 'bc-m1'), ['bc-m2']);
    });

    test('is empty rather than partial when everything is filtered', () {
      expect(visible(isOfferable: (_) => false), isEmpty);
    });
  });
}
