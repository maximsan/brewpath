import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:coffee_quest/core/constants/app_strings.dart';
import 'package:coffee_quest/core/widgets/error_view.dart';
import 'package:coffee_quest/core/widgets/loading_indicator.dart';
import 'package:coffee_quest/features/learn/domain/learn_providers.dart';
import 'package:coffee_quest/features/lessons/domain/lesson_completion_service.dart';
import 'package:coffee_quest/features/progress/domain/progress_providers.dart';
import 'package:coffee_quest/shared/models/coffee_card_model.dart';
import 'package:coffee_quest/shared/repositories/content_repository.dart';

/// Loaded outcome for the screen. Exactly one of [completion] / [reviewResult]
/// is set, depending on whether this was a first completion or a review.
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
  });

  final String lessonId;

  /// First-try accuracy of the run that reached this screen (0–100).
  final int score;

  /// Whether the run was a review of an already-completed lesson.
  final bool review;

  @override
  ConsumerState<LessonCompletionScreen> createState() =>
      _LessonCompletionScreenState();
}

class _LessonCompletionScreenState
    extends ConsumerState<LessonCompletionScreen> {
  late final Future<_Reward> _future = _completeAndLoad();

  /// Persists the run exactly once. First completion awards full XP/cards;
  /// review only updates mastery and may grant practice XP. Both paths are
  /// idempotent, so a rebuild or revisit will not double-award anything.
  Future<_Reward> _completeAndLoad() async {
    final content = ref.read(contentRepositoryProvider);
    final lesson = await content.getLessonById(widget.lessonId);
    if (lesson == null) {
      throw StateError('Lesson ${widget.lessonId} not found');
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
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...reward.reviewResult != null
                      ? _reviewContent(context, reward.reviewResult!)
                      : _completionContent(context, reward),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: () => context.go('/learn'),
                    child: const Text(AppStrings.continueLabel),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _completionContent(BuildContext context, _Reward reward) {
    final completion = reward.completion!;
    return [
      const Icon(Icons.celebration, size: 72),
      const SizedBox(height: 16),
      Text(
        'Lesson complete!',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: 8),
      Text(
        '+${completion.lessonXp} XP',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      if (completion.moduleCompleted) ...[
        const SizedBox(height: 4),
        Text(
          '+${completion.moduleBonusXp} XP · Module complete!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
      if (reward.card != null) ...[
        const SizedBox(height: 24),
        Card(
          child: ListTile(
            leading: const Icon(Icons.style),
            title: Text(reward.card!.title),
            subtitle: Text(reward.card!.moduleTag),
          ),
        ),
      ],
    ];
  }

  List<Widget> _reviewContent(BuildContext context, LessonReviewResult review) {
    return [
      const Icon(Icons.replay, size: 72),
      const SizedBox(height: 16),
      Text(
        'Review complete!',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: 8),
      Text(
        'Best score: ${review.bestScore}%',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 4),
      Text(
        review.practiceXpAwarded
            ? '+2 XP · Practice'
            : 'Practice XP already earned today',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    ];
  }
}
