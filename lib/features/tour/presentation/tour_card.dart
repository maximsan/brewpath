import 'package:brew_path/features/tour/domain/tour_step.dart';
import 'package:brew_path/features/tour/presentation/tour_card_controls.dart';
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

  /// The stop the card is explaining.
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
              TourCardControls(
                step: step,
                onSkip: onSkip,
                onAdvance: onAdvance,
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
