import 'package:brew_path/features/tour/domain/tour_geometry.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

// The Tour overlay's arithmetic: where the frame goes, which side the card
// takes, and how far the feed moves to make a target framable.
void main() {
  group('the frame', () {
    test('stands off the target evenly on all four sides', () {
      const target = Rect.fromLTWH(20, 100, 200, 80);
      final inset = OffTokens.tourFrameInset.value;

      expect(
        tourFrameRect(target),
        Rect.fromLTWH(
          20 - inset,
          100 - inset,
          200 + 2 * inset,
          80 + 2 * inset,
        ),
      );
    });
  });

  group('which side the card takes', () {
    const areaHeight = 800.0;

    test('below a target with room under it', () {
      expect(
        tourCardSitsBelow(
          target: const Rect.fromLTWH(0, 40, 300, 120),
          areaHeight: areaHeight,
        ),
        isTrue,
      );
    });

    test('above a target that leaves the card no room', () {
      // Its bottom sits inside the card's own height of the screen foot, so a
      // card below it would hang off the bottom.
      expect(
        tourCardSitsBelow(
          target: const Rect.fromLTWH(0, 500, 300, 120),
          areaHeight: areaHeight,
        ),
        isFalse,
      );
    });

    test('the boundary is the card headroom itself', () {
      const justAbove = Rect.fromLTWH(0, 0, 300, areaHeight - 330 - 1);
      const exactly = Rect.fromLTWH(0, 0, 300, areaHeight - 330);

      expect(
        tourCardSitsBelow(target: justAbove, areaHeight: areaHeight),
        isTrue,
      );
      expect(
        tourCardSitsBelow(target: exactly, areaHeight: areaHeight),
        isFalse,
        reason: 'the rule is strict: exactly the headroom is not enough',
      );
    });

    test('the tab bar, framed at the very foot, takes a card above it', () {
      // The last stop's target is the shell's own bar. Nothing can sit under
      // it, and the rule has to reach that conclusion on its own.
      expect(
        tourCardSitsBelow(
          target: const Rect.fromLTWH(0, areaHeight - 80, 400, 80),
          areaHeight: areaHeight,
        ),
        isFalse,
      );
    });
  });

  group('how far the feed scrolls', () {
    test('not at all for a target already framable', () {
      expect(
        tourScrollDelta(
          topGap: OffTokens.tourScrollTopGap.value + 60,
          bottomOverflow: -20,
        ),
        0,
      );
    });

    test('down to the top line for a target sitting too high', () {
      // Negative: the feed scrolls back up so the target drops to the line.
      expect(tourScrollDelta(topGap: 40, bottomOverflow: -300), 40 - 140);
    });

    test('up for a target whose bottom runs past the card', () {
      expect(tourScrollDelta(topGap: 600, bottomOverflow: 120), 120);
    });

    test('never so far up that the target rises above the top line', () {
      // The design caps the pull at the distance to the line, so a tall target
      // is never dragged out of the top of the feed to make room for the card.
      expect(
        tourScrollDelta(topGap: 180, bottomOverflow: 400),
        180 - 140,
        reason: 'the cap is what stops the scroll overshooting the top line',
      );
    });

    test('a target both too high and overflowing is only pushed down', () {
      expect(tourScrollDelta(topGap: 10, bottomOverflow: 400), 10 - 140);
    });
  });

  group('how far a target overflows the room the card needs', () {
    test('negative while the card still fits under it', () {
      expect(
        tourBottomOverflow(
          target: const Rect.fromLTWH(0, 0, 300, 100),
          viewportHeight: 800,
        ),
        100 - 800 + OffTokens.tourScrollCardClearance.value,
      );
    });

    test('positive once it does not', () {
      expect(
        tourBottomOverflow(
          target: const Rect.fromLTWH(0, 600, 300, 100),
          viewportHeight: 800,
        ),
        greaterThan(0),
      );
    });
  });

  group('where the card sits', () {
    const areaHeight = 852.0;
    const cardHeight = 150.0;
    const statusBar = EdgeInsets.only(top: 59, bottom: 34);
    final gap = OffTokens.tourCardInset.value;

    test('under a target with room beneath it', () {
      const target = Rect.fromLTWH(0, 100, 300, 120);

      expect(
        tourCardTop(
          target: target,
          areaHeight: areaHeight,
          cardHeight: cardHeight,
          safeArea: statusBar,
        ),
        target.bottom + gap,
      );
    });

    test('over a target with none', () {
      const target = Rect.fromLTWH(0, 300, 300, 400);

      expect(
        tourCardTop(
          target: target,
          areaHeight: areaHeight,
          cardHeight: cardHeight,
          safeArea: statusBar,
        ),
        target.top - gap - cardHeight,
      );
    });

    test('takes the other side when its own has no room', () {
      // The stop-1 case: a tall Today card near the top of the feed. The
      // design's rule says above, where only the status bar's strip is left.
      const target = Rect.fromLTWH(0, 172, 393, 392);

      final top = tourCardTop(
        target: target,
        areaHeight: areaHeight,
        cardHeight: cardHeight,
        safeArea: statusBar,
      );

      expect(
        tourCardSitsBelow(target: target, areaHeight: areaHeight),
        isFalse,
      );
      expect(top, target.bottom + gap);
      expect(top, greaterThan(statusBar.top));
    });

    test('clamps when neither side has room', () {
      // A target filling the screen: above is off the top, below off the foot.
      const target = Rect.fromLTWH(0, 80, 393, 700);

      final top = tourCardTop(
        target: target,
        areaHeight: areaHeight,
        cardHeight: cardHeight,
        safeArea: statusBar,
      );

      expect(top, greaterThanOrEqualTo(statusBar.top + gap));
      expect(
        top + cardHeight,
        lessThanOrEqualTo(areaHeight - statusBar.bottom - gap),
      );
    });

    test('never under the home indicator', () {
      const target = Rect.fromLTWH(0, 700, 393, 100);

      final top = tourCardTop(
        target: target,
        areaHeight: areaHeight,
        cardHeight: cardHeight,
        safeArea: statusBar,
      );

      expect(
        top + cardHeight,
        lessThanOrEqualTo(areaHeight - statusBar.bottom - gap),
      );
    });

    test('at rest near the foot until a target is measured', () {
      expect(
        tourCardTop(
          target: null,
          areaHeight: areaHeight,
          cardHeight: cardHeight,
          safeArea: statusBar,
        ),
        areaHeight - OffTokens.tourCardRestingBottom.value - cardHeight,
      );
    });

    test('shows its top when the room is shorter than the card', () {
      expect(
        tourCardTop(
          target: const Rect.fromLTWH(0, 100, 300, 120),
          areaHeight: 200,
          cardHeight: cardHeight,
          safeArea: statusBar,
        ),
        statusBar.top + gap,
      );
    });
  });
}
