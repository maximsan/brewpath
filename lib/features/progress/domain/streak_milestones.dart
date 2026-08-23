/// The streak's milestone schedule, ring fraction, and celebration rule
/// (#26, #236).
library;

/// The early schedule; past its last entry a milestone lands every
/// [lateMilestoneInterval] days.
const List<int> earlyMilestones = [3, 7, 14, 30, 60, 100, 180, 365];

/// Days between milestones once the early schedule runs out.
const int lateMilestoneInterval = 30;

/// Whether [streak] lands exactly on a milestone.
bool isMilestone(int streak) {
  if (earlyMilestones.contains(streak)) return true;
  return streak > earlyMilestones.last && streak % lateMilestoneInterval == 0;
}

/// The next milestone strictly above [streak].
int nextMilestone(int streak) {
  for (final milestone in earlyMilestones) {
    if (milestone > streak) return milestone;
  }
  return (streak ~/ lateMilestoneInterval + 1) * lateMilestoneInterval;
}

/// The ring's fill toward the next milestone, 0..1.
///
/// Always short of full by construction — [nextMilestone] is strictly above
/// the count, so a freshly-hit milestone shows the ring reaching toward the
/// next one rather than a closed circle with nothing left to want.
double milestoneRingFraction(int streak) {
  if (streak <= 0) return 0;
  return streak / nextMilestone(streak);
}

/// Whether the celebration beat is due: today's streak sits exactly on a
/// milestone and today is later than the acknowledged day.
///
/// Max-merged day semantics make this self-heal after a lapse: break the
/// streak, climb back to seven, and that day is later than the acknowledgement
/// — so the comeback celebrates again. A single day can never hold two
/// milestones, since the streak advances at most once per calendar day.
bool milestoneCelebrationDue({
  required int streak,
  required int? ackedDay,
  required int today,
}) => isMilestone(streak) && (ackedDay == null || today > ackedDay);
