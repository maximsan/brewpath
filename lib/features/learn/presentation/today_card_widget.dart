import 'package:brew_path/features/learn/domain/keep_sharp_providers.dart';
import 'package:brew_path/features/learn/presentation/keep_sharp_card_body.dart';
import 'package:brew_path/features/learn/presentation/today_lesson_body.dart';
import 'package:brew_path/features/learn/presentation/today_locked_body.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Hero card for the day's primary action, in one of its three states: the
/// next lesson, that same lesson behind the purchase, or — when every
/// available lesson is done — the Keep Sharp recommendation for the day.
///
/// The card itself is the same accent hero in all three. Only what is written
/// on it changes, so the wall reads as a state of the day rather than as a
/// different surface the learner has been moved to.
class TodayCardWidget extends StatelessWidget {
  /// Creates a [TodayCardWidget].
  const TodayCardWidget({
    required this.today,
    this.isLocked = false,
    this.lessonsAhead,
    this.keepSharp,
    this.keepSharpDone = false,
    super.key,
  });

  /// The lesson due today, or `null` when the user is caught up.
  final LessonModel? today;

  /// Whether the free tier does not carry [today].
  ///
  /// Decided by `isLessonPurchaseLocked` where the entitlement is read, not
  /// here: the card draws the answer, it does not work it out.
  final bool isLocked;

  /// Every lesson still ahead of the learner, course-wide, or null while the
  /// count is still being read. Read only while [isLocked] — it is the locked
  /// card's pitch.
  final int? lessonsAhead;

  /// The day's Keep Sharp pick, shown when [today] is null. Null means no
  /// registered practice type has material (the quiet degenerate state).
  final KeepSharpRecommendation? keepSharp;

  /// Whether today's recommendation already met its own completion rule.
  final bool keepSharpDone;

  /// The hero card's corner. Public because each body clips its own ink
  /// splash to it, and a second copy of the figure is a second thing to keep
  /// in step.
  static const double heroRadius = 12;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final lesson = today;

    return Card(
      margin: EdgeInsets.zero,
      color: mood.accent,
      child: switch (lesson) {
        null => KeepSharpCardBody(
          recommendation: keepSharp,
          acknowledged: keepSharpDone,
        ),
        _ when isLocked => TodayLockedBody(
          lesson: lesson,
          lessonsAhead: lessonsAhead,
        ),
        _ => TodayLessonBody(lesson: lesson),
      },
    );
  }
}
