import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/lessons/domain/lesson_finish_result.dart';
import 'package:brew_path/features/progress/domain/activity_recorder.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/features/progress/domain/tree_growth.dart';
import 'package:brew_path/features/progress/domain/xp_service.dart';
import 'package:brew_path/services/analytics/analytics_provider.dart';
import 'package:brew_path/services/analytics/analytics_service.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/repositories/card_repository.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/module_progress_repository.dart';
import 'package:brew_path/shared/repositories/progress_repository.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/repositories/settings_repository.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/progress_record.dart';
import 'package:brew_path/shared/storage/snapshot/daily_activity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lesson_completion_service.g.dart';

/// Orchestrates everything that happens when a lesson finishes: persist
/// progress, award points, unlock the lesson's card, mark the day, and grant
/// the module bonus once every lesson in it is done.
///
/// **Not idempotent, and must not be.** Replaying a finished lesson records
/// the day again, moves mastery upward and may pay the once-a-day practice
/// reward — a replay is a real activity (§3), not a no-op. What *is* paid at
/// most once is the lesson's own reward: points, the card, the module bonus.
class LessonCompletionService {
  /// Creates a [LessonCompletionService].
  const LessonCompletionService({
    required this.progressRepository,
    required this.settingsRepository,
    required this.cardRepository,
    required this.contentRepository,
    required this.moduleProgressRepository,
    required this.snapshotRepository,
    required this.analyticsService,
    required this.xpService,
  });

  /// Lesson-completion records.
  final ProgressRepository progressRepository;

  /// User settings (XP, streak, preferences).
  final SettingsRepository settingsRepository;

  /// Collected coffee cards.
  final CardRepository cardRepository;

  /// Content (modules and lessons).
  final ContentRepository contentRepository;

  /// Per-module "bonus awarded" ledger.
  final ModuleProgressRepository moduleProgressRepository;

  /// The progress snapshot, which holds the Coffee Tree's stage.
  final SnapshotRepository snapshotRepository;

  /// Analytics sink.
  final AnalyticsService analyticsService;

  /// XP calculations.
  final XpService xpService;

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
  /// [now] fixes the calendar day this run is recorded against and the
  /// practice-reward ledger it is compared to — the two decisions a test needs
  /// to pin. Row-level write stamps still read the clock directly.
  Future<LessonFinishResult> finishLesson(
    LessonModel lesson, {
    required MasteryResult mastery,
    DateTime? now,
  }) async {
    final at = now ?? DateTime.now();
    final existing = await progressRepository.getByLessonId(lesson.id);
    // The record travels rather than being looked up again: a second read
    // could return null after Reset Progress landed between the two awaits,
    // and an invariant re-derived is an invariant that can fail.
    return existing == null
        ? _firstCompletion(lesson, mastery: mastery, now: at)
        : _replay(lesson, existing, mastery: mastery, now: at);
  }

  Future<LessonFinishResult> _firstCompletion(
    LessonModel lesson, {
    required MasteryResult mastery,
    required DateTime now,
  }) async {
    final xp = xpService.calculateLessonXp(lesson.steps.length);
    await progressRepository.saveCompletion(
      lessonId: lesson.id,
      xpEarned: xp,
      mastery: mastery,
    );
    await settingsRepository.addXp(xp);
    await analyticsService.logEvent(
      'xp_earned',
      parameters: {'amount': xp, 'source': 'lesson'},
    );

    final cardId = lesson.cardId;
    if (cardId != null) {
      await cardRepository.collectCard(cardId);
      await analyticsService.logEvent(
        'card_unlocked',
        parameters: {'card_id': cardId, 'lesson_id': lesson.id},
      );
    }

    await recordActivity(
      snapshotRepository,
      type: ActivityType.lesson,
      subject: lesson.id,
      now: now,
    );

    await _growTree();

    final moduleBonus = await _maybeAwardModuleBonus(lesson);

    await analyticsService.logEvent(
      'lesson_completed',
      parameters: {
        'lesson_id': lesson.id,
        'module_id': lesson.moduleId,
        'xp_earned': xp,
      },
    );

    return LessonFinishResult(
      isReplay: false,
      lessonXp: xp,
      moduleBonusXp: moduleBonus,
      mastery: mastery,
      practiceXpAwarded: false,
    );
  }

  /// A replay of an already-finished [lesson]. Never re-awards lesson or
  /// module XP, never collects a card, never grows the tree. Updates the
  /// stored mastery upward only, grants [XpService.practiceXp] at most once
  /// per lesson per calendar day, and records the day every time (§3).
  Future<LessonFinishResult> _replay(
    LessonModel lesson,
    ProgressRecord record, {
    required MasteryResult mastery,
    required DateTime now,
  }) async {
    final at = now;
    final today = dateOnly(at);
    // Never downgrade: band rank first, ratio only as a tiebreak.
    record.mastery = MasteryResult.best(record.mastery, mastery);

    var practiceXpAwarded = false;
    final last = record.lastPracticeXpDate;
    if (last == null || dateOnly(last) != today) {
      practiceXpAwarded = true;
      record.lastPracticeXpDate = today;
      await settingsRepository.addXp(xpService.practiceXp);
      await analyticsService.logEvent(
        'xp_earned',
        parameters: {'amount': xpService.practiceXp, 'source': 'practice'},
      );
    }

    await progressRepository.saveProgress(record);
    // A replay that reaches the final card protects the day (§3) — the rule
    // that lets a streak outlive the last authored lesson. It qualifies every
    // time; the once-a-day practice XP above is a separate ledger.
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

    return LessonFinishResult(
      isReplay: true,
      lessonXp: 0,
      moduleBonusXp: 0,
      mastery: record.mastery,
      practiceXpAwarded: practiceXpAwarded,
    );
  }

  /// Awards the module-completion bonus when [lesson] was the last unfinished
  /// lesson of its module. Guarded by a persisted per-module ledger so the
  /// bonus is granted at most once. Returns the bonus XP granted, or `0`.
  Future<int> _maybeAwardModuleBonus(LessonModel lesson) async {
    if (await moduleProgressRepository.isModuleXpAwarded(lesson.moduleId)) {
      return 0;
    }

    final modules = await contentRepository.getModules();
    final matches = modules.where((m) => m.id == lesson.moduleId);
    if (matches.isEmpty) return 0;
    final module = matches.first;

    final completed = await progressRepository.getAllCompleted();
    final completedIds = completed.map((r) => r.lessonId).toSet();
    final allDone = module.lessonIds.every(completedIds.contains);
    if (!allDone) return 0;

    final bonus = xpService.moduleCompletionBonus;
    await settingsRepository.addXp(bonus);
    await moduleProgressRepository.markModuleXpAwarded(module.id);
    await analyticsService.logEvent(
      'xp_earned',
      parameters: {'amount': bonus, 'source': 'module_bonus'},
    );

    // Completing this module unlocks any module gated on it.
    for (final next in modules.where((m) => m.unlockRequirement == module.id)) {
      await analyticsService.logEvent(
        'module_unlocked',
        parameters: {'module_id': next.id},
      );
    }
    return bonus;
  }

  /// Advances the Coffee Tree to the stage this completion has earned.
  ///
  /// Only called from the first-completion path, so replays grow nothing. The
  /// write is raise-only, so a course
  /// that grows later cannot take a stage back, and a stage already reached on
  /// another device survives the merge by the same rule.
  Future<void> _growTree() async {
    final completed = await progressRepository.getAllCompleted();
    final lessons = await contentRepository.getLessons();
    final stage = treeStageForProgress(
      completed: completed.length,
      total: lessons.length,
    );

    final snapshot = await snapshotRepository.read();
    if (stage <= snapshot.clearedByReset.treeStage) return;
    await snapshotRepository.write(
      snapshot.copyWith(
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        clearedByReset: snapshot.clearedByReset.withTreeStageAtLeast(stage),
      ),
    );
  }
}

/// Provides the [LessonCompletionService] with its dependencies wired in.
@riverpod
LessonCompletionService lessonCompletionService(Ref ref) =>
    LessonCompletionService(
      progressRepository: ref.watch(progressRepositoryProvider),
      settingsRepository: ref.watch(settingsRepositoryProvider),
      cardRepository: ref.watch(cardRepositoryProvider),
      contentRepository: ref.watch(contentRepositoryProvider),
      moduleProgressRepository: ref.watch(moduleProgressRepositoryProvider),
      snapshotRepository: ref.watch(snapshotRepositoryProvider),
      analyticsService: ref.watch(analyticsServiceProvider),
      xpService: const XpService(),
    );
