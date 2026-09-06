import 'package:brew_path/app/app.dart';
import 'package:brew_path/app/app_router.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/tour/domain/tour_copy.dart';
import 'package:brew_path/features/tour/domain/tour_providers.dart';
import 'package:brew_path/features/tour/domain/tour_step.dart';
import 'package:brew_path/features/tour/presentation/today_tour.dart';
import 'package:brew_path/shared/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/widget_harness.dart';

/// The Tour's controls: the two buttons on every card, and the tab switch that
/// ends the run.
///
/// Driven through the whole app rather than through one screen, because both
/// behaviours are facts about the shell — the layer is drawn beside the
/// scaffold rather than inside a tab, and the tab bar its last stop frames
/// lives outside every branch.
void main() {
  setUp(useInMemoryDatabase);

  /// Tall enough for the whole Learn list, as the other Tour tests use.
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

  /// Drives the running Tour without `pumpAndSettle`, which never returns
  /// while Roasty's idle animation is looping behind the layer.
  Future<void> letTheTourRun(WidgetTester tester) async {
    for (var frame = 0; frame < 20; frame++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  /// Boots the app onto the first stop, the way accepting the offer does, and
  /// hands back the container so a test can drive the router.
  Future<ProviderContainer> startTheTour(WidgetTester tester) async {
    useTallViewport(tester);
    await armTheTour();

    final container = await pumpWithProviders(tester, const BrewPathApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text(TourCopy.introAccept));
    await letTheTourRun(tester);
    return container;
  }

  /// Whether the layer is on screen, which is the whole of what "running"
  /// means now: the Tour is an ordinary child of the shell, so a Tour that has
  /// ended is a Tour that is not built.
  bool tourIsRunning(WidgetTester tester, ProviderContainer container) =>
      container.read(tourRunningProvider) &&
      find.byType(TodayTour).evaluate().isNotEmpty;

  testWidgets('every card carries Skip and Next', (tester) async {
    await startTheTour(tester);

    expect(find.text(TourCopy.stopSkip), findsOneWidget);
    expect(find.text(TourCopy.stopNext), findsOneWidget);
    // Not yet: Done belongs to the stop the Tour ends on.
    expect(find.text(TourCopy.stopDone), findsNothing);
  });

  testWidgets('Skip closes the Tour on the first card', (tester) async {
    final container = await startTheTour(tester);

    await tester.tap(find.text(TourCopy.stopSkip));
    await letTheTourRun(tester);

    expect(tourIsRunning(tester, container), isFalse);
    expect(find.text(TourCopy.todayTitle), findsNothing);
  });

  testWidgets('Next walks the stops and the last one says Done', (
    tester,
  ) async {
    await startTheTour(tester);

    expect(find.text(TourCopy.todayTitle), findsOneWidget);

    // Three taps from the first stop to the fourth, which is the tab bar.
    for (final title in [TourCopy.practiceTitle, TourCopy.headerTitle]) {
      await tester.tap(find.text(TourCopy.stopNext));
      await letTheTourRun(tester);
      expect(find.text(title), findsOneWidget);
    }
    await tester.tap(find.text(TourCopy.stopNext));
    await letTheTourRun(tester);

    expect(find.text(TourCopy.tabsTitle), findsOneWidget);
    expect(find.text(TourCopy.stopDone), findsOneWidget);
    expect(find.text(TourCopy.stopNext), findsNothing);
  });

  testWidgets('Done closes the Tour on the last card', (tester) async {
    final container = await startTheTour(tester);

    for (var stop = 0; stop < TourStep.count - 1; stop++) {
      await tester.tap(find.text(TourCopy.stopNext));
      await letTheTourRun(tester);
    }

    await tester.tap(find.text(TourCopy.stopDone));
    await letTheTourRun(tester);

    expect(tourIsRunning(tester, container), isFalse);
    expect(find.text(TourCopy.tabsTitle), findsNothing);
  });

  testWidgets('switching tabs mid-Tour ends it', (tester) async {
    final container = await startTheTour(tester);
    expect(find.text(TourCopy.todayTitle), findsOneWidget);

    // Driven through the router rather than by tapping the tab bar: the Tour's
    // own barrier swallows every tap while a card is up, so navigation is the
    // only way a branch changes mid-run — which is exactly the case that used
    // to leave stop 1's callout floating over Path, because the host wraps the
    // shell and nothing disposed on the switch.
    container.read(appRouterProvider).goNamed(AppRoutes.path.name);
    await letTheTourRun(tester);

    expect(tourIsRunning(tester, container), isFalse);
    expect(find.text(TourCopy.todayTitle), findsNothing);
    expect(find.text(TourCopy.stopNext), findsNothing);
  });
}
