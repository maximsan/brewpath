import 'package:brew_path/core/widgets/error_view.dart';
import 'package:brew_path/core/widgets/loading_indicator.dart';
import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/features/learn/presentation/game_type_practice_widgets.dart';
import 'package:brew_path/features/mini_games/presentation/lesson_step_runner.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/shared/models/lesson_step_model.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cross-lesson practice drill for a single game type. Pulls every step of
/// the chosen type out of the user's completed lessons and runs them through
/// the standard [LessonStepRunner]. No DB writes, no XP, no card unlocks.
class GameTypePracticeScreen extends ConsumerStatefulWidget {
  /// Creates a [GameTypePracticeScreen].
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
  int _correctCount = 0; // there is no second try, so this is simply correct

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

  void _onSolved() => _correctCount++;

  void _onContinue(int total) {
    setState(() {
      // total is the sentinel for "finished".
      _stepIndex = _stepIndex + 1 >= total ? total : _stepIndex + 1;
    });
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
          if (steps.isEmpty) return const GameTypeEmptyState();
          if (_stepIndex >= steps.length) {
            return GameTypeSummary(
              correct: _correctCount,
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
                GameTypeStepProgress(
                  current: _stepIndex + 1,
                  total: steps.length,
                ),
                const SizedBox(height: 24),
                LessonStepRunner(
                  key: ValueKey(_stepIndex),
                  step: steps[_stepIndex],
                  onSolved: _onSolved,
                  onContinue: () => _onContinue(steps.length),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
