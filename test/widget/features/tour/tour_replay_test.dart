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
import '../../../support/tour_harness.dart';
import '../../../support/widget_harness.dart';

// The point of this entry point is what replay does *not* do — it writes
// nothing — so most of these assertions are negative ones. It reaches the row
// the way a learner does, through Settings → Support → Help and support → App
// Guide, because the path is half of what the ticket asks for.
void main() {
  setUp(useInMemoryDatabase);

  /// Tall enough for the whole of *Profile* and of Settings, so a tap cannot
  /// land on a widget below the viewport.
  const profileViewport = Size(400, 3600);

  void useTallViewport(WidgetTester tester) =>
      useTourViewport(tester, size: profileViewport);

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

  testWidgets('replay goes straight to the first stop', (tester) async {
    useTallViewport(tester);

    await pumpWithProviders(tester, const BrewPathApp());
    await openAppGuide(tester);

    await tester.tap(find.byType(ReplayIntroRow));
    await letTheTourRun(tester);

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
    // End the first run the cleared flag starts, so what follows is the
    // replay path and not the first-run path — then clear what ending wrote.
    await awaitTheFirstStop(tester);
    await tester.tap(find.text(TourCopy.stopSkip));
    await awaitTourSeenWritten(tester);

    final before = await repo.getSettings();
    await repo.saveSettings(before..tourSeen = false);

    await openAppGuide(tester);
    await tester.tap(find.byType(ReplayIntroRow));
    await letTheTourRun(tester);

    expect(
      (await repo.getSettings()).tourSeen,
      isFalse,
      reason: 'replay must not touch the flag the first run owns',
    );
  });
}
