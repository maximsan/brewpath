import 'dart:async';

import 'package:brew_path/core/widgets/flip_geometry.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_category_mark.dart';
import 'package:brew_path/features/dictionary/presentation/flashcard_face.dart';
import 'package:brew_path/features/dictionary/presentation/flashcards_copy.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:flutter/material.dart';

/// The design's `transition: transform 480ms`.
const Duration flashcardFlipDuration = Duration(milliseconds: 480);

/// The design's `cubic-bezier(0.34, 1.1, 0.4, 1)` — a turn that overshoots a
/// little, so the card settles rather than stops dead.
const Cubic flashcardFlipCurve = Cubic(0.34, 1.1, 0.4, 1);

/// The design's `perspective: 1400px`, as the depth term of a 3D transform.
const double _flashcardPerspective = 1 / 1400;

/// One card, turning over when it is tapped.
///
/// **The whole card is the button.** The design puts the tap on the card
/// rather than under it, which is also what makes the drill work one-handed:
/// a learner flipping through twelve terms should never have to aim.
class FlashcardView extends StatefulWidget {
  /// Creates a [FlashcardView].
  const FlashcardView({
    required this.term,
    required this.category,
    required this.isRevealed,
    required this.onFlip,
    super.key,
  });

  /// The term this card carries.
  final DictionaryTerm term;

  /// The category it sits in — its name and its mark.
  final DictionaryCategoryMark category;

  /// Whether the definition is the side showing.
  final bool isRevealed;

  /// Turns the card over.
  final VoidCallback onFlip;

  @override
  State<FlashcardView> createState() => _FlashcardViewState();
}

class _FlashcardViewState extends State<FlashcardView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: flashcardFlipDuration,
    value: flipRestValue(showingBack: widget.isRevealed),
  );

  late final Animation<double> _turn = CurvedAnimation(
    parent: _controller,
    curve: flashcardFlipCurve,
  );

  @override
  void didUpdateWidget(FlashcardView old) {
    super.didUpdateWidget(old);
    if (old.isRevealed == widget.isRevealed) return;
    _turnTo(widget.isRevealed);
  }

  /// Turns to the named side — or, with animations off, is simply already
  /// there. A reduced-motion learner still gets both faces; what they do not
  /// get is half a second of a card edge-on.
  void _turnTo(bool showingBack) {
    final rest = flipRestValue(showingBack: showingBack);
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = rest;
      return;
    }
    // The turn is not awaited: the card is already showing the right face by
    // the time it settles, and a caller waiting on the animation would be
    // waiting on nothing it can act upon.
    unawaited(_controller.animateTo(rest));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final term = widget.term;

    return Semantics(
      button: true,
      // The label is the side being read; the hint is what a press does. Said
      // the other way round, a screen reader announces "tap to reveal" over
      // and over and never reads the card.
      label: widget.isRevealed
          ? '${term.term}. ${term.shortExplanation}'
          : term.term,
      hint: widget.isRevealed
          ? FlashcardsCopy.tapToSeeTerm
          : FlashcardsCopy.tapToReveal,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: widget.onFlip,
        child: AnimatedBuilder(
          animation: _turn,
          builder: (context, _) => _turned(context, term),
        ),
      ),
    );
  }

  Widget _turned(BuildContext context, DictionaryTerm term) {
    final progress = _turn.value;
    final showsBack = flipShowsBack(progress);

    return Transform(
      alignment: Alignment.center,
      transform: flipTransform(
        progress: progress,
        perspective: _flashcardPerspective,
      ),
      // Only one face is ever built. Both would occupy the same box, and the
      // one behind is seen mirror-imaged through the rest of the turn — what
      // the design's `backface-visibility: hidden` prevents and Flutter has no
      // equivalent of.
      child: showsBack
          // The back is drawn already turned, so it reads the right way round
          // once the card carrying it has finished its own half-turn.
          ? Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..rotateY(flipAngle(flipTurnedOver)),
              child: FlashcardBack(
                category: widget.category,
                term: term.term,
                definition: term.shortExplanation,
              ),
            )
          : FlashcardFront(
              category: widget.category,
              term: term.term,
              pronunciation: term.pronunciation,
            ),
    );
  }
}
