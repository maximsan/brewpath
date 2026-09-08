import 'package:brew_path/core/widgets/fade_up.dart';
import 'package:brew_path/features/lessons/presentation/cards/tastefix_reaction.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';

/// What the design's Balanced state says once the cup is fixed.
const String tastefixBalancedLabel = 'Balanced';

/// How much of the chip's own colour fills it — `var(--berry) 13%`.
const double _symptomFill = 0.13;

/// The Balanced chip's fill — `var(--sage) 16%`, a shade stronger.
const double _balancedFill = 0.16;

/// What the cup tastes of, as the design's berry chips — or the sage Balanced
/// chip that replaces the whole row once a fix works.
///
/// The row is the reaction, not decoration: a fix that fails dims the symptoms
/// it was meant to relieve, so the cup reads as worse before the words say so.
class TastefixSymptoms extends StatelessWidget {
  /// Creates a [TastefixSymptoms] for [tags], drawn for [reaction].
  const TastefixSymptoms({
    required this.tags,
    required this.reaction,
    super.key,
  });

  /// The symptoms, as the round authored them (`SOUR`, `THIN`).
  final List<String> tags;

  /// How the cup answered the fix.
  final TastefixReaction reaction;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    if (reaction.isBalanced) {
      return Semantics(
        label: 'Result: $tastefixBalancedLabel',
        excludeSemantics: true,
        child: FadeUp(
          child: _Chip(
            text: tastefixBalancedLabel,
            tint: mood.sage,
            fill: _balancedFill,
          ),
        ),
      );
    }

    return Semantics(
      label: 'Tastes: ${tags.join(', ')}',
      excludeSemantics: true,
      child: Wrap(
        spacing: OffTokens.tastefixChipGap.value,
        runSpacing: OffTokens.tastefixChipGap.value,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final tag in tags)
            AnimatedOpacity(
              opacity: reaction.isWorsened ? tastefixDimmedOpacity : 1,
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : tastefixDimDuration,
              child: _Chip(text: tag, tint: mood.berry, fill: _symptomFill),
            ),
        ],
      ),
    );
  }
}

/// One pill: the word in its own colour over a wash of the same.
class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.tint, required this.fill});

  final String text;
  final Color tint;
  final double fill;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: OffTokens.tastefixChipPadding.value,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: fill),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        text.toUpperCase(),
        style: AppText.label(
          face: AppFace.mono,
          color: tint,
          tracking: AppTracking.tag,
        ),
      ),
    );
  }
}
