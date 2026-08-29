import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/utils/module_icons.dart';
import 'package:brew_path/core/widgets/error_view.dart';
import 'package:brew_path/core/widgets/icon_badge.dart';
import 'package:brew_path/core/widgets/loading_indicator.dart';
import 'package:brew_path/features/companion/domain/companion_reaction.dart';
import 'package:brew_path/features/companion/presentation/companion_celebration.dart';
import 'package:brew_path/features/learn/domain/module_summary_provider.dart';
import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Celebratory recap shown after a module's final lesson: the companion plays
/// its module-complete moment, with the module's Module Reward card and the
/// lesson cards earned along the way.
class ModuleSummaryScreen extends ConsumerStatefulWidget {
  /// Creates a [ModuleSummaryScreen].
  const ModuleSummaryScreen({required this.moduleId, super.key});

  /// Id of the completed module to recap.
  final String moduleId;

  @override
  ConsumerState<ModuleSummaryScreen> createState() =>
      _ModuleSummaryScreenState();
}

class _ModuleSummaryScreenState extends ConsumerState<ModuleSummaryScreen> {
  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(moduleSummaryProvider(widget.moduleId));
    return Scaffold(
      body: SafeArea(
        child: summary.when(
          loading: () => const LoadingIndicator(),
          error: (e, _) => ErrorView(message: '$e'),
          data: _buildSummary,
        ),
      ),
    );
  }

  Widget _buildSummary(ModuleSummary summary) {
    final theme = Theme.of(context);
    final mood = context.mood;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: CompanionCelebration(
                reaction: CompanionReaction.moduleComplete,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Module complete!',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              summary.module.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: mood.inkMute,
              ),
            ),
            // No points line. The module pays nothing (§5.1, #16); the reward
            // this moment always had is the Module Reward card below.
            if (summary.moduleReward != null) ...[
              const SizedBox(height: AppSpacing.lg),
              _ModuleRewardCard(card: summary.moduleReward!),
            ],
            if (summary.earnedCards.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              _EarnedCards(cards: summary.earnedCards),
            ],
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: () => context.goNamed(AppRoutes.learn.name),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

/// The module's own reward, given its own billing above the lesson cards.
class _ModuleRewardCard extends StatelessWidget {
  const _ModuleRewardCard({required this.card});

  static const double _badgeSize = 72;

  final CoffeeCardModel card;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    return Column(
      children: [
        IconBadge.circleMark(
          mark: moduleMark(card.iconName),
          size: _badgeSize,
          semanticLabel: card.title,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          card.title,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            color: mood.accent,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          // Borrowed from the design's card-unlock beat, where
          // `ModuleRewardCardScreen` pairs the eyebrow REWARD UNLOCKED with
          // "You earned a card." The app has no dedicated reward screen, so
          // the words land as a caption on the recap rather than as that
          // eyebrow — the same phrase in a different slot, not the same
          // element. What it is *not* is the glossary term: "Module Reward"
          // names the thing, and was never the sentence shown over it.
          'Reward unlocked',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(color: mood.inkMute),
        ),
      ],
    );
  }
}

/// Horizontal strip of the cards earned within the module.
class _EarnedCards extends StatelessWidget {
  const _EarnedCards({required this.cards});

  static const double _badgeSize = 56;

  final List<CoffeeCardModel> cards;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final card in cards)
          IconBadge.circleMark(
            mark: moduleMark(card.iconName),
            size: _badgeSize,
            semanticLabel: card.title,
          ),
      ],
    );
  }
}
