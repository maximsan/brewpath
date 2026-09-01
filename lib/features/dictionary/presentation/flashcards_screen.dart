import 'dart:async';

import 'package:brew_path/app/day_surfaces.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/drill_results_view.dart';
import 'package:brew_path/core/widgets/error_view.dart';
import 'package:brew_path/core/widgets/loading_indicator.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/core/widgets/roast_meter.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/dictionary/domain/dictionary_providers.dart';
import 'package:brew_path/features/dictionary/domain/flashcard_completion.dart';
import 'package:brew_path/features/dictionary/domain/flashcard_deck.dart';
import 'package:brew_path/features/dictionary/domain/flashcard_providers.dart';
import 'package:brew_path/features/dictionary/presentation/flashcard_view.dart';
import 'package:brew_path/features/dictionary/presentation/flashcards_copy.dart';
import 'package:brew_path/features/dictionary/presentation/flashcards_empty_view.dart';
import 'package:brew_path/features/lessons/domain/card_seed.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The flashcards drill: the learner's saved terms, one card at a time.
///
/// The deck is watched rather than snapshotted at open, so un-saving a term —
/// here or on another device — takes it out of the round while the round is
/// running. That is the case the deal is reconciled for on every build: the
/// order is state, the deck is not.
///
/// Results are a state of this screen rather than a route of their own, for
/// the same reason a mini-game's are: the count never outlives the review.
class FlashcardsScreen extends ConsumerStatefulWidget {
  /// Creates a [FlashcardsScreen].
  const FlashcardsScreen({super.key});

  @override
  ConsumerState<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends ConsumerState<FlashcardsScreen> {
  /// The deal's seed. Re-minted by Shuffle, and by going again.
  int _nonce = mintLessonNonce();

  /// Display position → deck index, reconciled against the deck on every
  /// build. Null until the first build has a deck to deal.
  List<int>? _order;

  int _position = 0;
  bool _isRevealed = false;
  bool _isFinished = false;

  /// Whether this review has already been written down. Reset by a fresh deal,
  /// because going again is a second review.
  bool _recorded = false;

  /// Deals [size] cards afresh and puts the learner at the first of them.
  void _deal(int size) {
    _nonce = mintLessonNonce();
    _order = flashcardDeal(size, nonce: _nonce);
    _position = 0;
    _isRevealed = false;
    _isFinished = false;
    _recorded = false;
  }

  void _shuffle(int size) => setState(() => _deal(size));

  void _flip() => setState(() => _isRevealed = !_isRevealed);

  /// Moves [step] cards through the deck, closing the card behind.
  ///
  /// Stepping forward off the last card finishes the review; there is no way
  /// to step past it, so the finish is reached exactly once per deal.
  void _move(int step, int size) => setState(() {
    _isRevealed = false;
    if (step > 0 && _position >= size - 1) {
      _isFinished = true;
      return;
    }
    _position = (_position + step).clamp(0, size - 1);
  });

  /// Writes the finished review down — once per deal.
  ///
  /// A review that is abandoned never reaches the finish, so it writes
  /// nothing: the entry is the fact that every card was seen.
  void _recordReviewOnce() {
    if (_recorded) return;
    _recorded = true;
    unawaited(
      recordFlashcardReview(
        ref.read(snapshotRepositoryProvider),
        DateTime.now(),
      ).then((_) {
        if (!mounted) return;
        // The review may have marked the day and met Keep Sharp's rule, and
        // everything that reads the day is derived — so the surfaces under
        // this one have to be told to look again.
        invalidateDaySurfaces(ref);
      }),
    );
  }

  /// Leaves the drill for wherever it was opened from.
  void _close() => context.pop();

  @override
  Widget build(BuildContext context) {
    final deck = ref.watch(flashcardDeckProvider);
    final view = ref.watch(dictionaryViewProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const IconMark(AppIcon.close),
          tooltip: 'Close',
          onPressed: _close,
        ),
        title: _meter(deck.asData?.value.length ?? 0),
        actions: [
          // Only worth offering when there is more than one order to deal.
          if ((deck.asData?.value.length ?? 0) > 1 && !_isFinished)
            IconButton(
              // `rematch` — "run it back" — rather than the design's own
              // shuffle glyph, which the icon set does not carry. The mark
              // means the same act here, and the extractor owns the catalog:
              // hand-drawing a seventy-fourth icon is how a set stops being
              // the design's.
              icon: const IconMark(AppIcon.rematch),
              tooltip: FlashcardsCopy.shuffle,
              onPressed: () => _shuffle(deck.requireValue.length),
            ),
        ],
      ),
      body: deck.when(
        loading: () => Semantics(
          label: 'Loading your deck',
          child: const LoadingIndicator(),
        ),
        error: (error, _) => Semantics(
          label: 'Your deck could not be loaded',
          child: ErrorView(message: '$error'),
        ),
        data: (cards) => _body(cards, view.asData?.value),
      ),
    );
  }

  /// The position counter, absent when there is nothing to count through.
  Widget? _meter(int size) {
    if (size == 0 || _isFinished) return null;
    final card = _position + 1;
    return RoastMeter(
      position: card,
      total: size,
      semanticsLabel: 'Card $card of $size',
    );
  }

  Widget _body(List<DictionaryTerm> cards, DictionaryView? view) {
    if (cards.isEmpty) return const FlashcardsEmptyView();

    // Reconciled every build, never trusted: the deck can shrink under an open
    // round, and a deal holding an index past its end would throw on the next
    // card.
    final order = _order = reconcileFlashcardOrder(
      _order ?? flashcardDeal(cards.length, nonce: _nonce),
      cards.length,
    );
    final position = _position.clamp(0, order.length - 1);

    if (_isFinished) {
      _recordReviewOnce();
      return DrillResultsView(
        kicker: FlashcardsCopy.resultsKicker,
        value: '${cards.length}',
        note: FlashcardsCopy.reviewedNote(cards.length),
        message: FlashcardsCopy.resultsMessage,
        primaryLabel: FlashcardsCopy.goAgain,
        onPrimary: () => _shuffle(cards.length),
        secondaryLabel: FlashcardsCopy.done,
        onSecondary: _close,
      );
    }

    final term = cards[order[position]];
    return _Deal(
      term: term,
      category: _categoryLabel(view, term),
      cards: cards.length,
      position: position,
      isRevealed: _isRevealed,
      onFlip: _flip,
      onPrevious: position == 0 ? null : () => _move(-1, cards.length),
      onNext: () => _move(1, cards.length),
      onOpenEntry: () => unawaited(context.pushDictionaryTerm(term.id)),
    );
  }

  /// The label of [term]'s category, or its id while the view is still
  /// loading — the deck resolves first, and a card is worth more than the
  /// kicker over it.
  String _categoryLabel(DictionaryView? view, DictionaryTerm term) =>
      view?.categories
          .where((category) => category.id == term.categoryId)
          .firstOrNull
          ?.label ??
      '';
}

/// One card in the deal, and the two ways through the deck.
class _Deal extends StatelessWidget {
  const _Deal({
    required this.term,
    required this.category,
    required this.cards,
    required this.position,
    required this.isRevealed,
    required this.onFlip,
    required this.onPrevious,
    required this.onNext,
    required this.onOpenEntry,
  });

  final DictionaryTerm term;
  final String category;
  final int cards;
  final int position;
  final bool isRevealed;
  final VoidCallback onFlip;
  final VoidCallback? onPrevious;
  final VoidCallback onNext;
  final VoidCallback onOpenEntry;

  /// The design's `minHeight: 380` on the card.
  static const double _cardHeight = 380;

  bool get _isLast => position >= cards - 1;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SmallcapsLabel(FlashcardsCopy.deckLine(cards)),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: _cardHeight),
                child: FlashcardView(
                  // Keyed by term so a card never inherits the previous one's
                  // turn: without this, moving on from a revealed card shows
                  // the next term's definition already face-up.
                  key: ValueKey(term.id),
                  term: term,
                  category: category,
                  isRevealed: isRevealed,
                  onFlip: onFlip,
                ),
              ),
            ),
            // The entry link is the card's continuation, not deck chrome: it
            // appears only once the definition is showing, because a link to
            // "more" before the reveal undercuts the recall the drill is for.
            // The row keeps its height either way, so the flip never shifts
            // the buttons under it.
            SizedBox(
              height: _linkRowHeight,
              child: isRevealed
                  ? Center(
                      child: TextButton(
                        onPressed: onOpenEntry,
                        child: const Text(FlashcardsCopy.viewEntry),
                      ),
                    )
                  : null,
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onPrevious,
                    child: const Text(FlashcardsCopy.previous),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: PrimaryButton(
                    label: _isLast
                        ? FlashcardsCopy.finish
                        : FlashcardsCopy.next,
                    onPressed: onNext,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Tall enough for the link, reserved whether or not it is showing.
  static const double _linkRowHeight = 48;
}
