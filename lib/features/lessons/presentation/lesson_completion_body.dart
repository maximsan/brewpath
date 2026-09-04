import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/widgets/float_topbar.dart';
import 'package:brew_path/core/widgets/reward_flip_view.dart';
import 'package:brew_path/core/widgets/reward_row.dart';
import 'package:brew_path/core/widgets/sticky_action_bar.dart';
import 'package:brew_path/features/cards/presentation/reward_card.dart';
import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/features/challenges/presentation/challenge_suggestion.dart';
import 'package:brew_path/features/lessons/domain/lesson_completion_actions.dart';
import 'package:brew_path/features/lessons/domain/lesson_destination.dart';
import 'package:brew_path/features/lessons/presentation/lesson_completion_beat.dart';
import 'package:brew_path/features/lessons/presentation/lesson_completion_header.dart';
import 'package:brew_path/features/lessons/presentation/lesson_completion_reward.dart';
import 'package:brew_path/features/lessons/presentation/lesson_completion_tree.dart';
import 'package:brew_path/features/lessons/presentation/reward_points_line.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:brew_path/shared/models/content/brew_challenge.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The completion screen, and the card on its back.
///
/// **The card lives on the back of the screen**, reached from the New-card row
/// — the same flip grammar the module ending uses, where the turn is the
/// ceremony's own beat. It used to open in a covering sheet, which made the
/// collectible something that happened *over* the celebration rather than part
/// of it.
///
/// Pure view. Everything it renders is decided before it is built: the reward
/// by the service, the footer's action by [completionActions]. It performs no
/// I/O and makes no policy decision of its own.
///
/// **One slot of the design's footer is empty here.** It puts *Duel a friend*
/// under the action as a quiet link; the duel is v2, so the slot exists on
/// `StickyActionBar` and nothing passes it.
class LessonCompletionBody extends StatefulWidget {
  /// Creates a [LessonCompletionBody].
  const LessonCompletionBody({
    required this.lessonId,
    required this.lessonTitle,
    required this.mastery,
    required this.reward,
    required this.actions,
    required this.onClose,
    super.key,
  });

  /// The lesson that was just finished.
  final String lessonId;

  /// Its name, which is the screen's headline.
  final String lessonTitle;

  /// **This run's** graded result — not the stored best.
  ///
  /// The two differ on a replay, and the design reports the run. Showing the
  /// best instead would tell a learner who has just played badly that they did
  /// well, and would withhold the practice invitation from the exact run that
  /// earned it.
  final MasteryResult mastery;

  /// What the run recorded, plus any card it unlocked.
  final LessonCompletionReward reward;

  /// The footer's resolved action.
  final CompletionActions actions;

  /// Leaves the celebration.
  final VoidCallback onClose;

  @override
  State<LessonCompletionBody> createState() => _LessonCompletionBodyState();
}

class _LessonCompletionBodyState extends State<LessonCompletionBody>
    with SingleTickerProviderStateMixin, RewardFlipController {
  @override
  Widget build(BuildContext context) {
    return RewardFlipView(
      turn: flipProgress,
      front: _report,
      back: _card,
    );
  }

  Widget _report(BuildContext context) {
    final reward = widget.reward;
    final card = reward.card;
    final practice = widget.actions.practice;

    return FloatTopbarScrollScope(
      builder: (context, {required isScrolled}) => Stack(
        children: [
          StickyActionBar(
            label: widget.actions.label,
            onPressed: () => context.goTo(widget.actions.destination),
            ghost: practice == null
                ? null
                : GhostAction(
                    label: practice.label,
                    onPressed: () => context.goTo(practice.destination),
                  ),
            content: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.gutter,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LessonCompletionHeader(
                    eyebrow: completionEyebrow(
                      isReplay: reward.result.isReplay,
                    ),
                    title: widget.lessonTitle,
                    mastery: widget.mastery,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  LessonCompletionTree(
                    fromStage: reward.result.treeStageBefore,
                    toStage: reward.result.treeStageAfter,
                    lessonsToNextStage: reward.result.lessonsToNextStage,
                  ),
                  // Points land under the tree — what you earned feeds what
                  // grows.
                  const SizedBox(height: AppSpacing.base),
                  RewardPointsLine(points: reward.result.pointsEarned),
                  RewardBeats(
                    lessonId: widget.lessonId,
                    freezeEarned: reward.result.freezeEarned,
                    card: card,
                    onOpenCard: () => turnTo(showCard: true),
                  ),
                ],
              ),
            ),
          ),
          FloatTopbar(
            icon: AppIcon.close,
            label: AppLabels.close,
            onPressed: widget.onClose,
            isScrolled: isScrolled,
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context) {
    final card = widget.reward.card;

    return Stack(
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              FloatTopbar.height + AppSpacing.xl,
              AppSpacing.gutter,
              AppSpacing.xl,
            ),
            child: Center(child: card == null ? null : RewardCard(card: card)),
          ),
        ),
        FloatTopbar(
          icon: AppIcon.back,
          label: AppLabels.flipBack,
          onPressed: () => turnTo(showCard: false),
          isScrolled: false,
        ),
      ],
    );
  }
}

/// The occasional beats a run earned, as the design's one list.
///
/// Renders nothing at all when a run earned none — which is most replays — so
/// there is no gap where a list would have been.
class RewardBeats extends ConsumerStatefulWidget {
  /// Creates a [RewardBeats].
  const RewardBeats({
    required this.lessonId,
    required this.freezeEarned,
    required this.card,
    required this.onOpenCard,
    super.key,
  });

  /// The lesson whose challenge, if any, joins the list.
  final String lessonId;

  /// Whether this run earned the streak freeze.
  final bool freezeEarned;

  /// The card it handed over, if it did.
  final CoffeeCardModel? card;

  /// Turns the screen over to that card.
  final VoidCallback onOpenCard;

  /// What the freeze row says it covers.
  static const String freezeLabel = 'Freeze earned';

  /// And the line under it.
  static const String freezeDetail = 'One missed day is covered.';

  /// The card row's own label — the collectible's title is its detail.
  static const String cardLabel = 'New card';

  @override
  ConsumerState<RewardBeats> createState() => _RewardBeatsState();
}

class _RewardBeatsState extends ConsumerState<RewardBeats> {
  /// The offer this screen arrived with.
  ///
  /// **Latched, not watched.** Taking the offer up puts the challenge in play,
  /// which is exactly what stops it being an offer — so a list that kept
  /// asking would drop the row at the moment it is meant to confirm, and the
  /// learner would tap and watch it vanish. The list reports what this run
  /// earned; it does not re-decide that mid-celebration.
  BrewChallenge? _offer;

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    _offer ??= ref
        .watch(lessonChallengeOfferProvider(widget.lessonId))
        .asData
        ?.value;
    final offer = _offer;

    final rows = <Widget>[
      if (widget.freezeEarned)
        const RewardRow(
          label: RewardBeats.freezeLabel,
          detail: RewardBeats.freezeDetail,
        ),
      if (card != null)
        RewardRow(
          label: RewardBeats.cardLabel,
          detail: card.title,
          onPress: widget.onOpenCard,
        ),
      if (offer != null) ChallengeSuggestion(challenge: offer),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: RewardList(rows: rows),
    );
  }
}
