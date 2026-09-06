import 'dart:async';

import 'package:brew_path/core/widgets/bean_gauge.dart';
import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/features/learn/presentation/practice/replay_row.dart';
import 'package:brew_path/features/lessons/domain/lesson_destination.dart';
import 'package:brew_path/features/monetization/presentation/activity_start.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The finished lessons, one replay row each, under the shelf's *Lessons*
/// group.
///
/// Draws nothing for an empty list, and the group that holds it is not drawn
/// either: the design lists the group only once there is something finished
/// to revisit, so a new learner's shelf opens on Games alone.
class PracticeAnyLessonWidget extends StatelessWidget {
  /// Creates a [PracticeAnyLessonWidget].
  const PracticeAnyLessonWidget({required this.lessons, super.key});

  /// Every finished lesson, with its module, in course order.
  final List<LessonWithModule> lessons;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in lessons)
          ReplayRow(
            // The design's `FlavorWheel` drawn full: the bean gauge at its
            // full mark, at the size it is drawn.
            icon: BeanGauge(
              fill: 1,
              color: mood.accent,
              muted: mood.inkMute,
              ink: mood.ink,
            ),
            title: entry.lesson.title,
            sub: entry.lesson.moduleLabel,
            meta: '~${entry.lesson.time} min',
            // A replay, not a throwaway run: reaching the final card records
            // the day (§3), exactly as replaying from the course path does.
            // Where the learner started it has never been what decides
            // whether it counts.
            onTap: () =>
                unawaited(context.goToActivity(lessonRun(entry.lesson.id))),
          ),
      ],
    );
  }
}
