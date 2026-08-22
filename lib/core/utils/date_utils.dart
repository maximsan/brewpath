/// Pure calendar-day helpers used by streak logic. No timezone math beyond the
/// local `DateTime` — the streak rule only cares about whole local days.
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Whether [a] and [b] fall on the same local calendar day.
bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// [d]'s local calendar day as an integer day index — the day scheme the
/// snapshot's `activeDays` and `acks` store, and the Keep Sharp rotation
/// turns on. Consecutive local days map to consecutive integers.
int epochDay(DateTime d) =>
    dateOnly(d).millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;

// English-only, deliberately. The app ships no localisation, and pulling in a
// formatting dependency for one header line would be a platform decision made
// for a string — the same call this repo made against a URL launcher.
const _weekdayNames = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// [d] as the long form the header shows — `Friday, May 8`.
String longDate(DateTime d) =>
    '${_weekdayNames[d.weekday - 1]}, ${_monthNames[d.month - 1]} ${d.day}';
