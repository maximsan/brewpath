import 'package:brew_path/features/challenges/domain/challenge_bank.dart';
import 'package:brew_path/features/challenges/domain/challenge_lifecycle.dart';
import 'package:brew_path/shared/models/content/brew_challenge.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'challenge_providers.g.dart';

/// The twelve Coffee Challenges.
@riverpod
Future<List<BrewChallenge>> challengeBank(Ref ref) =>
    ref.watch(contentRepositoryProvider).getBrewChallenges();

/// The challenge Today should show, or null when nothing is in play.
///
/// A lapsed window stops showing here and stores nothing — clearing the pair
/// and parking the challenge is the expiry path's write, not a read's side
/// effect.
@riverpod
Future<BrewChallenge?> activeChallenge(Ref ref) async {
  // Every watch resolved before the first await: a rebuild mid-flight must not
  // find a watch on the far side of an async gap, where the old build's ref is
  // already disposed.
  final snapshots = ref.watch(snapshotRepositoryProvider);
  final bank = ref.watch(challengeBankProvider.future);
  final nowMillis = DateTime.now().millisecondsSinceEpoch;

  final stored = (await snapshots.read()).clearedByReset.activeChallenge.value;
  final id = liveChallengeId(stored, nowMillis: nowMillis);
  return id == null ? null : challengeById(await bank, id);
}

/// The capstone [moduleId] offers, or null when it has none or is unearned.
@riverpod
Future<BrewChallenge?> moduleChallengeOffer(Ref ref, String moduleId) async {
  final content = ref.watch(contentRepositoryProvider);
  final progress = ref.watch(progressRepositoryProvider);
  final bank = await ref.watch(challengeBankProvider.future);

  final challenge = challengeForModule(bank, moduleId);
  if (challenge == null) return null;

  final modules = await content.getModules();
  final module = modules.where((m) => m.id == moduleId).firstOrNull;
  if (module == null) return null;

  final completed = await progress.getAllCompleted();
  final offerable = challengeOfferable(
    challenge: challenge,
    moduleLessonIds: module.lessonIds.toSet(),
    completedLessonIds: {for (final record in completed) record.lessonId},
  );
  return offerable ? challenge : null;
}

/// Puts [id] in play, and returns the challenge it displaced, if any.
///
/// A free function the caller invalidates around, matching every other write
/// on this snapshot. The displaced id is **returned rather than parked** —
/// parking is the saved queue's write, and this build has no queue yet, so
/// surfacing it here is what lets that land without touching the lifecycle.
Future<String?> startChallenge(
  SnapshotRepository repository, {
  required String id,
  required DateTime now,
}) async {
  final snapshot = await repository.read();
  final progress = snapshot.clearedByReset;

  final start = startChallengeTransition(
    id: id,
    current: progress.activeChallenge.value,
    completed: progress.challengesCompleted,
    nowMillis: now.millisecondsSinceEpoch,
  );

  await repository.write(
    snapshot.copyWith(
      updatedAt: now.millisecondsSinceEpoch,
      clearedByReset: progress.withActiveChallenge(
        start.active,
        at: now.millisecondsSinceEpoch,
        writerId: snapshot.deviceId,
      ),
    ),
  );
  return start.displaced;
}
