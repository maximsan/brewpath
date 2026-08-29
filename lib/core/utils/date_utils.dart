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

/// [epochDay]'s inverse: the local calendar day [day] indexes.
///
/// Needed wherever a stored day index has to be shown rather than compared —
/// the snapshot keeps activity as indices, and the Profile's joined line reads
/// the earliest of them.
///
/// **Not a plain division back.** [epochDay] floors a *local* midnight's UTC
/// milliseconds, so east of UTC that midnight falls on the previous UTC day
/// and the naive inverse lands a day early. Every offset is under 24 hours, so
/// checking the candidate against [epochDay] and stepping once is exact.
DateTime dateFromEpochDay(int day) {
  final utc = DateTime.fromMillisecondsSinceEpoch(
    day * Duration.millisecondsPerDay,
    isUtc: true,
  );
  final candidate = DateTime(utc.year, utc.month, utc.day);

  return epochDay(candidate) == day
      ? candidate
      : DateTime(utc.year, utc.month, utc.day + 1);
}

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

/// [date] as the long form the header shows — `Friday, May 8`.
String longDate(DateTime date) =>
    '${_weekdayNames[date.weekday - 1]}, '
    '${_monthNames[date.month - 1]} ${date.day}';

/// [date] as the month and year the Profile's closing line shows — `May 2026`.
String monthYear(DateTime date) =>
    '${_monthNames[date.month - 1]} ${date.year}';
