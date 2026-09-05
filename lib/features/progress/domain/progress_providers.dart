import 'package:brew_path/app/current_day.dart';
import 'package:brew_path/core/constants/points_values.dart';
import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/progress/domain/completed_lessons.dart';
import 'package:brew_path/features/progress/domain/grove_treatment.dart';
import 'package:brew_path/features/progress/domain/joined_date.dart';
import 'package:brew_path/features/progress/domain/streak_day_set.dart';
import 'package:brew_path/features/progress/domain/streak_engine.dart';
import 'package:brew_path/features/progress/domain/streak_status.dart';
import 'package:brew_path/features/progress/domain/streak_week.dart';
import 'package:brew_path/features/progress/domain/tree_growth.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'progress_providers.g.dart';

/// The learner's points total — **derived, never stored**.
///
/// Two payouts exist and both leave a record: a finished lesson is worth the
/// flat ten it authors, and a challenge's five is implied by its id sitting in
/// the completed set. Summing them here means the total cannot drift from what
/// was actually earned, and Reset Progress needs no rule of its own — clearing
/// the completions clears the total by construction.
///
/// **The payout is read off the course, not off a copy of it.** The old
/// completions table banked the points on the row; the snapshot stores which
/// lessons are finished and nothing about what they paid, because what a
/// lesson is worth is a fact about the lesson. A finished lesson the content
/// no longer carries therefore pays nothing, which is the same answer a
/// dropped row would have given.
@riverpod
Future<int> totalPoints(Ref ref) async {
  // Every watch resolved before the first await: a rebuild mid-flight must not
  // find a watch on the far side of an async gap.
  final completedFuture = ref.watch(completedLessonsProvider.future);
  final content = ref.watch(contentRepositoryProvider);
  final snapshots = ref.watch(snapshotRepositoryProvider);

  final lessons = await content.getLessons();
  final snapshot = await snapshots.read();
  final completed = await completedFuture;

  final fromLessons = lessons
      .where((lesson) => completed.contains(lesson.id))
      .fold<int>(0, (sum, lesson) => sum + lesson.points);
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
/// The qualifying-day set every streak surface folds over — one derivation,
/// so the engine, the save notice and the week strip can never disagree on
/// which days count.
@riverpod
Future<Set<int>> activeDaySet(Ref ref) async {
  final completedFuture = ref.watch(completedLessonsProvider.future);
  final snapshot = await ref.watch(snapshotRepositoryProvider).read();
  final completed = await completedFuture;
  final progress = snapshot.clearedByReset;
  return streakDaySet(
    activeDays: progress.activeDays,
    dailyActivity: progress.dailyActivity,
    firstCompletionDays: completed.firstCompletionDays,
  );
}

/// The current week's seven cells, ready for any strip host — one
/// derivation, so the streak screen, the Profile tile and the share card can
/// never disagree about a day.
@riverpod
Future<List<StreakDay>> weekStripDays(Ref ref) async {
  // Every watch before the first await, and the day from the provider the
  // rollover invalidates — never a clock read at the point of use.
  final today = ref.watch(currentDayProvider);
  final statusFuture = ref.watch(streakStatusProvider.future);
  final days = await ref.watch(activeDaySetProvider.future);
  final status = await statusFuture;
  return weekStrip(activeDays: days, status: status, today: today);
}

/// The derived streak state — the engine's fold over [activeDaySet].
@riverpod
Future<StreakStatus> streakStatus(Ref ref) async {
  final today = epochDay(ref.watch(currentDayProvider));
  return deriveStreak(
    activeDays: await ref.watch(activeDaySetProvider.future),
    today: today,
  );
}

/// The user's current streak in days.
@riverpod
Future<int> streak(Ref ref) async =>
    (await ref.watch(streakStatusProvider.future)).streak;

/// The lessons the learner has finished, off the progress snapshot.
///
/// **The snapshot is the record** (#115). It used to be the completions
/// table, which is now written by nothing and dropped by #116; the two fields
/// read here — the day each lesson was first finished, and the best result
/// stored for it — are what those rows carried that anything still asks for.
@riverpod
Future<CompletedLessons> completedLessons(Ref ref) async {
  final snapshot = await ref.watch(snapshotRepositoryProvider).read();
  final progress = snapshot.clearedByReset;
  return CompletedLessons(
    completedOn: progress.completedLessons,
    mastery: progress.bestResults,
  );
}

/// The ids of the lessons the learner has finished.
///
/// Named once because the answer is asked for by things that have no use for
/// the records themselves — the router's course wall, and the count of lessons
/// still ahead — and re-deriving a set at each of them is a second place for
/// the question to be answered differently.
@riverpod
Future<Set<String>> completedLessonIds(Ref ref) async =>
    (await ref.watch(completedLessonsProvider.future)).ids;

/// The ids of all cards the user has collected, off the progress snapshot.
///
/// Stored in full rather than derived from the finished lessons: the lesson id
/// space has been rewritten once already on this project, and a derived set
/// would have silently revoked every card the rename touched.
@riverpod
Future<List<String>> collectedCards(Ref ref) async {
  final snapshot = await ref.watch(snapshotRepositoryProvider).read();
  return snapshot.clearedByReset.ownedCollectibles.toList();
}

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
  // Every watch resolved before the first await, and **one read** of the
  // snapshot: the stored stage and the completions it is compared against
  // must come from the same moment, or a completion landing between two reads
  // would be counted on one side of the max and not the other.
  final content = ref.watch(contentRepositoryProvider);
  final snapshots = ref.watch(snapshotRepositoryProvider);

  final progress = (await snapshots.read()).clearedByReset;
  final modules = await content.getModules();

  final derived = treeStageForProgress(
    completed: progress.completedLessons.length,
    moduleSizes: moduleSizesInOrder(modules),
  );
  final stored = progress.treeStage;
  return stored > derived ? stored : derived;
}

/// Core lessons finished, and how many the course holds.
///
/// *Core* means every lesson in every module — the design's `CORE_LESSON_IDS`
/// is `MODULES.flatMap(m => m.lessons)` (`data.jsx:2935`), and the app has no
/// lesson outside a module, so this is not a new content concept and needs no
/// flag on `LessonModel`. It is the very pair [treeStage] already folds over,
/// named once here so the tree screen's counter and the stage it sits under
/// can never disagree about what they are counting.
typedef CoreLessonProgress = ({int completed, int total});

/// The learner's progress through the core course.
@riverpod
Future<CoreLessonProgress> coreLessonProgress(Ref ref) async {
  final completedFuture = ref.watch(completedLessonsProvider.future);
  final lessons = await ref.watch(contentRepositoryProvider).getLessons();
  return (completed: (await completedFuture).count, total: lessons.length);
}

/// The month the Profile's closing line names, or null before there is one.
///
/// The rule is [deriveJoinedDate]'s: the install stamp when the database
/// recorded one, and the earliest active day for every device created before
/// it did. The active-day set is read either way rather than only on the
/// fallback, so a stamp arriving later cannot change which providers this one
/// depends on mid-session.
@riverpod
Future<DateTime?> joinedDate(Ref ref) async {
  final daysFuture = ref.watch(activeDaySetProvider.future);
  final installedAt = await ref.watch(installRepositoryProvider).installedAt();

  return deriveJoinedDate(
    installedAt: installedAt,
    activeDays: await daysFuture,
  );
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
