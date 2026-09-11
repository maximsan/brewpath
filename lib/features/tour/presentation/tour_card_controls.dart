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
            // Gone on the last stop, where Done is the only way out.
            child: step.isLast
                ? const SizedBox.shrink()
                : Semantics(
                    label: TourCopy.stopSkipSemanticLabel,
                    child: _TourPill(
                      label: TourCopy.stopSkip,
                      fill: mood.surface2,
                      ink: mood.ink,
                      padding: OffTokens.tourSkipPadding.value,
                      edge: mood.rule,
                      onPressed: onSkip,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _Dots(current: step, mood: mood),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: _TourPill(
              label: step.isLast ? TourCopy.stopDone : TourCopy.stopNext,
              fill: mood.accent,
              ink: mood.accentInk,
              padding: OffTokens.tourAdvancePadding.value,
              onPressed: onAdvance,
            ),
          ),
        ),
      ],
    );
  }
}

/// One of the card's two buttons — the quiet Skip, or the accent advance.
///
/// The shape is named rather than inherited: the app's button theme rounds to
/// the chrome radius, which would make the design's `borderRadius: 999` a soft
/// rectangle.
class _TourPill extends StatelessWidget {
  const _TourPill({
    required this.label,
    required this.fill,
    required this.ink,
    required this.padding,
    required this.onPressed,
    this.edge,
  });

  final String label;
  final Color fill;
  final Color ink;
  final EdgeInsets padding;

  /// The border Skip wears and the advance pill does not.
  final Color? edge;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: onPressed,
    style: FilledButton.styleFrom(
      backgroundColor: fill,
      side: switch (edge) {
        final Color color => BorderSide(color: color),
        null => null,
      },
      padding: padding,
      shape: const StadiumBorder(),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
    child: Text(
      label,
      style: AppText.support(color: ink, face: AppFace.control),
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
