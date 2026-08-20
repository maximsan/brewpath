import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/core/utils/module_icons.dart';
import 'package:brew_path/core/widgets/icon_badge.dart';
import 'package:brew_path/features/companion/domain/companion_reaction.dart';
import 'package:brew_path/features/companion/presentation/companion_celebration.dart';
import 'package:brew_path/features/lessons/domain/lesson_destination.dart';
import 'package:brew_path/features/lessons/domain/lesson_finish_result.dart';
import 'package:brew_path/features/lessons/presentation/lesson_completion_reward.dart';
import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Presentation for the post-lesson screen: a hero badge, outcome text and any
/// reward card, then the Continue button. Pure view — it renders the loaded
/// [LessonCompletionReward] and the run's graded result, and performs no I/O.
class LessonCompletionBody extends StatelessWidget {
  /// Creates a [LessonCompletionBody].
  const LessonCompletionBody({
    required this.reward,
    super.key,
    this.celebrating = false,
    this.moduleSummaryId,
  });

  /// The loaded reward to render.
  final LessonCompletionReward reward;

  /// Whether this is a first completion, which is what earns the celebrating
  /// companion. A review or practice run shows a static badge instead.
  final bool celebrating;

  /// When set, Continue routes to the module-summary recap for this module id
  /// (the lesson just completed its module); otherwise it returns to Learn.
  final String? moduleSummaryId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ..._content(context),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () => _onContinue(context),
              child: const Text(AppLabels.continueLabel),
            ),
          ],
        ),
      ),
    );
  }

  void _onContinue(BuildContext context) {
    final moduleId = moduleSummaryId;
    context.goTo(moduleId != null ? moduleSummary(moduleId) : learnTab);
  }

  /// Total by construction: the run was a first completion or a replay, and
  /// the service already decided which.
  List<Widget> _content(BuildContext context) => reward.result.isReplay
      ? _replayContent(context, reward.result)
      : _completionContent(context, reward.result);

  List<Widget> _completionContent(
    BuildContext context,
    LessonFinishResult completion,
  ) {
    final theme = Theme.of(context);
    final mood = context.mood;
    return [
      _CompletionHero(celebrating: celebrating),
      const SizedBox(height: 20),
      Text(
        'Lesson complete!',
        textAlign: TextAlign.center,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        '+${completion.lessonXp} XP',
        textAlign: TextAlign.center,
        style: theme.textTheme.titleLarge?.copyWith(
          color: mood.accent,
          fontWeight: FontWeight.w700,
        ),
      ),
      if (completion.moduleCompleted) ...[
        const SizedBox(height: 4),
        Text(
          '+${completion.moduleBonusXp} XP · Module complete!',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(color: mood.accent),
        ),
      ],
      if (reward.card != null) ...[
        const SizedBox(height: 24),
        _RewardCard(card: reward.card!),
      ],
    ];
  }

  List<Widget> _replayContent(BuildContext context, LessonFinishResult review) {
    final theme = Theme.of(context);
    final mood = context.mood;
    return [
      const _HeroBadge(icon: Icons.replay),
      const SizedBox(height: 20),
      Text(
        'Review complete!',
        textAlign: TextAlign.center,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        'Best score: ${review.mastery.correct} / ${review.mastery.total}',
        textAlign: TextAlign.center,
        style: theme.textTheme.titleLarge?.copyWith(
          color: mood.accent,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        review.practiceXpAwarded
            ? '+2 XP · Practice'
            : 'Practice XP already earned today',
        textAlign: TextAlign.center,
        style: theme.textTheme.titleMedium?.copyWith(
          color: mood.inkMute,
        ),
      ),
    ];
  }
}

/// The first-completion hero: the celebratory companion (with a speech bubble
/// when a line is available), falling back to the static badge if no handle is
/// supplied.
class _CompletionHero extends StatelessWidget {
  const _CompletionHero({this.celebrating = false});

  static const double _companionSize = 140;

  final bool celebrating;

  @override
  Widget build(BuildContext context) {
    if (!celebrating) return const _HeroBadge(icon: Icons.celebration);
    return const Center(
      child: CompanionCelebration(
        reaction: CompanionReaction.lessonComplete,
        size: _companionSize,
      ),
    );
  }
}

/// Round tinted celebration/replay badge shown above the headline.
class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.icon});

  final IconData icon;

  static const double _size = 96;
  static const double _iconSize = 48;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconBadge.circle(icon: icon, size: _size, iconSize: _iconSize),
    );
  }
}

/// Card-reward row shown when the completed lesson grants a collectible.
class _RewardCard extends StatelessWidget {
  const _RewardCard({required this.card});

  final CoffeeCardModel card;

  static const double _badgeSize = 48;
  static const double _cardRadius = 12;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            IconBadge.rounded(
              icon: moduleIcon(card.iconName),
              size: _badgeSize,
              radius: _cardRadius,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(card.title, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    card.moduleTag,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: mood.inkMute,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
