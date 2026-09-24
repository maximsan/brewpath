import 'dart:async';

import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/utils/module_icons.dart';
import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/features/learn/domain/lesson_module_groups.dart';
import 'package:brew_path/features/learn/presentation/practice/practice_sub_group.dart';
import 'package:brew_path/features/learn/presentation/practice/replay_row.dart';
import 'package:brew_path/features/lessons/presentation/replay_confirm_sheet.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The finished lessons under the list's *Lessons* group, one sub-group per
/// module, each row the lesson's title alone.
///
/// The module's glyph and eyebrow sit on the sub-group's header, never on a
/// row, and a row carries no duration: the confirm sheet states the length
/// before anything starts. A lone module arrives open; several arrive shut.
class PracticeAnyLessonWidget extends StatelessWidget {
  /// Creates a [PracticeAnyLessonWidget].
  const PracticeAnyLessonWidget({required this.lessons, super.key});

  /// Every finished lesson, with its module, in course order.
  final List<LessonWithModule> lessons;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final groups = groupLessonsByModule(lessons);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final group in groups)
          PracticeSubGroup(
            label: group.label,
            count: group.lessons.length,
            openAtFirst: groups.length == 1,
            // The design's `CatGlyph size={18} color="var(--ink-mute)"`.
            mark: IconMark(
              moduleMark(group.module.iconName),
              size: PracticeSubGroup.markSize,
              color: mood.inkMute,
            ),
            children: [
              for (final entry in group.lessons)
                ReplayRow(
                  title: entry.lesson.title,
                  // A replay, not a throwaway run: reaching the final card
                  // records the day (§3), exactly as replaying from the
                  // course path does.
                  onTap: () => unawaited(
                    context.goToLessonAskingReview(entry.lesson.id),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
