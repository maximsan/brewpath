import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:brew_path/shared/models/module_model.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'module_summary_provider.g.dart';

/// Recap data for a finished module: the module, its Field Guide card, and the
/// lesson cards the learner earned within it.
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
    this.fieldGuide,
  });

  /// The completed module.
  final ModuleModel module;

  /// Collected cards whose lesson belongs to [module].
  final List<CoffeeCardModel> earnedCards;

  /// The module's own Field Guide card — the recap's reward — or null when it
  /// has not been collected.
  final CoffeeCardModel? fieldGuide;
}

/// Builds the [ModuleSummary] for [moduleId] by joining content (module +
/// cards) with persisted progress (collected cards).
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

  final fieldGuide = await content.getCardForModule(moduleId);

  return ModuleSummary(
    module: module,
    earnedCards: earnedCards,
    fieldGuide: fieldGuide != null && collectedIds.contains(fieldGuide.id)
        ? fieldGuide
        : null,
  );
}
