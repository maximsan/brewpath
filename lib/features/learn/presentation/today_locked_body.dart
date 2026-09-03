import 'dart:async';

import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/features/monetization/domain/locked_row_copy.dart';
import 'package:brew_path/features/monetization/domain/plus_gate_trigger.dart';
import 'package:brew_path/features/monetization/presentation/plus_gate_sheet.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The Today card when the next lesson is behind the purchase.
///
/// A free learner past the free lessons still has a next lesson, and hiding it
/// would leave the day's lead card either empty or pointing at work they have
/// already done. So the card shows the lesson and tells the truth about it:
/// the eyebrow is the wall, the count is what buying opens, and the action
/// says what it costs instead of reading *Start* and then refusing.
///
/// It keeps the accent hero it wears unlocked. This is the card the learner
/// opens the app onto, and demoting it to a grey panel would make the wall
/// read as the app breaking rather than as something for sale.
class TodayLockedBody extends StatelessWidget {
  /// Creates a [TodayLockedBody] for [lesson].
  const TodayLockedBody({
    required this.lesson,
    required this.lessonsAhead,
    super.key,
  });

  /// The next lesson in course order — shown, not hidden.
  final LessonModel lesson;

  /// Every lesson still ahead of the learner, course-wide.
  final int lessonsAhead;

  /// The hero card's corner, which the ink splash has to be clipped to.
  static const double _heroRadius = 12;
  static const double _iconSm = 18;

  /// The design's `<LockMark size={12}/>` on the card's action.
  static const double _ctaLockSize = 12;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;

    return InkWell(
      // Tappable anywhere, like the locked Path row: this is where someone
      // meets the wall, and a dead card would say no without saying what it
      // costs.
      onTap: () => _offer(context),
      borderRadius: BorderRadius.circular(_heroRadius),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _eyebrow(theme, mood),
            const SizedBox(height: 8),
            Text(
              lesson.title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: mood.accentInk,
              ),
            ),
            const SizedBox(height: 8),
            _lessonsAheadLine(mood),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _offer(context),
                icon: const IconMark(AppIcon.lock, size: _ctaLockSize),
                label: const Text(LockedRowCopy.unlockFoundations),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The wall, stated once. The module number the unlocked card carries is
  /// deliberately absent — the eyebrow has replaced it.
  Widget _eyebrow(ThemeData theme, MoodColors mood) => Semantics(
    // A node of its own: excluding the descendants leaves the annotation with
    // nothing to attach to, and the label is silently dropped.
    container: true,
    label: LockedRowCopy.continuesInFoundations,
    excludeSemantics: true,
    child: Row(
      children: [
        IconMark(AppIcon.lock, size: _iconSm, color: mood.accentInk),
        const SizedBox(width: 8),
        Text(
          LockedRowCopy.continuesInFoundations,
          style: theme.textTheme.labelMedium?.copyWith(
            color: mood.accentInk,
          ),
        ),
      ],
    ),
  );

  /// What the purchase opens, counted rather than written down.
  Widget _lessonsAheadLine(MoodColors mood) => Semantics(
    container: true,
    // Spoken with what it is ahead *in*, which the uppercase line leaves to
    // the eyebrow above it.
    label: LockedRowCopy.lessonsAheadSemantics(lessonsAhead),
    excludeSemantics: true,
    child: Text(
      LockedRowCopy.lessonsAhead(lessonsAhead).toUpperCase(),
      style: AppText.label(
        mood: mood,
        color: mood.accentInk,
        face: AppFace.mono,
      ),
    ),
  );

  void _offer(BuildContext context) =>
      unawaited(showPlusGate(context, LockedLesson(title: lesson.title)));
}
