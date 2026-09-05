/// Gathering the day set the fold reads, from every store that knows a day.
library;

import 'package:brew_path/features/progress/domain/qualifying_day.dart';

/// Every local calendar day the learner is known to have shown up on.
///
/// Three sources, unioned — which is the whole safety property: a union can
/// only ever *add* a day, so no source can unmark one another source recorded,
/// and disagreement between them costs nothing.
///
/// - [activeDays] is the record. It is the only one kept forever, it is what
///   merges across devices, and it is what a write path adds to.
/// - [dailyActivity] re-derives the recent end of it. The activity record is
///   pruned to the last couple of days, so this can only confirm days already
///   in [activeDays] — what it buys is a day whose entries arrived from a peer
///   without their mark.
/// - [firstCompletionDays] is the **backfill**, and the reason this function
///   exists. A learner who finished lessons before the day set was written has
///   a full history in the completion records and an empty [activeDays]; left
///   alone, moving the streak onto the day set would silently zero the streak
///   of every install that already had one. Reset clears the completion
///   records along with the day set, so this cannot resurrect a streak the
///   learner asked to be rid of.
///
/// The backfill is a **read-time union, not a migration**: it writes nothing,
/// so it is idempotent, needs no version gate, and cannot half-apply. It stops
/// mattering on its own once every completion also records a day — it just
/// keeps agreeing with [activeDays] instead of adding to it.
Set<int> streakDaySet({
  required Set<int> activeDays,
  required Map<int, Set<String>> dailyActivity,
  required Iterable<int> firstCompletionDays,
}) => {
  ...activeDays,
  ...qualifyingDays(dailyActivity),
  ...firstCompletionDays,
};
