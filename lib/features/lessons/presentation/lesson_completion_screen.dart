import 'package:coffee_quest/core/widgets/error_view.dart';
import 'package:coffee_quest/core/widgets/loading_indicator.dart';
import 'package:coffee_quest/features/cards/domain/cards_providers.dart';
import 'package:coffee_quest/features/companion/application/companion_providers.dart';
import 'package:coffee_quest/features/companion/domain/companion_reaction.dart';
import 'package:coffee_quest/features/companion/presentation/companion_handle.dart';
import 'package:coffee_quest/features/learn/domain/learn_providers.dart';
import 'package:coffee_quest/features/lessons/domain/lesson_completion_service.dart';
import 'package:coffee_quest/features/lessons/presentation/lesson_completion_body.dart';
import 'package:coffee_quest/features/lessons/presentation/lesson_completion_reward.dart';
import 'package:coffee_quest/features/progress/domain/progress_providers.dart';
import 'package:coffee_quest/shared/models/coffee_card_model.dart';
import 'package:coffee_quest/shared/repositories/content_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Post-lesson screen: shows earned XP and any unlocked card, then routes back.
class LessonCompletionScreen extends ConsumerStatefulWidget {
  /// Creates a [LessonCompletionScreen].
  const LessonCompletionScreen({
    required this.lessonId,
    required this.score,
    super.key,
    this.review = false,
    this.practice = false,
  });

  /// Id of the completed lesson.
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
  late final Future<LessonCompletionReward> _future = _completeAndLoad();
  final CompanionHandle _companionHandle = CompanionHandle();
  String? _companionLine;
  String? _moduleId;
  bool _reacted = false;

  @override
  void dispose() {
    _companionHandle.dispose();
    super.dispose();
  }

  /// Persists the run exactly once. First completion awards full XP/cards;
  /// review only updates mastery and may grant practice XP; practice runs
  /// from the Learn-tab practice section write nothing at all. Every path is
  /// idempotent, so a rebuild or revisit will not double-award anything.
  Future<LessonCompletionReward> _completeAndLoad() async {
    final content = ref.read(contentRepositoryProvider);
    final lesson = await content.getLessonById(widget.lessonId);
    if (lesson == null) {
      throw StateError('Lesson ${widget.lessonId} not found');
    }
    _moduleId = lesson.moduleId;

    if (widget.practice) {
      // Pure practice — no service call, no XP, no card, no streak. Just
      // display a summary using the run's score.
      return const LessonCompletionReward();
    }

    if (widget.review) {
      final reviewResult = await ref
          .read(lessonCompletionServiceProvider)
          .reviewLesson(lesson, score: widget.score);
      // A review changes nothing else; only practice XP affects a shell tab.
      if (reviewResult.practiceXpAwarded) {
        ref.invalidate(totalXpProvider);
      }
      return LessonCompletionReward(reviewResult: reviewResult);
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
    // `cardsWithCollectionProvider` no longer chains through
    // `collectedCardsProvider`, so invalidate it explicitly.
    ref.invalidate(cardsWithCollectionProvider);

    CoffeeCardModel? card;
    final cardId = lesson.cardId;
    if (cardId != null) {
      final cards = await content.getCards();
      card = cards.where((c) => c.id == cardId).firstOrNull;
    }
    return LessonCompletionReward(completion: completion, card: card);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<LessonCompletionReward>(
          future: _future,
          builder: _buildResult,
        ),
      ),
    );
  }

  Widget _buildResult(
    BuildContext context,
    AsyncSnapshot<LessonCompletionReward> snap,
  ) {
    if (snap.connectionState != ConnectionState.done) {
      return const LoadingIndicator();
    }
    if (snap.hasError) return ErrorView(message: '${snap.error}');
    final reward = snap.data!;
    final firstCompletion = reward.completion != null;
    if (firstCompletion) {
      _companionLine ??= ref
          .watch(companionLinesProvider)
          .asData
          ?.value
          .lineFor(CompanionReaction.lessonComplete);
      _fireLessonCompleteOnce();
    }
    final moduleCompleted = reward.completion?.moduleCompleted ?? false;
    return LessonCompletionBody(
      reward: reward,
      score: widget.score,
      companionHandle: firstCompletion ? _companionHandle : null,
      companionLine: firstCompletion ? _companionLine : null,
      moduleSummaryId: moduleCompleted ? _moduleId : null,
    );
  }

  /// Fires the lesson-complete reaction a single time, after the first frame so
  /// the companion is mounted and schedules its own auto-revert.
  void _fireLessonCompleteOnce() {
    if (_reacted) return;
    _reacted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _companionHandle.react(CompanionReaction.lessonComplete);
    });
  }
}
