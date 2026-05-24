import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:coffee_quest/core/constants/app_strings.dart';
import 'package:coffee_quest/core/utils/module_icons.dart';
import 'package:coffee_quest/core/widgets/error_view.dart';
import 'package:coffee_quest/core/widgets/loading_indicator.dart';
import 'package:coffee_quest/features/learn/domain/learn_providers.dart';
import 'package:coffee_quest/features/lessons/domain/lesson_completion_service.dart';
import 'package:coffee_quest/features/progress/domain/progress_providers.dart';
import 'package:coffee_quest/shared/models/coffee_card_model.dart';
import 'package:coffee_quest/shared/repositories/content_repository.dart';

/// Loaded outcome for the screen. Exactly one of [completion] / [reviewResult]
/// is set for first-completion / review runs; both are null for pure
/// [LessonCompletionScreen.practice] runs (which write nothing).
class _Reward {
  const _Reward({this.completion, this.reviewResult, this.card});
  final LessonCompletionResult? completion;
  final LessonReviewResult? reviewResult;
  final CoffeeCardModel? card;
}

class LessonCompletionScreen extends ConsumerStatefulWidget {
  const LessonCompletionScreen({
    super.key,
    required this.lessonId,
    required this.score,
    this.review = false,
    this.practice = false,
  });

  final String lessonId;

  /// First-try accuracy of the run that reached this screen (0–100).
  final int score;

  /// Whether the run was a review of an already-completed lesson.
  final bool review;

  /// Whether the run was a pure practice repetition (no XP, no DB writes).
  /// Takes precedence over [review].
  final bool practice;

  @override
  ConsumerState<LessonCompletionScreen> createState() =>
      _LessonCompletionScreenState();
}

class _LessonCompletionScreenState
    extends ConsumerState<LessonCompletionScreen> {
  late final Future<_Reward> _future = _completeAndLoad();

  /// Persists the run exactly once. First completion awards full XP/cards;
  /// review only updates mastery and may grant practice XP; practice runs
  /// from the Learn-tab practice section write nothing at all. Every path is
  /// idempotent, so a rebuild or revisit will not double-award anything.
  Future<_Reward> _completeAndLoad() async {
    final content = ref.read(contentRepositoryProvider);
    final lesson = await content.getLessonById(widget.lessonId);
    if (lesson == null) {
      throw StateError('Lesson ${widget.lessonId} not found');
    }

    if (widget.practice) {
      // Pure practice — no service call, no XP, no card, no streak. Just
      // display a summary using the run's score.
      return const _Reward();
    }

    if (widget.review) {
      final reviewResult = await ref
          .read(lessonCompletionServiceProvider)
          .reviewLesson(lesson, score: widget.score);
      // A review changes nothing else; only practice XP affects a shell tab.
      if (reviewResult.practiceXpAwarded) {
        ref.invalidate(totalXpProvider);
      }
      return _Reward(reviewResult: reviewResult);
    }

    final completion = await ref
        .read(lessonCompletionServiceProvider)
        .completeLesson(lesson, score: widget.score);

    // The Learn, Cards, and Profile screens live in the indexed-stack shell and
    // stay mounted while this screen covers them, so every completion-derived
    // provider must be invalidated explicitly — otherwise "Today's lesson" and
    // module progress keep showing the just-finished lesson, and the profile's
    // Total XP / streak / lesson & card counts keep showing pre-completion
    // values, when the user returns.
    ref.invalidate(todayLessonProvider);
    ref.invalidate(modulesWithProgressProvider);
    ref.invalidate(totalXpProvider);
    ref.invalidate(streakProvider);
    ref.invalidate(completedLessonsProvider);
    ref.invalidate(collectedCardsProvider);

    CoffeeCardModel? card;
    final cardId = lesson.cardId;
    if (cardId != null) {
      final cards = await content.getCards();
      card = cards.where((c) => c.id == cardId).firstOrNull;
    }
    return _Reward(completion: completion, card: card);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<_Reward>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const LoadingIndicator();
            }
            if (snap.hasError) return ErrorView(message: '${snap.error}');
            final reward = snap.data!;
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...(reward.reviewResult != null
                        ? _reviewContent(context, reward.reviewResult!)
                        : reward.completion != null
                        ? _completionContent(
                            context,
                            reward,
                            reward.completion!,
                          )
                        : _practiceContent(context)),
                    const SizedBox(height: 32),
                    FilledButton(
                      onPressed: () => context.go('/learn'),
                      child: const Text(AppStrings.continueLabel),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _completionContent(
    BuildContext context,
    _Reward reward,
    LessonCompletionResult completion,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return [
      const _HeroBadge(icon: Icons.celebration),
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
        'Score: ${widget.score}%',
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

/// Round tinted celebration/replay badge shown above the headline.
class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Container(
        width: 96,
        height: 96,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 48, color: colors.onPrimaryContainer),
      ),
    );
  }
}

/// Card-reward row shown when the completed lesson grants a collectible.
class _RewardCard extends StatelessWidget {
  const _RewardCard({required this.card});

  final CoffeeCardModel card;

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
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
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
