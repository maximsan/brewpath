import 'package:brew_path/app/app.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/features/learn/presentation/learn_list_view.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_copy.dart';
import 'package:brew_path/features/tour/domain/app_guide_copy.dart';
import 'package:brew_path/features/tour/domain/tour_copy.dart';
import 'package:brew_path/features/tour/presentation/replay_intro_row.dart';
import 'package:brew_path/shared/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/find_mark.dart';
import '../../../support/widget_harness.dart';

/// Replay from the App Guide: the stops, without the offer.
///
/// The whole point of this entry point is what replay *does not* do — no intro
/// overlay, and no write — so most of these assertions are negative ones. It
/// reaches the row the way a learner does, through Settings → Support → Help
/// and support → App Guide, because the path is half of what the ticket asks
/// for.
void main() {
  setUp(useInMemoryDatabase);

  /// Tall enough for the whole of *Profile* and of Settings, so a tap cannot
  /// land on a widget below the viewport.
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
    await tester.tap(findMark(AppIcon.leaf, active: false));
    await settleLoaders(tester);
    await tester.pumpAndSettle();
  }

  /// Profile → gear → Help and support → App Guide, which is the only way in.
  ///
  /// One push deeper than it used to be: the design files the guide inside the
  /// Help screen, which now exists (#395).
  Future<void> openAppGuide(WidgetTester tester) async {
    await openProfile(tester);
    await tester.tap(findMark(AppIcon.gear));
    await tester.pumpAndSettle();
    await tester.tap(find.text(SettingsCopy.helpRow));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppGuideCopy.title));
    await tester.pumpAndSettle();
  }

  testWidgets('Settings files the App Guide inside Help and support', (
    tester,
  ) async {
    // It used to be a section heading on the Settings root, because the Help
    // screen did not exist. It does now, and the design puts the guide in it.
    useTallViewport(tester);

    await pumpWithProviders(tester, const BrewPathApp());
    await openProfile(tester);
    await tester.tap(findMark(AppIcon.gear));
    await tester.pumpAndSettle();

    expect(find.text(SettingsCopy.helpRow), findsOneWidget);
    expect(find.text(AppGuideCopy.title), findsNothing);

    await tester.tap(find.text(SettingsCopy.helpRow));
    await tester.pumpAndSettle();

    expect(find.text(AppGuideCopy.title), findsWidgets);
    expect(find.text(AppGuideCopy.settingsRowBody), findsOneWidget);
  });

  testWidgets('the App Guide explains each part and offers a replay', (
    tester,
  ) async {
    useTallViewport(tester);

    await pumpWithProviders(tester, const BrewPathApp());
    await openAppGuide(tester);

    for (final section in AppGuideCopy.sections) {
      expect(
        find.text(section.body),
        findsOneWidget,
        reason: 'the guide must say what ${section.title} does',
      );
    }
    expect(find.text(TourCopy.replayTitle), findsOneWidget);
    expect(find.text(TourCopy.replayBody), findsOneWidget);
  });

  testWidgets('Profile no longer carries the replay row', (tester) async {
    useTallViewport(tester);

    await pumpWithProviders(tester, const BrewPathApp());
    await openProfile(tester);

    // It moved to the App Guide. Profile carries no preferences at all now
    // (#429), so a replay row here would be the only control on the screen.
    expect(find.byType(ReplayIntroRow), findsNothing);
  });

  testWidgets('replay runs the stops with no intro overlay', (tester) async {
    useTallViewport(tester);

    await pumpWithProviders(tester, const BrewPathApp());
    await openAppGuide(tester);

    await tester.tap(find.byType(ReplayIntroRow));
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
    await openAppGuide(tester);

    await tester.tap(find.byType(ReplayIntroRow));
    await letTheTourRun(tester);

    // The stops are anchored on Learn, so the row has to switch tabs — and
    // clear the two pushed screens it was tapped from — as well as start the
    // Tour. The tab's own list is what names it: the shared header is
    // wordless until a tab scrolls under it (#441).
    expect(find.byType(LearnListView), findsOneWidget);
  });

  testWidgets('replay writes nothing', (tester) async {
    useTallViewport(tester);

    // Arrive with the flag deliberately unset, which a real device never is by
    // this point — precisely so a stray write would be visible.
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

    await openAppGuide(tester);
    await tester.tap(find.byType(ReplayIntroRow));
    await letTheTourRun(tester);

    expect(
      (await repo.getSettings()).tourSeen,
      isFalse,
      reason: 'replay must not touch the flag the intro overlay owns',
    );
  });
}
