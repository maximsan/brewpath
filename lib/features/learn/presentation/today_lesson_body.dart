import 'dart:async';

import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/features/learn/presentation/today_card_widget.dart';
import 'package:brew_path/features/lessons/domain/lesson_destination.dart';
import 'package:brew_path/features/monetization/presentation/activity_start.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';

/// The Today card when the lesson is the learner's to open: what it is, where
/// it sits in the course, what finishing it pays, and a way in.
class TodayLessonBody extends StatelessWidget {
  /// Creates a [TodayLessonBody] for [lesson].
  const TodayLessonBody({required this.lesson, super.key});

  /// The lesson due today.
  final LessonModel lesson;

  static const double _mutedAlpha = 0.8;
  static const double _iconSm = 18;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;

    return InkWell(
      onTap: () => unawaited(context.goToActivity(lessonRun(lesson.id))),
      borderRadius: BorderRadius.circular(TodayCardWidget.heroRadius),
      child: Padding(
        padding: EdgeInsets.all(OffTokens.todayHeroPadding.value),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconMark(
                  AppIcon.cup,
                  size: _iconSm,
                  color: mood.accentInk,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  "Today's lesson",
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: mood.accentInk,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              lesson.title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: mood.accentInk,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              // Where in the course this sits. The lessons bank authors no
              // blurb, and the module label is what the design prints here.
              lesson.moduleLabel,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: mood.accentInk.withValues(alpha: _mutedAlpha),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _PointsPill(points: lesson.points),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () =>
                      unawaited(context.goToActivity(lessonRun(lesson.id))),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact `+PTS` reward chip shown on the hero card.
/// The points pill's own padding — the design's `padding: 6px 10px`, neither
/// of which is a spacing stop.
const double _pillPadX = 10;
const double _pillPadY = 6;

class _PointsPill extends StatelessWidget {
  const _PointsPill({required this.points});

  final int points;

  static const double _pillRadius = 20;
  static const double _pillAlpha = 0.12;
  static const double _iconMd = 16;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _pillPadX,
        vertical: _pillPadY,
      ),
      decoration: BoxDecoration(
        color: mood.accentInk.withValues(alpha: _pillAlpha),
        borderRadius: BorderRadius.circular(_pillRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconMark(AppIcon.bean, size: _iconMd, color: mood.accentInk),
          const SizedBox(width: 4),
          Text(
            '+$points PTS',
            style: theme.textTheme.labelMedium?.copyWith(
              color: mood.accentInk,
            ),
          ),
        ],
      ),
    );
  }
}
