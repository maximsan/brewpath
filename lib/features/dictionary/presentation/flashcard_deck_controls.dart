import 'package:brew_path/core/widgets/focus_revealed_button.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/features/dictionary/presentation/flashcards_copy.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// What is left under the deck once Prev and Next are gone.
///
/// One focus-revealed control per direction and, on the last card, Finish.
/// The stack's slivers are decorative and hidden from assistive technology, so
/// a forward-only affordance would leave those users with no way back.
class FlashcardDeckControls extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final mood = context.mood;
    final ring = Color.lerp(mood.rule, mood.accent, _ringShare)!;

    return Row(
      children: [
        if (!isOnFirst)
          Expanded(
            child: FocusRevealedButton(
              label: FlashcardsCopy.previousCard,
              ring: ring,
              height: revealedHeight,
              onPressed: onPrevious,
            ),
          ),
        if (!isOnFirst) const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: isOnLast
              ? PrimaryButton(
                  label: FlashcardsCopy.finish,
                  onPressed: onNext,
                )
              : FocusRevealedButton(
                  label: FlashcardsCopy.nextCard,
                  ring: ring,
                  height: revealedHeight,
                  onPressed: onNext,
                ),
        ),
      ],
    );
  }
}
