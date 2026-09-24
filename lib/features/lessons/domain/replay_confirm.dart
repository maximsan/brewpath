/// What the confirm sheet says before a lesson is replayed (#573).
library;

import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/progress/domain/freeze_status_line.dart';
import 'package:brew_path/l10n/generated/app_localizations.dart';

/// One line of the sheet: what it measures, and this run's answer.
typedef ReplayConfirmLine = ({String label, String value});

/// The sheet's four lines for a lesson of [minutes] and [cards].
///
/// [lastCompletedDay] is the stored last run, or the first completion for a
/// lesson last finished before that day was recorded; null when neither is
/// known, which leaves the line off rather than guessing at it.
List<ReplayConfirmLine> replayConfirmLines({
  required AppLocalizations strings,
  required int minutes,
  required int cards,
  required bool dayAlreadyEarned,
  required int? lastCompletedDay,
  required DateTime today,
}) => [
  (
    label: strings.replayConfirmPointsLabel,
    value: strings.replayConfirmPointsValue,
  ),
  (
    label: strings.replayConfirmStreakLabel,
    value: dayAlreadyEarned
        ? strings.replayConfirmStreakEarned
        : strings.replayConfirmStreakCounts,
  ),
  (
    label: strings.replayConfirmLengthLabel,
    value: strings.replayConfirmLength(minutes, cards),
  ),
  if (lastCompletedDay != null)
    (
      label: strings.replayConfirmLastCompletedLabel,
      value: dayName(strings, lastCompletedDay, today: today),
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
