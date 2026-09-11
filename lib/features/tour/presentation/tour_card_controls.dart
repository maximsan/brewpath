import 'package:brew_path/features/tour/domain/tour_copy.dart';
import 'package:brew_path/features/tour/domain/tour_step.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';

/// The row along the foot of a Tour card: Skip, the step dots, and the button
/// that moves the Tour on.
///
/// Three slots, the dots in the middle one: Skip leaves on the last stop,
/// where Done is the only way out, and the dots stay where they were.
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
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: step.isLast
                ? const SizedBox.shrink()
                : _SkipPill(mood: mood, onPressed: onSkip),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _Dots(current: step, mood: mood),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: _AdvancePill(
              label: step.isLast ? TourCopy.stopDone : TourCopy.stopNext,
              mood: mood,
              onPressed: onAdvance,
            ),
          ),
        ),
      ],
    );
  }
}

/// The way out of a running Tour: the design's quiet pill, in the surface a
/// step up from the card it sits on.
class _SkipPill extends StatelessWidget {
  const _SkipPill({required this.mood, required this.onPressed});

  final MoodColors mood;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    label: TourCopy.stopSkipSemanticLabel,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: mood.surface2,
        side: BorderSide(color: mood.rule),
        padding: OffTokens.tourSkipPadding.value,
        // The design's `borderRadius: 999`, named for the same reason the
        // advance pill names it: the app's button theme rounds to the chrome
        // radius, which would make a stadium a soft rectangle.
        shape: const StadiumBorder(),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        TourCopy.stopSkip,
        style: AppText.support(color: mood.ink, face: AppFace.control),
      ),
    ),
  );
}

/// Next, and Done on the stop the Tour ends on.
class _AdvancePill extends StatelessWidget {
  const _AdvancePill({
    required this.label,
    required this.mood,
    required this.onPressed,
  });

  final String label;
  final MoodColors mood;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: onPressed,
    style: FilledButton.styleFrom(
      backgroundColor: mood.accent,
      padding: OffTokens.tourAdvancePadding.value,
      shape: const StadiumBorder(),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
    child: Text(
      label,
      style: AppText.support(color: mood.accentInk, face: AppFace.control),
    ),
  );
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
