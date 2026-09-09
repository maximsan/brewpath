import 'package:brew_path/features/lessons/presentation/cards/tastefix_reaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('tastefixShakeOffset', () {
    test('starts and ends at rest', () {
      expect(tastefixShakeOffset(0), 0);
      expect(tastefixShakeOffset(1), 0);
    });

    test('hits the design stops', () {
      expect(tastefixShakeOffset(0.25), closeTo(-5, 0.001));
      expect(tastefixShakeOffset(0.5), closeTo(5, 0.001));
      expect(tastefixShakeOffset(0.75), closeTo(-3, 0.001));
    });

    test('swings both ways and never past the widest stop', () {
      var sawLeft = false;
      var sawRight = false;
      for (var step = 0; step <= 100; step++) {
        final offset = tastefixShakeOffset(step / 100);
        expect(offset.abs(), lessThanOrEqualTo(5.001));
        if (offset < -0.001) sawLeft = true;
        if (offset > 0.001) sawRight = true;
      }
      expect(sawLeft && sawRight, isTrue);
    });

    test('holds at rest outside the run', () {
      expect(tastefixShakeOffset(-1), 0);
      expect(tastefixShakeOffset(2), 0);
    });
  });

  group('tastefixPulseScale', () {
    test('starts and ends at its own size', () {
      expect(tastefixPulseScale(0), 1);
      expect(tastefixPulseScale(1), 1);
    });

    test('peaks at the design stop, halfway', () {
      expect(tastefixPulseScale(0.5), closeTo(1.035, 0.001));
    });

    test('only ever grows', () {
      for (var step = 0; step <= 100; step++) {
        final scale = tastefixPulseScale(step / 100);
        expect(scale, greaterThanOrEqualTo(1));
        expect(scale, lessThanOrEqualTo(1.035));
      }
    });

    test('holds at its own size outside the run', () {
      expect(tastefixPulseScale(-1), 1);
      expect(tastefixPulseScale(2), 1);
    });
  });
}
