import 'dart:async';

import 'package:brew_path/core/constants/xp_values.dart';
import 'package:brew_path/core/widgets/error_view.dart';
import 'package:brew_path/core/widgets/loading_indicator.dart';
import 'package:brew_path/features/lessons/presentation/xp_gain_toast.dart';
import 'package:brew_path/features/mini_games/domain/mini_game_result.dart';
import 'package:brew_path/features/mini_games/presentation/lesson_step_runner.dart';
import 'package:brew_path/services/analytics/analytics_provider.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const double _pillRadius = 20;
const int _percentScale = 100;
const double _progressBarHeight = 6;
const double _progressBarRadius = 3;
const double _xpToastTop = 96; // sits below the step-progress header

/// Immersive single-lesson flow: plays each step, then routes to completion.
class LessonScreen extends ConsumerStatefulWidget {
  /// Creates a [LessonScreen].
  const LessonScreen({
    required this.lessonId,
    super.key,
    this.review = false,
    this.practice = false,
  });

  /// Id of the lesson to play.
  final String lessonId;

  /// Whether this run is a review of an already-completed lesson. Carried
  /// through to the completion screen so it skips re-awarding XP.
  final bool review;

  /// Whether this run is a pure practice repetition launched from the Learn
  /// tab's "Practice Any Lesson" section. Practice runs never call
  /// completeLesson or reviewLesson — no XP, no card, no streak, no module
  /// bonus, no DB writes. Takes precedence over [review].
  final bool practice;

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  int _stepIndex = 0;
  int _attempt = 0; // bumped on a wrong answer to remount the step fresh
  int _firstTryCorrectCount = 0; // steps cleared on the first attempt
  bool _started = false; // ensures lesson_started fires exactly once
  int _xpToastSeq = 0; // bumped per correct step to restart the toast
  bool _xpToastVisible = false;

  void _logStartedOnce(LessonModel lesson) {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        ref
            .read(analyticsServiceProvider)
            .logEvent(
              'lesson_started',
              parameters: {
                'lesson_id': lesson.id,
                'module_id': lesson.moduleId,
              },
            ),
      );
    });
  }

  void _onResult(LessonModel lesson, MiniGameResult result) {
    switch (result) {
      case MiniGameCorrect():
        if (_attempt == 0) _firstTryCorrectCount++;
        if (_stepIndex + 1 >= lesson.steps.length) {
          // Mastery = first-try accuracy as a percentage (0–100).
          final score = (100 * _firstTryCorrectCount / lesson.steps.length)
              .round();
          context.go(
            '/learn/lesson/${lesson.id}/complete'
            '?review=${widget.review}&practice=${widget.practice}&score=$score',
          );
        } else {
          setState(() {
            _stepIndex++;
            _attempt = 0;
            _xpToastSeq++; // float a per-step "+XP" toast on advance
            _xpToastVisible = true;
          });
        }
      case MiniGameIncorrect():
        setState(() => _attempt++); // retry the same step
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(contentRepositoryProvider);
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<LessonModel?>(
        future: repo.getLessonById(widget.lessonId),
        builder: _buildBody,
      ),
    );
  }

  Widget _buildBody(BuildContext context, AsyncSnapshot<LessonModel?> snap) {
    if (snap.connectionState != ConnectionState.done) {
      return const LoadingIndicator();
    }
    if (snap.hasError) return ErrorView(message: '${snap.error}');
    final lesson = snap.data;
    if (lesson == null || lesson.steps.isEmpty) {
      return const ErrorView(message: 'Lesson not found');
    }
    _logStartedOnce(lesson);
    return Stack(
      children: [
        _lessonContent(context, lesson),
        if (_xpToastVisible)
          Positioned(
            top: _xpToastTop,
            left: 0,
            right: 0,
            child: Center(
              child: XpGainToast(
                key: ValueKey(_xpToastSeq),
                amount: XpValues.perStep,
                onComplete: () => setState(() => _xpToastVisible = false),
              ),
            ),
          ),
      ],
    );
  }

  Widget _lessonContent(BuildContext context, LessonModel lesson) {
    final step = lesson.steps[_stepIndex];
    final theme = Theme.of(context);
    final mood = context.mood;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            lesson.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            lesson.summary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: mood.inkMute,
            ),
          ),
          const SizedBox(height: 16),
          _StepProgress(current: _stepIndex + 1, total: lesson.steps.length),
          const SizedBox(height: 24),
          LessonStepRunner(
            key: ValueKey('${_stepIndex}_$_attempt'),
            step: step,
            onResult: (r) => _onResult(lesson, r),
          ),
        ],
      ),
    );
  }
}

/// Compact step indicator above the active mini-game: a pill on the left
/// (`Step X of Y`), percent on the right, themed progress bar beneath.
class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    final progress = total == 0 ? 0.0 : current / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: mood.accent,
                borderRadius: BorderRadius.circular(_pillRadius),
              ),
              child: Text(
                'Step $current of $total',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: mood.accentInk,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${(progress * _percentScale).round()}%',
              style: theme.textTheme.labelMedium?.copyWith(
                color: mood.inkMute,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          minHeight: _progressBarHeight,
          borderRadius: BorderRadius.circular(_progressBarRadius),
          backgroundColor: mood.surface2,
          color: mood.accent,
        ),
      ],
    );
  }
}
