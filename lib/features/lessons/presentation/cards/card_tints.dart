/// The alphas a lesson card lays a mood colour behind a row or tile at.
///
/// One home rather than five: the same values were copied across every picking
/// card, so retuning a wash meant editing each and hoping none was missed.
/// Mood-independent by construction — an alpha is applied *to* a mood colour —
/// so there is no `of(context)` accessor.
abstract final class CardTints {
  /// Wash behind a marked or chosen surface — `.match-item.matched`'s sage
  /// 12%, and the same value behind a right answer, a picked tile and a
  /// revealed tell.
  static const double wash = 0.12;

  /// Wash behind a wrong answer. Softer than [wash] on purpose, so a bad run
  /// does not read as a wall of red.
  static const double wrongWash = 0.08;

  /// Wash behind a word picked but not yet checked —
  /// `color-mix(in oklab, var(--accent) 10%, var(--surface))`. Lighter than
  /// [wash]: a pick is a claim, and the design tints it less than a verdict.
  static const double pickedWash = 0.10;

  /// What an option that was neither picked nor the answer fades to once the
  /// card is solved, so the two that mean something carry the eye.
  static const double solvedOpacity = 0.4;
}
