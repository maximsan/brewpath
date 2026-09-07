import 'dart:async';

import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/learn/presentation/today_card_layout.dart';
import 'package:brew_path/features/monetization/domain/locked_row_copy.dart';
import 'package:brew_path/features/monetization/domain/plus_gate_trigger.dart';
import 'package:brew_path/features/monetization/presentation/plus_gate_sheet.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/models/module_model.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The Today card when the next lesson is behind the purchase.
///
/// A free learner past the free lessons still has a next lesson, and hiding it
/// would leave the day's lead card either empty or pointing at work they have
/// already done. So the card shows the lesson and tells the truth about it:
/// the eyebrow is the wall, the count is what buying opens, and the action
/// says what it costs instead of reading *Begin lesson* and then refusing.
///
/// The same card as the open state, on the same surface. The eyebrow alone
/// changes colour — accent, which ADR-0016 gives the purchase lock and denies
/// progression — so the wall is told by the one line that names it, and the
/// module number that line replaces is not printed twice.
///
/// **One lock, on the action.** The design puts a single `<LockMark size={12}/>`
/// on the button and none in the eyebrow, which already says the same thing in
/// words; ADR-0016 keeps a row to one lock for the same reason.
class TodayLockedBody extends StatelessWidget {
  /// Creates a [TodayLockedBody] for [lesson].
  const TodayLockedBody({
    required this.lesson,
    required this.lessonsAhead,
    this.module,
    super.key,
  });

  /// The next lesson in course order — shown, not hidden.
  final LessonModel lesson;

  /// The module it belongs to, for its picture. Null draws the card without.
  final ModuleModel? module;

  /// Every lesson still ahead of the learner, course-wide, or null while the
  /// count is still being read.
  ///
  /// Null draws no line at all rather than a zero: `0 LESSONS AHEAD` on a card
  /// whose whole point is how much course is left would be the wrong half of a
  /// flash to show.
  final int? lessonsAhead;

  /// The design's `<LockMark size={12}/>` on the card's action.
  static const double _ctaLockSize = 12;

  /// The design's `color-mix(in oklab, var(--ink-mute) 62%, var(--ink))` on
  /// the meta line.
  static const double _metaInkShare = 0.62;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final ahead = lessonsAhead;

    return TodayCardLayout(
      // Tappable anywhere, like the locked Path row: this is where someone
      // meets the wall, and a dead card would say no without saying what it
      // costs.
      onTap: () => _offer(context),
      eyebrow: SmallcapsLabel(
        LockedRowCopy.continuesInFoundations,
        color: mood.accentText,
      ),
      title: lesson.title,
      module: module,
      meta: ahead == null ? null : _lessonsAheadLine(mood, ahead),
      action: PrimaryButton(
        label: LockedRowCopy.unlockFoundations,
        leadingMark: AppIcon.lock,
        leadingMarkSize: _ctaLockSize,
        // The button is the one thing a screen reader is asked to activate,
        // so it is where the lesson it would open belongs.
        semanticsLabel: LockedRowCopy.unlockToContinue(lesson.title),
        onPressed: () => _offer(context),
      ),
    );
  }

  /// What the purchase opens, counted rather than written down.
  Widget _lessonsAheadLine(MoodColors mood, int ahead) => Semantics(
    // A node of its own: excluding the descendants leaves the annotation with
    // nothing to attach to, and the label is silently dropped.
    container: true,
    // Spoken with what it is ahead *in*, which the uppercase line leaves to
    // the eyebrow above it.
    label: LockedRowCopy.lessonsAheadSemantics(ahead),
    excludeSemantics: true,
    child: Text(
      LockedRowCopy.lessonsAhead(ahead).toUpperCase(),
      style: AppText.label(
        mood: mood,
        face: AppFace.mono,
        color: mood.inkMix(_metaInkShare),
      ),
    ),
  );

  void _offer(BuildContext context) =>
      unawaited(showPlusGate(context, LockedLesson(title: lesson.title)));
}
