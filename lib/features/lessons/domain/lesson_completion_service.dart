import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/lessons/domain/lesson_finish_result.dart';
import 'package:brew_path/features/progress/domain/activity_recorder.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/features/progress/domain/streak_day_set.dart';
import 'package:brew_path/features/progress/domain/streak_engine.dart';
import 'package:brew_path/features/progress/domain/tree_growth.dart';
import 'package:brew_path/services/analytics/analytics_provider.dart';
import 'package:brew_path/services/analytics/analytics_service.dart';
import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/models/module_model.dart';
import 'package:brew_path/shared/repositories/card_repository.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/progress_repository.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/progress_record.dart';
import 'package:brew_path/shared/storage/snapshot/daily_activity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lesson_completion_service.g.dart';

/// Where the Coffee Tree stood before a run and after it, and how far the next
/// stage is from here.
typedef TreeGrowth = ({int before, int after, int? toNext});

/// Orchestrates everything that happens when a lesson finishes: persist
/// progress, award points, unlock the lesson's card, mark the day, and hand
/// over the module's Module Reward card once every lesson in it is done.
///
/// **Two payouts exist and neither is here by the run's choice** (§5.1, #16):
/// a lesson's first completion pays the flat ten it authors, and nothing a
/// lesson can do pays anything else. No module bonus, no practice reward, no
/// per-step drip.
///
/// **Not idempotent, and must not be.** Replaying a finished lesson records
/// the day again and moves mastery upward — a replay is a real activity (§3),
/// not a no-op. What *is* done at most once is the lesson's own reward: the
/// points, its card, and the Module Reward card the module hands over.
class LessonCompletionService {
  /// Creates a [LessonCompletionService].
  const LessonCompletionService({
    required this.progressRepository,
    required this.cardRepository,
    required this.contentRepository,
    required this.snapshotRepository,
    required this.analyticsService,
  });

  /// Lesson-completion records.
  final ProgressRepository progressRepository;

  /// Collected coffee cards.
  final CardRepository cardRepository;

  /// Content (modules and lessons).
  final ContentRepository contentRepository;

  /// The progress snapshot, which holds the Coffee Tree's stage.
  final SnapshotRepository snapshotRepository;

  /// Analytics sink.
  final AnalyticsService analyticsService;

  /// Finishes [lesson] — the one way a run that reached the final card is
  /// recorded. [mastery] is the run's graded `{correct, total}` result.
  ///
  /// **Which path it takes is derived, never asserted by the caller.** A
  /// lesson with a completion record is a replay; one without is a first
  /// completion. That fact already lives in the progress store, and asking the
  /// caller to supply it instead is what let the two disagree: a finished
  /// lesson reached without the replay marker used to return here having
  /// recorded nothing at all (#188).
  ///
  /// Both paths record the day. There is no branch through a finished run that
  /// writes nothing.
  ///
  /// [now] fixes the calendar day this run is recorded against — the decision
  /// a test needs to pin. Row-level write stamps still read the clock
  /// directly.
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

    final existing = await progressRepository.getByLessonId(lesson.id);
    // The record travels rather than being looked up again: a second read
    // could return null after Reset Progress landed between the two awaits,
    // and an invariant re-derived is an invariant that can fail.
    final result = existing == null
        ? await _firstCompletion(lesson, mastery: mastery, now: at)
        : await _replay(lesson, existing, mastery: mastery, now: at);

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
    final snapshot = await snapshotRepository.read();
    final progress = snapshot.clearedByReset;
    final completed = await progressRepository.getAllCompleted();
    return streakDaySet(
      activeDays: progress.activeDays,
      dailyActivity: progress.dailyActivity,
      firstCompletionDays: completed.map((record) => record.completedAt),
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
    // Recorded on the completion, and only there. The running total used to be
    // banked into a settings counter alongside this row; it is now summed off
    // these rows on read, so there is no second copy to drift.
    await progressRepository.saveCompletion(
      lessonId: lesson.id,
      xpEarned: points,
      mastery: mastery,
    );
    await analyticsService.logEvent(
      'points_earned',
      parameters: {'amount': points, 'source': 'lesson'},
    );

    await _collect(
      await contentRepository.getCardForLesson(lesson.id),
      source: {'lesson_id': lesson.id},
    );

    await recordActivity(
      snapshotRepository,
      type: ActivityType.lesson,
      subject: lesson.id,
      now: now,
    );

    final growth = await _growTree();

    final module = await _maybeCompletedModule(lesson);
    final moduleCard = module == null ? null : await _awardModuleReward(module);

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
      treeStageBefore: growth.before,
      treeStageAfter: growth.after,
      lessonsToNextStage: growth.toNext,
      moduleCompleted: module != null,
      moduleCard: moduleCard,
    );
  }

  /// A replay of an already-finished [lesson]. **Pays nothing** — no lesson
  /// points, no module reward, no practice reward — collects no card and grows
  /// nothing. Updates the stored mastery upward only, and records the day
  /// every time (§3).
  ///
  /// A replay used to pay two points, capped per lesson per calendar day. That
  /// broke §5.1's *replays pay 0* outright, and the cap scaled with the course:
  /// at thirty-two lessons it paid sixty-four a day for pure repetition against
  /// three hundred and twenty for learning everything, so five days of replays
  /// out-earned the whole course (#16).
  ///
  /// What a replay is still worth is real: it can lift mastery, and it protects
  /// the day.
  Future<LessonFinishResult> _replay(
    LessonModel lesson,
    ProgressRecord record, {
    required MasteryResult mastery,
    required DateTime now,
  }) async {
    final at = now;
    // Never downgrade: band rank first, ratio only as a tiebreak.
    record.mastery = MasteryResult.best(record.mastery, mastery);

    await progressRepository.saveProgress(record);
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
      mastery: record.mastery,
      // A replay grows nothing, so the pair is equal by construction — but the
      // screen still shows the tree, and still says how far the next stage is.
      treeStageBefore: standing.before,
      treeStageAfter: standing.after,
      lessonsToNextStage: standing.toNext,
    );
  }

  /// The module [lesson] just completed, or null when it left one unfinished.
  ///
  /// Answers only *"did this close a module?"* — deliberately separate from
  /// what closing one is worth, so the recap's routing never depends on a
  /// reward lookup succeeding.
  Future<ModuleModel?> _maybeCompletedModule(LessonModel lesson) async {
    final modules = await contentRepository.getModules();
    final module = modules
        .where((candidate) => candidate.id == lesson.moduleId)
        .firstOrNull;
    if (module == null) return null;

    final completed = await progressRepository.getAllCompleted();
    final completedIds = completed.map((record) => record.lessonId).toSet();
    return module.lessonIds.every(completedIds.contains) ? module : null;
  }

  /// Hands over [module]'s Module Reward card and reports the module after
  /// it as unlocked. Returns the card, or null when the bank names none.
  ///
  /// **This is the module moment's whole reward.** It used to bank a bonus of
  /// twenty-five, guarded by a persisted per-module ledger so it could only pay
  /// once. The design pays nothing for a module — a bonus double-counts lessons
  /// already paid — and what actually waits at the moment is this collectible,
  /// one of five that no path in the app had ever collected (§5.1, #16).
  ///
  /// **No ledger guards it, because the card is its own ledger.** Collecting a
  /// card already held is a no-op, where paying a bonus twice was not, so the
  /// idempotence the old ledger bought is now a property of the thing awarded.
  Future<CoffeeCardModel?> _awardModuleReward(ModuleModel module) async {
    final card = await contentRepository.getCardForModule(module.id);
    await _collect(card, source: {'module_id': module.id});

    // Completing this module unlocks the one after it. Modules open in course
    // order, so the module gated on this one is the one at the next position.
    final modules = await contentRepository.getModules();
    for (final next in modules.where((m) => m.n == module.n + 1)) {
      await analyticsService.logEvent(
        'module_unlocked',
        parameters: {'module_id': next.id},
      );
    }
    return card;
  }

  /// Collects [card] and reports it, or does nothing when there is no card.
  ///
  /// [source] names what awarded it — a lesson or a module — which is the only
  /// difference between the two award paths.
  Future<void> _collect(
    CoffeeCardModel? card, {
    required Map<String, Object> source,
  }) async {
    if (card == null) return;
    await cardRepository.collectCard(card.id);
    await analyticsService.logEvent(
      'card_unlocked',
      parameters: {'card_id': card.id, ...source},
    );
  }

  /// Advances the Coffee Tree to the stage this completion has earned.
  ///
  /// Only called from the first-completion path, so replays grow nothing. The
  /// write is raise-only, so a course
  /// that grows later cannot take a stage back, and a stage already reached on
  /// another device survives the merge by the same rule.
  Future<TreeGrowth> _growTree() async {
    final completed = await progressRepository.getAllCompleted();
    final modules = await contentRepository.getModules();
    final sizes = moduleSizesInOrder(modules);
    final stage = treeStageForProgress(
      completed: completed.length,
      moduleSizes: sizes,
    );
    final toNext = lessonsToNextStage(
      completed: completed.length,
      moduleSizes: sizes,
    );

    final snapshot = await snapshotRepository.read();
    final before = snapshot.clearedByReset.treeStage;
    if (stage <= before) {
      return (before: before, after: before, toNext: toNext);
    }
    await snapshotRepository.write(
      snapshot.copyWith(
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        clearedByReset: snapshot.clearedByReset.withTreeStageAtLeast(stage),
      ),
    );
    return (before: before, after: stage, toNext: toNext);
  }

  /// What the tree did, and how far the next stage is.
  ///
  /// Read out of the same call that writes the stage, so the screen cannot ask
  /// a second time and get an answer the write has already moved past.
  Future<TreeGrowth> _treeStanding() async {
    final completed = await progressRepository.getAllCompleted();
    final modules = await contentRepository.getModules();
    final sizes = moduleSizesInOrder(modules);
    final snapshot = await snapshotRepository.read();
    final stage = snapshot.clearedByReset.treeStage;
    return (
      before: stage,
      after: stage,
      toNext: lessonsToNextStage(
        completed: completed.length,
        moduleSizes: sizes,
      ),
    );
  }
}

/// Provides the [LessonCompletionService] with its dependencies wired in.
@riverpod
LessonCompletionService lessonCompletionService(Ref ref) =>
    LessonCompletionService(
      progressRepository: ref.watch(progressRepositoryProvider),
      cardRepository: ref.watch(cardRepositoryProvider),
      contentRepository: ref.watch(contentRepositoryProvider),
      snapshotRepository: ref.watch(snapshotRepositoryProvider),
      analyticsService: ref.watch(analyticsServiceProvider),
    );
