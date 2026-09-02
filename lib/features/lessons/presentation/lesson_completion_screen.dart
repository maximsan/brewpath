import 'package:brew_path/app/day_surfaces.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/error_view.dart';
import 'package:brew_path/core/widgets/loading_indicator.dart';
import 'package:brew_path/features/cards/domain/cards_providers.dart';
import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/features/companion/domain/companion_reaction.dart';
import 'package:brew_path/features/companion/presentation/roasty_moment.dart';
import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/features/lessons/domain/lesson_completion_actions.dart';
import 'package:brew_path/features/lessons/domain/lesson_completion_service.dart';
import 'package:brew_path/features/lessons/domain/lesson_destination.dart';
import 'package:brew_path/features/lessons/presentation/lesson_completion_beat.dart';
import 'package:brew_path/features/lessons/presentation/lesson_completion_body.dart';
import 'package:brew_path/features/lessons/presentation/lesson_completion_reward.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Post-lesson screen: the companion's beat, then what the run paid — the
/// lesson's name, its score, the points, the freeze and any card — and the way
/// on.
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

  /// Whether the opening beat has handed over. The content is not built until
  /// it has, which is the design's two-phase reveal.
  bool _beatDone = false;

  /// Whether this run has already been handed to the module ending.
  bool _handedOver = false;

  /// Persists the run exactly once. A first completion pays the lesson's flat
  /// ten and hands over its card, plus the module's Module Reward card where
  /// the run closed one; a replay pays nothing, updates mastery upward and
  /// marks the day (§3). Every path is idempotent, so a rebuild or revisit
  /// will not double-award anything — and every path records, which is why
  /// the write-nothing practice mode is gone.
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
    invalidateDaySurfaces(ref);
    ref.invalidate(todayLessonProvider);
    ref.invalidate(modulesWithProgressProvider);
    ref.invalidate(totalPointsProvider);
    ref.invalidate(completedLessonsProvider);
    ref.invalidate(collectedCardsProvider);
    // `cardsWithCollectionProvider` no longer chains through
    // `collectedCardsProvider`, so invalidate it explicitly.
    ref.invalidate(cardsWithCollectionProvider);
    // A finished lesson can unlock a Coffee Challenge, and Today and Profile
    // stay mounted behind this screen — so neither would notice on its own.
    ref.invalidate(savedChallengesProvider);
    ref.invalidate(completedChallengesProvider);

    final card = result.isReplay
        ? null
        : await content.getCardForLesson(lesson.id);
    // Read after the invalidation above, so it is the lesson queued *behind*
    // this completion rather than the one just finished.
    final next = await ref.read(todayLessonProvider.future);

    return LessonCompletionReward(
      result: result,
      lesson: lesson,
      card: card,
      nextLessonId: next?.id,
    );
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

    // **A run that closed its module plays one ending, not two** (#458).
    // This screen hands the moment over whole: its own beat never plays, and
    // the module ending reports what this lesson paid on its behalf.
    if (reward.result.moduleCompleted) {
      _handOverToModuleEnding(reward);
      return const LoadingIndicator();
    }

    if (!_beatDone) {
      return RoastyMoment(
        reaction: CompanionReaction.lessonComplete,
        eyebrow: completionEyebrow(isReplay: reward.result.isReplay),
        title: completionBeatTitle(widget.mastery.band),
        onDone: () {
          if (mounted) setState(() => _beatDone = true);
        },
      );
    }

    return Stack(
      children: [
        Positioned.fill(child: _content(reward)),
        // The design keeps the lesson topbar's X here, so the celebration is
        // never a screen the learner is held on.
        Positioned(
          top: 0,
          left: 0,
          child: IconButton(
            icon: const IconMark(AppIcon.close),
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            onPressed: () => context.goTo(pathTab),
          ),
        ),
      ],
    );
  }

  /// Replaces this route with the module ending, carrying the run's own facts.
  ///
  /// Scheduled off the frame rather than called during `build`, which is the
  /// only safe place to navigate from a builder. The latch makes it once: a
  /// rebuild before the route changes would otherwise queue a second
  /// navigation onto the same destination.
  void _handOverToModuleEnding(LessonCompletionReward reward) {
    if (_handedOver) return;
    _handedOver = true;
    final moduleId = _moduleId;
    if (moduleId == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.goTo(
        moduleSummary(
          moduleId,
          runLessonId: widget.lessonId,
          freezeEarned: reward.result.freezeEarned,
          fromStage: reward.result.treeStageBefore,
          toStage: reward.result.treeStageAfter,
        ),
      );
    });
  }

  /// The screen reports **the run that reached it**, which on a replay is not
  /// the stored best: `LessonFinishResult.mastery` is the never-downgraded
  /// record, and the design prints the run (`prototype/rewards.jsx:57-73`).
  /// Every band-driven surface below therefore reads `widget.mastery`.
  Widget _content(LessonCompletionReward reward) => LessonCompletionBody(
    lessonId: widget.lessonId,
    lessonTitle: reward.lesson.title,
    mastery: widget.mastery,
    reward: reward,
    actions: completionActions(
      lessonId: widget.lessonId,
      band: widget.mastery.band,
      nextLessonId: reward.nextLessonId,
    ),
  );
}
