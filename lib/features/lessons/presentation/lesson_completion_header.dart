import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The completion headline: a smallcaps kicker, **the lesson's own name**, and
/// the run's score.
///
/// **The name is the headline.** The app used to make `Lesson complete!` the
/// title and never say which lesson it was — the eyebrow says what happened,
/// and the h1 says what it happened to (`prototype/rewards.jsx:50-56`).
class LessonCompletionHeader extends StatelessWidget {
  /// Creates a [LessonCompletionHeader].
  const LessonCompletionHeader({
    required this.eyebrow,
    required this.title,
    required this.mastery,
    super.key,
  });

  /// The kicker over the title — what this run was.
  final String eyebrow;

  /// The lesson's own name.
  final String title;

  /// The run's graded result. An unscored one draws no score line.
  final MasteryResult mastery;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SmallcapsLabel(eyebrow),
        const SizedBox(height: AppSpacing.xs),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppText.title(mood: mood),
        ),
        if (mastery.isScored) ...[
          const SizedBox(height: AppSpacing.base),
          _ScoreLine(mastery: mastery),
        ],
      ],
    );
  }
}

/// The score, and the chip beside it when the run earned one.
class _ScoreLine extends StatelessWidget {
  const _ScoreLine({required this.mastery});

  final MasteryResult mastery;

  /// The dot that parts the score from the chip.
  static const double _dotSize = 3;

  /// How present that dot is — the design's `opacity: 0.6`.
  static const double _dotOpacity = 0.6;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final chip = MasteryChip.forBand(mastery.band);
    return Semantics(
      label: 'Scored ${mastery.correct} out of ${mastery.total}',
      excludeSemantics: chip == null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${mastery.correct} / ${mastery.total}',
            style: AppText.body(
              mood: mood,
              color: mood.ink,
              face: AppFace.mono,
            ),
          ),
          if (chip != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Container(
              width: _dotSize,
              height: _dotSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: mood.inkMute.withValues(alpha: _dotOpacity),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            chip,
          ],
        ],
      ),
    );
  }
}

/// The mastery chip — **only a weak run earns one**.
///
/// The design says why in as many words: the score above it already reports
/// how the run went, so a chip on a good run adds nothing. And it wears the
/// action colour rather than a failure red, *"because it is an invitation to
/// replay, never a failure"* — which is the same colour as the
/// "Practice this lesson again" link it is paired with.
class MasteryChip extends StatelessWidget {
  /// Creates a [MasteryChip].
  const MasteryChip({required this.band, super.key});

  /// The chip for [band], or null for a band the design gives no chip.
  static MasteryChip? forBand(MasteryBand? band) =>
      band == MasteryBand.needsPractice ? MasteryChip(band: band!) : null;

  /// The band the chip names.
  final MasteryBand band;

  /// How much accent washes the chip's fill, over the page.
  static const double _fillTint = 0.12;

  /// How much accent the chip's hairline carries, over the structural rule.
  static const double _borderTint = 0.4;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          mood.accent.withValues(alpha: _fillTint),
          mood.surface,
        ),
        border: Border.all(
          color: Color.alphaBlend(
            mood.accent.withValues(alpha: _borderTint),
            mood.rule,
          ),
        ),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: SmallcapsLabel(band.label, color: mood.accentText),
    );
  }
}
