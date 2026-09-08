import 'package:brew_path/features/learn/domain/keep_sharp_providers.dart';
import 'package:brew_path/features/learn/presentation/keep_sharp_card_body.dart';
import 'package:brew_path/features/learn/presentation/today_lesson_body.dart';
import 'package:brew_path/features/learn/presentation/today_locked_body.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/models/module_model.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The card for the day's primary action, in one of its three states: the
/// next lesson, that same lesson behind the purchase, or — when every
/// available lesson is done — the Keep Sharp recommendation for the day.
///
/// **Two skins, not three.** The design draws the lesson card on the surface
/// with a rule around it (`.card`), in both its open and its locked state, so
/// the wall reads as the same card saying something else. Keep Sharp alone
/// takes the accent (`background: var(--accent)`): it is a state of the day,
/// not a lesson, and the colour is what says so at a glance.
class TodayCardWidget extends StatelessWidget {
  /// Creates a [TodayCardWidget].
  const TodayCardWidget({
    required this.today,
    this.module,
    this.isLocked = false,
    this.lessonsAhead,
    this.keepSharp,
    this.keepSharpDone = false,
    super.key,
  });

  /// The lesson due today, or `null` when the user is caught up.
  final LessonModel? today;

  /// The module [today] belongs to — its picture, and the lesson's place in
  /// it. Null while the modules are still being read, which draws the card
  /// with neither rather than holding it back.
  final ModuleModel? module;

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

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final lesson = today;

    if (lesson == null) {
      return _shell(
        fill: mood.accent,
        edge: mood.accent,
        child: KeepSharpCardBody(
          recommendation: keepSharp,
          acknowledged: keepSharpDone,
        ),
      );
    }
    return _shell(
      fill: mood.surface,
      edge: mood.rule,
      child: isLocked
          ? TodayLockedBody(
              lesson: lesson,
              module: module,
              lessonsAhead: lessonsAhead,
            )
          : TodayLessonBody(lesson: lesson, module: module),
    );
  }

  /// The design's `.card`: a fill, a one-pixel edge, and the chrome radius.
  Widget _shell({
    required Color fill,
    required Color edge,
    required Widget child,
  }) => Card(
    margin: EdgeInsets.zero,
    color: fill,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.chrome),
      side: BorderSide(color: edge),
    ),
    child: child,
  );
}
