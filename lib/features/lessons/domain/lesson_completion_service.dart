import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/features/progress/domain/streak_service.dart';
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
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lesson_completion_service.g.dart';

/// Outcome of [LessonCompletionService.completeLesson] — the XP actually
/// banked, split so the completion screen can show the module-completion bonus
/// separately from the lesson's own reward.
class LessonCompletionResult {
  /// Creates a [LessonCompletionResult].
  const LessonCompletionResult({
    required this.lessonXp,
    required this.moduleBonusXp,
  });

  /// XP awarded for finishing the lesson itself.
  final int lessonXp;

  /// XP awarded for completing the lesson's module, or `0` when the module is
  /// not yet fully complete.
  final int moduleBonusXp;

  /// Whether finishing this lesson also completed its module.
  bool get moduleCompleted => moduleBonusXp > 0;

  /// Total XP banked by this completion.
  int get totalXp => lessonXp + moduleBonusXp;
}

/// Outcome of [LessonCompletionService.reviewLesson] — a review never re-awards
/// full lesson or module XP; it only updates mastery and may grant practice XP.
class LessonReviewResult {
  /// Creates a [LessonReviewResult].
  const LessonReviewResult({
    required this.mastery,
    required this.practiceXpAwarded,
  });

  /// The lesson's best graded result after this review.
  final MasteryResult mastery;

  /// Whether practice XP was granted (false when already practiced today).
  final bool practiceXpAwarded;
}

/// Orchestrates everything that happens when a lesson finishes: persist
/// progress, award XP, unlock the lesson's card, advance the streak, and grant
/// bonus once every lesson in the module is done. Idempotent — replaying a
/// completed lesson is a no-op so XP and cards are never double-counted.
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
    required this.streakService,
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

  /// Streak calculations.
  final StreakService streakService;

  /// First completion of [lesson]. [mastery] is the run's graded
  /// `{correct, total}` result. Awards full lesson XP, the card, streak, and
  /// the module bonus — each exactly once.
  Future<LessonCompletionResult> completeLesson(
    LessonModel lesson, {
    required MasteryResult mastery,
  }) async {
    final existing = await progressRepository.getByLessonId(lesson.id);
    if (existing != null) {
      // Replay: nothing is re-awarded. Report the lesson's previously banked
      // XP so a revisited completion screen still shows a consistent figure.
      return LessonCompletionResult(
        lessonXp: existing.xpEarned,
        moduleBonusXp: 0,
      );
    }

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

    final settings = await settingsRepository.getSettings();
    final streak = streakService.onLessonCompleted(
      currentStreak: settings.streakDays,
      lastActivityDate: settings.lastActivityDate,
      now: DateTime.now(),
    );
    settings
      ..streakDays = streak.streakDays
      ..lastActivityDate = streak.lastActivityDate;
    await settingsRepository.saveSettings(settings);

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

    return LessonCompletionResult(lessonXp: xp, moduleBonusXp: moduleBonus);
  }

  /// Re-runs a completed [lesson] for practice. Never re-awards full lesson or
  /// module XP, never collects cards, never touches completion/streak. Updates
  /// the stored mastery upward only, and grants [XpService.practiceXp] at most
  /// once per lesson per calendar day. [now] is injectable for tests.
  Future<LessonReviewResult> reviewLesson(
    LessonModel lesson, {
    required MasteryResult mastery,
    DateTime? now,
  }) async {
    final record = await progressRepository.getByLessonId(lesson.id);
    if (record == null) {
      // Defensive: review is only ever offered for completed lessons.
      return const LessonReviewResult(
        mastery: MasteryResult.unscored,
        practiceXpAwarded: false,
      );
    }

    final today = _dateOnly(now ?? DateTime.now());
    // Never downgrade: band rank first, ratio only as a tiebreak.
    record.mastery = MasteryResult.best(record.mastery, mastery);

    var practiceXpAwarded = false;
    final last = record.lastPracticeXpDate;
    if (last == null || _dateOnly(last) != today) {
      practiceXpAwarded = true;
      record.lastPracticeXpDate = today;
      await settingsRepository.addXp(xpService.practiceXp);
      await analyticsService.logEvent(
        'xp_earned',
        parameters: {'amount': xpService.practiceXp, 'source': 'practice'},
      );
    }

    await progressRepository.saveProgress(record);

    await analyticsService.logEvent(
      'lesson_reviewed',
      parameters: {
        'lesson_id': lesson.id,
        'module_id': lesson.moduleId,
        'correct': mastery.correct,
        'total': mastery.total,
      },
    );

    return LessonReviewResult(
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
  /// Only reached on a first completion — a replay returns before this — so
  /// replays and practice grow nothing. The write is raise-only, so a course
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

  /// Strips the time component so practice XP is gated per calendar day.
  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
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
      streakService: const StreakService(),
    );
