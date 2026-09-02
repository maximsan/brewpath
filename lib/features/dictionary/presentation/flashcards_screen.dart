import 'dart:async';

import 'package:brew_path/app/day_surfaces.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/utils/module_icons.dart';
import 'package:brew_path/core/widgets/drill_results_view.dart';
import 'package:brew_path/core/widgets/error_view.dart';
import 'package:brew_path/core/widgets/loading_indicator.dart';
import 'package:brew_path/core/widgets/roast_meter.dart';
import 'package:brew_path/features/dictionary/domain/flashcard_completion.dart';
import 'package:brew_path/features/dictionary/domain/flashcard_providers.dart';
import 'package:brew_path/features/dictionary/domain/flashcard_round.dart';
import 'package:brew_path/features/dictionary/domain/vocab_providers.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_category_mark.dart';
import 'package:brew_path/features/dictionary/presentation/flashcard_deal_view.dart';
import 'package:brew_path/features/dictionary/presentation/flashcards_copy.dart';
import 'package:brew_path/features/dictionary/presentation/flashcards_empty_view.dart';
import 'package:brew_path/features/lessons/domain/card_seed.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The flashcards drill: the learner's saved terms, one card at a time.
///
/// The deck is watched rather than snapshotted at open, so un-saving a term —
/// here or on another device — takes it out of the round while the round is
/// running. Every move reconciles against the deck first, which is why the
/// round is a value: the screen holds where the learner is, and the deck says
/// what is still there to be.
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

  /// Null until the first deck arrives to be dealt.
  FlashcardRound? _round;

  /// Whether this review has been written down. Cleared by a fresh deal,
  /// because going again is a second review.
  bool _recorded = false;

  /// The round as it stands against a deck of [size], reconciled.
  ///
  /// Derived rather than read, so `build` never writes: a deck that shrank
  /// while the drill sat idle is answered for at the next paint, and every
  /// move below starts from the same reconciled value.
  FlashcardRound _roundFor(int size) =>
      (_round ?? FlashcardRound.deal(size, nonce: _nonce)).reconciled(size);

  void _shuffle(int size) => setState(() {
    _nonce = mintLessonNonce();
    _round = FlashcardRound.deal(size, nonce: _nonce);
    _recorded = false;
  });

  void _flip(int size) => setState(() => _round = _roundFor(size).flipped());

  void _back(int size) => setState(() => _round = _roundFor(size).back());

  /// Steps on — and, when that ends the review, writes it down.
  ///
  /// The write lives on the transition rather than on the render, so it
  /// happens once because it is reached once: `forward` is the only way to
  /// [FlashcardRound.isFinished], and there is no step past it.
  void _forward(int size) {
    final next = _roundFor(size).forward();
    setState(() => _round = next);
    if (next.isFinished) _recordReview();
  }

  /// Records one finished review. Guarded as well as placed, because Shuffle
  /// can return to the finish without a fresh deal in between.
  void _recordReview() {
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
    final pools = ref.watch(vocabPoolsProvider);
    final deck = ref.watch(flashcardDeckProvider);
    final cards = deck.asData?.value ?? const <DictionaryTerm>[];
    final round = _roundFor(cards.length);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const IconMark(AppIcon.close),
          tooltip: 'Close',
          onPressed: _close,
        ),
        title: _meter(round),
        actions: [
          // Only worth offering when there is more than one order to deal.
          if (cards.length > 1 && !round.isFinished)
            IconButton(
              // `rematch` — "run it back" — rather than the design's own
              // shuffle glyph, which the icon set does not carry. The mark
              // means the same act here, and the extractor owns the catalog:
              // hand-drawing a seventy-fourth icon is how a set stops being
              // the design's.
              icon: const IconMark(AppIcon.rematch),
              tooltip: FlashcardsCopy.shuffle,
              onPressed: () => _shuffle(cards.length),
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
        data: (cards) => _body(
          cards,
          round,
          pools.asData?.value.categoryLabels ?? const {},
          isOutOfReach: pools.asData?.value.savedIsOutOfReach ?? false,
        ),
      ),
    );
  }

  /// The position counter — held at the full count on the finished state,
  /// which is where the design leaves it.
  Widget? _meter(FlashcardRound round) {
    if (round.length == 0) return null;
    final card = round.isFinished ? round.length : round.position + 1;
    return RoastMeter(
      position: card,
      total: round.length,
      semanticsLabel: 'Card $card of ${round.length}',
    );
  }

  Widget _body(
    List<DictionaryTerm> cards,
    FlashcardRound round,
    Map<String, String> categoryLabels, {
    required bool isOutOfReach,
  }) {
    if (cards.isEmpty) {
      return FlashcardsEmptyView(isOutOfReach: isOutOfReach);
    }

    if (round.isFinished) {
      return DrillResultsView.counted(
        headline: '${cards.length}',
        note: FlashcardsCopy.reviewedNote(cards.length),
        message: FlashcardsCopy.resultsMessage,
        primary: (
          label: FlashcardsCopy.goAgain,
          onPressed: () => _shuffle(cards.length),
        ),
        secondary: (label: FlashcardsCopy.done, onPressed: _close),
      );
    }

    final term = cards[round.card];
    return FlashcardDealView(
      term: term,
      category: _categoryOf(categoryLabels, term),
      round: round,
      deckSize: cards.length,
      onFlip: () => _flip(cards.length),
      onPrevious: round.isOnFirst ? null : () => _back(cards.length),
      onNext: () => _forward(cards.length),
      onOpenEntry: () => unawaited(context.pushDictionaryTerm(term.id)),
    );
  }

  /// [term]'s category, or [DictionaryCategoryMark.unresolved] before the
  /// labels have resolved — a card is worth more than the kicker over it.
  DictionaryCategoryMark _categoryOf(
    Map<String, String> labels,
    DictionaryTerm term,
  ) {
    final label = labels[term.categoryId];
    return label == null
        ? DictionaryCategoryMark.unresolved
        : DictionaryCategoryMark(
            label: label,
            mark: moduleMark(term.categoryId),
          );
  }
}
