/// The words every locked row uses.
///
/// A locked row says what would unlock it for the learner reading it. Two
/// locks look the same and are not: one opens by learning, the other only by
/// buying. ADR-0016 has the rule.
library;

/// The strings a locked row uses.
abstract final class LockedRowCopy {
  /// The purchase lock. Named as what it is, not as a refusal.
  static const partOfFoundations = 'Part of Foundations';

  /// A purchase-locked module. The count is the pitch.
  static String purchasedModule(int lessonCount) =>
      '$partOfFoundations · $lessonCount lessons';

  /// A module waiting on the one before it.
  static String finishToUnlock(String previousTitle) =>
      'Finish $previousTitle to unlock';

  /// A locked module with nothing before it to finish.
  static String moduleSize(int lessonCount) => '$lessonCount lessons';

  /// The Reference shelf, to someone who has not bought the course.
  ///
  /// No lesson they can finish opens it: free is the first three lessons
  /// (ADR-0007) and the earliest guide is taught by the sixth. So the true
  /// answer is buy it, not keep going.
  static const referenceLockedFree = 'Visual guides come with the full course';

  /// The Reference shelf, to someone who owns the course but has not yet
  /// reached the lesson that fills it.
  static String referenceUnlocksWith(String lessonTitle) =>
      'Unlocks with $lessonTitle';

  /// What a screen reader is told about a purchase-locked row.
  static String purchaseLockedSemantics(String title) =>
      '$title. $partOfFoundations.';

  /// The Today card's eyebrow once the learner is past the free lessons.
  ///
  /// A statement about the course rather than a refusal, and it is the whole
  /// of the wall: the card drops its module number, because the eyebrow has
  /// already said where the learner has got to.
  static const continuesInFoundations = 'Continues in Foundations';

  /// What the purchase opens, counted — every lesson still ahead of the
  /// learner, course-wide.
  ///
  /// Not their position in one module: once the eyebrow is the wall, a
  /// *lesson 4 of 7* says nothing about what buying would give them.
  static String lessonsAhead(int count) => '$count lessons ahead';

  /// The Today card's action, named for what it opens.
  ///
  /// Honest at the point of tapping: the button on a locked card must never
  /// read *Begin* and then raise a wall.
  static const unlockFoundations = 'Unlock Foundations';

  /// What a screen reader is told the locked card's action would do.
  ///
  /// The button is the one thing there is to activate, so the lesson it opens
  /// belongs on it rather than only in the title above it.
  static String unlockToContinue(String title) =>
      '$unlockFoundations to continue: $title';

  /// What a screen reader is told the counted line means.
  static String lessonsAheadSemantics(int count) =>
      '${lessonsAhead(count)} in Foundations';
}
