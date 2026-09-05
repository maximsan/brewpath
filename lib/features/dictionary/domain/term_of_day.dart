/// Which term the dictionary offers today.
///
/// A function of the date and the tier, with nothing stored: two devices that
/// agree on the calendar agree on the term, and there is no pick to reconcile
/// when they sync. `docs/decisions.md` §12 amended this from a function of the
/// date alone, because the pool it runs over turned out to differ by tier.
library;

import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/dictionary/domain/dictionary_derivations.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';

/// The terms Term of the Day may pick from, in bank order.
///
/// Two conditions, both load-bearing:
///
/// **It has a full explanation.** The screen's one action promises the full
/// entry, so a term whose whole content is its one-liner would put a button
/// there with nothing behind it.
///
/// **The tier can reach it.** A free learner's dictionary does not carry the
/// reference terms at all — offering one as today's term would name a word
/// they cannot go and look up. That is [visibleTerms]'s rule, read rather
/// than restated, so the pool and the shelf cannot disagree about it.
List<DictionaryTerm> termOfDayPool({
  required List<DictionaryTerm> terms,
  required bool hasCourse,
}) => [
  for (final term in visibleTerms(terms: terms, hasCourse: hasCourse))
    if (term.deepExplanation != null) term,
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
