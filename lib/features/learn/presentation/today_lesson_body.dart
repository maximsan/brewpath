import 'dart:async';

import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/learn/domain/lesson_position.dart';
import 'package:brew_path/features/learn/presentation/today_card_layout.dart';
import 'package:brew_path/features/lessons/domain/lesson_destination.dart';
import 'package:brew_path/features/monetization/presentation/activity_start.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/models/module_model.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The Today card when the lesson is the learner's to open: which module it
/// is in, what it is called, the module's picture, where it sits in the
/// module and how long it takes, and *Begin lesson*.
///
/// No points on the card. The design's meta line is position and time —
/// `LESSON 1/7 · ~3 MIN` — and what finishing pays is the lesson's own to
/// announce, at the end.
class TodayLessonBody extends StatelessWidget {
  /// Creates a [TodayLessonBody] for [lesson].
  const TodayLessonBody({required this.lesson, this.module, super.key});

  /// The lesson due today.
  final LessonModel lesson;

  /// The module it belongs to, or null while unknown — no picture and no
  /// position, rather than a wrong one.
  final ModuleModel? module;

  /// The design's `color-mix(in oklab, var(--ink-mute) 62%, var(--ink))` on
  /// the meta line.
  static const double _metaInkShare = 0.62;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final module = this.module;
    final position = module == null
        ? null
        : lessonPositionIn(module, lesson.id);

    void open() => unawaited(context.goToActivity(lessonRun(lesson.id)));

    return TodayCardLayout(
      onTap: open,
      eyebrow: SmallcapsLabel(lesson.moduleLabel),
      title: lesson.title,
      module: module,
      meta: position == null
          ? null
          : Semantics(
              container: true,
              label: todayMetaSemantics(position, minutes: lesson.time),
              excludeSemantics: true,
              child: Text(
                todayMetaLine(position, minutes: lesson.time),
                style: AppText.label(
                  mood: mood,
                  face: AppFace.mono,
                  color: mood.inkMix(_metaInkShare),
                ),
              ),
            ),
      action: PrimaryButton(
        label: AppLabels.beginLesson,
        // The lesson it opens, said once, where the reader is asked to act.
        semanticsLabel: '${AppLabels.beginLesson}: ${lesson.title}',
        onPressed: open,
      ),
    );
  }
}
