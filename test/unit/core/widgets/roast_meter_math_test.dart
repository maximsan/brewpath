import 'package:brew_path/core/widgets/roast_meter_math.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('roastProgress', () {
    test('spreads the whole ramp between the first card and the last', () {
      // Raw green on card one, espresso on card eight — the design's prose,
      // which its own `done / total` arithmetic never delivers.
      expect(roastProgress(position: 1, total: 8), 0);
      expect(roastProgress(position: 8, total: 8), 1);
      expect(roastProgress(position: 4, total: 8), 3 / 7);
    });

    test('moves by the same step on every card of a run', () {
      final steps = [
        for (var position = 1; position <= 8; position++)
          roastProgress(position: position, total: 8),
      ];

      expect(steps.toSet(), hasLength(8));
      expect(steps, orderedEquals(steps.toList()..sort()));
    });

    test('a run with no gap to spread the ramp over stays raw', () {
      // A one-card run has nowhere to roast to, and an empty one was never
      // started — neither may divide by zero.
      expect(roastProgress(position: 1, total: 1), 0);
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
