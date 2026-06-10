/// Pure calendar-day helpers used by streak logic. No timezone math beyond the
/// local `DateTime` — the streak rule only cares about whole local days.
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Whether [a] and [b] fall on the same local calendar day.
bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Whole-calendar-day difference from [from] to [to] (positive when [to] is
/// later). Time-of-day is ignored.
int dayGap(DateTime from, DateTime to) =>
    dateOnly(to).difference(dateOnly(from)).inDays;
