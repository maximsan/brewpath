/// What a card is allowed to tell its host, and what it keeps to itself.
///
/// **One signal.** A graded card reports success and nothing else. There is no
/// incorrect callback anywhere in the app, because nothing would consume one: a
/// wrong answer raises its reaction *inside* the card — the mark against the
/// option, the explanation, the note — and the host only ever needs the count
/// of successes against a total it already knows.
///
/// **No retry.** A card latches irreversibly the moment the learner commits,
/// and continuing is gated on that latch. No card offers a way back to an
/// unanswered state, so "how many did you get right" has one reading and the
/// host never has to ask *which attempt*.
///
/// **No partial credit.** Miss counts, per-item marks and tolerance bands stay
/// inside the card that owns them, driving its own feedback. None of it crosses
/// this boundary, because a fraction here would have to mean something to
/// mastery, and mastery counts whole cards.
library;

/// Fired once by a graded card, at the moment it is answered correctly.
///
/// Never fired for a wrong answer, and never fired twice — the card has latched
/// by then. Hosts count these against a total known before the lesson starts.
typedef CardSolved = void Function();

/// Fired when the learner chooses to move on from a card that has latched.
///
/// Every card exposes this; only graded cards also expose [CardSolved].
typedef CardAdvance = void Function();
