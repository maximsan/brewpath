import 'package:brew_path/core/utils/date_utils.dart';

/// Whether [now] falls on a different local calendar day than [lastSeenDay],
/// which is an `epochDay` index.
///
/// **Different, not later.** A clock that moves backwards — travelling west, or
/// a wrong one corrected — is a rollover too: the streak folds against `today`
/// and ignores every day after it, so a smaller today is a different answer.
bool dayHasRolledOver({required int lastSeenDay, required DateTime now}) =>
    epochDay(now) != lastSeenDay;

/// How long from [now] until the next local midnight.
///
/// Always positive: on the boundary itself it returns the whole day ahead
/// rather than zero, so a timer armed at midnight cannot spin. Built from
/// local `DateTime`s, so an hour lost or gained to DST is carried by the
/// subtraction rather than assumed away.
Duration untilNextMidnight(DateTime now) =>
    DateTime(now.year, now.month, now.day + 1).difference(now);
