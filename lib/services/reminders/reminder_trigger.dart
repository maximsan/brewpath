/// The zone a reminder is posted in, and the instant it is posted at — pure,
/// so the zone names iOS hands over can be asserted without a device.
library;

import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Loads the timezone database the reminder is posted against.
///
/// The full set, not `latest_10y`: iOS still names some zones by their old
/// names — `Asia/Calcutta`, `Europe/Kiev` — which only the full set carries.
void loadReminderZones() => tz_data.initializeTimeZones();

/// The zone [identifier] names, or null where the database has no such zone.
tz.Location? reminderZone(String identifier) {
  try {
    return tz.getLocation(identifier);
  } on tz.LocationNotFoundException {
    return null;
  }
}

/// The instant to hand the platform for [at]: the same wall clock in [zone],
/// or the instant itself in UTC where the zone is unknown — a reminder at the
/// right moment that ignores a later clock change beats none at all.
tz.TZDateTime reminderTrigger(DateTime at, tz.Location? zone) => zone == null
    ? tz.TZDateTime.from(at, tz.UTC)
    : tz.TZDateTime(zone, at.year, at.month, at.day, at.hour, at.minute);
