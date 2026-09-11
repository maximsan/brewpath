import 'package:brew_path/app/app_router.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/tour/domain/tour_copy.dart';
import 'package:brew_path/features/tour/domain/tour_providers.dart';
import 'package:brew_path/features/tour/presentation/today_tour.dart';
import 'package:brew_path/features/tour/presentation/tour_card_controls.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/tour_harness.dart';
import '../../../support/widget_harness.dart';

// Driven through the whole app rather than one screen, because both behaviours
// are facts about the shell: the layer is drawn beside the scaffold rather than
// inside a tab, and the tab bar that ends the Tour lives outside every branch.
void main() {
  setUp(useInMemoryDatabase);

  /// Whether the layer is on screen, which is the whole of what "running"
  /// means now: the Tour is an ordinary child of the shell, so a Tour that has
  /// ended is a Tour that is not built.
  bool tourIsRunning(WidgetTester tester, ProviderContainer container) =>
      container.read(tourRunningProvider).isRunning &&
      find.byType(TodayTour).evaluate().isNotEmpty;

  /// Where the dots sit on the card in front of us. They are the one thing in
  /// the controls row kept from assistive technology, the counter above the
  /// title saying the same in words.
  Rect dotsRect(WidgetTester tester) => tester.getRect(
    find.descendant(
      of: find.byType(TourCardControls),
      matching: find.byType(ExcludeSemantics),
    ),
  );

  testWidgets('a card on the way carries Skip and Next', (tester) async {
    await bootIntoTheTour(tester);

    expect(find.text(TourCopy.stopSkip), findsOneWidget);
    expect(find.text(TourCopy.stopNext), findsOneWidget);
    // Not yet: Done belongs to the stop the Tour ends on.
    expect(find.text(TourCopy.stopDone), findsNothing);
  });

  testWidgets('the last card drops Skip, leaving Done the only way out', (
    tester,
  ) async {
    await bootIntoTheTour(tester);
    await walkToTheLastStop(tester);

    expect(find.text(TourCopy.stopSkip), findsNothing);
    expect(find.text(TourCopy.stopDone), findsOneWidget);
  });

  testWidgets('the dots keep their place when Skip goes', (tester) async {
    await bootIntoTheTour(tester);
    final withSkip = dotsRect(tester);

    await walkToTheLastStop(tester);

    // Three slots, the dots in the middle one: losing Skip must not slide the
    // row of dots to where the eye was not expecting them.
    expect(dotsRect(tester).center.dx, closeTo(withSkip.center.dx, 0.5));
  });

  testWidgets('Skip is the design pill, not a bare word', (tester) async {
    await bootIntoTheTour(tester);
    // The app boots Dark Roast, which is the settings row's own default.
    const mood = MoodColors.darkRoast;

    final skip = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, TourCopy.stopSkip),
    );
    final style = skip.style!;
    const pressed = <WidgetState>{};

    expect(style.backgroundColor!.resolve(pressed), mood.surface2);
    expect(style.side!.resolve(pressed)!.color, mood.rule);
    expect(style.shape!.resolve(pressed), isA<StadiumBorder>());
    expect(
      tester.widget<Text>(find.text(TourCopy.stopSkip)).style!.color,
      mood.ink,
    );
  });

  testWidgets('Skip closes the Tour on the first card', (tester) async {
    final container = await bootIntoTheTour(tester);

    await tester.tap(find.text(TourCopy.stopSkip));
    await letTheTourRun(tester);

    expect(tourIsRunning(tester, container), isFalse);
    expect(find.text(TourCopy.todayTitle), findsNothing);
  });

  testWidgets('Next walks the stops and the last one says Done', (
    tester,
  ) async {
    await bootIntoTheTour(tester);

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
    final container = await bootIntoTheTour(tester);

    await walkToTheLastStop(tester);
    await tester.tap(find.text(TourCopy.stopDone));
    await letTheTourRun(tester);

    expect(tourIsRunning(tester, container), isFalse);
    expect(find.text(TourCopy.tabsTitle), findsNothing);
  });

  testWidgets('switching tabs mid-Tour ends it', (tester) async {
    final container = await bootIntoTheTour(tester);
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
