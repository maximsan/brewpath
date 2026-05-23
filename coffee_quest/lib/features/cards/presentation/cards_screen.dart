import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:coffee_quest/core/constants/app_strings.dart';
import 'package:coffee_quest/core/widgets/error_view.dart';
import 'package:coffee_quest/core/widgets/loading_indicator.dart';
import 'package:coffee_quest/core/widgets/section_header.dart';
import 'package:coffee_quest/features/cards/domain/cards_providers.dart';
import 'package:coffee_quest/features/cards/presentation/card_grid_item_widget.dart';

class CardsScreen extends ConsumerWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(cardsWithCollectionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.tabCards)),
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
    final colors = theme.colorScheme;
    final total = list.length;
    final collected = list.where((c) => c.isCollected).length;
    final progress = total == 0 ? 0.0 : collected / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Collection',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$collected of $total cards collected',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: progress,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
          backgroundColor: colors.surfaceContainerHighest,
          color: colors.primary,
        ),
      ],
    );
  }
}
