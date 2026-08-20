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
  });

  /// Id of the completed lesson.
  final String lessonId;

  /// Graded result of the run that reached this screen.
  final MasteryResult mastery;

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

    final result = await ref
        .read(lessonCompletionServiceProvider)
        .finishLesson(lesson, mastery: widget.mastery);

    // The Learn, Cards and Profile screens live in the indexed-stack shell and
    // stay mounted while this screen covers them, so nothing derived from the
    // run rebuilds on its own. Every one of these is invalidated on both
    // paths: a replay moves the streak and the Keep Sharp card exactly as a
    // first completion does, and the run that pays nothing still records a day.
    ref.invalidate(todayLessonProvider);
    ref.invalidate(modulesWithProgressProvider);
    ref.invalidate(totalXpProvider);
    ref.invalidate(streakStatusProvider);
    ref.invalidate(completedLessonsProvider);
    ref.invalidate(collectedCardsProvider);
    ref.invalidate(keepSharpAcknowledgedTodayProvider);
    ref.invalidate(keepSharpRecommendationProvider);
    // `cardsWithCollectionProvider` no longer chains through
    // `collectedCardsProvider`, so invalidate it explicitly.
    ref.invalidate(cardsWithCollectionProvider);

    final card = result.isReplay
        ? null
        : await content.getCardForLesson(lesson.id);
    return LessonCompletionReward(result: result, card: card);
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
    return LessonCompletionBody(
      reward: reward,
      celebrating: !reward.result.isReplay,
      moduleSummaryId: reward.result.moduleCompleted ? _moduleId : null,
    );
  }
}
