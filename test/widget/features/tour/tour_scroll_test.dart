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

/// The Tour on a phone-sized screen, where its targets do not all fit.
///
/// The other Tour tests use a viewport tall enough to hold the whole Learn
/// feed, which is what makes them readable — and which means none of them ever
/// exercises the scroll. This one does: it is the only place the feed actually
/// has to move for a stop to be framed at all.
void main() {
  setUp(useInMemoryDatabase);

  /// A real phone, so the feed is taller than the screen.
  void usePhoneViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(400, 800);
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

  Future<void> letTheTourRun(WidgetTester tester) async {
    for (var frame = 0; frame < 20; frame++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> startTheTour(WidgetTester tester) async {
    usePhoneViewport(tester);
    await armTheTour();

    await pumpWithProviders(tester, const BrewPathApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text(TourCopy.introAccept));
    await letTheTourRun(tester);
  }

  Rect? paintedFrame(WidgetTester tester) {
    final paint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(TourFrame),
        matching: find.byType(CustomPaint),
      ),
    );
    return (paint.painter! as TourFramePainter).frame;
  }

  Rect anchorRect(WidgetTester tester, TourStep step) {
    final target =
        TourAnchor.contextFor(step)!.findRenderObject()! as RenderBox;
    final layer = tester.renderObject<RenderBox>(find.byType(TodayTour));
    return target.localToGlobal(Offset.zero, ancestor: layer) & target.size;
  }

  /// How far the Learn feed has been scrolled.
  double feedOffset(WidgetTester tester) =>
      Scrollable.of(TourAnchor.contextFor(TourStep.today)!).position.pixels;

  Future<void> advance(WidgetTester tester) async {
    await tester.tap(find.text(TourCopy.stopNext));
    await letTheTourRun(tester);
  }

  testWidgets('a stop below the fold is scrolled to and framed', (
    tester,
  ) async {
    await startTheTour(tester);
    expect(feedOffset(tester), 0, reason: 'the first stop is already in view');

    await advance(tester);

    expect(
      feedOffset(tester),
      greaterThan(0),
      reason: 'the practice section does not fit on a phone with the day',
    );
    // And the frame landed on it rather than where it used to be. The target
    // is measured *after* the scroll, which is the whole reason the two are
    // a frame apart.
    expect(
      paintedFrame(tester),
      anchorRect(
        tester,
        TourStep.practice,
      ).inflate(OffTokens.tourFrameInset.value),
    );
  });

  testWidgets('a stop that frames chrome returns the feed to the top', (
    tester,
  ) async {
    await startTheTour(tester);
    await advance(tester);
    expect(feedOffset(tester), greaterThan(0));

    await advance(tester);

    // Stop three is the header. It does not move with the feed, so there is
    // nothing to scroll *to* — what the scroll is for is putting the page back
    // where the learner will find it.
    expect(find.text(TourCopy.headerTitle), findsOneWidget);
    expect(feedOffset(tester), 0);
  });

  testWidgets('the scrolled-to target is clear of the header above it', (
    tester,
  ) async {
    await startTheTour(tester);
    await advance(tester);

    // The design brings a target no closer than this to the feed's top edge,
    // so the frame never ends up under the header floating over the page.
    expect(
      anchorRect(tester, TourStep.practice).top,
      greaterThanOrEqualTo(OffTokens.tourScrollTopGap.value),
    );
  });
}
