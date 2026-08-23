import 'package:brew_path/app/app.dart';
import 'package:brew_path/features/tour/domain/tour_copy.dart';
import 'package:brew_path/features/tour/presentation/tour_stops.dart';
import 'package:brew_path/shared/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../support/widget_harness.dart';

/// The Tour's auto-run gate, its two answers, and the write both of them make.
///
/// Driven through the whole app rather than through `LearnScreen` alone,
/// because the gate is a *fact about the shell*: the flag lives in the
/// database, the offer is made when the Learn tab shows real data, and the
/// fourth stop is anchored on the tab bar. A test that pumped Learn on its own
/// would prove none of that.
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
  /// The spotlight's moving animation repeats for as long as a stop is on
  /// screen, so `pumpAndSettle` never returns — the same reason the shared
  /// harness hand-rolls its settle around Roasty's idle loop. `runAsync` is
  /// what lets the real Drift write behind `markTourSeen` actually complete
  /// between frames.
  Future<void> letTheTourRun(WidgetTester tester) async {
    for (var frame = 0; frame < 20; frame++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  testWidgets('offers the Tour when Learn shows with the flag unset', (
    tester,
  ) async {
    useTallViewport(tester);
    await armTheTour();

    await pumpWithProviders(tester, const BrewPathApp());
    await tester.pumpAndSettle();

    expect(find.text(TourCopy.introTitle), findsOneWidget);
    expect(find.text(TourCopy.introBody), findsOneWidget);
    expect(find.text(TourCopy.introAccept), findsOneWidget);
    expect(find.text(TourCopy.introDecline), findsOneWidget);
  });

  testWidgets('does not offer the Tour once the flag is set', (tester) async {
    // The harness seeds `tourSeen`, which is the already-toured device.
    useTallViewport(tester);

    await pumpWithProviders(tester, const BrewPathApp());
    await tester.pumpAndSettle();

    expect(find.text(TourCopy.introTitle), findsNothing);
  });

  testWidgets('Skip answers the offer and writes the flag', (tester) async {
    useTallViewport(tester);
    await armTheTour();

    await pumpWithProviders(tester, const BrewPathApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text(TourCopy.introDecline));
    await tester.pumpAndSettle();

    // Declining is an answer, not an absence of one: the write is what stops
    // the app asking again on the next open.
    expect(await tourSeenOnDisk(), isTrue);
    expect(find.text(TourCopy.introTitle), findsNothing);
    // And it skips: no stop is on screen.
    expect(find.text(TourCopy.todayTitle), findsNothing);
  });

  testWidgets('Show me answers the offer, writes the flag and runs the stops', (
    tester,
  ) async {
    useTallViewport(tester);
    await armTheTour();

    await pumpWithProviders(tester, const BrewPathApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text(TourCopy.introAccept));
    await letTheTourRun(tester);

    expect(await tourSeenOnDisk(), isTrue);
    // The first stop's locked copy, which only the running Tour renders.
    expect(find.text(TourCopy.todayTitle), findsOneWidget);
    expect(find.text(TourCopy.todayBody), findsOneWidget);
  });

  testWidgets('the offer is made once per launch, not once per rebuild', (
    tester,
  ) async {
    useTallViewport(tester);
    await armTheTour();

    await pumpWithProviders(tester, const BrewPathApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text(TourCopy.introDecline));
    await tester.pumpAndSettle();

    // Learn rebuilds constantly as its providers resolve. The flag is written
    // asynchronously, so for a moment after the tap it still reads false —
    // a rebuild in that window must not put the overlay back up.
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text(TourCopy.introTitle), findsNothing);
  });

  testWidgets('reduced motion strips the Tour of its animations', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    useTallViewport(tester);

    await pumpWithProviders(tester, const BrewPathApp());
    await tester.pumpAndSettle();

    // Asserted on the engine rather than on pixels: these three fields are the
    // whole of what reduced motion changes, and a screenshot could not tell a
    // disabled animation from one caught between frames. The scroll becomes a
    // cut rather than a slide — it cannot be dropped, because an off-screen
    // stop still has to be reached.
    final engine = ShowcaseView.getNamed(TourStops.scope);
    expect(engine.disableMovingAnimation, isTrue);
    expect(engine.disableScaleAnimation, isTrue);
    expect(engine.scrollDuration, Duration.zero);
  });

  testWidgets('the Tour animates normally without reduced motion', (
    tester,
  ) async {
    useTallViewport(tester);

    await pumpWithProviders(tester, const BrewPathApp());
    await tester.pumpAndSettle();

    final engine = ShowcaseView.getNamed(TourStops.scope);
    expect(engine.disableMovingAnimation, isFalse);
    expect(engine.disableScaleAnimation, isFalse);
    expect(engine.scrollDuration, greaterThan(Duration.zero));
  });
}
