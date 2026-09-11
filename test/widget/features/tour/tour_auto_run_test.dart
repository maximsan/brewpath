import 'package:brew_path/app/app.dart';
import 'package:brew_path/app/app_router.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/tour/domain/tour_copy.dart';
import 'package:brew_path/features/tour/presentation/today_tour.dart';
import 'package:brew_path/features/tour/presentation/tour_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/tour_harness.dart';
import '../../../support/widget_harness.dart';

// Driven through the whole app rather than `LearnScreen` alone, because the
// gate is a fact about the shell: the flag lives in the database, the run
// starts when the Learn tab shows real data, and the fourth stop is anchored
// on the tab bar. Pumping Learn on its own would prove none of that.
void main() {
  setUp(useInMemoryDatabase);

  testWidgets('runs the Tour, unasked, when Learn shows with the flag unset', (
    tester,
  ) async {
    await bootIntoTheTour(tester);

    // Straight to the first stop: the design draws the Tour as soon as Today
    // does, with nothing to answer first (#537).
    expect(find.byType(TodayTour), findsOneWidget);
    expect(find.text(TourCopy.todayTitle), findsOneWidget);
    expect(find.text(TourCopy.todayBody), findsOneWidget);
  });

  testWidgets('does not run the Tour once the flag is set', (tester) async {
    // The harness seeds `tourSeen`, which is the already-toured device.
    useTourViewport(tester);

    await pumpWithProviders(tester, const BrewPathApp());
    await letTheTourRun(tester);

    expect(find.byType(TodayTour), findsNothing);
    expect(find.text(TourCopy.todayTitle), findsNothing);
  });

  testWidgets('a run on screen has not spent the flag yet', (tester) async {
    await bootIntoTheTour(tester);

    // Written by ending, as the design's `tourDone` is — not by starting.
    expect(await tourSeenOnDisk(), isFalse);
  });

  testWidgets('Skip ends the run and writes the flag', (tester) async {
    await bootIntoTheTour(tester);

    await tester.tap(find.text(TourCopy.stopSkip));
    await letTheTourRun(tester);

    expect(find.byType(TodayTour), findsNothing);
    await awaitTourSeenWritten(tester);
  });

  testWidgets('Done ends the run and writes the flag', (tester) async {
    await bootIntoTheTour(tester);

    await walkToTheLastStop(tester);
    await tester.tap(find.text(TourCopy.stopDone));
    await letTheTourRun(tester);

    expect(find.byType(TodayTour), findsNothing);
    await awaitTourSeenWritten(tester);
  });

  testWidgets('leaving the tab ends the run and writes the flag', (
    tester,
  ) async {
    final container = await bootIntoTheTour(tester);

    // Through the router rather than the tab bar, whose taps the Tour's own
    // shield swallows while a card is up.
    container.read(appRouterProvider).goNamed(AppRoutes.path.name);
    await letTheTourRun(tester);

    // Walking away is an ending too (#338), and every ending spends the first
    // run: the Tour is shown once and never asks (#537).
    expect(find.byType(TodayTour), findsNothing);
    await awaitTourSeenWritten(tester);
  });

  testWidgets('a run ended by leaving the tab does not restart this launch', (
    tester,
  ) async {
    final container = await bootIntoTheTour(tester);
    final router = container.read(appRouterProvider);

    router.goNamed(AppRoutes.path.name);
    await letTheTourRun(tester);
    router.goNamed(AppRoutes.learn.name);
    await letTheTourRun(tester);

    // Learn rebuilds on the way back with its day already resolved, which is
    // exactly the moment that used to start the run.
    expect(find.byType(TodayTour), findsNothing);
  });

  /// How long the frame takes to travel, as the running layer reports it.
  Duration frameMoveDuration(WidgetTester tester) => tester
      .widget<TweenAnimationBuilder<Rect?>>(
        find.descendant(
          of: find.byType(TourFrame),
          matching: find.byType(TweenAnimationBuilder<Rect?>),
        ),
      )
      .duration;

  testWidgets('reduced motion makes the frame arrive in a cut', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await bootIntoTheTour(tester);

    // The move is shortened to nothing rather than dropped: the frame still
    // has to *arrive* at each stop, so what reduced motion removes is the
    // travel, not the arrival.
    expect(frameMoveDuration(tester), Duration.zero);
  });

  testWidgets('the frame travels at the design speed without it', (
    tester,
  ) async {
    await bootIntoTheTour(tester);

    expect(frameMoveDuration(tester), TourFrame.moveDuration);
  });
}
