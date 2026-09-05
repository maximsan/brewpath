/// Every word a term's entry says about its tier, in one place.
library;

import 'package:brew_path/features/dictionary/presentation/term_of_day_copy.dart';

/// What a free learner reads where the full entry would be.
abstract final class TermEntryCopy {
  /// The label over the gated part of the entry — the clearly labelled
  /// expansion `docs/decisions.md` §12 asks for, with the tier named as the
  /// app names it.
  static const fullExplanation = 'Full explanation · Plus';

  /// The gated row's action. The same words as Term of the Day's, because
  /// both promise the same thing and both raise the gate rather than deliver
  /// the short explanation the learner is already reading.
  static const String readFullEntry = TermOfDayCopy.readFullEntry;

  /// What the row says would open it, in ADR-0016's shape: the thing that
  /// would actually unlock it for the person reading.
  static const comesWithCourse = 'Comes with the full course.';

  /// The peek sheet's way through to the entry for a learner without the
  /// course — the design's own label when there is no full entry to promise.
  static const openEntry = 'Open entry';

  /// What a screen reader is told the gated row does.
  static const gateSemantics = '$readFullEntry. $comesWithCourse';
}
