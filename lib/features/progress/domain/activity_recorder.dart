/// The one write path for a completed activity.
library;

import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/progress/domain/qualifying_day.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/snapshot/daily_activity.dart';

/// Records one completed activity of [type] on [subject], against [now].
///
/// Every completion that counts goes through here — a lesson, a replay, a
/// mini-game run, and whatever registers a surface next — so the §2–§3 rule is
/// asked once and the two halves of the event never drift apart: the entry is
/// what happened, the active day is what it earned.
///
/// **Nothing here counts anything.** The streak, the freeze and the covered
/// days are folded back out of the day set by `deriveStreak` on every read, so
/// a completion leaves behind only the fact that it happened. The stored
/// counter this replaced could not survive two devices — five days offline on
/// each do not make five — where a union of days is exactly right.
///
/// Callers still own their own invalidation: only the widget layer knows what
/// was on screen when the day turned over.
Future<void> recordActivity(
  SnapshotRepository repository, {
  required ActivityType type,
  required String subject,
  required DateTime now,
}) async {
  final day = epochDay(now);
  final entry = activityEntry(
    type: type,
    token: mintActivityToken(),
    subject: subject,
  );

  final snapshot = await repository.read();
  final progress = snapshot.clearedByReset;
  await repository.write(
    snapshot.copyWith(
      updatedAt: now.millisecondsSinceEpoch,
      clearedByReset: progress.withActivity(
        day,
        entry,
        // The whole rule, not one activity's clause of it: a lesson already
        // finished today has marked the day, and asking the narrower question
        // would answer about a different day than the one being written.
        marksDay: dayQualifies({...?progress.dailyActivity[day], entry}),
      ),
    ),
  );
}
