/// What the confirm sheet says before a lesson is replayed (#573).
library;

import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/progress/domain/freeze_status_line.dart';

/// One line of the sheet: what it measures, and this run's answer.
typedef ReplayConfirmLine = ({String label, String value});

/// The sheet's words, named so a test reads what the app reads.
///
/// Written for this app rather than ported: the design's own line says a
/// replay changes nothing for points *and* streak, and here a replay protects
/// the day — so the two facts no longer fit on one line.
abstract final class ReplayConfirmCopy {
  /// What the confirm reads.
  static const confirm = 'Review lesson';

  /// What the dismiss reads.
  static const cancel = 'Not now';

  /// The points line, which never varies: a replay pays nothing (§5.1).
  static const ReplayConfirmLine points = (label: 'Points', value: 'No change');

  /// The streak line's label.
  static const streak = 'Streak';

  /// The streak line on a day the replay would still protect.
  static const streakCounts = 'Counts for today';

  /// The streak line on a day already covered by something else.
  static const streakEarned = 'Already earned today';

  /// The length line's label.
  static const length = 'Length';

  /// The last-run line's label.
  static const lastCompleted = 'Last completed';

  /// What the sheet is titled — the lesson, asked as a question.
  static String title(String lessonTitle) => '$lessonTitle?';
}

/// The sheet's four lines for a lesson of [minutes] and [cards].
///
/// [lastCompletedDay] is the stored last run, or the first completion for a
/// lesson last finished before that day was recorded; null when neither is
/// known, which leaves the line off rather than guessing at it.
List<ReplayConfirmLine> replayConfirmLines({
  required int minutes,
  required int cards,
  required bool dayAlreadyEarned,
  required int? lastCompletedDay,
  required DateTime today,
}) => [
  ReplayConfirmCopy.points,
  (
    label: ReplayConfirmCopy.streak,
    value: dayAlreadyEarned
        ? ReplayConfirmCopy.streakEarned
        : ReplayConfirmCopy.streakCounts,
  ),
  (label: ReplayConfirmCopy.length, value: lengthLine(minutes, cards)),
  if (lastCompletedDay != null)
    (
      label: ReplayConfirmCopy.lastCompleted,
      value: dayName(lastCompletedDay, today: today),
    ),
];

/// How long the run is, and how much of it there is — `~4 min · 7 cards`.
String lengthLine(int minutes, int cards) =>
    '~$minutes min · $cards ${cards == 1 ? 'card' : 'cards'}';

/// [day] as a learner would name it, against [today].
///
/// A named day while one is in living memory, then the date: *last Tuesday*
/// is a day someone can place, and *87 days ago* is arithmetic. The year is
/// added once it is not this one, so an old run cannot pass as this year's.
String dayName(int day, {required DateTime today}) {
  final named = recentDayName(day, today: today);
  if (named != null) return named;
  final date = dateFromEpochDay(day);
  final short = shortDate(date);
  return date.year == today.year ? short : '$short, ${date.year}';
}
