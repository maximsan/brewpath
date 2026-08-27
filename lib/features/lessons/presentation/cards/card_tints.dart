/// The alphas a lesson card lays a mood colour behind a row or tile at.
///
/// One home rather than five: the same two values were copied across every
/// picking card, so retuning what the design calls a wash meant editing each
/// of them and hoping none was missed.
///
/// Card-local on purpose. Nothing outside a lesson card washes a surface this
/// way, so these stay beside the cards that use them rather than widening the
/// theme's surface.
///
/// Mood-independent by construction: an alpha is applied *to* a mood colour,
/// so there is nothing here to flip between Cupping and Dark Roast — which is
/// why it carries no `of(context)` accessor.
abstract final class CardTints {
  /// Wash behind a marked or chosen surface — `.match-item.matched`'s sage
  /// 12%, and the same value behind a right answer, a picked tile and a
  /// revealed tell.
  static const double wash = 0.12;

  /// Wash behind a wrong answer. Softer than [wash] on purpose, so a bad run
  /// does not read as a wall of red.
  static const double wrongWash = 0.08;
}
