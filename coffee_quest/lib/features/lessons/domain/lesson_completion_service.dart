import 'package:coffee_quest/features/progress/domain/streak_service.dart';
import 'package:coffee_quest/features/progress/domain/xp_service.dart';
import 'package:coffee_quest/services/analytics/analytics_provider.dart';
import 'package:coffee_quest/services/analytics/analytics_service.dart';
import 'package:coffee_quest/shared/models/lesson_model.dart';
import 'package:coffee_quest/shared/repositories/card_repository.dart';
import 'package:coffee_quest/shared/repositories/content_repository.dart';
import 'package:coffee_quest/shared/repositories/module_progress_repository.dart';
import 'package:coffee_quest/shared/repositories/progress_repository.dart';
import 'package:coffee_quest/shared/repositories/repository_providers.dart';
import 'package:coffee_quest/shared/repositories/settings_repository.dart';
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
    required this.bestScore,
    required this.practiceXpAwarded,
  });

  /// The lesson's best first-try accuracy after this review (0–100).
  final int bestScore;

  /// Whether practice XP was granted (false when already practiced today).
  final bool practiceXpAwarded;
}

/// Orchestrates everything that happens when a lesson finishes: persist progress,
/// award XP, unlock the lesson's card, advance the streak, and grant the module
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

  /// Analytics sink.
  final AnalyticsService analyticsService;

  /// XP calculations.
  final XpService xpService;

  /// Streak calculations.
  final StreakService streakService;

  /// First completion of [lesson]. [score] is the run's first-try accuracy
  /// (0–100). Awards full lesson XP, the card, streak, and the module bonus —
  /// each exactly once.
  Future<LessonCompletionResult> completeLesson(
    LessonModel lesson, {
    required int score,
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
      score: score,
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
  /// the stored best score upward only, and grants [XpService.practiceXp] at
  /// most once per lesson per calendar day. [now] is injectable for tests.
  Future<LessonReviewResult> reviewLesson(
    LessonModel lesson, {
    required int score,
    DateTime? now,
  }) async {
    final record = await progressRepository.getByLessonId(lesson.id);
    if (record == null) {
      // Defensive: review is only ever offered for completed lessons.
      return const LessonReviewResult(bestScore: 0, practiceXpAwarded: false);
    }

    final today = _dateOnly(now ?? DateTime.now());
    if (score > record.bestScore) record.bestScore = score;

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
        'score': score,
      },
    );

    return LessonReviewResult(
      bestScore: record.bestScore,
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
      analyticsService: ref.watch(analyticsServiceProvider),
      xpService: const XpService(),
      streakService: const StreakService(),
    );
