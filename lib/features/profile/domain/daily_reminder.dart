/// Everything the daily reminder is, short of actually firing.
///
/// The times are the design's eight, transcribed from
/// `prototype/settings.jsx:103` — a fixed set rather than a free time picker,
/// because the design's sheet offers slots to tap and the copy promises *"one
/// quiet reminder a day"*, not an alarm to configure.
///
/// **Nothing here schedules anything.** The rows and the sheet are this
/// layer's; whether a reminder ever arrives is unruled and unbuilt, and lives
/// at #443. So this holds the choice and the words for it, and the setting is
/// stored the way any other preference is.
abstract final class DailyReminder {
  /// The slots the sheet offers, in the design's order.
  static const times = [
    '6:30 AM',
    '7:00 AM',
    '7:30 AM',
    '8:00 AM',
    '8:30 AM',
    '12:30 PM',
    '6:00 PM',
    '8:30 PM',
  ];

  /// The slot the sheet lands on when the learner has not chosen one
  /// (`prototype/screens.jsx:504`).
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

  /// What the reminder row shows for [time] when notifications are [enabled].
  ///
  /// A time is only a setting while the switch above it is on; with it off the
  /// row reads *Off* rather than a time that will not arrive.
  static String rowValue({required bool enabled, String? time}) =>
      enabled ? (time ?? defaultTime) : offLabel;
}
