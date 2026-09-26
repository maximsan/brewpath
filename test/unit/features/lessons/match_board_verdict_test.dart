import 'package:brew_path/features/lessons/presentation/cards/match_board.dart';
import 'package:brew_path/l10n/generated/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

// A pure function beside the board's other rules rather than a ternary in its
// `build`, so the singular can be checked at the one count that gets it wrong
// without pumping a board to reach it.
void main() {
  test('a board cleared first time is clean, not a count of nothing', () {
    expect(matchBoardVerdict(AppLocalizationsEn(), 0), 'Clean board');
  });

  test('one drop is singular', () {
    expect(matchBoardVerdict(AppLocalizationsEn(), 1), '1 wrong drop');
  });

  test('more than one is not', () {
    expect(matchBoardVerdict(AppLocalizationsEn(), 2), '2 wrong drops');
    expect(matchBoardVerdict(AppLocalizationsEn(), 7), '7 wrong drops');
  });
}
