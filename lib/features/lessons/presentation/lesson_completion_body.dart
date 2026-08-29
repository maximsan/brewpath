import 'package:brew_path/core/widgets/sticky_action_bar.dart';
import 'package:brew_path/features/challenges/presentation/challenge_suggestion.dart';
import 'package:brew_path/features/lessons/domain/lesson_completion_actions.dart';
import 'package:brew_path/features/lessons/domain/lesson_destination.dart';
import 'package:brew_path/features/lessons/presentation/lesson_completion_beat.dart';
import 'package:brew_path/features/lessons/presentation/lesson_completion_header.dart';
import 'package:brew_path/features/lessons/presentation/lesson_completion_rail.dart';
import 'package:brew_path/features/lessons/presentation/lesson_completion_reward.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// The completion screen's content: the headline, the run's score, and the
/// payout rail — over the shared sticky footer.
///
/// Pure view. Everything it renders is decided before it is built: the reward
/// by the service, the footer's action and link by [completionActions]. It
/// performs no I/O and makes no policy decision of its own.
class LessonCompletionBody extends StatelessWidget {
  /// Creates a [LessonCompletionBody].
  const LessonCompletionBody({
    required this.lessonId,
    required this.lessonTitle,
    required this.reward,
    required this.actions,
    super.key,
  });

  /// The lesson that was just finished.
  final String lessonId;

  /// Its name, which is the screen's headline.
  final String lessonTitle;

  /// What the run recorded, plus any card it unlocked.
  final LessonCompletionReward reward;

  /// The footer's resolved action and quiet link.
  final CompletionActions actions;

  @override
  Widget build(BuildContext context) {
    final link = actions.link;
    return StickyActionBar(
      label: actions.label,
      onPressed: () => context.goTo(actions.destination),
      link: link == null
          ? null
          : QuietLink(
              label: link.label,
              onTap: () => context.goTo(link.destination),
            ),
      // The design pins the Coffee Challenge offer to the footer rather than
      // leaving it in the scroll, so it travels with the action it competes
      // with. Twenty of the thirty-two lessons carry none, and the widget
      // renders nothing at all for those — no gap, no divider.
      preface: ChallengeSuggestion(lessonId: lessonId),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LessonCompletionHeader(
              eyebrow: completionEyebrow(
                isReplay: reward.result.isReplay,
              ),
              title: lessonTitle,
              mastery: reward.result.mastery,
            ),
            const SizedBox(height: AppSpacing.xl),
            LessonCompletionRail(
              pointsEarned: reward.result.pointsEarned,
              freezeEarned: reward.result.freezeEarned,
              lessonCard: reward.card,
              moduleCard: reward.result.moduleCard,
            ),
          ],
        ),
      ),
    );
  }
}
