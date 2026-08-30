import 'dart:io';

import 'package:brew_path/features/profile/domain/daily_reminder.dart';
import 'package:flutter_test/flutter_test.dart';

/// The reminder's slots and copy, read back out of the design.
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
