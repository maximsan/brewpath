import 'package:brew_path/features/challenges/domain/challenge_surface_state.dart';
import 'package:flutter_test/flutter_test.dart';

/// One derivation, four surfaces. The failure it prevents is two of them
/// disagreeing about the same challenge on the same screen.
void main() {
  ChallengeSurfaceState state({
    String? activeId,
    Set<String> completed = const {},
    Set<String> saved = const {},
    bool offerable = true,
  }) => challengeSurfaceState(
    id: 'bc-m1',
    activeId: activeId,
    completed: completed,
    saved: saved,
    offerable: offerable,
  );

  test('is available when earned and untouched', () {
    expect(state(), ChallengeSurfaceState.available);
  });

  test('is locked when its content is unreached', () {
    expect(state(offerable: false), ChallengeSurfaceState.locked);
  });

  test('is saved when parked', () {
    expect(state(saved: const {'bc-m1'}), ChallengeSurfaceState.saved);
  });

  test('is completed once logged', () {
    expect(state(completed: const {'bc-m1'}), ChallengeSurfaceState.completed);
  });

  test('is active when in play', () {
    expect(state(activeId: 'bc-m1'), ChallengeSurfaceState.active);
  });

  group('precedence', () {
    test('active beats completed — a replay is live progress', () {
      // A learner who just restarted one is looking at something in play; a
      // surface calling it done would contradict their own Today screen.
      expect(
        state(activeId: 'bc-m1', completed: const {'bc-m1'}),
        ChallengeSurfaceState.active,
      );
    });

    test('active beats saved', () {
      expect(
        state(activeId: 'bc-m1', saved: const {'bc-m1'}),
        ChallengeSurfaceState.active,
      );
    });

    test('completed beats locked — earning it cannot be revoked', () {
      expect(
        state(completed: const {'bc-m1'}, offerable: false),
        ChallengeSurfaceState.completed,
      );
    });

    test('completed beats saved', () {
      expect(
        state(completed: const {'bc-m1'}, saved: const {'bc-m1'}),
        ChallengeSurfaceState.completed,
      );
    });

    test('locked beats saved — a queue entry does not unlock content', () {
      expect(
        state(saved: const {'bc-m1'}, offerable: false),
        ChallengeSurfaceState.locked,
      );
    });
  });

  test('another challenge being active says nothing about this one', () {
    expect(state(activeId: 'bc-m2'), ChallengeSurfaceState.available);
  });
}
