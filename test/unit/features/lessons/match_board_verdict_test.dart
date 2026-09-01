import 'package:brew_path/features/lessons/presentation/cards/match_board.dart';
import 'package:flutter_test/flutter_test.dart';

/// What a finished board is called.
///
/// A pure function beside the board's other rules rather than a ternary in its
/// `build`, so the singular can be checked at the one count that gets it wrong
/// without pumping a board to reach it.
void main() {
  test('a board cleared first time is clean, not a count of nothing', () {
    expect(matchBoardVerdict(0), 'Clean board');
  });

  test('one drop is singular', () {
    expect(matchBoardVerdict(1), '1 wrong drop');
  });

  test('more than one is not', () {
    expect(matchBoardVerdict(2), '2 wrong drops');
    expect(matchBoardVerdict(7), '7 wrong drops');
  });
}
