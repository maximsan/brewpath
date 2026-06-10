/// Outcome a mini-game emits back to the lesson runner. Sealed so the runner
/// can switch exhaustively.
sealed class MiniGameResult {
  /// Creates a [MiniGameResult].
  const MiniGameResult();
}

/// The user answered correctly.
class MiniGameCorrect extends MiniGameResult {
  /// Creates a [MiniGameCorrect].
  const MiniGameCorrect();
}

/// The user answered incorrectly, optionally with a [hint].
class MiniGameIncorrect extends MiniGameResult {
  /// Creates a [MiniGameIncorrect].
  const MiniGameIncorrect({this.hint});

  /// Optional hint to show the user.
  final String? hint;
}
