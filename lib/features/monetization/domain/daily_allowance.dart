/// The free tier's daily ration of activities, as one rule.
///
/// `docs/decisions.md` §8 caps a free learner at two full learning/practice
/// activities per local calendar day. #65 settled what that counts — every
/// practice format, replays included — and settled the record it reads: a
/// per-day set of completion *events*, so the cap is that set's cardinality.
///
/// Pure, and it takes the day's entries rather than a number, so the sentence
/// "the cap is how many entries today holds" lives here and not at a call site
/// that could count something else.
library;

/// How many full learning/practice activities a free local day holds.
///
/// Coffee Challenges and passive browsing spend none of it (§8), which is why
/// neither writes an entry to the record this counts.
const int freeDailyActivities = 2;

/// Whether another activity may start on a day already holding
/// [entriesToday].
///
/// **Every entry counts, including one this build cannot read.** A newer build
/// may write an activity type this one does not know; it is still something
/// the learner completed, and a downgrade that handed free activities back
/// would be a leak rather than a kindness.
bool mayStartActivity({
  required bool hasCourse,
  required Iterable<String> entriesToday,
}) => hasCourse || entriesToday.length < freeDailyActivities;
