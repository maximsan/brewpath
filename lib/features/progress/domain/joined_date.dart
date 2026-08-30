import 'package:brew_path/core/utils/date_utils.dart';

/// The day Profile's closing line names — the earliest thing known about this
/// learner, or null when nothing is.
///
/// Two sources, and the **earlier** of them wins rather than one outranking
/// the other. [installedAt] is the recorded first run, which is the only source
/// that is right for someone who installed and did not start for weeks.
/// [activeDays] is what a device created before schema v11 has instead, and it
/// is also older evidence than any stamp when a restored snapshot carries days
/// from before this copy of the app existed. Taking the minimum is right in
/// both directions; ranking them is wrong in one.
///
/// Null when neither is known, so a device predating the stamp that has done
/// nothing shows no line rather than naming today.
///
/// Ruled by
/// [ADR-0012](../../../../docs/adr/0012-the-joined-line-dates-the-install-and-old-devices-are-not-back-dated.md).
DateTime? deriveJoinedDate({
  required DateTime? installedAt,
  required Set<int> activeDays,
}) {
  final installedDay = installedAt == null ? null : epochDay(installedAt);
  final firstActiveDay = activeDays.isEmpty
      ? null
      : activeDays.reduce((earliest, day) => day < earliest ? day : earliest);

  final joined = switch ((installedDay, firstActiveDay)) {
    (null, null) => null,
    (final int day, null) => day,
    (null, final int day) => day,
    (final int installed, final int active) =>
      installed < active ? installed : active,
  };

  return joined == null ? null : dateFromEpochDay(joined);
}
