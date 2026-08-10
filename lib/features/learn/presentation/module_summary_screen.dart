import 'package:brew_path/core/utils/module_icons.dart';
import 'package:brew_path/core/widgets/error_view.dart';
import 'package:brew_path/core/widgets/loading_indicator.dart';
import 'package:brew_path/features/companion/application/companion_providers.dart';
import 'package:brew_path/features/companion/domain/companion_reaction.dart';
import 'package:brew_path/features/companion/presentation/companion.dart';
import 'package:brew_path/features/companion/presentation/companion_bubble.dart';
import 'package:brew_path/features/companion/presentation/companion_handle.dart';
import 'package:brew_path/features/learn/domain/module_summary_provider.dart';
import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Celebratory recap shown after a module's final lesson: the companion plays
/// its module-complete moment, with the module's total XP and earned cards.
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
  final CompanionHandle _companionHandle = CompanionHandle();
  String? _companionLine;
  bool _reacted = false;

  @override
  void dispose() {
    _companionHandle.dispose();
    super.dispose();
  }

  void _fireModuleCompleteOnce() {
    if (_reacted) return;
    _reacted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _companionHandle.react(CompanionReaction.moduleComplete);
    });
  }

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
    _companionLine ??= ref
        .watch(companionLinesProvider)
        .asData
        ?.value
        .lineFor(CompanionReaction.moduleComplete);
    _fireModuleCompleteOnce();

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final companion = Companion(handle: _companionHandle);
    final line = _companionLine;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: line == null
                  ? companion
                  : CompanionBubble(text: line, child: companion),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Module complete!',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              summary.module.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '+${summary.totalXp} XP',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (summary.earnedCards.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              _EarnedCards(cards: summary.earnedCards),
            ],
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: () => context.go('/learn'),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
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
    final colors = Theme.of(context).colorScheme;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final card in cards)
          Container(
            width: _badgeSize,
            height: _badgeSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              moduleIcon(card.iconName),
              color: colors.onPrimaryContainer,
              semanticLabel: card.title,
            ),
          ),
      ],
    );
  }
}
