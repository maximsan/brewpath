import 'package:brew_path/core/widgets/focus_revealed_button.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/l10n/app_strings.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// What is left under the deck once Prev and Next are gone.
///
/// One focus-revealed control per direction and, on the last card, Finish.
/// The stack's slivers are decorative and hidden from assistive technology, so
/// a forward-only affordance would leave those users with no way back.
class FlashcardDeckControls extends StatefulWidget {
  /// Creates a [FlashcardDeckControls].
  const FlashcardDeckControls({
    required this.isOnFirst,
    required this.isOnLast,
    required this.onPrevious,
    required this.onNext,
    super.key,
  });

  /// The design's `height: kbd ? 44 : 1` on the pair.
  static const double revealedHeight = 44;

  /// The design's `color-mix(in oklab, var(--accent) 34%, var(--rule))`.
  static const double _ringShare = 0.34;

  /// Whether there is a card behind this one.
  final bool isOnFirst;

  /// Whether stepping on finishes rather than advances.
  final bool isOnLast;

  /// Steps back a card.
  final VoidCallback onPrevious;

  /// Steps on, or finishes.
  final VoidCallback onNext;

  @override
  State<FlashcardDeckControls> createState() => _FlashcardDeckControlsState();
}

class _FlashcardDeckControlsState extends State<FlashcardDeckControls> {
  bool _previousStanding = false;
  bool _nextStanding = false;

  /// A control's share of the row — the design's `flex: kbd ? 1 : '0 0 1px'`.
  ///
  /// Collapsed, it takes no room, so Finish has the whole row on the last
  /// card; standing, it splits the row with whatever is beside it.
  Widget _share({required bool standing, required Widget child}) =>
      Flexible(flex: standing ? 1 : 0, fit: FlexFit.tight, child: child);

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final ring = Color.lerp(
      mood.rule,
      mood.accent,
      FlashcardDeckControls._ringShare,
    )!;

    return Row(
      children: [
        if (!widget.isOnFirst) ...[
          _share(
            standing: _previousStanding,
            child: FocusRevealedButton(
              label: context.strings.flashcardsPreviousCard,
              ring: ring,
              height: FlashcardDeckControls.revealedHeight,
              onPressed: widget.onPrevious,
              onFocusChange: (standing) =>
                  setState(() => _previousStanding = standing),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
        if (widget.isOnLast)
          Expanded(
            child: PrimaryButton(
              label: context.strings.flashcardsFinish,
              onPressed: widget.onNext,
            ),
          )
        else
          _share(
            standing: _nextStanding,
            child: FocusRevealedButton(
              label: context.strings.flashcardsNextCard,
              ring: ring,
              height: FlashcardDeckControls.revealedHeight,
              onPressed: widget.onNext,
              onFocusChange: (standing) =>
                  setState(() => _nextStanding = standing),
            ),
          ),
      ],
    );
  }
}
