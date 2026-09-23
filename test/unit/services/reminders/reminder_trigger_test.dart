import 'package:brew_path/services/reminders/reminder_trigger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(loadReminderZones);

  final eightAm = DateTime(2026, 9, 24, 8);

  test('the name iOS gives India resolves', () {
    // Foundation's `knownTimeZoneIdentifiers` holds `Asia/Calcutta` and not
    // `Asia/Kolkata`; a database without the old names has no zone for a
    // learner there, and they would never get a reminder.
    expect(reminderZone('Asia/Calcutta'), isNotNull);
    expect(reminderZone('Europe/Kiev'), isNotNull);
    expect(reminderZone('Asia/Katmandu'), isNotNull);
  });

  test('a zone the database lacks is null, not a throw', () {
    expect(reminderZone('Nowhere/Nothing'), isNull);
  });

  test('the trigger is the slot on the wall clock in the zone', () {
    final trigger = reminderTrigger(eightAm, reminderZone('Asia/Calcutta'));

    expect(trigger.location.name, 'Asia/Calcutta');
    expect(trigger.hour, 8);
    expect(trigger.minute, 0);
    // 8:00 in India is 02:30 UTC, whatever zone this test happens to run in.
    expect(trigger.toUtc(), DateTime.utc(2026, 9, 24, 2, 30));
  });

  test('with no zone the instant itself is kept', () {
    final trigger = reminderTrigger(eightAm, null);

    expect(trigger.millisecondsSinceEpoch, eightAm.millisecondsSinceEpoch);
  });
}
