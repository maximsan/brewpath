import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/progress/domain/grove_treatment.dart';
import 'package:brew_path/features/progress/domain/qualifying_day.dart';
import 'package:brew_path/features/progress/domain/streak_engine.dart';
import 'package:brew_path/features/progress/domain/streak_status.dart';
import 'package:brew_path/features/progress/domain/tree_growth.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/storage/progress_record.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'progress_providers.g.dart';

/// The user's total XP.
@riverpod
Future<int> totalXp(Ref ref) async {
  final settings = await ref.watch(settingsRepositoryProvider).getSettings();
  return settings.totalXp;
}

/// The streak, the freeze and the covered days, derived from the snapshot.
///
/// Read against `DateTime.now()`, so it is only as fresh as the last time it
/// was built — which is why the streak surfaces recompute on resume rather
/// than trusting a value computed before midnight.
///
/// The day set is the union of the stored `activeDays` and the days the
/// activity record still qualifies. The record is pruned to the last couple of
/// days, so the union can only confirm the recent end of the set; what it buys
/// is a day whose entries arrived from a peer without their mark.
@riverpod
Future<StreakStatus> streakStatus(Ref ref) async {
  final snapshot = await ref.watch(snapshotRepositoryProvider).read();
  final progress = snapshot.clearedByReset;

  return deriveStreak(
    activeDays: {
      ...progress.activeDays,
      ...qualifyingDays(progress.dailyActivity),
    },
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
