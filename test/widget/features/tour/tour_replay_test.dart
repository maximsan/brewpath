import 'package:brew_path/app/app.dart';
import 'package:brew_path/app/app_header.dart';
import 'package:brew_path/features/tour/domain/tour_copy.dart';
import 'package:brew_path/features/tour/presentation/replay_tour_row.dart';
import 'package:brew_path/shared/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/widget_harness.dart';

/// Replay from Profile: the stops, without the offer.
///
/// The whole point of this ticket is what replay *does not* do — no intro
/// overlay, and no write — so most of these assertions are negative ones.
void main() {
  setUp(useInMemoryDatabase);

  /// Tall enough for the whole of *Profile*, not just Learn: the replay row is
  /// the last thing on that page, under the tree, the stats and the Customize
  /// grid, and a tap cannot land on a widget below the viewport.
  void useTallViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(400, 3600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  /// Drives the running Tour without `pumpAndSettle`, which never returns
  /// while a spotlight's moving animation is repeating on screen.
  Future<void> letTheTourRun(WidgetTester tester) async {
    for (var frame = 0; frame < 20; frame++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> openProfile(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.person_outline));
    await settleLoaders(tester);
    await tester.pumpAndSettle();
  }

  testWidgets('Profile offers a replay row under Customize', (tester) async {
    useTallViewport(tester);

    await pumpWithProviders(tester, const BrewPathApp());
    await openProfile(tester);

    expect(find.text(TourCopy.replayTitle), findsOneWidget);
    expect(find.text(TourCopy.replayBody), findsOneWidget);
  });

  testWidgets('replay runs the stops with no intro overlay', (tester) async {
    useTallViewport(tester);

    await pumpWithProviders(tester, const BrewPathApp());
    await openProfile(tester);

    await tester.tap(find.byType(ReplayTourRow));
    await letTheTourRun(tester);

    // Straight to stop 1 — the question the overlay asks was answered the
    // first time, and asking it again is what this entry point exists to skip.
    expect(find.text(TourCopy.introTitle), findsNothing);
    expect(find.text(TourCopy.todayTitle), findsOneWidget);
    expect(find.text(TourCopy.todayBody), findsOneWidget);
  });

  testWidgets('replay lands the learner on the Learn tab', (tester) async {
    useTallViewport(tester);

    await pumpWithProviders(tester, const BrewPathApp());
    await openProfile(tester);

    await tester.tap(find.byType(ReplayTourRow));
    await letTheTourRun(tester);

    // The stops are anchored on Learn, so the row has to switch tabs as well
    // as start the Tour — a replay that ran while Profile was on screen would
    // spotlight nothing. Learn is named by the shared header's title, which is
    // where the tab's identity lives now that the shell owns the chrome.
    expect(find.widgetWithText(AppHeader, 'TODAY'), findsOneWidget);
  });

  testWidgets('replay writes nothing', (tester) async {
    useTallViewport(tester);

    // Arrive at Profile with the flag deliberately unset, which a real device
    // never is by this point — precisely so a stray write would be visible.
    final repo = SettingsRepository();
    final armed = await repo.getSettings()
      ..tourSeen = false;
    await repo.saveSettings(armed);

    await pumpWithProviders(tester, const BrewPathApp());
    // Dismiss the auto-run offer the cleared flag earns, so what follows is
    // the replay path and not the offer path.
    await tester.pumpAndSettle();
    await tester.tap(find.text(TourCopy.introDecline));
    await tester.pumpAndSettle();

    final before = await repo.getSettings();
    await repo.saveSettings(before..tourSeen = false);

    await openProfile(tester);
    await tester.tap(find.byType(ReplayTourRow));
    await letTheTourRun(tester);

    expect(
      (await repo.getSettings()).tourSeen,
      isFalse,
      reason: 'replay must not touch the flag the intro overlay owns',
    );
  });
}
