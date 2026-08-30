import 'dart:math' as math;

import 'package:brew_path/features/learn/domain/module_flip.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('flipTurns', () {
    test('the front is face-on and the back is half a turn round', () {
      expect(flipTurns(showingBack: false), 0);
      expect(flipTurns(showingBack: true), 0.5);
    });
  });

  group('flipAngle', () {
    test('runs from face-on to half a turn', () {
      expect(flipAngle(0), 0);
      expect(flipAngle(1), closeTo(math.pi, 1e-9));
    });

    test('is halfway round at the midpoint', () {
      expect(flipAngle(0.5), closeTo(math.pi / 2, 1e-9));
    });
  });

  group('flipShowsBack', () {
    test('the front holds until the edge, then the back takes over', () {
      // The two faces occupy the same box, so exactly one may be visible.
      // Swapping at the quarter-turn is what stops the front being seen
      // mirror-imaged through the second half of the turn.
      expect(flipShowsBack(0), isFalse);
      expect(flipShowsBack(0.49), isFalse);
      expect(flipShowsBack(0.51), isTrue);
      expect(flipShowsBack(1), isTrue);
    });

    test('the swap is exactly at the edge-on frame', () {
      expect(flipShowsBack(flipHalfway), isTrue);
      expect(flipShowsBack(flipHalfway - 0.001), isFalse);
    });
  });

  group('flipDuration', () {
    test("is the design's 820ms", () {
      expect(flipDuration, const Duration(milliseconds: 820));
    });
  });
}
