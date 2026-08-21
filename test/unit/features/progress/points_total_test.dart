import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/widget_harness.dart';

/// The learner's points total, asserted through the provider the screens read
/// rather than through a helper — a total that agrees with a helper but
/// disagrees with the Profile screen is the failure worth catching.
///
/// **Two rules and nothing else pays** (§5.1, #16): ten for a lesson's first
/// completion, five for a challenge's. There is no counter behind any of this;
/// the total is summed off the records each payout already leaves.
void main() {
  setUp(useInMemoryDatabase);

  // Pinned, so a run started before midnight and asserted after it cannot fail.
  final at = DateTime(2026, 8, 20, 12);

  ProviderContainer harness() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  /// Records a first completion paying the flat ten a lesson authors.
  Future<void> completeLesson(ProviderContainer container, String lessonId) =>
      container
          .read(progressRepositoryProvider)
          .saveCompletion(
            lessonId: lessonId,
            xpEarned: 10,
            mastery: const MasteryResult(correct: 5, total: 5),
          );

  Future<int> total(ProviderContainer container) =>
      container.read(totalPointsProvider.future);

  test('a fresh install has banked nothing', () async {
    expect(await total(harness()), 0);
  });

  test('one lesson banks the flat ten it authors', () async {
    final container = harness();
    await completeLesson(container, 'm1l1');

    expect(await total(container), 10);
  });

  test('two lessons bank twenty', () async {
    final container = harness();
    await completeLesson(container, 'm1l1');
    await completeLesson(container, 'm1l2');

    expect(await total(container), 20);
  });

  test('a logged challenge adds its five', () async {
    final container = harness();
    await completeLesson(container, 'm1l1');
    await completeLesson(container, 'm1l2');
    await logChallenge(
      container.read(snapshotRepositoryProvider),
      id: 'bc-m1',
      reaction: 'Preferred 1:15',
      now: at,
    );

    expect(await total(container), 25);
  });

  test('re-logging the same challenge adds nothing', () async {
    final container = harness();
    for (var round = 0; round < 2; round++) {
      await logChallenge(
        container.read(snapshotRepositoryProvider),
        id: 'bc-m1',
        reaction: 'Preferred 1:15',
        now: at,
      );
    }

    expect(await total(container), 5);
  });

  test(
    'the total follows the lesson, not the number of cards it holds',
    () async {
      // A lesson pays what it authors. The engine this replaced multiplied a
      // per-step value by the card count, so a five-card lesson banked fifty.
      final container = harness();
      await completeLesson(container, 'm1l1');

      expect(await total(container), isNot(50));
      expect(await total(container), 10);
    },
  );

  test('a reset takes the total back to zero', () async {
    final container = harness();
    await completeLesson(container, 'm1l1');
    await logChallenge(
      container.read(snapshotRepositoryProvider),
      id: 'bc-m1',
      reaction: 'Preferred 1:15',
      now: at,
    );
    expect(await total(container), 15);

    await container.read(accountWipeProvider).resetProgress();
    container.invalidate(totalPointsProvider);
    container.invalidate(completedLessonsProvider);

    expect(await total(container), 0);
  });
}
