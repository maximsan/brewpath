import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/features/tour/domain/tour_copy.dart';
import 'package:brew_path/features/tour/domain/tour_geometry.dart';
import 'package:brew_path/features/tour/domain/tour_step.dart';
import 'package:brew_path/features/tour/presentation/today_tour.dart';
import 'package:brew_path/features/tour/presentation/tour_anchor.dart';
import 'package:brew_path/features/tour/presentation/tour_frame.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/tour_harness.dart';
import '../../../support/widget_harness.dart';

// What the rebuild is for: a frame that finds each target and travels between
// them, a card that takes the side with room on it, and a page nothing can
// reach while either is up. The old engine could draw none of it — its cut-out
// could not carry a ring, and it never interpolated the highlight (#339).
void main() {
  setUp(useInMemoryDatabase);

  /// The hole the layer is currently painting.
  Rect? paintedFrame(WidgetTester tester) {
    final paint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(TourFrame),
        matching: find.byType(CustomPaint),
      ),
    );
    return (paint.painter! as TourFramePainter).frame;
  }

  /// The content box [step]'s frame is drawn around, in the layer's
  /// coordinates — the anchor's own box less whatever of it is padding.
  Rect anchorRect(WidgetTester tester, TourStep step) {
    final target =
        TourAnchor.contextFor(step)!.findRenderObject()! as RenderBox;
    final layer = tester.renderObject<RenderBox>(find.byType(TodayTour));
    final box =
        target.localToGlobal(Offset.zero, ancestor: layer) & target.size;
    return tourContentBox(box, TourAnchor.insetFor(step));
  }

  testWidgets('the frame surrounds the stop it is on', (tester) async {
    await bootIntoTheTour(tester);

    expect(
      paintedFrame(tester),
      anchorRect(
        tester,
        TourStep.today,
      ).inflate(OffTokens.tourFrameInset.value),
      reason: 'the frame stands off the target it names, on all four sides',
    );
  });

  testWidgets('the frame travels to the next stop', (tester) async {
    await bootIntoTheTour(tester);
    final first = paintedFrame(tester);

    await tester.tap(find.text(TourCopy.stopNext));
    await letTheTourRun(tester);

    expect(paintedFrame(tester), isNot(first));
    expect(
      paintedFrame(tester),
      anchorRect(
        tester,
        TourStep.practice,
      ).inflate(OffTokens.tourFrameInset.value),
    );
  });

  testWidgets('the frame reaches the tab bar, which no tab contains', (
    tester,
  ) async {
    // The stop the old engine could not hold: the bar lives outside every
    // branch, so a layer drawn inside the tab could never frame it.
    await bootIntoTheTour(tester);
    await walkToTheLastStop(tester);

    expect(find.text(TourCopy.tabsTitle), findsOneWidget);
    expect(
      paintedFrame(tester),
      anchorRect(tester, TourStep.tabs).inflate(OffTokens.tourFrameInset.value),
    );
  });

  testWidgets('the card takes the side with room on it', (tester) async {
    await bootIntoTheTour(tester);
    final layerHeight = tester.getSize(find.byType(TodayTour)).height;

    // Stop one sits near the top of a tall feed, so the card goes under it.
    final firstCard = tester.getRect(find.text(TourCopy.todayTitle));
    expect(firstCard.top, greaterThan(paintedFrame(tester)!.bottom));

    await walkToTheLastStop(tester);

    // The last stop is the bar at the very foot: nothing fits under it, and
    // the card has to go above instead.
    final lastFrame = paintedFrame(tester)!;
    expect(
      lastFrame.bottom,
      greaterThan(layerHeight - OffTokens.tourCardHeadroom.value),
      reason: 'the tab bar is exactly the case the headroom rule is for',
    );
    expect(
      tester.getRect(find.text(TourCopy.tabsTitle)).bottom,
      lessThan(lastFrame.top),
    );
  });

  testWidgets('the day and the practice shelf are framed at the gutter', (
    tester,
  ) async {
    await bootIntoTheTour(tester);
    final width = tester.getSize(find.byType(TodayTour)).width;
    final standoff = OffTokens.tourFrameInset.value;

    // The frame rings what the stop points at, not the page it is laid out on:
    // both sections run full-bleed, and ringing their boxes put the outline
    // off both screen edges.
    for (final step in [TourStep.today, TourStep.practice]) {
      if (step != TourStep.today) {
        await tester.tap(find.text(TourCopy.stopNext));
        await letTheTourRun(tester);
      }
      final frame = paintedFrame(tester)!;
      expect(
        frame.left,
        AppSpacing.gutter - standoff,
        reason: '$step must be framed at the design gutter',
      );
      expect(frame.right, width - AppSpacing.gutter + standoff);
    }
  });

  testWidgets('the tab bar is framed on its tabs, not on its strips', (
    tester,
  ) async {
    await bootIntoTheTour(tester);
    await walkToTheLastStop(tester);

    // The bar's box runs from its hairline to the foot of the screen. The
    // design rings the row of tabs inside it, so the frame starts below the
    // hairline and every tab's mark is inside it.
    final bar = tester.getRect(find.byType(NavigationBar));
    final frame = paintedFrame(tester)!;
    final standoff = OffTokens.tourFrameInset.value;

    expect(frame.top, bar.top + OffTokens.tabBarTopPad.value - standoff);
    expect(frame.top, greaterThan(bar.top));
    for (final mark in tester.widgetList<IconMark>(find.byType(IconMark))) {
      final box = tester.getRect(find.byWidget(mark));
      if (!bar.overlaps(box)) continue;
      expect(
        frame.contains(box.topLeft) && frame.contains(box.bottomRight),
        isTrue,
        reason: 'every tab mark stays inside the frame',
      );
    }
  });

  testWidgets('the frame clears the home indicator under the tab bar', (
    tester,
  ) async {
    // The design pads the bar 28 below its tabs for the indicator; the app
    // leaves out the strip the bar's own `SafeArea` took, which is the inset
    // the device reports — and is nothing at all on a phone without one.
    const indicator = 34.0;
    tester.view.padding = const FakeViewPadding(bottom: indicator);
    addTearDown(tester.view.resetPadding);

    await bootIntoTheTour(tester);
    await walkToTheLastStop(tester);

    final bar = tester.getRect(find.byType(NavigationBar));
    final frame = paintedFrame(tester)!;

    expect(
      frame.bottom,
      bar.bottom - indicator + OffTokens.tourFrameInset.value,
    );
    expect(frame.bottom, lessThan(bar.bottom));
  });

  testWidgets('nothing behind the Tour can be tapped, target included', (
    tester,
  ) async {
    await bootIntoTheTour(tester);

    // The day's own call to action, under the frame that is explaining it.
    // The design freezes the page: the target is being introduced, not offered.
    await tester.tap(
      find.text(AppLabels.beginLesson),
      warnIfMissed: false,
    );
    await letTheTourRun(tester);

    expect(
      find.text(TourCopy.todayTitle),
      findsOneWidget,
      reason: 'the tap must not have opened the lesson under the frame',
    );
  });
}
