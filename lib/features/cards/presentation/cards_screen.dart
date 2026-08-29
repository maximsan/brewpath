import 'package:brew_path/core/widgets/error_view.dart';
import 'package:brew_path/core/widgets/loading_indicator.dart';
import 'package:brew_path/features/cards/domain/cards_grid.dart';
import 'package:brew_path/features/cards/domain/cards_providers.dart';
import 'package:brew_path/features/cards/presentation/card_grid_item_widget.dart';
import 'package:brew_path/features/cards/presentation/cards_footer.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tiles per row, and how tall each sits — the design's 3:4 portrait card.
const int _columns = 2;
const double _tileAspect = 3 / 4;
const double _tileGap = AppSpacing.sm;

/// Cards tab: the collection, as far as the learner has got.
///
/// **One flat grid, not a grouped one.** The design does not section the deck
/// by module, and it does not lay out the whole locked set: it shows what has
/// been earned, one locked card as a teaser, and a footer naming the rest
/// (#396). What is drawn and what is counted are decided in `cards_grid.dart`.
class CardsScreen extends ConsumerWidget {
  /// Creates a [CardsScreen].
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(cardsWithCollectionProvider);

    return Scaffold(
      body: cards.when(
        loading: () => Semantics(
          label: 'Loading your collection',
          child: const LoadingIndicator(),
        ),
        error: (error, _) => Semantics(
          label: 'Your collection could not be loaded.',
          excludeSemantics: true,
          child: ErrorView(message: '$error'),
        ),
        data: (list) => _CardsBody(list: list),
      ),
    );
  }
}

class _CardsBody extends StatelessWidget {
  const _CardsBody({required this.list});

  final List<CardWithCollection> list;

  @override
  Widget build(BuildContext context) {
    final shown = cardsGridItems(list);
    final remaining = unearnedRemainder(list);

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.md,
            AppSpacing.gutter,
            AppSpacing.lg,
          ),
          sliver: SliverToBoxAdapter(child: _CollectionCount(list: list)),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _columns,
              mainAxisSpacing: _tileGap,
              crossAxisSpacing: _tileGap,
              childAspectRatio: _tileAspect,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => CardGridItemWidget(item: shown[index]),
              childCount: shown.length,
            ),
          ),
        ),
        if (remaining > 0)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              AppSpacing.md,
              AppSpacing.gutter,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: CardsFooter(remaining: remaining),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
      ],
    );
  }
}

/// How far the collection has got, in the one line the design gives it.
///
/// A bare `{earned} of {total}` in mono at the label step — no prose, and no
/// progress bar: the grid itself is the progress, and a second reading of it
/// above the grid says nothing the tiles do not.
///
/// It carries no title. The tab's name is the shared header's, and the design
/// never states it twice on one screen.
///
/// ⚠️ **One recorded divergence: the tracking.** The design tracks this line
/// at `0.08em`; the label rung tracks at `0.14em`, the smallcaps value it owes
/// its uppercase siblings. The ladder owns tracking precisely so a call site
/// cannot drift, so this takes the rung and the difference is written down
/// rather than spent — it is under a pixel per character at this step.
class _CollectionCount extends StatelessWidget {
  const _CollectionCount({required this.list});

  final List<CardWithCollection> list;

  @override
  Widget build(BuildContext context) {
    final count = '${earnedCount(list)} of ${list.length}';

    return Text(
      // Uppercased here rather than authored so, because the case is the
      // design's treatment of the line, not part of what it says — which is
      // also why the spoken label below keeps its own.
      count.toUpperCase(),
      style: AppText.label(mood: context.mood, face: AppFace.mono),
      semanticsLabel: '$count cards collected',
    );
  }
}
