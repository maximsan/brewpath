/// What a locked row says, on every surface that draws one.
///
/// **A locked row names what would unlock it _for this learner_.** Two locks
/// look identical and are not: progression opens by learning, and the purchase
/// does not open by learning at all. Telling a free learner to finish a lesson
/// they cannot reach is the defect the owner ruled against on
/// [#91](https://github.com/maximsan/brewpath/issues/91) — recorded as
/// ADR-0015 — and it is the same defect on a lesson row, a module row and the
/// Reference shelf, so the three read their words from here.
///
/// Pure strings: what is locked and for whom is decided by the caller, so
/// every line can be asserted without pumping a widget.
library;

/// The strings a locked row uses.
abstract final class LockedRowCopy {
  /// The purchase lock, named as what it *is* rather than as a refusal.
  ///
  /// The course's own name, which is what the design puts on the mark
  /// (`screens.jsx:1336`, `:1509`) — a learner who bought Foundations should
  /// recognise the thing they are being offered.
  static const partOfFoundations = 'Part of Foundations';

  /// A purchase-locked module's sub-line: what it is, and how much is in it.
  ///
  /// The count is the pitch — `Part of Foundations` alone says only *no*
  /// (`screens.jsx:1345`).
  static String purchasedModule(int lessonCount) =>
      '$partOfFoundations · $lessonCount lessons';

  /// A progress-locked module's sub-line, for a learner who can actually
  /// finish the module named.
  static String finishToUnlock(String previousTitle) =>
      'Finish $previousTitle to unlock';

  /// A module locked with nothing before it to finish — it states its size.
  static String moduleSize(int lessonCount) => '$lessonCount lessons';

  /// The Reference shelf, to a learner the free tier will never open it for.
  ///
  /// The free set is the first three lessons (ADR-0007) and the earliest guide
  /// is taught by the sixth, so no lesson a free learner can complete reaches
  /// this shelf. The honest answer is *purchase*, not *keep learning*.
  static const referenceLockedFree = 'Visual guides come with the full course';

  /// The Reference shelf, to someone who owns the course but has not yet
  /// reached the lesson that fills it — here the lesson hint is the true one.
  static String referenceUnlocksWith(String lessonTitle) =>
      'Unlocks with $lessonTitle';

  /// What a screen reader is told about a purchase-locked row.
  static String purchaseLockedSemantics(String title) =>
      '$title. $partOfFoundations.';
}
