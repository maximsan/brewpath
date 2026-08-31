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
///
/// The **tile** is untouched and still diverges — a locked one draws `???`
/// where the design draws the card's place in the set. That is #434's, and it
/// matters more now than it did: there is exactly one locked tile on screen,
/// and it is the next card the learner will earn.
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
        // Excluded rather than merged, as the mini-game player's error branch
        // has it: the raw exception is not a sentence, and reading it after
        // the label says the failure twice. ⚠️ Safe only while no retry is
        // offered — `ErrorView` grows a Retry button when handed `onRetry`,
        // and this would silence it.
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
          // The design opens both the header block and the grid below it at 24
          // from what precedes them.
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.lg,
            AppSpacing.gutter,
            AppSpacing.lg,
          ),
          sliver: SliverToBoxAdapter(
            child: _CollectionCount(
              earned: earnedCount(list),
              total: list.length,
            ),
          ),
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
/// The design does give this screen a large `Collection` title — paired with a
/// header that is *invisible* until the tab scrolls. The app's header draws at
/// rest, so the pair cannot be had here yet; #441 owns that, and the title
/// comes back with it.
///
/// Its tracking is the design's own rather than the rung's — see
/// [AppTracking.meta] for why a figure does not want the smallcaps value.
class _CollectionCount extends StatelessWidget {
  const _CollectionCount({required this.earned, required this.total});

  /// How many cards the learner holds.
  final int earned;

  /// How many there are to hold.
  final int total;

  @override
  Widget build(BuildContext context) {
    final count = '$earned of $total';
    // A figure rather than a kicker: at the rung's smallcaps 0.14em the
    // numerals drift apart and the line stops reading as one count.
    final style = AppText.label(
      mood: context.mood,
      face: AppFace.mono,
      tracking: AppTracking.meta,
    );

    return Text(
      // Uppercased here rather than authored so, because the case is the
      // design's treatment of the line, not part of what it says — which is
      // also why the spoken label below keeps its own.
      count.toUpperCase(),
      style: style,
      semanticsLabel: '$count cards collected',
    );
  }
}
