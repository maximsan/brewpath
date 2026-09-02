/// What a card's Coffee Challenge is doing, as its tile shows it.
///
/// A domain fact rather than a widget's: the tile draws the three differently,
/// but *which* one a card is in is decided by the bank and the learner's
/// history, and this is where both live.
enum CardChallengeState {
  /// No challenge is attached to this card.
  none,

  /// One is attached and unbrewed — the design rings it as an offer.
  open,

  /// Brewed. The design stamps it.
  tried,
}
