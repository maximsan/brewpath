import 'package:brew_path/core/swipe/horizontal_swipe.dart';
import 'package:brew_path/core/swipe/swipe_deck_stack.dart';
import 'package:brew_path/core/swipe/swipe_hint.dart';
import 'package:brew_path/core/swipe/swipe_hint_caption.dart';
import 'package:brew_path/core/swipe/swipe_surface.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/dictionary/domain/flashcard_round.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_category_mark.dart';
import 'package:brew_path/features/dictionary/presentation/flashcard_deck_controls.dart';
import 'package:brew_path/features/dictionary/presentation/flashcard_face.dart';
import 'package:brew_path/features/dictionary/presentation/flashcard_view.dart';
import 'package:brew_path/features/dictionary/presentation/flashcards_copy.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The card in front of the learner, and the deck it is walked with.
///
/// The stack behind the card **is** the affordance: a deck that looks like a
/// deck needs no button row to say it can be moved through.
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

  /// The committed card **leaves the screen** with a tilt before the next one
  /// appears: snapping back with new content inside read as a jump cut.
  ///
  /// The design's `exitDistance: 460, exitDurationMs: 260,
  /// tiltDegreesPer100px: 7`.
  static const SwipeMotion _motion = SwipeMotion(
    exitDistance: _exitDistance,
    exitDuration: Duration(milliseconds: _exitMillis),
    tiltDegreesPer100px: _tiltPer100px,
  );

  static const double _exitDistance = 460;
  static const int _exitMillis = 260;
  static const double _tiltPer100px = 7;

  /// The first-run hint's words.
  static const String _hintLabel = 'Swipe the card left for the next term';

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
  Widget build(BuildContext context) => SwipeHint(
    surface: SwipeSurface.flashcards,
    builder: (context, hint) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SmallcapsLabel(FlashcardsCopy.deckLine(deckSize)),
            const SizedBox(height: AppSpacing.md),
            Expanded(child: _deck(hint)),
            SwipeHintCaption(show: hint.showing, label: _hintLabel),
            _EntryLink(
              isShowing: round.isRevealed,
              onOpen: onOpenEntry,
              height: _linkRowHeight,
              fade: _linkFade,
              delay: _linkDelay,
            ),
            FlashcardDeckControls(
              isOnFirst: round.isOnFirst,
              isOnLast: round.isOnLast,
              onPrevious: () => _back(hint),
              onNext: () => _forward(hint),
            ),
          ],
        ),
      ),
    ),
  );

  void _forward(SwipeHintState hint) {
    hint.markUsed();
    onNext();
  }

  void _back(SwipeHintState hint) {
    hint.markUsed();
    onPrevious?.call();
  }

  /// **Point-at-target, deliberately not the drag model**: there is no card
  /// following a finger on a keyboard, so Right means forward as it does in
  /// every carousel and OS. Mapping keys to the gesture's own direction
  /// recreated the collision the deleted buttons had.
  Widget _deck(SwipeHintState hint) => CallbackShortcuts(
    bindings: {
      const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
          _forward(hint),
      const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _back(hint),
    },
    // The deck takes focus as it opens, so the arrow keys answer without the
    // learner first having to find something to tab to.
    child: Focus(
      autofocus: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: _cardHeight),
        child: SwipeNudge(
          offset: hint.offset,
          child: HorizontalSwipe(
            motion: _motion,
            // Advancing off the last card finishes, which is why this is not
            // narrowed the way the stack's own side is.
            canBack: !round.isOnFirst,
            onAdvance: () => _forward(hint),
            onBack: () => _back(hint),
            behind: (context, drag) => SwipeDeckStack(
              drag: drag,
              radius: FlashcardFace.radius,
              canAdvance: !round.isOnLast,
              canBack: !round.isOnFirst,
            ),
            builder: (context, drag) => FlashcardView(
              // Keyed by term so a card never inherits the previous one's
              // turn: without this, moving on from a revealed card shows the
              // next term's definition already face-up.
              key: ValueKey(term.id),
              term: term,
              category: category,
              isRevealed: round.isRevealed,
              onFlip: onFlip,
            ),
          ),
        ),
      ),
    ),
  );
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
