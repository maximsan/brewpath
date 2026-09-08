import 'package:brew_path/features/tour/domain/tour_copy.dart';
import 'package:brew_path/features/tour/domain/tour_step.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';

/// The row along the foot of a Tour card: Skip, the step dots, and the button
/// that moves the Tour on.
class TourCardControls extends StatelessWidget {
  /// Creates the controls for [step].
  const TourCardControls({
    required this.step,
    required this.onSkip,
    required this.onAdvance,
    super.key,
  });

  /// The stop whose card this row sits on.
  final TourStep step;

  /// Ends the Tour without finishing it.
  final VoidCallback onSkip;

  /// Moves to the next stop, or ends the Tour on the last.
  final VoidCallback onAdvance;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Spelled apart from the intro overlay's decline even though the word
        // is the same: one answers the offer, the other abandons a run.
        Semantics(
          label: TourCopy.stopSkipSemanticLabel,
          child: TextButton(
            onPressed: onSkip,
            style: TextButton.styleFrom(
              padding: OffTokens.tourSkipPadding.value,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              TourCopy.stopSkip,
              style: AppText.support(
                color: mood.inkMute,
                face: AppFace.control,
              ),
            ),
          ),
        ),
        _Dots(current: step, mood: mood),
        FilledButton(
          onPressed: onAdvance,
          style: FilledButton.styleFrom(
            backgroundColor: mood.accent,
            padding: OffTokens.tourAdvancePadding.value,
            // The design's `borderRadius: 999`. Named rather than inherited:
            // the app's button theme rounds to the chrome radius, which would
            // quietly make the design's one stadium button a soft rectangle.
            shape: const StadiumBorder(),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            step.isLast ? TourCopy.stopDone : TourCopy.stopNext,
            style: AppText.support(
              color: mood.accentInk,
              face: AppFace.control,
            ),
          ),
        ),
      ],
    );
  }
}

/// One dot per stop, the current one in the accent.
///
/// Hidden from assistive technology: the counter above the card's title says
/// the same thing in words, and four unlabelled dots say nothing when read
/// aloud.
class _Dots extends StatelessWidget {
  const _Dots({required this.current, required this.mood});

  final TourStep current;
  final MoodColors mood;

  @override
  Widget build(BuildContext context) {
    final size = OffTokens.tourStepDotSize.value;
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final step in TourStep.values) ...[
            // The design sets the gap to the dot's own width.
            if (step.index > 0) SizedBox(width: size),
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: step == current ? mood.accent : mood.rule,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
