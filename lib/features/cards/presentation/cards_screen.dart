import 'package:brew_path/core/widgets/error_view.dart';
import 'package:brew_path/core/widgets/loading_indicator.dart';
import 'package:brew_path/core/widgets/section_header.dart';
import 'package:brew_path/features/cards/domain/cards_providers.dart';
import 'package:brew_path/features/cards/presentation/card_grid_item_widget.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cards tab: a grid of collectible coffee cards (locked until earned).
class CardsScreen extends ConsumerWidget {
  /// Creates a [CardsScreen].
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(cardsWithCollectionProvider);

    return Scaffold(
      body: cards.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorView(message: '$e'),
        data: (list) => _CardsBody(list: list),
      ),
    );
  }
}

class _CardsBody extends StatelessWidget {
  const _CardsBody({required this.list});

  final List<CardWithCollection> list;

  /// Groups cards by `moduleTag`, preserving the first-seen order from content
  /// so categories appear in their authoring sequence (Beans → Taste).
  Map<String, List<CardWithCollection>> _groupByCategory() {
    final groups = <String, List<CardWithCollection>>{};
    for (final item in list) {
      groups.putIfAbsent(item.card.moduleTag, () => []).add(item);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groupByCategory();

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          sliver: SliverToBoxAdapter(child: _CollectionHeader(list: list)),
        ),
        for (final entry in groups.entries) ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            sliver: SliverToBoxAdapter(child: SectionHeader(entry.key)),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) => CardGridItemWidget(item: entry.value[i]),
                childCount: entry.value.length,
              ),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }
}

/// Collection-progress summary above the grouped grid.
class _CollectionHeader extends StatelessWidget {
  const _CollectionHeader({required this.list});

  final List<CardWithCollection> list;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    final total = list.length;
    final collected = list.where((c) => c.isCollected).length;
    final progress = total == 0 ? 0.0 : collected / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Collection',
          style: theme.textTheme.titleMedium?.copyWith(),
        ),
        const SizedBox(height: 4),
        Text(
          '$collected of $total cards collected',
          style: theme.textTheme.bodySmall?.copyWith(
            color: mood.inkMute,
          ),
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: progress,
          minHeight: AppSpacing.xs,
          borderRadius: BorderRadius.circular(AppSpacing.xxs),
          backgroundColor: mood.surface2,
          color: mood.accent,
        ),
      ],
    );
  }
}
