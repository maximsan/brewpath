import 'package:flutter_test/flutter_test.dart';

import '../../../support/dart_sources.dart';

// A lesson's payout is per-lesson authored data (§5.1, #16), so no constant in
// the companion layer can be right about it. #16 ruled the hardcoded `+15 XP`
// dropped and #160's sweep rewrote it to `+10 PTS` instead, fixing the word and
// leaving the defect (#212). Scoped to the companion layer: `+10 PTS` is right
// on the lesson result screen, which reads the real payout — the rule is that
// painted mascot art states no amount.
void main() {
  /// A points amount, in either vocabulary, signed or not.
  ///
  /// The sign is optional on purpose: `'10 PTS'` states a payout exactly as
  /// `'+10 PTS'` does, and requiring the `+` would have let the next one
  /// through.
  final payout = RegExp(r'[+-]?\s*\d+\s*(PTS|pts|XP|points)\b');

  test('no companion source states a points amount', () {
    final offenders = <String>[];

    for (final file in dartSourcesUnder('lib/features/companion')) {
      for (final literal in stringLiteralsIn(file.readAsStringSync())) {
        if (payout.hasMatch(literal)) {
          offenders.add('${file.path}: "$literal"');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'the mascot states no payout — a lesson pays what it authors '
          '(§5.1, #16). Found:\n${offenders.join('\n')}',
    );
  });
}
