import 'dart:math' as math;

import 'package:brew_path/features/progress/domain/tree_frames.dart';
import 'package:brew_path/features/progress/domain/tree_growth.dart';
import 'package:brew_path/features/progress/domain/tree_stage_names.dart';
import 'package:brew_path/features/progress/presentation/coffee_tree_animation.dart';
import 'package:flutter_test/flutter_test.dart';

/// The tree screen's three derivations, none of which needs a widget: what a
/// stage is called, how full the bar is, and where the sway is pointing.
void main() {
  group('stage names', () {
    test('names every shipped stage, title-cased', () {
      expect(treeStageName(1), 'Seed');
      expect(treeStageName(10), 'Harvest');
      // Two words take one capital, not two — the design's `pretty()`.
      expect(treeStageName(6), 'Green cherry');
    });

    test('a fresh install reads as the seed, like the art', () {
      // The stored value is 0 before anything is finished, and the seed frame
      // is what a fresh tree shows.
      expect(treeStageName(freshTreeStage), treeStageName(1));
    });

    test('the next stage is the one after, and nothing at full growth', () {
      expect(nextTreeStageName(1), 'Sprout');
      expect(nextTreeStageName(9), 'Harvest');
      expect(nextTreeStageName(treeStageCount), isNull);
    });

    test('there is a name for every frame', () {
      expect(treeStageNames, hasLength(treeStageCount));
    });
  });

  group('progress fraction', () {
    test('is the plain ratio in the middle', () {
      expect(treeProgressFraction(completed: 16, total: 32), 0.5);
    });

    test('floors at a visible sliver rather than an empty track', () {
      expect(
        treeProgressFraction(completed: 0, total: 32),
        minTreeProgressFraction,
      );
    });

    test('a course with no lessons reads as the floor, not a crash', () {
      expect(
        treeProgressFraction(completed: 0, total: 0),
        minTreeProgressFraction,
      );
    });

    test('clamps at full when the course has shrunk under a learner', () {
      // A grown-then-shrunk course can leave more completions than lessons.
      expect(treeProgressFraction(completed: 40, total: 32), 1);
    });
  });

  group('sway', () {
    /// The design's keyframes: -0.8° at 0% and 100%, +0.8° at 50%.
    double degrees(double progress) =>
        treeSwayRadiansAt(progress) * 180 / math.pi;

    test("leans the design's amount, both ways", () {
      expect(degrees(0), closeTo(-treeSwayDegrees, 1e-9));
      expect(degrees(0.5), closeTo(treeSwayDegrees, 1e-9));
    });

    test('returns to where it started, so the loop does not jump', () {
      expect(degrees(1), closeTo(degrees(0), 1e-9));
    });

    test('is stillest at the ends and quickest through the middle', () {
      // What `ease-in-out` means, asserted as a property rather than as a
      // curve name: the same slice of time moves the tree further at the
      // midpoint than it does at the turn.
      const slice = 0.02;
      final atTheTurn = (degrees(slice) - degrees(0)).abs();
      final throughTheMiddle = (degrees(0.25 + slice) - degrees(0.25)).abs();
      expect(throughTheMiddle, greaterThan(atTheTurn));
    });

    test('never leans further than the design allows', () {
      for (var step = 0; step <= 100; step++) {
        expect(degrees(step / 100).abs(), lessThanOrEqualTo(treeSwayDegrees));
      }
    });

    test('a still tree stands upright, not frozen mid-lean', () {
      expect(treeSwayHeldRadians, 0);
    });
  });
}
