import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:coffee_quest/features/progress/domain/streak_service.dart';
import 'package:coffee_quest/features/progress/domain/xp_service.dart';
import 'package:coffee_quest/services/analytics/analytics_provider.dart';
import 'package:coffee_quest/services/analytics/analytics_service.dart';
import 'package:coffee_quest/shared/models/lesson_model.dart';
import 'package:coffee_quest/shared/repositories/card_repository.dart';
import 'package:coffee_quest/shared/repositories/content_repository.dart';
import 'package:coffee_quest/shared/repositories/progress_repository.dart';
import 'package:coffee_quest/shared/repositories/repository_providers.dart';
import 'package:coffee_quest/shared/repositories/settings_repository.dart';

part 'lesson_completion_service.g.dart';

/// Orchestrates everything that happens when a lesson finishes: persist progress,
/// award XP, unlock the lesson's card, advance the streak, and grant the module
/// bonus once every lesson in the module is done. Idempotent — replaying a
/// completed lesson is a no-op so XP and cards are never double-counted.
class LessonCompletionService {
  const LessonCompletionService({
    required this.progressRepository,
    required this.settingsRepository,
    required this.cardRepository,
    required this.contentRepository,
    required this.analyticsService,
    required this.xpService,
    required this.streakService,
  });

  final ProgressRepository progressRepository;
  final SettingsRepository settingsRepository;
  final CardRepository cardRepository;
  final ContentRepository contentRepository;
  final AnalyticsService analyticsService;
  final XpService xpService;
  final StreakService streakService;

  Future<void> completeLesson(LessonModel lesson) async {
    final existing = await progressRepository.getByLessonId(lesson.id);
    if (existing != null) return;

    final xp = xpService.calculateLessonXp(lesson.steps.length);
    await progressRepository.saveCompletion(lessonId: lesson.id, xpEarned: xp);
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

    await _maybeAwardModuleBonus(lesson);

    await analyticsService.logEvent(
      'lesson_completed',
      parameters: {
        'lesson_id': lesson.id,
        'module_id': lesson.moduleId,
        'xp_earned': xp,
      },
    );
  }

  Future<void> _maybeAwardModuleBonus(LessonModel lesson) async {
    final modules = await contentRepository.getModules();
    final matches = modules.where((m) => m.id == lesson.moduleId);
    if (matches.isEmpty) return;
    final module = matches.first;

    final completed = await progressRepository.getAllCompleted();
    final completedIds = completed.map((r) => r.lessonId).toSet();
    final allDone = module.lessonIds.every(completedIds.contains);
    if (!allDone) return;

    final bonus = xpService.moduleCompletionBonus;
    await settingsRepository.addXp(bonus);
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
  }
}

@riverpod
LessonCompletionService lessonCompletionService(Ref ref) =>
    LessonCompletionService(
      progressRepository: ref.watch(progressRepositoryProvider),
      settingsRepository: ref.watch(settingsRepositoryProvider),
      cardRepository: ref.watch(cardRepositoryProvider),
      contentRepository: ref.watch(contentRepositoryProvider),
      analyticsService: ref.watch(analyticsServiceProvider),
      xpService: const XpService(),
      streakService: const StreakService(),
    );
