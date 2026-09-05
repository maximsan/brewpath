import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The completion headline: a smallcaps kicker, **the lesson's own name**, and
/// the run's score.
///
/// **The name is the headline.** The app used to make `Lesson complete!` the
/// title and never say which lesson it was — the eyebrow says what happened,
/// and the h1 says what it happened to.
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

/// The run's score, and nothing beside it.
///
/// **No chip.** The design drops it: the score already reports how the run
/// went, the accent practice button under the action carries the verdict, and
/// the Path row wears the persistent one. Saying it three times on one screen
/// is noise.
class _ScoreLine extends StatelessWidget {
  const _ScoreLine({required this.mastery});

  final MasteryResult mastery;

  /// The design writes the line out in words — `3 / 5 correct` — rather than
  /// leaving a bare ratio to be read as anything.
  static String read(MasteryResult mastery) =>
      '${mastery.correct} / ${mastery.total} correct';

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    return Semantics(
      label: 'Scored ${mastery.correct} out of ${mastery.total}',
      excludeSemantics: true,
      child: Text(
        read(mastery),
        style: AppText.body(mood: mood, color: mood.ink, face: AppFace.mono),
      ),
    );
  }
}
