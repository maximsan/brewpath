/// The streak's qualifying-activity rule (`docs/decisions.md` §2–§3, #33).
///
/// One question, asked of one day's stored completion entries: **did this day
/// count?** No clock, no storage, no widgets — the rule is a fold over strings
/// the day already holds, so a day can be re-judged at any time from what was
/// written rather than from a flag written alongside it.
///
/// The answer feeds two places and only two: the `marksDay` argument every
/// write path passes to `ClearedByReset.withActivity`, and [qualifyingDays],
/// which re-derives the set for a record whose marks were written by a peer.
library;

import 'package:brew_path/shared/storage/snapshot/daily_activity.dart';

/// Whether one completion of [type] protects the day on its own (§3).
///
/// Exhaustive on purpose: a new [ActivityType] does not compile until this
/// rule says what it counts for, which is the only place the answer belongs.
///
/// **Keep Sharp is absent because it is not an activity.** §6 gives it the
/// recommended type's own completion rule, so a completed recommendation
/// writes that type's entry and is judged by the line for it here.
///
/// **§4's non-qualifying list is absent for a stronger reason** — Coffee
/// Challenges, Term of the Day, reading a dictionary entry, browsing Saved or
/// the Coffee Cards, and Roasty or grove customisation have no [ActivityType]
/// at all, so nothing can write one. The exclusion is structural, not a
/// branch that could be forgotten.
bool _marksDayAlone(ActivityType type) => switch (type) {
  ActivityType.lesson => true,
  ActivityType.replay => true,
  ActivityType.vocab => true,
  ActivityType.flashcards => true,
  // The one activity that needs a partner: two *different* games (§5, #59).
  ActivityType.miniGame => false,
};

/// Whether a day's completion [entries] make it a qualifying day (§2–§3).
///
/// The **first** qualifying completion protects the day and nothing after it
/// adds a second — which costs no code here, because the answer is a boolean
/// over the whole day rather than a count.
///
/// An entry whose type this build does not recognise reads as **not**
/// qualifying. It was written by a newer build, which marked the day active in
/// the same write; `activeDays` unions across devices, so the mark arrives
/// even though the reason for it does not.
bool dayQualifies(Iterable<String> entries) {
  for (final raw in entries) {
    final type = parseActivityEntry(raw).type;
    if (type != null && _marksDayAlone(type)) return true;
  }
  return miniGamesMarkTheDay(entries);
}

/// The days in [dailyActivity] whose entries qualify them.
///
/// A second opinion on the stored `activeDays`, never a replacement for it:
/// the activity record is pruned to the last couple of days while the day set
/// is kept forever, so this can only ever confirm the recent end of it. Union
/// the two — that heals a day whose entries qualify but whose mark did not
/// survive the trip, and can never unmark a day.
Set<int> qualifyingDays(Map<int, Set<String>> dailyActivity) => {
  for (final entry in dailyActivity.entries)
    if (dayQualifies(entry.value)) entry.key,
};
