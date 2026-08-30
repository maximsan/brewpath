import 'package:brew_path/core/utils/date_utils.dart';

/// The date Profile's closing line names, or null when nothing is known.
///
/// [installedAt] is the recorded start of the account — written once, when the
/// database is created. It is the answer whenever it exists, because it is the
/// only source that is right for someone who installed the app and did not
/// start for weeks.
///
/// [activeDays] stands in when it does not. A database created before the
/// stamp shipped has no record of its own install and is deliberately not
/// back-dated by the migration, so the earliest day the learner did anything is
/// the closest thing that is actually true for them. It reads a month late for
/// the same late starter, which is the divergence the stamp closes going
/// forward and cannot close backwards.
///
/// Null when neither is known, so a fresh, untouched install shows no line
/// rather than naming today as the day they joined.
DateTime? deriveJoinedDate({
  required DateTime? installedAt,
  required Set<int> activeDays,
}) {
  if (installedAt != null) return installedAt;
  if (activeDays.isEmpty) return null;

  return dateFromEpochDay(
    activeDays.reduce((earliest, day) => day < earliest ? day : earliest),
  );
}
