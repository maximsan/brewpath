import 'package:brew_path/core/widgets/error_view.dart';
import 'package:brew_path/core/widgets/loading_indicator.dart';
import 'package:brew_path/features/cards/domain/cards_providers.dart';
import 'package:brew_path/features/learn/domain/keep_sharp_providers.dart';
import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/features/lessons/domain/lesson_completion_service.dart';
import 'package:brew_path/features/lessons/presentation/lesson_completion_body.dart';
import 'package:brew_path/features/lessons/presentation/lesson_completion_reward.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Post-lesson screen: shows earned XP and any unlocked card, then routes back.
class LessonCompletionScreen extends ConsumerStatefulWidget {
  /// Creates a [LessonCompletionScreen].
  const LessonCompletionScreen({
    required this.lessonId,
    required this.mastery,
    super.key,
    this.review = false,
  });

  /// Id of the completed lesson.
  final String lessonId;

  /// Graded result of the run that reached this screen.
  final MasteryResult mastery;

  /// Whether the run was a review of an already-completed lesson.
  final bool review;

  @override
  ConsumerState<LessonCompletionScreen> createState() =>
      _LessonCompletionScreenState();
}

class _LessonCompletionScreenState
    extends ConsumerState<LessonCompletionScreen> {
  late final Future<LessonCompletionReward> _future = _completeAndLoad();
  String? _moduleId;

  /// Persists the run exactly once. First completion awards full points and
  /// the card; a replay updates mastery upward, may grant practice points, and
  /// marks the day (§3). Every path is idempotent, so a rebuild or revisit
  /// will not double-award anything — and every path records, which is why the
  /// write-nothing practice mode is gone.
  Future<LessonCompletionReward> _completeAndLoad() async {
    final content = ref.read(contentRepositoryProvider);
    final lesson = await content.getLessonById(widget.lessonId);
    if (lesson == null) {
      throw StateError('Lesson ${widget.lessonId} not found');
    }
    _moduleId = lesson.moduleId;

    if (widget.review) {
      final reviewResult = await ref
          .read(lessonCompletionServiceProvider)
          .reviewLesson(lesson, mastery: widget.mastery);
      // A completed replay protects the day (§3), so everything derived from
      // it has to look again — even when the once-a-day practice XP did not
      // pay. The Learn tab is covered by the run rather than replaced, so it
      // never rebuilds on its own, and the card would go on asking for a
      // replay the learner had just finished.
      ref.invalidate(streakStatusProvider);
      ref.invalidate(completedLessonsProvider);
      ref.invalidate(keepSharpAcknowledgedTodayProvider);
      ref.invalidate(keepSharpRecommendationProvider);
      if (reviewResult.practiceXpAwarded) {
        ref.invalidate(totalXpProvider);
      }
      return LessonCompletionReward(reviewResult: reviewResult);
    }

    final completion = await ref
        .read(lessonCompletionServiceProvider)
        .completeLesson(lesson, mastery: widget.mastery);

    // The Learn, Cards, and Profile screens live in the indexed-stack shell and
    // stay mounted while this screen covers them, so every completion-derived
    // provider must be invalidated explicitly — otherwise "Today's lesson" and
    // module progress keep showing the just-finished lesson, and the profile's
    // Total XP / streak / lesson & card counts keep showing pre-completion
    // values, when the user returns.
    ref.invalidate(todayLessonProvider);
    ref.invalidate(modulesWithProgressProvider);
    ref.invalidate(totalXpProvider);
    ref.invalidate(streakStatusProvider);
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
    final moduleCompleted = reward.completion?.moduleCompleted ?? false;
    return LessonCompletionBody(
      reward: reward,
      celebrating: firstCompletion,
      moduleSummaryId: moduleCompleted ? _moduleId : null,
    );
  }
}
