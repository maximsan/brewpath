import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/profile/presentation/widgets/profile_card.dart';
import 'package:brew_path/features/progress/domain/mastery_rollup.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Mastery's permanent home: how many lessons are solid, how many want another
/// run, and a way through to the Path to do it.
///
/// The moment of earning shows mastery once and then it is gone; the design
/// gives it a card here.
///
/// **Two states, not three.** The fold is [rollUpMastery]'s — Perfect and Solid
/// are both *solid*, because the design's bar has two colours.
class LessonProgressRollup extends StatelessWidget {
  /// Creates a [LessonProgressRollup].
  const LessonProgressRollup({
    required this.rollup,
    required this.onPractice,
    super.key,
  });

  /// The course, split into the design's two states.
  final MasteryRollup rollup;

  /// Opens the Path, where a weak lesson can be practised.
  final VoidCallback onPractice;

  /// The segmented bar's thickness.
  static const double _barHeight = 8;

  /// The hairline the design draws between segments, so two touching bands
  /// read as two rather than as a gradient.
  static const double _segmentGap = 1.5;

  /// The legend's dots.
  static const double _dotSize = 8;

  /// Gap between the two legend entries — the design's 16.
  static const double _legendGap = AppSpacing.md;

  /// Gap between a legend dot and its words — the design's 6.
  static const double _dotGap = AppSpacing.xxs + 2;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return ProfileCard(
      radius: ProfileCard.cardRadius,
      onTap: onPractice,
      semanticLabel:
          'Lesson progress. ${rollup.completed} of ${rollup.total} done, '
          '${rollup.solid} solid, ${rollup.needsPractice} need practice.',
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Expanded(child: SmallcapsLabel('Lesson progress')),
                    // Finished lessons, not scored ones — the same count the
                    // hero above shows.
                    Text(
                      '${rollup.completed} / ${rollup.total} DONE',
                      style: AppText.label(mood: mood, face: AppFace.mono),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                _SegmentedBar(rollup: rollup),
                const SizedBox(height: AppSpacing.sm),
                _Legend(rollup: rollup),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          IconMark(AppIcon.chevron, color: mood.inkMute),
        ],
      ),
    );
  }
}

/// The bar: solid, then needs-practice, then the unplayed remainder.
class _SegmentedBar extends StatelessWidget {
  const _SegmentedBar({required this.rollup});

  final MasteryRollup rollup;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final remainder = rollup.remainder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: SizedBox(
        height: LessonProgressRollup._barHeight,
        child: ColoredBox(
          color: mood.bg,
          child: Row(
            children: [
              if (rollup.solid > 0)
                Expanded(
                  flex: rollup.solid,
                  child: _Segment(color: mood.sage),
                ),
              if (rollup.needsPractice > 0)
                Expanded(
                  flex: rollup.needsPractice,
                  child: _Segment(color: mood.accent),
                ),
              if (remainder > 0) Spacer(flex: remainder),
            ],
          ),
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        border: Border(
          right: BorderSide(
            color: context.mood.surface,
            width: LessonProgressRollup._segmentGap,
          ),
        ),
      ),
      child: const SizedBox.expand(),
    );
  }
}

/// `N solid · N need practice`, the second muted when there is nothing to
/// practise — the design dims it rather than hiding it, so the pair stays a
/// pair.
class _Legend extends StatelessWidget {
  const _Legend({required this.rollup});

  final MasteryRollup rollup;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    // Flexible rather than fixed: the design sets both entries `nowrap`, which
    // on a narrow phone overflows rather than wrapping. Letting them share the
    // width keeps the pair on one line, which is the part that matters.
    return Row(
      children: [
        Flexible(
          child: _LegendEntry(
            color: mood.sage,
            count: rollup.solid,
            label: 'solid',
            ink: mood.ink,
          ),
        ),
        const SizedBox(width: LessonProgressRollup._legendGap),
        Flexible(
          child: _LegendEntry(
            color: mood.accent,
            count: rollup.needsPractice,
            label: 'need practice',
            ink: rollup.needsPractice > 0 ? mood.ink : mood.inkMute,
          ),
        ),
      ],
    );
  }
}

class _LegendEntry extends StatelessWidget {
  const _LegendEntry({
    required this.color,
    required this.count,
    required this.label,
    required this.ink,
  });

  final Color color;
  final int count;
  final String label;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: LessonProgressRollup._dotSize,
          height: LessonProgressRollup._dotSize,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
        ),
        const SizedBox(width: LessonProgressRollup._dotGap),
        // The design sets the number in the control face and the word in the
        // body one, so the count carries the line.
        Flexible(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$count',
                  style: AppText.support(color: ink, face: AppFace.control),
                ),
                TextSpan(text: ' $label'),
              ],
            ),
            style: AppText.support(color: ink),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
