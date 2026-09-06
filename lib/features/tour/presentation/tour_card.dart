import 'package:brew_path/features/tour/domain/tour_copy.dart';
import 'package:brew_path/features/tour/domain/tour_step.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';

/// What a Tour stop says, and the two ways out of it.
///
/// Counter, title, body, then Skip on the left, the dots in the middle and
/// Next — *Done* on the last stop — on the right. The card is the Tour's whole
/// interface: the frame beside it points, and everything else on screen is
/// behind a shield.
class TourCard extends StatelessWidget {
  /// Creates the card for [step].
  const TourCard({
    required this.step,
    required this.onSkip,
    required this.onAdvance,
    super.key,
  });

  /// The design's `borderRadius: 16`. Off `AppRadii.chrome` (14) within the
  /// slack that token's own note allows a component that needs its own.
  static const double radius = 16;

  /// The design's `0 18px 44px rgba(0,0,0,0.24)`: the card floats over a dimmed
  /// page, so it needs a shadow the dim cannot flatten.
  static const List<BoxShadow> _lift = [
    BoxShadow(color: Color(0x3D000000), blurRadius: 44, offset: Offset(0, 18)),
  ];

  /// The stop on show.
  final TourStep step;

  /// Ends the Tour without finishing it.
  final VoidCallback onSkip;

  /// Moves to the next stop, or ends the Tour on the last.
  final VoidCallback onAdvance;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final lineGap = SizedBox(height: OffTokens.tourCardLineGap.value);
    return Material(
      type: MaterialType.transparency,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: mood.surface,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: mood.rule),
          boxShadow: _lift,
        ),
        child: Padding(
          padding: OffTokens.tourCardPadding.value,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Counter(step: step, mood: mood),
              lineGap,
              Text(step.title, style: AppText.heading(mood: mood)),
              lineGap,
              Text(
                step.body,
                style: AppText.support(
                  mood: mood,
                ).copyWith(height: OffTokens.tourCardBodyLeading.value),
              ),
              const SizedBox(height: AppSpacing.sm),
              _Controls(
                step: step,
                onSkip: onSkip,
                onAdvance: onAdvance,
                mood: mood,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// `N of 4`, in the design's mono smallcaps.
///
/// Uppercased here rather than in the string, the way `SmallcapsLabel` does it:
/// the case is the type rule, not part of what the counter says — so the
/// original is what assistive technology is given.
class _Counter extends StatelessWidget {
  const _Counter({required this.step, required this.mood});

  final TourStep step;
  final MoodColors mood;

  @override
  Widget build(BuildContext context) {
    final counted = '${step.position} of ${TourStep.count}';
    return Semantics(
      label: counted,
      excludeSemantics: true,
      child: Text(
        counted.toUpperCase(),
        style: AppText.label(mood: mood, face: AppFace.mono),
      ),
    );
  }
}

/// Skip, the dots, and the button that moves the Tour on.
class _Controls extends StatelessWidget {
  const _Controls({
    required this.step,
    required this.onSkip,
    required this.onAdvance,
    required this.mood,
  });

  /// Skip is text on the card rather than a filled button; the vertical stop
  /// keeps it a comfortable tap target.
  static const _skipPadding = EdgeInsets.symmetric(
    horizontal: AppSpacing.xxs,
    vertical: AppSpacing.sm,
  );

  /// The room inside the advance pill.
  static const _advancePadding = EdgeInsets.symmetric(
    horizontal: AppSpacing.md,
    vertical: AppSpacing.sm,
  );

  final TourStep step;
  final VoidCallback onSkip;
  final VoidCallback onAdvance;
  final MoodColors mood;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // Spelled apart from the intro overlay's decline even though the word is
      // the same: one answers the offer, the other abandons a run.
      TextButton(
        onPressed: onSkip,
        style: TextButton.styleFrom(
          padding: _skipPadding,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          TourCopy.stopSkip,
          style: AppText.support(color: mood.inkMute, face: AppFace.control),
        ),
      ),
      _Dots(current: step, mood: mood),
      FilledButton(
        onPressed: onAdvance,
        style: FilledButton.styleFrom(
          backgroundColor: mood.accent,
          padding: _advancePadding,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          step.isLast ? TourCopy.stopDone : TourCopy.stopNext,
          style: AppText.support(color: mood.accentInk, face: AppFace.control),
        ),
      ),
    ],
  );
}

/// One dot per stop, the current one in the accent.
///
/// Hidden from assistive technology: the counter above says the same thing in
/// words, and four unlabelled dots say nothing when read aloud.
class _Dots extends StatelessWidget {
  const _Dots({required this.current, required this.mood});

  /// The design's `width: 5, height: 5` dots, set `gap: 5` apart.
  static const double _size = 5;

  final TourStep current;
  final MoodColors mood;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final step in TourStep.values) ...[
          if (step.index > 0) const SizedBox(width: _size),
          Container(
            width: _size,
            height: _size,
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
