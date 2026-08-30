import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:brew_path/shared/models/module_model.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'module_summary_provider.g.dart';

/// Recap data for a finished module: the module, its Module Reward card,
/// and the lesson cards the learner earned within it.
///
/// **No points total.** It used to carry the module's summed lesson points plus
/// a completion bonus, and the recap screen led with that number. The module
/// pays nothing (§5.1, #16), and the number it showed double-counted lessons
/// already paid — so the field is gone rather than computed and ignored.
class ModuleSummary {
  /// Creates a [ModuleSummary].
  const ModuleSummary({
    required this.module,
    required this.earnedCards,
    required this.hasNextModule,
    required this.treeStage,
    this.moduleReward,
  });

  /// The completed module.
  final ModuleModel module;

  /// Collected cards whose lesson belongs to [module].
  final List<CoffeeCardModel> earnedCards;

  /// The module's own Module Reward card — the recap's reward — or null when it
  /// has not been collected.
  final CoffeeCardModel? moduleReward;

  /// Whether a module follows this one in the course.
  ///
  /// The ending's action reads *Begin next module* where one does and *Back to
  /// Path* where none does (`rewards.jsx:340`) — so the screen has to know
  /// which module it just closed, not only that it closed one.
  final bool hasNextModule;

  /// Where the coffee tree stands now.
  ///
  /// The screen draws the tree at rest rather than growing it: the growth
  /// belongs to the lesson that caused it, and the lesson-completion screen
  /// has already played it by the time this one opens. See #458.
  final int treeStage;
}

/// Builds the [ModuleSummary] for [moduleId] by joining content (module +
/// cards) with persisted progress (collected cards).
@riverpod
Future<ModuleSummary> moduleSummary(Ref ref, String moduleId) async {
  final content = ref.watch(contentRepositoryProvider);
  final modules = await content.getModules();
  final module = modules.firstWhere((m) => m.id == moduleId);
  final lessonIds = module.lessonIds.toSet();
  // Position, not list order: the course is numbered, and a bank that ever
  // ships out of order must not decide what "next" means.
  final hasNextModule = modules.any((m) => m.n > module.n);

  final cards = await content.getCards();
  final collectedIds =
      (await ref.watch(cardRepositoryProvider).getAllCollectedCardIds())
          .toSet();
  final earnedCards = cards
      .where(
        (c) => lessonIds.contains(c.lessonId) && collectedIds.contains(c.id),
      )
      .toList();

  final moduleReward = await content.getCardForModule(moduleId);

  return ModuleSummary(
    module: module,
    earnedCards: earnedCards,
    hasNextModule: hasNextModule,
    treeStage: await ref.watch(treeStageProvider.future),
    moduleReward: moduleReward != null && collectedIds.contains(moduleReward.id)
        ? moduleReward
        : null,
  );
}
