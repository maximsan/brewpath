import 'package:brew_path/core/utils/date_utils.dart';

/// Whether [now] falls on a different local calendar day than [lastSeenDay],
/// which is an `epochDay` index.
///
/// **Different, not later.** A clock that moves backwards — travelling west, or
/// a wrong one corrected — is a rollover too: the streak folds against `today`
/// and ignores every day after it, so a smaller today is a different answer.
/// Testing for `>` would leave those surfaces showing a value derived for a day
/// the learner is no longer in.
bool dayHasRolledOver({required int lastSeenDay, required DateTime now}) =>
    epochDay(now) != lastSeenDay;
