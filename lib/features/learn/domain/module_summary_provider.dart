import 'package:brew_path/core/constants/xp_values.dart';
import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:brew_path/shared/models/module_model.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'module_summary_provider.g.dart';

/// Recap data for a finished module: the module, the cards the user has earned
/// within it, and the total XP banked (per-lesson XP plus the bonus).
class ModuleSummary {
  /// Creates a [ModuleSummary].
  const ModuleSummary({
    required this.module,
    required this.earnedCards,
    required this.totalXp,
  });

  /// The completed module.
  final ModuleModel module;

  /// Collected cards whose lesson belongs to [module].
  final List<CoffeeCardModel> earnedCards;

  /// XP banked for the module: summed lesson XP plus the completion bonus.
  final int totalXp;
}

/// Builds the [ModuleSummary] for [moduleId] by joining content (module +
/// cards) with persisted progress (completed lessons, collected cards).
@riverpod
Future<ModuleSummary> moduleSummary(Ref ref, String moduleId) async {
  final content = ref.watch(contentRepositoryProvider);
  final modules = await content.getModules();
  final module = modules.firstWhere((m) => m.id == moduleId);
  final lessonIds = module.lessonIds.toSet();

  final cards = await content.getCards();
  final collectedIds =
      (await ref.watch(cardRepositoryProvider).getAllCollectedCardIds())
          .toSet();
  final earnedCards = cards
      .where(
        (c) => lessonIds.contains(c.lessonId) && collectedIds.contains(c.id),
      )
      .toList();

  final progress = ref.watch(progressRepositoryProvider);
  final completed = await progress.getAllCompleted();
  final lessonXp = completed
      .where((r) => lessonIds.contains(r.lessonId))
      .fold<int>(0, (sum, r) => sum + r.xpEarned);

  return ModuleSummary(
    module: module,
    earnedCards: earnedCards,
    totalXp: lessonXp + XpValues.moduleCompletionBonus,
  );
}
