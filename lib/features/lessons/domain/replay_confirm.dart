/// What the confirm sheet says before a lesson is replayed (#573).
///
/// Written for this app rather than ported: the design's line says a replay
/// changes nothing for points *and* streak, and here a replay protects the
/// day — so the two facts no longer fit on one line.
library;

import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/progress/domain/freeze_status_line.dart';
import 'package:brew_path/l10n/generated/app_localizations.dart';

/// One line of the sheet: what it measures, and this run's answer.
typedef ReplayConfirmLine = ({String label, String value});

/// What the sheet is drawn from. The words are the widget's, off the `.arb`.
///
/// `lastCompletedDay` is the stored last run, or the first completion for a
/// lesson finished before that day was recorded; null when neither is known.
typedef ReplayConfirmFacts = ({
  String lessonTitle,
  int minutes,
  int cards,
  bool dayAlreadyEarned,
  int? lastCompletedDay,
  DateTime today,
});

/// The sheet's four lines for the run [facts] describes.
///
/// A run with no day on record leaves the last line off rather than guessing
/// at it, so the sheet shows three.
List<ReplayConfirmLine> replayConfirmLines(
  AppLocalizations strings,
  ReplayConfirmFacts facts,
) => [
  // A replay pays nothing (§5.1), so this line never varies.
  (
    label: strings.replayConfirmPointsLabel,
    value: strings.replayConfirmPointsValue,
  ),
  (
    label: strings.replayConfirmStreakLabel,
    value: facts.dayAlreadyEarned
        ? strings.replayConfirmStreakEarned
        : strings.replayConfirmStreakCounts,
  ),
  (
    label: strings.replayConfirmLengthLabel,
    value: strings.replayConfirmLength(facts.minutes, facts.cards),
  ),
  if (facts.lastCompletedDay case final day?)
    (
      label: strings.replayConfirmLastCompletedLabel,
      value: dayName(strings, day, today: facts.today),
    ),
];

/// [day] as a learner would name it, against [today].
///
/// A named day while one is in living memory, then the date: *last Tuesday*
/// is a day someone can place, and *87 days ago* is arithmetic. The year is
/// added once it is not this one, so an old run cannot pass as this year's.
String dayName(
  AppLocalizations strings,
  int day, {
  required DateTime today,
}) {
  final named = recentDayName(day, today: today);
  if (named != null) return named;
  final date = dateFromEpochDay(day);
  final short = shortDate(date);
  return date.year == today.year
      ? short
      : strings.replayConfirmDatedYear(short, date.year);
}
