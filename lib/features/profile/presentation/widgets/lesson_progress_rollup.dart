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
/// gives it a card here (`prototype/screens.jsx:2645-2683`).
///
/// **Two states, not three.** The fold is [rollUpMastery]'s — Perfect and Solid
/// are both *solid*, because the design's bar has two colours.
class LessonProgressRollup extends StatelessWidget {
  /// Creates a [LessonProgressRollup].
  const LessonProgressRollup({
    required this.rollup,
    required this.total,
    required this.onPractice,
    super.key,
  });

  /// The design's radius for the cards under the hero.
  static const double _radius = 16;

  /// The segmented bar's thickness.
  static const double _barHeight = 8;

  /// The hairline the design draws between segments, so two touching bands
  /// read as two rather than as a gradient.
  static const double _segmentGap = 1.5;

  /// The legend's dots.
  static const double _dotSize = 8;

  /// Gap between the two legend entries.
  static const double _legendGap = 16;

  /// The scored lessons, split into the design's two states.
  final MasteryRollup rollup;

  /// Lessons in the course, scored or not.
  final int total;

  /// Opens the Path, where a weak lesson can be practised.
  final VoidCallback onPractice;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return ProfileCard(
      radius: _radius,
      onTap: onPractice,
      semanticLabel:
          'Lesson progress. ${rollup.scored} of $total done, '
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
                    Text(
                      '${rollup.scored} / $total DONE',
                      style: AppText.label(mood: mood, face: AppFace.mono),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                _SegmentedBar(rollup: rollup, total: total),
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
  const _SegmentedBar({required this.rollup, required this.total});

  final MasteryRollup rollup;
  final int total;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final remainder = rollup.remainderOf(total);

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
        const SizedBox(width: AppSpacing.xxs + 2),
        Flexible(
          child: Text(
            '$count $label',
            style: AppText.support(color: ink),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
