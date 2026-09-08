import 'package:flutter/foundation.dart';

/// The guess the opening `predict` card took, carried to the closing `recall`
/// card that resolves it.
///
/// Held at lesson scope rather than written down: it is the tension the lesson
/// is built on, worth nothing once the lesson ends, and a learner who replays
/// starts the loop again from an empty hand.
@immutable
class HeldGuess {
  /// Creates a [HeldGuess].
  const HeldGuess({required this.pick, required this.answer});

  /// What the learner guessed.
  final String pick;

  /// What the card's author says it actually is.
  final String answer;

  /// Whether the opening guess turned out to be right.
  bool get wasRight => pick == answer;

  @override
  bool operator ==(Object other) =>
      other is HeldGuess && other.pick == pick && other.answer == answer;

  @override
  int get hashCode => Object.hash(pick, answer);
}

/// The guess loop a lesson runs: the guess already taken, and where the next
/// one goes.
///
/// One value rather than two parameters because they are the two ends of a
/// single seam — a card that takes a guess and a card that resolves one — and
/// no card renderer ever wants one without the other in reach.
@immutable
class GuessLoop {
  /// Creates a [GuessLoop].
  const GuessLoop({this.held, this.onGuess});

  /// A lesson with no guess in it, and none to take: every card kind but two.
  static const none = GuessLoop();

  /// What the opening card guessed, if this run opened on one.
  final HeldGuess? held;

  /// Where a guess goes when one is taken.
  final ValueChanged<HeldGuess>? onGuess;
}
