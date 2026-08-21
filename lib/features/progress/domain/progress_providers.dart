import 'package:brew_path/core/constants/points_values.dart';
import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/progress/domain/grove_treatment.dart';
import 'package:brew_path/features/progress/domain/streak_day_set.dart';
import 'package:brew_path/features/progress/domain/streak_engine.dart';
import 'package:brew_path/features/progress/domain/streak_status.dart';
import 'package:brew_path/features/progress/domain/tree_growth.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/storage/progress_record.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'progress_providers.g.dart';

/// The learner's points total — **derived, never stored**.
///
/// Two payouts exist and both already leave a record: a lesson's flat ten is
/// written onto its completion row, and a challenge's five is implied by its id
/// sitting in the completed set. Summing them here means the total cannot drift
/// from what was actually earned, and Reset Progress needs no rule of its own —
/// clearing the completions clears the total by construction.
///
/// It used to be a counter on the settings row that every payout incremented.
/// A counter is a second copy of a derivable fact, and the fact it copied was
/// computed under rules the app no longer plays (#16).
@riverpod
Future<int> totalPoints(Ref ref) async {
  final completed = await ref.watch(completedLessonsProvider.future);
  final snapshot = await ref.watch(snapshotRepositoryProvider).read();

  final fromLessons = completed.fold<int>(
    0,
    (sum, record) => sum + record.xpEarned,
  );
  final challengesLogged = snapshot.clearedByReset.challengesCompleted.length;

  return fromLessons + challengesLogged * PointsValues.challengeCompletion;
}

/// The streak, the freeze and the covered days, derived from the snapshot.
///
/// Read against `DateTime.now()`, so it is only as fresh as the last time it
/// was built — which is why `DayRolloverWatcher` invalidates this on a resume
/// that crossed midnight, rather than letting a value computed before it stand.
///
/// The day set it folds is assembled by [streakDaySet], which also backfills
/// a learner whose completions predate the day set — see it for why the three
/// sources are unioned rather than ranked.
@riverpod
Future<StreakStatus> streakStatus(Ref ref) async {
  final snapshot = await ref.watch(snapshotRepositoryProvider).read();
  final completed = await ref.watch(completedLessonsProvider.future);
  final progress = snapshot.clearedByReset;

  return deriveStreak(
    activeDays: streakDaySet(
      activeDays: progress.activeDays,
      dailyActivity: progress.dailyActivity,
      firstCompletionDays: completed.map((record) => record.completedAt),
    ),
    today: epochDay(DateTime.now()),
  );
}

/// The user's current streak in days.
@riverpod
Future<int> streak(Ref ref) async =>
    (await ref.watch(streakStatusProvider.future)).streak;

/// All of the user's completed-lesson records.
@riverpod
Future<List<ProgressRecord>> completedLessons(Ref ref) =>
    ref.watch(progressRepositoryProvider).getAllCompleted();

/// The ids of all cards the user has collected.
@riverpod
Future<List<String>> collectedCards(Ref ref) =>
    ref.watch(cardRepositoryProvider).getAllCollectedCardIds();

/// Highest tree stage ever reached: `max(stored, derived)`, as the field has
/// always described itself.
///
/// The stored half is written by first-time lesson completion and never goes
/// down. The derived half is what the *current* course size implies, and it
/// is here to heal a learner whose stored stage predates the writer — taking
/// the max is what stops it doing harm, because a grown course derives lower
/// for the same learner and the stored floor wins.
@riverpod
Future<int> treeStage(Ref ref) async {
  final snapshot = await ref.watch(snapshotRepositoryProvider).read();
  final completed = await ref.watch(completedLessonsProvider.future);
  final lessons = await ref.watch(contentRepositoryProvider).getLessons();
  final derived = treeStageForProgress(
    completed: completed.length,
    total: lessons.length,
  );
  final stored = snapshot.clearedByReset.treeStage;
  return stored > derived ? stored : derived;
}

/// The planted grove, resolved against the banks into one matrix and one scale.
///
/// Joined here rather than in the widget so the tree stays ignorant of species
/// and lights: it receives a treatment, not a pair of ids to look up.
@riverpod
Future<GroveTreatment> groveTreatment(Ref ref) async {
  final snapshot = await ref.watch(snapshotRepositoryProvider).read();
  final content = ref.watch(contentRepositoryProvider);
  final grove = snapshot.clearedByDeleteOnly.grove.value;

  return groveTreatmentFor(
    varieties: await content.getGroveVarieties(),
    lights: await content.getGroveLights(),
    variety: grove.variety,
    light: grove.light,
  );
}
