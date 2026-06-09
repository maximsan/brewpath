import 'package:coffee_quest/core/widgets/error_view.dart';
import 'package:coffee_quest/core/widgets/loading_indicator.dart';
import 'package:coffee_quest/features/learn/domain/learn_providers.dart';
import 'package:coffee_quest/features/mini_games/domain/mini_game_result.dart';
import 'package:coffee_quest/features/mini_games/presentation/lesson_step_runner.dart';
import 'package:coffee_quest/features/progress/domain/progress_providers.dart';
import 'package:coffee_quest/shared/models/lesson_step_model.dart';
import 'package:coffee_quest/shared/repositories/content_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Cross-lesson practice drill for a single game type. Pulls every step of
/// the chosen type out of the user's completed lessons and runs them through
/// the standard [LessonStepRunner]. No DB writes, no XP, no card unlocks.
class GameTypePracticeScreen extends ConsumerStatefulWidget {
  const GameTypePracticeScreen({required this.gameType, super.key});

  /// JSON discriminator: `multiple_choice` | `drag_drop` | `slider` |
  /// `tap_order`. Passed straight from the route path parameter.
  final String gameType;

  @override
  ConsumerState<GameTypePracticeScreen> createState() =>
      _GameTypePracticeScreenState();
}

class _GameTypePracticeScreenState
    extends ConsumerState<GameTypePracticeScreen> {
  late final Future<List<LessonStepModel>> _stepsFuture = _loadSteps();

  int _stepIndex = 0;
  int _attempt = 0;
  int _firstTryCorrectCount = 0;

  Future<List<LessonStepModel>> _loadSteps() async {
    final content = ref.read(contentRepositoryProvider);
    final completed = await ref.read(completedLessonsProvider.future);
    final completedIds = completed.map((r) => r.lessonId).toSet();
    final lessons = await content.getLessons();

    final steps = <LessonStepModel>[];
    for (final lesson in lessons) {
      if (!completedIds.contains(lesson.id)) continue;
      for (final step in lesson.steps) {
        if (stepTypeKey(step) == widget.gameType) steps.add(step);
      }
    }
    return steps;
  }

  void _onResult(int total, MiniGameResult result) {
    switch (result) {
      case MiniGameCorrect():
        if (_attempt == 0) _firstTryCorrectCount++;
        if (_stepIndex + 1 >= total) {
          setState(() => _stepIndex = total); // sentinel: finished
        } else {
          setState(() {
            _stepIndex++;
            _attempt = 0;
          });
        }
      case MiniGameIncorrect():
        setState(() => _attempt++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = gameTypeDisplayName(widget.gameType);
    return Scaffold(
      appBar: AppBar(title: Text('Practice · $title')),
      body: FutureBuilder<List<LessonStepModel>>(
        future: _stepsFuture,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const LoadingIndicator();
          }
          if (snap.hasError) return ErrorView(message: '${snap.error}');
          final steps = snap.data ?? const [];
          if (steps.isEmpty) return const _EmptyState();
          if (_stepIndex >= steps.length) {
            return _Summary(
              correct: _firstTryCorrectCount,
              total: steps.length,
            );
          }

          final theme = Theme.of(context);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '$title practice',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                _StepProgress(current: _stepIndex + 1, total: steps.length),
                const SizedBox(height: 24),
                LessonStepRunner(
                  key: ValueKey('${_stepIndex}_$_attempt'),
                  step: steps[_stepIndex],
                  onResult: (r) => _onResult(steps.length, r),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.school_outlined,
              size: 56,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No practice questions yet',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Complete a lesson with this game type to unlock practice.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go('/learn'),
              child: const Text('Back to Learn'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.correct, required this.total});

  final int correct;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.fitness_center,
                size: 48,
                color: colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Practice complete!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$correct / $total first-try correct',
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
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () => context.go('/learn'),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact step indicator matching the standard lesson runner's style.
class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
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
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Step $current of $total',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
          backgroundColor: colors.surfaceContainerHighest,
          color: colors.primary,
        ),
      ],
    );
  }
}
