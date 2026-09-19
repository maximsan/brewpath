import 'dart:math' as math;

import 'package:brew_path/core/swipe/swipe_geometry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('direction is a contract', () {
    test('left advances and right goes back', () {
      expect(swipeAimOf(-1), SwipeAim.advance);
      expect(swipeAimOf(1), SwipeAim.back);
      expect(swipeAimOf(0), isNull);
    });

    test('a direction with nothing that way is blocked', () {
      expect(
        swipeIsBlocked(distance: -60, canAdvance: false, canBack: true),
        isTrue,
      );
      expect(
        swipeIsBlocked(distance: 60, canAdvance: false, canBack: true),
        isFalse,
      );
      expect(
        swipeIsBlocked(distance: 0, canAdvance: false, canBack: false),
        isFalse,
      );
    });
  });

  group('the damped block', () {
    test('a blocked direction still moves, at 22%', () {
      expect(
        swipeOffset(distance: -60, blocked: true, maxDrag: 170),
        closeTo(-13.2, 0.001),
      );
    });

    test('an open direction moves with the finger', () {
      expect(swipeOffset(distance: -60, blocked: false, maxDrag: 170), -60);
    });

    test('neither direction passes the ceiling', () {
      expect(swipeOffset(distance: 900, blocked: false, maxDrag: 170), 170);
      expect(swipeTravel(distance: -900, maxDrag: 170), -170);
    });
  });

  group('a blocked direction explains itself on the gesture', () {
    test('the caption is full by 30px of finger travel', () {
      expect(swipeCaptionOpacity(30), 1);
      expect(swipeCaptionOpacity(60), 1);
      expect(swipeCaptionOpacity(-30), 1);
    });

    test('a 60px blocked swipe captions itself fully, not at 0.3', () {
      const distance = -60.0;
      final moved = swipeOffset(
        distance: distance,
        blocked: true,
        maxDrag: 170,
      );
      final travel = swipeTravel(distance: distance, maxDrag: 170);

      expect(swipeCaptionOpacity(moved), lessThan(0.5));
      expect(swipeCaptionOpacity(travel), 1);
    });

    test('it fades in over the first 30px', () {
      expect(swipeCaptionOpacity(15), 0.5);
      expect(swipeCaptionOpacity(0), 0);
    });
  });

  group('the commit decision', () {
    test('past the threshold, each way commits its own aim', () {
      expect(
        swipeCommit(
          offset: -70,
          commitThreshold: 70,
          canAdvance: true,
          canBack: true,
        ),
        SwipeAim.advance,
      );
      expect(
        swipeCommit(
          offset: 70,
          commitThreshold: 70,
          canAdvance: true,
          canBack: true,
        ),
        SwipeAim.back,
      );
    });

    test('short of it, nothing commits', () {
      expect(
        swipeCommit(
          offset: -69,
          commitThreshold: 70,
          canAdvance: true,
          canBack: true,
        ),
        isNull,
      );
    });

    test('a blocked direction never commits, however far it is dragged', () {
      expect(
        swipeCommit(
          offset: -170,
          commitThreshold: 70,
          canAdvance: false,
          canBack: true,
        ),
        isNull,
      );
    });

    test('progress is signed, and stops at one', () {
      expect(swipeCommitProgress(offset: -35, commitThreshold: 70), -0.5);
      expect(swipeCommitProgress(offset: 140, commitThreshold: 70), 1);
    });
  });

  group('the fly-off', () {
    test('a committed swipe leaves the side it is heading for', () {
      expect(
        swipeExitOffset(aim: SwipeAim.advance, exitDistance: 340),
        -340,
      );
      expect(swipeExitOffset(aim: SwipeAim.back, exitDistance: 340), 340);
    });

    test('the tilt follows the movement, in radians', () {
      expect(
        swipeTilt(offset: 100, degreesPer100px: 7),
        closeTo(7 * math.pi / 180, 1e-9),
      );
      expect(swipeTilt(offset: 100, degreesPer100px: 0), 0);
    });
  });

  group('the deck stack', () {
    const riseDistance = 104.0;

    test('a sliver rises as the drag comes its way', () {
      expect(
        deckSliverRise(
          reveals: SwipeAim.advance,
          offset: -52,
          riseDistance: riseDistance,
        ),
        0.5,
      );
      expect(
        deckSliverRise(
          reveals: SwipeAim.back,
          offset: -52,
          riseDistance: riseDistance,
        ),
        0,
      );
    });

    test('the exit carries it the rest of the way, not in one jump', () {
      // A commit releases at the threshold, so the rise is part-way up; the
      // flight is far longer than the rise, so it arrives under its own steam.
      const releasedAt = -70.0;
      final atRelease = deckSliverRise(
        reveals: SwipeAim.advance,
        offset: releasedAt,
        riseDistance: riseDistance,
      );

      expect(atRelease, greaterThan(0));
      expect(atRelease, lessThan(1));
      expect(
        deckSliverRise(
          reveals: SwipeAim.advance,
          offset: -340,
          riseDistance: riseDistance,
        ),
        1,
      );
    });

    test('each sliver rests on its own side and comes home at one', () {
      expect(
        deckSliverOffset(reveals: SwipeAim.advance, inset: 13, rise: 0),
        13,
      );
      expect(deckSliverOffset(reveals: SwipeAim.back, inset: 13, rise: 0), -13);
      expect(
        deckSliverOffset(reveals: SwipeAim.advance, inset: 13, rise: 1),
        0,
      );
    });

    test('depth comes from scale, which costs no contrast', () {
      expect(deckSliverScale(restScale: 0.955, rise: 0), 0.955);
      expect(deckSliverScale(restScale: 0.955, rise: 1), 1);
    });
  });
}
