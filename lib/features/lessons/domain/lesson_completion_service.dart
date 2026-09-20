import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/lessons/domain/first_completion_fold.dart';
import 'package:brew_path/features/lessons/domain/lesson_finish_result.dart';
import 'package:brew_path/features/progress/domain/activity_recorder.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/features/progress/domain/progress_write.dart';
import 'package:brew_path/features/progress/domain/streak_day_set.dart';
import 'package:brew_path/features/progress/domain/streak_engine.dart';
import 'package:brew_path/features/progress/domain/tree_growth.dart';
import 'package:brew_path/services/analytics/analytics_provider.dart';
import 'package:brew_path/services/analytics/analytics_service.dart';
import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/models/module_model.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/snapshot/daily_activity.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_scopes.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lesson_completion_service.g.dart';

/// Where the Coffee Tree stood before a run and after it, and how far the next
/// stage is from here.
typedef TreeGrowth = ({int before, int after, int? toNext});

/// Records a finished lesson: progress, the flat points it authors, its card,
/// the day, and the Module Reward once its module is done (§5.1, #16).
///
/// Not idempotent, and must not be: a replay records the day again and lifts
/// mastery (§3). What happens at most once is the lesson's own reward — the
/// points, its card, and the module's card.
class LessonCompletionService {
  /// Creates a [LessonCompletionService].
  const LessonCompletionService({
    required this.contentRepository,
    required this.snapshotRepository,
    required this.analyticsService,
  });

  /// Content (modules and lessons).
  final ContentRepository contentRepository;

  /// The progress snapshot — **the record** of what a learner has finished,
  /// what they scored, and what they hold (#115).
  final SnapshotRepository snapshotRepository;

  /// Analytics sink.
  final AnalyticsService analyticsService;

  /// Finishes [lesson] with the run's graded [mastery] — the one way a run
  /// that reached the final card is recorded, and both paths record the day.
  ///
  /// First completion or replay is derived from the progress store, never
  /// asserted by the caller (#188). [now] fixes the calendar day and stamps
  /// every write, so a pinned run leaves nothing behind that read the clock.
  Future<LessonFinishResult> finishLesson(
    LessonModel lesson, {
    required MasteryResult mastery,
    DateTime? now,
  }) async {
    final at = now ?? DateTime.now();
    // Read before anything is written, because both writes below can add
    // today to the day set — the completion row through the backfill, and the
    // activity record directly. Sampled after the first of them, "before"
    // would already contain today and no run could ever read as earning a
    // freeze.
    final daysBefore = await _qualifyingDays();

    final finished = (await snapshotRepository.read())
        .clearedByReset
        .completedLessons
        .containsKey(lesson.id);
    final result = finished
        ? await _replay(lesson, mastery: mastery, now: at)
        : await _firstCompletion(lesson, mastery: mastery, now: at);

    return result.withFreezeEarned(
      earned: freezeEarnedBetween(
        before: daysBefore,
        after: await _qualifyingDays(),
        today: epochDay(at),
      ),
    );
  }

  /// The qualifying-day set as the stores hold it at this instant.
  ///
  /// Assembled by the same [streakDaySet] union every streak surface reads
  /// through, so what the completion screen reports about the freeze and what
  /// the streak screen shows can never be derived two different ways.
  Future<Set<int>> _qualifyingDays() async {
    final progress = (await snapshotRepository.read()).clearedByReset;
    return streakDaySet(
      activeDays: progress.activeDays,
      dailyActivity: progress.dailyActivity,
      firstCompletionDays: progress.completedLessons.values,
    );
  }

  Future<LessonFinishResult> _firstCompletion(
    LessonModel lesson, {
    required MasteryResult mastery,
    required DateTime now,
  }) async {
    // What the lesson itself authors, flat. The old per-step formula had no
    // input left once steps became cards: a lesson's card count is a shape of
    // its teaching, not a measure of what finishing it is worth.
    final points = lesson.points;
    final course = (
      modules: await contentRepository.getModules(),
      cards: await contentRepository.getCards(),
    );

    // The completion, its card, the tree's stage and a closed module's reward
    // in **one write** (`foldFirstCompletion`). Nothing records the points —
    // a lesson pays what it authors, so the total is summed off the course
    // rather than off a copy of it banked here.
    late FirstCompletionFold fold;
    final progress = await _updateProgress((found) {
      fold = foldFirstCompletion(
        found,
        lesson: lesson,
        day: epochDay(now),
        mastery: mastery,
        course: course,
      );
      return fold.progress;
    }, now: now);
    await analyticsService.logEvent(
      'points_earned',
      parameters: {'amount': points, 'source': 'lesson'},
    );
    await _reportCollected(fold.card, source: {'lesson_id': lesson.id});

    await recordActivity(
      snapshotRepository,
      type: ActivityType.lesson,
      subject: lesson.id,
      now: now,
    );

    final closedModule = fold.closedModule;
    if (closedModule != null) {
      await _reportModuleReward(
        closedModule,
        fold.moduleCard,
        modules: course.modules,
      );
    }

    await analyticsService.logEvent(
      'lesson_completed',
      parameters: {
        'lesson_id': lesson.id,
        'module_id': lesson.moduleId,
        'points_earned': points,
      },
    );

    return LessonFinishResult(
      isReplay: false,
      pointsEarned: points,
      mastery: mastery,
      treeStageBefore: fold.stageBefore,
      treeStageAfter: progress.treeStage,
      lessonsToNextStage: lessonsToNextStage(
        completed: progress.completedLessons.length,
        moduleSizes: moduleSizesInOrder(course.modules),
      ),
      moduleCompleted: closedModule != null,
      moduleCard: fold.moduleCard,
    );
  }

  /// A replay of an already-finished [lesson]: pays nothing, collects no card
  /// and grows nothing (§5.1, #16). It lifts the stored mastery, never lowers
  /// it, and records the day every time (§3).
  Future<LessonFinishResult> _replay(
    LessonModel lesson, {
    required MasteryResult mastery,
    required DateTime now,
  }) async {
    final at = now;
    // Never downgrade: the writer folds with `MasteryResult.best`, band rank
    // first and ratio only as a tiebreak.
    // Read back off what was written rather than by asking again: a second
    // read could land after Reset Progress and report a lesson that is no
    // longer finished.
    final progress = await _updateProgress(
      (progress) => progress.withLessonReplayed(
        lesson.id,
        day: epochDay(at),
        mastery: mastery,
      ),
      now: at,
    );
    final best = progress.bestResults[lesson.id] ?? mastery;
    // A replay that reaches the final card protects the day (§3) — the rule
    // that lets a streak outlive the last authored lesson.
    await recordActivity(
      snapshotRepository,
      type: ActivityType.replay,
      subject: lesson.id,
      now: at,
    );

    await analyticsService.logEvent(
      'lesson_reviewed',
      parameters: {
        'lesson_id': lesson.id,
        'module_id': lesson.moduleId,
        'correct': mastery.correct,
        'total': mastery.total,
      },
    );

    final standing = await _treeStanding();
    return LessonFinishResult(
      isReplay: true,
      pointsEarned: 0,
      mastery: best,
      // A replay grows nothing, so the pair is equal by construction — but the
      // screen still shows the tree, and still says how far the next stage is.
      treeStageBefore: standing.before,
      treeStageAfter: standing.after,
      lessonsToNextStage: standing.toNext,
    );
  }

  /// Reports a closed [module]'s Module Reward [card] as collected and the
  /// module after it as unlocked. Reporting only: the card was written in the
  /// same fold as the completion that closed the module, and a card already
  /// held is its own ledger — the design pays nothing else for a module
  /// (§5.1, #16). That the module is closed is derived from its lessons, never
  /// stored: a stored answer disagrees the moment a finished module grows.
  Future<void> _reportModuleReward(
    ModuleModel module,
    CoffeeCardModel? card, {
    required List<ModuleModel> modules,
  }) async {
    await _reportCollected(card, source: {'module_id': module.id});

    // Completing this module unlocks the one after it. Modules open in course
    // order, so the module gated on this one is the one at the next position.
    for (final next in modules.where((m) => m.n == module.n + 1)) {
      await analyticsService.logEvent(
        'module_unlocked',
        parameters: {'module_id': next.id},
      );
    }
  }

  /// Reports [card] as unlocked, or says nothing when there is no card.
  ///
  /// **Reporting only** — the card is written into the snapshot beside the
  /// thing that earned it, so that a completion and its collectible cannot
  /// land separately. [source] names what awarded it, which is the only
  /// difference between the two award paths.
  Future<void> _reportCollected(
    CoffeeCardModel? card, {
    required Map<String, Object> source,
  }) async {
    if (card == null) return;
    await analyticsService.logEvent(
      'card_unlocked',
      parameters: {'card_id': card.id, ...source},
    );
  }

  /// This service's every progress write, through the shared writer.
  Future<ClearedByReset> _updateProgress(
    ClearedByReset Function(ClearedByReset progress) change, {
    required DateTime now,
  }) => updateProgress(snapshotRepository, change, now: now);

  /// What the tree did, and how far the next stage is.
  ///
  /// Read out of the same call that writes the stage, so the screen cannot ask
  /// a second time and get an answer the write has already moved past.
  Future<TreeGrowth> _treeStanding() async {
    final modules = await contentRepository.getModules();
    final sizes = moduleSizesInOrder(modules);
    final progress = (await snapshotRepository.read()).clearedByReset;
    final stage = progress.treeStage;
    return (
      before: stage,
      after: stage,
      toNext: lessonsToNextStage(
        completed: progress.completedLessons.length,
        moduleSizes: sizes,
      ),
    );
  }
}

/// Provides the [LessonCompletionService] with its dependencies wired in.
@riverpod
LessonCompletionService lessonCompletionService(Ref ref) =>
    LessonCompletionService(
      contentRepository: ref.watch(contentRepositoryProvider),
      snapshotRepository: ref.watch(snapshotRepositoryProvider),
      analyticsService: ref.watch(analyticsServiceProvider),
    );
