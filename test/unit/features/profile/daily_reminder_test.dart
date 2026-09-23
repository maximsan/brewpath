import 'dart:io';

import 'package:brew_path/features/profile/domain/daily_reminder.dart';
import 'package:flutter_test/flutter_test.dart';

// The slots and copy are read back out of the design rather than restated.
void main() {
  test("offers the design's eight slots, in its order", () {
    // The design writes them as one array; a set of times that drifted from it
    // would be the app inventing a schedule.
    final source = File('prototype/settings.jsx').readAsStringSync();
    final declaration = RegExp(
      r'const REMINDER_TIMES = \[([^\]]*)\]',
    ).firstMatch(source);

    expect(
      declaration,
      isNotNull,
      reason: 'the design no longer declares REMINDER_TIMES',
    );

    final stated = RegExp("'([^']+)'")
        .allMatches(declaration!.group(1)!)
        .map((match) => match.group(1)!)
        .toList();

    expect(DailyReminder.times, stated);
  });

  test('every slot fires at the time its label reads', () {
    // The label is what the learner picks; the hour and minute are what the
    // notification is scheduled for. A typo between them is a reminder at the
    // wrong time of day and nothing on screen says so.
    const noon = 12;
    for (final slot in DailyReminder.slots) {
      final written = RegExp(
        r'^(\d{1,2}):(\d{2}) (AM|PM)$',
      ).firstMatch(slot.label);
      expect(written, isNotNull, reason: slot.label);

      final onTheClock = int.parse(written!.group(1)!) % noon;
      expect(
        slot.hour,
        written.group(3) == 'PM' ? onTheClock + noon : onTheClock,
        reason: slot.label,
      );
      expect(slot.minute, int.parse(written.group(2)!), reason: slot.label);
    }
  });

  group('the slot a learner starts on', () {
    test("is the design's while it is still ahead", () {
      expect(
        DailyReminder.openingSlot(DateTime(2026, 9, 23, 6)).label,
        '8:00 AM',
      );
      expect(
        DailyReminder.openingSlot(DateTime(2026, 9, 23, 7, 59)).label,
        '8:00 AM',
      );
    });

    test('is the next one ahead once the default has gone by', () {
      // Switching the reminder on today has to give one today, which a slot
      // already past cannot (ruled 23 September 2026, #443).
      expect(
        DailyReminder.openingSlot(DateTime(2026, 9, 23, 9)).label,
        '12:30 PM',
      );
      expect(
        DailyReminder.openingSlot(DateTime(2026, 9, 23, 13)).label,
        '6:00 PM',
      );
    });

    test('the slot exactly now has gone by, not still ahead', () {
      // 8:00 on the dot is not a reminder anyone still gets today, so the
      // opening slot steps to the next one rather than keeping it.
      expect(
        DailyReminder.openingSlot(DateTime(2026, 9, 23, 8)).label,
        '8:30 AM',
      );
    });

    test("falls back to the design's once no slot is left today", () {
      expect(
        DailyReminder.openingSlot(DateTime(2026, 9, 23, 22)).label,
        DailyReminder.defaultTime,
      );
    });

    test('the slots ascend, which the rule above reads them as', () {
      final minutes = [
        for (final slot in DailyReminder.slots) slot.hour * 60 + slot.minute,
      ];
      expect(minutes, orderedEquals(minutes.toList()..sort()));
    });
  });

  test('the default slot is the one the design starts on', () {
    final source = File('prototype/screens.jsx').readAsStringSync();

    expect(
      source,
      contains("useState('${DailyReminder.defaultTime}')"),
      reason: 'the sheet should open on the slot the design opens on',
    );
    expect(DailyReminder.times, contains(DailyReminder.defaultTime));
  });

  group('the row value', () {
    test('reads Off while notifications are off, whatever time is stored', () {
      expect(
        DailyReminder.rowValue(enabled: false, time: '7:00 AM'),
        DailyReminder.offLabel,
      );
      expect(
        DailyReminder.rowValue(enabled: false),
        DailyReminder.offLabel,
      );
    });

    test('reads the chosen time once they are on', () {
      expect(DailyReminder.rowValue(enabled: true, time: '6:30 AM'), '6:30 AM');
    });

    test('falls back to the default slot when none was ever chosen', () {
      expect(
        DailyReminder.rowValue(enabled: true),
        DailyReminder.defaultTime,
      );
    });
  });
}
