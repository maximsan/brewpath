import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/dictionary/domain/flashcard_round.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_category_mark.dart';
import 'package:brew_path/features/dictionary/presentation/flashcard_view.dart';
import 'package:brew_path/features/dictionary/presentation/flashcards_copy.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// The card in front of the learner, and the two ways through the deck.
class FlashcardDealView extends StatelessWidget {
  /// Creates a [FlashcardDealView].
  const FlashcardDealView({
    required this.term,
    required this.category,
    required this.round,
    required this.deckSize,
    required this.onFlip,
    required this.onPrevious,
    required this.onNext,
    required this.onOpenEntry,
    super.key,
  });

  /// The card showing.
  final DictionaryTerm term;

  /// Its category's label and mark.
  final DictionaryCategoryMark category;

  /// Where the review has got to.
  final FlashcardRound round;

  /// How many cards the deck holds — the line over the card counts this.
  final int deckSize;

  /// Turns the card over.
  final VoidCallback onFlip;

  /// Steps back, or null on the first card.
  final VoidCallback? onPrevious;

  /// Steps on, or finishes on the last card.
  final VoidCallback onNext;

  /// Opens the term's full entry.
  final VoidCallback onOpenEntry;

  /// The design's `minHeight: 380` on the card.
  static const double _cardHeight = 380;

  /// Tall enough for the entry link, reserved whether or not it is showing so
  /// the flip never shifts the buttons under it.
  static const double _linkRowHeight = 48;

  /// The design's `opacity 200ms ease 140ms` — the link arrives *after* the
  /// turn, so it reads as the card's continuation rather than as a race.
  static const Duration _linkFade = Duration(milliseconds: 200);
  static const Duration _linkDelay = Duration(milliseconds: 140);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SmallcapsLabel(FlashcardsCopy.deckLine(deckSize)),
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
                  isRevealed: round.isRevealed,
                  onFlip: onFlip,
                ),
              ),
            ),
            _EntryLink(
              isShowing: round.isRevealed,
              onOpen: onOpenEntry,
              height: _linkRowHeight,
              fade: _linkFade,
              delay: _linkDelay,
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
                    label: round.isOnLast
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
}

/// The link to the full entry, which exists only once the definition is up.
///
/// A link to "more" before the reveal undercuts the recall the drill is for,
/// so it is not merely hidden — it is out of the tree, and out of the reading
/// order with it.
class _EntryLink extends StatelessWidget {
  const _EntryLink({
    required this.isShowing,
    required this.onOpen,
    required this.height,
    required this.fade,
    required this.delay,
  });

  final bool isShowing;
  final VoidCallback onOpen;
  final double height;
  final Duration fade;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    if (!isShowing) return SizedBox(height: height);

    final link = Center(
      child: TextButton(
        onPressed: onOpen,
        child: const Text(FlashcardsCopy.viewEntry),
      ),
    );

    return SizedBox(
      height: height,
      // Reduced motion gets the link at once rather than a slower arrival:
      // the delay exists to let the turn land, and with no turn to land there
      // is nothing to wait for.
      child: MediaQuery.disableAnimationsOf(context)
          ? link
          : _FadeIn(fade: fade, delay: delay, child: link),
    );
  }
}

/// Fades [child] in after [delay].
class _FadeIn extends StatefulWidget {
  const _FadeIn({
    required this.fade,
    required this.delay,
    required this.child,
  });

  final Duration fade;
  final Duration delay;
  final Widget child;

  @override
  State<_FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<_FadeIn> {
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    // Driven from a post-frame rebuild rather than a controller: one value,
    // one direction, and the widget is thrown away when the card turns back.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _opacity = 1);
    });
  }

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
    opacity: _opacity,
    duration: widget.fade,
    curve: Interval(
      widget.delay.inMilliseconds / (widget.delay + widget.fade).inMilliseconds,
      1,
    ),
    child: widget.child,
  );
}
