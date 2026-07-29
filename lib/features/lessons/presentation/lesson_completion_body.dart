import 'package:coffee_quest/core/constants/app_strings.dart';
import 'package:coffee_quest/core/utils/module_icons.dart';
import 'package:coffee_quest/features/companion/presentation/companion.dart';
import 'package:coffee_quest/features/companion/presentation/companion_bubble.dart';
import 'package:coffee_quest/features/companion/presentation/companion_handle.dart';
import 'package:coffee_quest/features/lessons/domain/lesson_completion_service.dart';
import 'package:coffee_quest/features/lessons/presentation/lesson_completion_reward.dart';
import 'package:coffee_quest/shared/models/coffee_card_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Presentation for the post-lesson screen: a hero badge, outcome text and any
/// reward card, then the Continue button. Pure view — it renders the loaded
/// [LessonCompletionReward] and the run score, and performs no I/O.
class LessonCompletionBody extends StatelessWidget {
  /// Creates a [LessonCompletionBody].
  const LessonCompletionBody({
    required this.reward,
    required this.score,
    super.key,
    this.companionHandle,
    this.companionLine,
    this.moduleSummaryId,
  });

  /// The loaded reward to render.
  final LessonCompletionReward reward;

  /// First-try accuracy of the run (0–100); shown for practice runs.
  final int score;

  /// Drives the celebratory companion on the first-completion path. When null
  /// (review / practice runs) a static badge is shown instead.
  final CompanionHandle? companionHandle;

  /// Optional speech line shown in the companion's bubble.
  final String? companionLine;

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
              child: const Text(AppStrings.continueLabel),
            ),
          ],
        ),
      ),
    );
  }

  void _onContinue(BuildContext context) {
    final moduleId = moduleSummaryId;
    if (moduleId != null) {
      context.goNamed('moduleSummary', pathParameters: {'moduleId': moduleId});
    } else {
      context.go('/learn');
    }
  }

  List<Widget> _content(BuildContext context) {
    final reviewResult = reward.reviewResult;
    final completion = reward.completion;
    if (reviewResult != null) return _reviewContent(context, reviewResult);
    if (completion != null) return _completionContent(context, completion);
    return _practiceContent(context);
  }

  List<Widget> _completionContent(
    BuildContext context,
    LessonCompletionResult completion,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return [
      _CompletionHero(handle: companionHandle, line: companionLine),
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
          color: colors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
      if (completion.moduleCompleted) ...[
        const SizedBox(height: 4),
        Text(
          '+${completion.moduleBonusXp} XP · Module complete!',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(color: colors.primary),
        ),
      ],
      if (reward.card != null) ...[
        const SizedBox(height: 24),
        _RewardCard(card: reward.card!),
      ],
    ];
  }

  List<Widget> _practiceContent(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return [
      const _HeroBadge(icon: Icons.fitness_center),
      const SizedBox(height: 20),
      Text(
        'Practice complete!',
        textAlign: TextAlign.center,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        'Score: $score%',
        textAlign: TextAlign.center,
        style: theme.textTheme.titleLarge?.copyWith(
          color: colors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        'Practice runs do not change your XP, streak, or progress.',
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
    ];
  }

  List<Widget> _reviewContent(BuildContext context, LessonReviewResult review) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
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
        'Best score: ${review.bestScore}%',
        textAlign: TextAlign.center,
        style: theme.textTheme.titleLarge?.copyWith(
          color: colors.primary,
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
          color: colors.onSurfaceVariant,
        ),
      ),
    ];
  }
}

/// The first-completion hero: the celebratory companion (with a speech bubble
/// when a line is available), falling back to the static badge if no handle is
/// supplied.
class _CompletionHero extends StatelessWidget {
  const _CompletionHero({this.handle, this.line});

  static const double _companionSize = 140;

  final CompanionHandle? handle;
  final String? line;

  @override
  Widget build(BuildContext context) {
    final handle = this.handle;
    if (handle == null) {
      return const _HeroBadge(icon: Icons.celebration);
    }
    final companion = Companion(handle: handle, size: _companionSize);
    final line = this.line;
    return Center(
      child: line == null
          ? companion
          : CompanionBubble(text: line, child: companion),
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
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Container(
        width: _size,
        height: _size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: _iconSize, color: colors.onPrimaryContainer),
      ),
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
    final colors = theme.colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: _badgeSize,
              height: _badgeSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(_cardRadius),
              ),
              child: Icon(
                moduleIcon(card.iconName),
                color: colors.onPrimaryContainer,
              ),
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
                      color: colors.onSurfaceVariant,
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
