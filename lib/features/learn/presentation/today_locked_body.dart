import 'dart:async';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/features/learn/presentation/today_card_widget.dart';
import 'package:brew_path/features/monetization/domain/locked_row_copy.dart';
import 'package:brew_path/features/monetization/domain/plus_gate_trigger.dart';
import 'package:brew_path/features/monetization/presentation/plus_gate_sheet.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';

/// The Today card when the next lesson is behind the purchase.
///
/// A free learner past the free lessons still has a next lesson, and hiding it
/// would leave the day's lead card either empty or pointing at work they have
/// already done. So the card shows the lesson and tells the truth about it:
/// the eyebrow is the wall, the count is what buying opens, and the action
/// says what it costs instead of reading *Start* and then refusing.
///
/// It keeps the accent hero it wears unlocked, so the wall reads as a state of
/// the day rather than as the app breaking. The design draws its own locked
/// card on the surface colour — but its *unlocked* card is on the surface
/// colour too, and this app's is not, so matching the tint would have copied
/// the wrong half of the relationship the design states.
///
/// **That choice has a cost, and it is not yet ruled on.** ADR-0016 says the
/// purchase lock is drawn in accent and progression in ink-mute. On an accent
/// ground there is no accent left to draw it in — the eyebrow, the count and
/// the lock all take `accentInk`, so nothing here separates a purchase lock
/// from a progression one by colour. The words carry it instead. Both halves
/// of this are the owner's to settle, on #215.
///
/// **One lock, on the action.** The design puts a single `<LockMark size={12}/>`
/// on the button and none in the eyebrow, which already says the same thing in
/// words; ADR-0016 keeps a row to one lock for the same reason.
class TodayLockedBody extends StatelessWidget {
  /// Creates a [TodayLockedBody] for [lesson].
  const TodayLockedBody({
    required this.lesson,
    required this.lessonsAhead,
    super.key,
  });

  /// The next lesson in course order — shown, not hidden.
  final LessonModel lesson;

  /// Every lesson still ahead of the learner, course-wide, or null while the
  /// count is still being read.
  ///
  /// Null draws no line at all rather than a zero: `0 LESSONS AHEAD` on a card
  /// whose whole point is how much course is left would be the wrong half of a
  /// flash to show.
  final int? lessonsAhead;

  /// The design's `<LockMark size={12}/>` on the card's action.
  static const double _ctaLockSize = 12;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    final ahead = lessonsAhead;

    return InkWell(
      // Tappable anywhere, like the locked Path row: this is where someone
      // meets the wall, and a dead card would say no without saying what it
      // costs.
      onTap: () => _offer(context),
      borderRadius: BorderRadius.circular(TodayCardWidget.heroRadius),
      child: Padding(
        padding: EdgeInsets.all(OffTokens.todayHeroPadding.value),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _eyebrow(theme, mood),
            const SizedBox(height: AppSpacing.xs),
            Text(
              lesson.title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: mood.accentInk,
              ),
            ),
            if (ahead != null) ...[
              const SizedBox(height: AppSpacing.xs),
              _lessonsAheadLine(mood, ahead),
            ],
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _offer(context),
                icon: const IconMark(AppIcon.lock, size: _ctaLockSize),
                // Relabelled rather than left as its own words: the button is
                // the one thing a screen reader is asked to activate, so it is
                // where the lesson it would open belongs.
                label: Semantics(
                  container: true,
                  label: LockedRowCopy.unlockToContinue(lesson.title),
                  excludeSemantics: true,
                  child: const Text(LockedRowCopy.unlockFoundations),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The wall, stated once. The module number the unlocked card carries is
  /// deliberately absent — this has replaced it.
  ///
  /// Given a semantics node of its own so it is announced as its own element
  /// rather than only as the first words of the card's long merged label.
  Widget _eyebrow(ThemeData theme, MoodColors mood) => Semantics(
    container: true,
    label: LockedRowCopy.continuesInFoundations,
    excludeSemantics: true,
    child: Text(
      LockedRowCopy.continuesInFoundations,
      style: theme.textTheme.labelMedium?.copyWith(color: mood.accentInk),
    ),
  );

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
        color: mood.accentInk,
        face: AppFace.mono,
      ),
    ),
  );

  void _offer(BuildContext context) =>
      unawaited(showPlusGate(context, LockedLesson(title: lesson.title)));
}
