import 'package:brew_path/app/tab_large_title.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/widgets/error_view.dart';
import 'package:brew_path/core/widgets/loading_indicator.dart';
import 'package:brew_path/features/cards/domain/cards_grid.dart';
import 'package:brew_path/features/cards/domain/cards_providers.dart';
import 'package:brew_path/features/cards/presentation/card_grid_item_widget.dart';
import 'package:brew_path/features/cards/presentation/cards_footer.dart';
import 'package:brew_path/l10n/app_strings.dart';
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
/// One flat grid: what has been earned, one locked card as a teaser, and a
/// footer naming the rest (#396); `cards_grid.dart` decides what is drawn. A
/// locked tile still draws `???` where the design draws the card's place in
/// the set, which is #434's.
class CardsScreen extends ConsumerWidget {
  /// Creates a [CardsScreen].
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(cardsWithCollectionProvider);

    return Scaffold(
      body: cards.when(
        loading: () => Semantics(
          label: context.strings.cardsLoading,
          child: const LoadingIndicator(),
        ),
        // Excluded rather than merged, as the mini-game player's error branch
        // has it: the raw exception is not a sentence, and reading it after
        // the label says the failure twice. ⚠️ Safe only while no retry is
        // offered — `ErrorView` grows a Retry button when handed `onRetry`,
        // and this would silence it.
        error: (error, _) => Semantics(
          label: context.strings.cardsLoadFailed,
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
          // The design opens the grid below this block at 24. No room at
          // the top: `TabLargeTitle` leaves it.
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            0,
            AppSpacing.gutter,
            AppSpacing.lg,
          ),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TabLargeTitle(AppRoutes.cards),
                const SizedBox(height: AppSpacing.xs),
                _CollectionCount(
                  earned: earnedCount(list),
                  total: list.length,
                ),
              ],
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
              (context, index) => CardGridItemWidget(placed: shown[index]),
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
/// A bare count in mono at the label step: the grid itself is the progress. No
/// title of its own — the tab's `TabLargeTitle` says the word once (#441). Its
/// tracking is the design's rather than the rung's; [AppTracking.meta] says
/// why a figure does not want the smallcaps value.
class _CollectionCount extends StatelessWidget {
  const _CollectionCount({required this.earned, required this.total});

  /// How many cards the learner holds.
  final int earned;

  /// How many there are to hold.
  final int total;

  @override
  Widget build(BuildContext context) {
    final count = '$earned of $total';
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
