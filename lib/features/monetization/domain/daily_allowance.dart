/// The free tier's daily ration of activities, as one rule.
///
/// `docs/decisions.md` §8 caps a free learner at two full learning/practice
/// activities per local calendar day; #65 settled that this counts every
/// practice format, replays included, as the cardinality of today's entries.
library;

/// How many full learning/practice activities a free local day holds.
///
/// Coffee Challenges and passive browsing spend none of it (§8), which is why
/// neither writes an entry to the record this counts.
const int freeDailyActivities = 2;

/// Whether another activity may start on a day already holding
/// [entriesToday].
///
/// Takes the entries rather than a count, so "the cap is how many entries
/// today holds" is stated here and not at a call site that could count
/// something else — including an entry whose type this build does not know,
/// which a newer one wrote and the learner still completed.
bool mayStartActivity({
  required bool hasCourse,
  required Iterable<String> entriesToday,
}) => hasCourse || entriesToday.length < freeDailyActivities;
