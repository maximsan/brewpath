import 'package:brew_path/app/app.dart';
import 'package:brew_path/features/tour/domain/tour_copy.dart';
import 'package:brew_path/features/tour/domain/tour_step.dart';
import 'package:brew_path/features/tour/presentation/today_tour.dart';
import 'package:brew_path/features/tour/presentation/tour_anchor.dart';
import 'package:brew_path/features/tour/presentation/tour_frame.dart';
import 'package:brew_path/shared/repositories/settings_repository.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/widget_harness.dart';

/// What the rebuild is for: a frame that finds each target and travels between
/// them, a card that takes the side with room on it, and a page nothing can
/// reach while either is up.
///
/// The old engine could draw none of this — its cut-out could not carry a ring,
/// and it never interpolated the highlight at all
/// ([#339](https://github.com/maximsan/brewpath/issues/339)).
void main() {
  setUp(useInMemoryDatabase);

  void useTallViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> armTheTour() async {
    final repo = SettingsRepository();
    final settings = await repo.getSettings()
      ..tourSeen = false;
    await repo.saveSettings(settings);
  }

  /// Drives the layer without `pumpAndSettle`, which never returns while
  /// Roasty idles behind it. Long enough for the frame's own 320ms travel.
  Future<void> letTheTourRun(WidgetTester tester) async {
    for (var frame = 0; frame < 20; frame++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> startTheTour(WidgetTester tester) async {
    useTallViewport(tester);
    await armTheTour();

    await pumpWithProviders(tester, const BrewPathApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text(TourCopy.introAccept));
    await letTheTourRun(tester);
  }

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

  /// Where [step]'s target actually is, in the layer's coordinates.
  Rect anchorRect(WidgetTester tester, TourStep step) {
    final target =
        TourAnchor.contextFor(step)!.findRenderObject()! as RenderBox;
    final layer = tester.renderObject<RenderBox>(find.byType(TodayTour));
    return target.localToGlobal(Offset.zero, ancestor: layer) & target.size;
  }

  testWidgets('the frame surrounds the stop it is on', (tester) async {
    await startTheTour(tester);

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
    await startTheTour(tester);
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
    await startTheTour(tester);
    for (var step = 0; step < TourStep.count - 1; step++) {
      await tester.tap(find.text(TourCopy.stopNext));
      await letTheTourRun(tester);
    }

    expect(find.text(TourCopy.tabsTitle), findsOneWidget);
    expect(
      paintedFrame(tester),
      anchorRect(tester, TourStep.tabs).inflate(OffTokens.tourFrameInset.value),
    );
  });

  testWidgets('the card takes the side with room on it', (tester) async {
    await startTheTour(tester);
    final layerHeight = tester.getSize(find.byType(TodayTour)).height;

    // Stop one sits near the top of a tall feed, so the card goes under it.
    final firstCard = tester.getRect(find.text(TourCopy.todayTitle));
    expect(firstCard.top, greaterThan(paintedFrame(tester)!.bottom));

    for (var step = 0; step < TourStep.count - 1; step++) {
      await tester.tap(find.text(TourCopy.stopNext));
      await letTheTourRun(tester);
    }

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

  testWidgets('nothing behind the Tour can be tapped, target included', (
    tester,
  ) async {
    await startTheTour(tester);

    // The day's own call to action, under the frame that is explaining it.
    // The design freezes the page: the target is being introduced, not offered.
    await tester.tap(
      find.widgetWithText(FilledButton, 'Start'),
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
