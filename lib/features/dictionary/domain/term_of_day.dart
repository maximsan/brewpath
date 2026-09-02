/// Which term the dictionary offers today.
///
/// A function of the date and the tier, with nothing stored: two devices that
/// agree on the calendar agree on the term, and there is no pick to reconcile
/// when they sync. `docs/decisions.md` §12 amended this from a function of the
/// date alone, because the pool it runs over turned out to differ by tier.
library;

import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';

/// The terms Term of the Day may pick from, in bank order.
///
/// Two conditions, both load-bearing:
///
/// **It has a full explanation.** The screen's one action promises the full
/// entry, so a term whose whole content is its one-liner would put a button
/// there with nothing behind it.
///
/// **The tier can reach it.** A term no lesson teaches is reference-only, and
/// a free learner's dictionary does not carry it at all — offering it as
/// today's term would name a word they cannot go and look up.
///
/// Derived from the bank on every read. The tier arithmetic in
/// `docs/decisions.md` §12 was measured against an earlier bank and no longer
/// matches it; the rule is what survived, not the numbers.
List<DictionaryTerm> termOfDayPool({
  required List<DictionaryTerm> terms,
  required bool hasCourse,
}) => [
  for (final term in terms)
    if (term.deepExplanation != null && (hasCourse || term.lessonId != null))
      term,
];

/// The term [date] lands on in [pool], or null when the pool is empty.
///
/// **The pick walks the pool**, one term per local day, so a term comes round
/// again only after every other has had its turn — comfortably longer than the
/// course takes to finish, which is what "never repeats in-course" means.
///
/// No clamping of the day index is needed the way the design source needs it:
/// Dart's `%` returns a non-negative result for a positive divisor, so a date
/// before the epoch indexes from the far end rather than off the front.
DictionaryTerm? termOfDay({
  required List<DictionaryTerm> pool,
  required DateTime date,
}) => pool.isEmpty ? null : pool[epochDay(date) % pool.length];
