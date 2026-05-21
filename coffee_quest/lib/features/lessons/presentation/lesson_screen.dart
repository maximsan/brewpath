import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:coffee_quest/core/widgets/error_view.dart';
import 'package:coffee_quest/core/widgets/loading_indicator.dart';
import 'package:coffee_quest/features/mini_games/domain/mini_game_result.dart';
import 'package:coffee_quest/features/mini_games/presentation/lesson_step_runner.dart';
import 'package:coffee_quest/services/analytics/analytics_provider.dart';
import 'package:coffee_quest/shared/models/lesson_model.dart';
import 'package:coffee_quest/shared/repositories/content_repository.dart';

class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  int _stepIndex = 0;
  int _attempt = 0; // bumped on a wrong answer to remount the step fresh
  bool _started = false; // ensures lesson_started fires exactly once

  void _logStartedOnce(LessonModel lesson) {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(analyticsServiceProvider)
          .logEvent(
            'lesson_started',
            parameters: {'lesson_id': lesson.id, 'module_id': lesson.moduleId},
          );
    });
  }

  void _onResult(LessonModel lesson, MiniGameResult result) {
    switch (result) {
      case MiniGameCorrect():
        if (_stepIndex + 1 >= lesson.steps.length) {
          context.go('/learn/lesson/${lesson.id}/complete');
        } else {
          setState(() {
            _stepIndex++;
            _attempt = 0;
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
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const LoadingIndicator();
          }
          if (snap.hasError) return ErrorView(message: '${snap.error}');
          final lesson = snap.data;
          if (lesson == null || lesson.steps.isEmpty) {
            return const ErrorView(message: 'Lesson not found');
          }
          _logStartedOnce(lesson);
          final step = lesson.steps[_stepIndex];
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  lesson.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(lesson.summary),
                const SizedBox(height: 8),
                Text(
                  'Step ${_stepIndex + 1} of ${lesson.steps.length}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const Divider(height: 32),
                LessonStepRunner(
                  key: ValueKey('${_stepIndex}_$_attempt'),
                  step: step,
                  onResult: (r) => _onResult(lesson, r),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
