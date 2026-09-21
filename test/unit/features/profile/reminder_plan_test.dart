import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/profile/domain/daily_reminder.dart';
import 'package:brew_path/features/profile/domain/reminder_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final eightAm = DailyReminder.slotFor('8:00 AM');

  List<DateTime> plan(DateTime now, {Set<int> activeDays = const {}}) =>
      reminderFireTimes(now: now, slot: eightAm, activeDays: activeDays);

  test('fills the horizon, one occurrence a day at the chosen slot', () {
    final times = plan(DateTime(2026, 9, 21, 6));

    expect(times, hasLength(reminderHorizonDays));
    expect(times.first, DateTime(2026, 9, 21, 8));
    expect(times.last, DateTime(2026, 9, 21 + reminderHorizonDays - 1, 8));
    expect(times.every((at) => at.hour == 8 && at.minute == 0), isTrue);
  });

  test("today's slot is dropped once it has gone by", () {
    final times = plan(DateTime(2026, 9, 21, 9));

    expect(times.first, DateTime(2026, 9, 22, 8));
    expect(times, hasLength(reminderHorizonDays - 1));
  });

  test('the slot exactly now is gone by, not still ahead', () {
    // A notification scheduled for this instant is one the OS refuses; the
    // plan has to have decided that, not the platform.
    expect(plan(DateTime(2026, 9, 21, 8)).first, DateTime(2026, 9, 22, 8));
  });

  test('a day already practised on gets no nudge', () {
    final today = epochDay(DateTime(2026, 9, 21));

    final times = plan(DateTime(2026, 9, 21, 6), activeDays: {today});

    expect(times.first, DateTime(2026, 9, 22, 8));
    expect(times.any((at) => epochDay(at) == today), isFalse);
  });

  test('a gap in the middle is skipped, not shifted', () {
    final tomorrow = epochDay(DateTime(2026, 9, 22));

    final times = plan(DateTime(2026, 9, 21, 6), activeDays: {tomorrow});

    expect(times, isNot(contains(DateTime(2026, 9, 22, 8))));
    expect(times, contains(DateTime(2026, 9, 21, 8)));
    expect(times, contains(DateTime(2026, 9, 23, 8)));
  });

  test('crossing a month keeps the slot on the wall clock', () {
    final times = plan(DateTime(2026, 9, 25, 6));

    expect(times, contains(DateTime(2026, 10, 1, 8)));
    expect(times.every((at) => at.hour == 8), isTrue);
  });

  test('an afternoon slot is the time its label names', () {
    final times = reminderFireTimes(
      now: DateTime(2026, 9, 21, 6),
      slot: DailyReminder.slotFor('8:30 PM'),
      activeDays: const {},
    );

    expect(times.first, DateTime(2026, 9, 21, 20, 30));
  });

  test('a stored slot this build no longer offers falls back', () {
    // The preference outlives any one build's list; a reminder at the default
    // hour beats none at all.
    expect(DailyReminder.slotFor('3:15 AM'), DailyReminder.defaultSlot);
    expect(DailyReminder.slotFor(null), DailyReminder.defaultSlot);
  });
}
