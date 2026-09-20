/// The Learn-tab save notice: when it is due, and what it says (#233).
library;

import 'package:brew_path/features/progress/domain/freeze_status_line.dart';
import 'package:brew_path/features/progress/domain/streak_status.dart';

/// The acks-map key for the save notice. The value is the **covered day**
/// being acknowledged — not the day it was shown — so a later save is a new
/// notice by construction and max-merge keeps the newest acknowledgement.
const String freezeSaveAckKey = 'freezeSave';

/// The notice's headline.
const String freezeSaveNoticeTitle = 'Your streak is safe.';

/// The covered day the notice should announce, or null when nothing is due.
///
/// Due when the newest covered day is later than [ackedDay] **and** every
/// day since it is active: otherwise the run broke after the save and "your
/// streak is safe" would be a lie.
int? dueFreezeSaveDay({
  required Set<int> activeDays,
  required StreakStatus status,
  required int? ackedDay,
  required int today,
}) {
  final pastDays = status.frozenDays.where((day) => day < today);
  if (pastDays.isEmpty) return null;
  final covered = pastDays.reduce((a, b) => a > b ? a : b);
  if (ackedDay != null && covered <= ackedDay) return null;
  for (var day = covered + 1; day < today; day++) {
    if (!activeDays.contains(day)) return null;
  }
  return covered;
}

/// The notice body: which day was covered, and when the next freeze comes.
///
/// One branch of copy by design — the prototype's "N still held" variant was
/// dead code under cap 1 and was deleted at the design source (#196). The
/// held tail exists only for the learner who has already re-earned by the
/// time they read this.
String freezeSaveNoticeBody({
  required int coveredDay,
  required StreakStatus status,
  required DateTime today,
}) {
  final dayName = recentDayName(coveredDay, today: today) ?? 'A missed day';
  final daysLeft = status.daysToNextFreeze;
  final tail = status.freezeHeld || daysLeft == null
      ? 'You already hold the next one.'
      : daysLeft == 1
      ? "You'll earn another in 1 day."
      : "You'll earn another in $daysLeft days.";
  return '$dayName was covered by a freeze. $tail';
}
