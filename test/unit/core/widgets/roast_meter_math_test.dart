import 'package:brew_path/core/widgets/roast_meter_math.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('roastProgress', () {
    test('reads the run from its first card to its last', () {
      expect(roastProgress(position: 1, total: 8), 1 / 8);
      expect(roastProgress(position: 4, total: 8), 0.5);
      expect(roastProgress(position: 8, total: 8), 1);
    });

    test('moves by the same step on every card of a run', () {
      final steps = [
        for (var position = 1; position <= 8; position++)
          roastProgress(position: position, total: 8),
      ];

      expect(steps.toSet(), hasLength(8));
      expect(steps, orderedEquals(steps.toList()..sort()));
    });

    test('a run with nothing in it has not started', () {
      // Rather than dividing by zero on a lesson whose cards were all filtered
      // out before the header could be told.
      expect(roastProgress(position: 1, total: 0), 0);
      expect(roastProgress(position: 0, total: 0), 0);
    });

    test('clamps rather than running off either end of the ramp', () {
      expect(roastProgress(position: 12, total: 8), 1);
      expect(roastProgress(position: -3, total: 8), 0);
    });
  });

  group('zeroPadded', () {
    test("pads a short count to the design's two figures", () {
      expect(zeroPadded(1), '01');
      expect(zeroPadded(8), '08');
    });

    test('leaves a count that is already wide enough alone', () {
      expect(zeroPadded(12), '12');
      expect(zeroPadded(140), '140');
    });
  });
}
