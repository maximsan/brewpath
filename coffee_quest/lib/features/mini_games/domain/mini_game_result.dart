/// Outcome a mini-game emits back to the lesson runner. Sealed so the runner
/// can switch exhaustively.
sealed class MiniGameResult {
  const MiniGameResult();
}

class MiniGameCorrect extends MiniGameResult {
  const MiniGameCorrect();
}

class MiniGameIncorrect extends MiniGameResult {
  const MiniGameIncorrect({this.hint});

  final String? hint;
}
