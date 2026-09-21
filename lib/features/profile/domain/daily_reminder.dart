/// One of the design's slots: the label it is written as, and the local time
/// it names.
typedef ReminderSlot = ({String label, int hour, int minute});

/// Everything the daily reminder is: the slots it offers, the words it says,
/// and the clock time behind each label.
///
/// A fixed set rather than a free time picker, because the design's sheet
/// offers slots to tap and the copy promises *"one quiet reminder a day"*.
/// `reminderFireTimes` turns a slot into occurrences to post.
abstract final class DailyReminder {
  /// The slots the sheet offers, in the design's order, each with the local
  /// time its label names.
  static const slots = <ReminderSlot>[
    (label: '6:30 AM', hour: 6, minute: 30),
    (label: '7:00 AM', hour: 7, minute: 0),
    (label: '7:30 AM', hour: 7, minute: 30),
    (label: '8:00 AM', hour: 8, minute: 0),
    (label: '8:30 AM', hour: 8, minute: 30),
    (label: '12:30 PM', hour: 12, minute: 30),
    (label: '6:00 PM', hour: 18, minute: 0),
    (label: '8:30 PM', hour: 20, minute: 30),
  ];

  /// The slot labels alone, which is what the sheet draws and the settings row
  /// stores.
  static List<String> get times => [for (final slot in slots) slot.label];

  /// The slot [label] names, or the [defaultSlot] where it names none.
  ///
  /// A stored label the app no longer offers falls back rather than throwing:
  /// the preference outlives any one build's list, and a reminder at the
  /// default hour beats none at all.
  static ReminderSlot slotFor(String? label) => slots.firstWhere(
    (slot) => slot.label == label,
    orElse: () => defaultSlot,
  );

  /// [defaultTime]'s slot.
  static ReminderSlot get defaultSlot =>
      slots.firstWhere((slot) => slot.label == defaultTime);

  /// The slot the sheet lands on when the learner has not chosen one.
  static const defaultTime = '8:00 AM';

  /// What the reminder row reads when no reminder is set.
  static const offLabel = 'Off';

  /// The sheet's title.
  static const sheetTitle = 'A nudge to brew';

  /// The line under it.
  static const sheetBody =
      'One quiet reminder a day to keep your streak '
      'alive.';

  /// The sheet's one action.
  static const sheetAction = 'Set reminder';

  /// What the notification is titled — the app, as every iOS banner names it.
  static const notificationTitle = 'BrewPath';

  /// What it says.
  ///
  /// No quantity in the sentence: one lesson is not what keeps a streak, any
  /// qualifying activity is (ruled 8 September 2026, #443).
  static const notificationBody = 'Today’s practice keeps your streak alive.';

  /// What the reminder row shows for [time] when notifications are [enabled].
  ///
  /// A time is only a setting while the switch above it is on; with it off the
  /// row reads *Off* rather than a time that will not arrive.
  static String rowValue({required bool enabled, String? time}) =>
      enabled ? (time ?? defaultTime) : offLabel;
}
