import 'package:brew_path/app/app.dart';
import 'package:brew_path/app/app_router.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/tour/domain/tour_copy.dart';
import 'package:brew_path/features/tour/domain/tour_step.dart';
import 'package:brew_path/features/tour/presentation/today_tour.dart';
import 'package:brew_path/features/tour/presentation/tour_frame.dart';
import 'package:brew_path/shared/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/widget_harness.dart';

// Driven through the whole app rather than `LearnScreen` alone, because the
// gate is a fact about the shell: the flag lives in the database, the run
// starts when the Learn tab shows real data, and the fourth stop is anchored
// on the tab bar. Pumping Learn on its own would prove none of that.
void main() {
  setUp(useInMemoryDatabase);

  /// Tall enough for the whole Learn list, as the other Learn tests use.
  void useTallViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  /// Clears the flag the harness seeds, so the app boots owing the Tour.
  Future<void> armTheTour() async {
    final repo = SettingsRepository();
    final settings = await repo.getSettings()
      ..tourSeen = false;
    await repo.saveSettings(settings);
  }

  Future<bool> tourSeenOnDisk() async =>
      (await SettingsRepository().getSettings()).tourSeen;

  /// Drives the running Tour without `pumpAndSettle`.
  ///
  /// Roasty idles on an infinite animation behind the layer, so `pumpAndSettle`
  /// never returns — the same reason the shared harness hand-rolls its settle.
  /// `runAsync` is what lets the real Drift write behind `markTourSeen`
  /// actually complete between frames.
  Future<void> letTheTourRun(WidgetTester tester) async {
    for (var frame = 0; frame < 20; frame++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  /// Boots the app owing the Tour, the way a first launch does, and hands back
  /// the container so a test can drive the router.
  Future<ProviderContainer> bootOwingTheTour(WidgetTester tester) async {
    useTallViewport(tester);
    await armTheTour();

    final container = await pumpWithProviders(tester, const BrewPathApp());
    await letTheTourRun(tester);
    return container;
  }

  Future<void> walkToTheLastStop(WidgetTester tester) async {
    for (var stop = 0; stop < TourStep.count - 1; stop++) {
      await tester.tap(find.text(TourCopy.stopNext));
      await letTheTourRun(tester);
    }
  }

  testWidgets('runs the Tour, unasked, when Learn shows with the flag unset', (
    tester,
  ) async {
    await bootOwingTheTour(tester);

    // Straight to the first stop: the design draws the Tour as soon as Today
    // does, with nothing to answer first (#537).
    expect(find.byType(TodayTour), findsOneWidget);
    expect(find.text(TourCopy.todayTitle), findsOneWidget);
    expect(find.text(TourCopy.todayBody), findsOneWidget);
  });

  testWidgets('does not run the Tour once the flag is set', (tester) async {
    // The harness seeds `tourSeen`, which is the already-toured device.
    useTallViewport(tester);

    await pumpWithProviders(tester, const BrewPathApp());
    await letTheTourRun(tester);

    expect(find.byType(TodayTour), findsNothing);
    expect(find.text(TourCopy.todayTitle), findsNothing);
  });

  testWidgets('a run on screen has not spent the flag yet', (tester) async {
    await bootOwingTheTour(tester);

    // Written by finishing, as the design's `tourDone` is — not by starting.
    expect(await tourSeenOnDisk(), isFalse);
  });

  testWidgets('Skip ends the run and writes the flag', (tester) async {
    await bootOwingTheTour(tester);

    await tester.tap(find.text(TourCopy.stopSkip));
    await letTheTourRun(tester);

    // Skipping is finishing early, not walking away: the write is what stops
    // the app running the Tour again on the next open.
    expect(find.byType(TodayTour), findsNothing);
    expect(await tourSeenOnDisk(), isTrue);
  });

  testWidgets('Done ends the run and writes the flag', (tester) async {
    await bootOwingTheTour(tester);

    await walkToTheLastStop(tester);
    await tester.tap(find.text(TourCopy.stopDone));
    await letTheTourRun(tester);

    expect(find.byType(TodayTour), findsNothing);
    expect(await tourSeenOnDisk(), isTrue);
  });

  testWidgets('leaving the tab ends the run without spending it', (
    tester,
  ) async {
    final container = await bootOwingTheTour(tester);

    // Through the router rather than the tab bar, whose taps the Tour's own
    // shield swallows while a card is up.
    container.read(appRouterProvider).goNamed(AppRoutes.path.name);
    await letTheTourRun(tester);

    // Ended, as #338 ruled — but not finished, so the Tour is still owed and
    // returns on the next launch, which is the design's rule for its flag.
    expect(find.byType(TodayTour), findsNothing);
    expect(await tourSeenOnDisk(), isFalse);
  });

  testWidgets('a run ended by leaving the tab does not restart this launch', (
    tester,
  ) async {
    final container = await bootOwingTheTour(tester);
    final router = container.read(appRouterProvider);

    router.goNamed(AppRoutes.path.name);
    await letTheTourRun(tester);
    router.goNamed(AppRoutes.learn.name);
    await letTheTourRun(tester);

    // The flag still reads false, and Learn rebuilds on the way back. Once per
    // launch is a fact the screen remembers, not one the flag can carry.
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
    await bootOwingTheTour(tester);

    // The move is shortened to nothing rather than dropped: the frame still
    // has to *arrive* at each stop, so what reduced motion removes is the
    // travel, not the arrival.
    expect(frameMoveDuration(tester), Duration.zero);
  });

  testWidgets('the frame travels at the design speed without it', (
    tester,
  ) async {
    await bootOwingTheTour(tester);

    expect(frameMoveDuration(tester), TourFrame.moveDuration);
  });
}
