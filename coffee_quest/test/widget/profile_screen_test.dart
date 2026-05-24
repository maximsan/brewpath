import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coffee_quest/app/app.dart';
import 'package:coffee_quest/shared/repositories/card_repository.dart';
import 'package:coffee_quest/shared/repositories/progress_repository.dart';
import 'package:coffee_quest/shared/repositories/settings_repository.dart';

import '../support/widget_harness.dart';

void main() {
  setUp(useInMemoryDatabase);

  Future<void> openProfile(WidgetTester tester) async {
    // Tall surface so the Profile ListView lays out the About section (and
    // its Version row) inside the viewport — otherwise virtualization keeps
    // it out of the widget tree and finders return 0.
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpWithProviders(tester, const CoffeeQuestApp());
    await tester.tap(find.byIcon(Icons.person_outline));
    await settleLoaders(tester);
  }

  testWidgets('shows zeroed stats and the app version for a fresh user', (
    tester,
  ) async {
    await openProfile(tester);

    expect(find.text('Total XP'), findsOneWidget);
    expect(find.text('Streak'), findsOneWidget);
    expect(find.text('0 days'), findsOneWidget);
    expect(find.text('1.0.0+1'), findsOneWidget); // mocked package_info
  });

  testWidgets('haptics toggle flips and persists via SettingsController', (
    tester,
  ) async {
    await openProfile(tester);

    final hapticsSwitch = find.widgetWithText(SwitchListTile, 'Haptics');
    expect(tester.widget<SwitchListTile>(hapticsSwitch).value, isTrue);

    await tester.tap(hapticsSwitch);
    await settleLoaders(tester);

    expect(tester.widget<SwitchListTile>(hapticsSwitch).value, isFalse);
  });

  testWidgets('Reset Progress is gated behind a confirmation dialog', (
    tester,
  ) async {
    // Seed some progress so we can prove the dialog Cancel path is a true no-op.
    await ProgressRepository()
        .saveCompletion(lessonId: 'lesson_a', xpEarned: 30, score: 80);
    await CardRepository().collectCard('card_a');
    final settings = await SettingsRepository().getSettings();
    settings.totalXp = 30;
    await SettingsRepository().saveSettings(settings);

    await openProfile(tester);

    // First tap must only open the dialog — no wipe yet.
    await tester.tap(find.text('Reset Progress'));
    await tester.pumpAndSettle();
    expect(find.text('Reset all progress?'), findsOneWidget);

    // Cancel keeps everything.
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Reset all progress?'), findsNothing);
    expect((await ProgressRepository().getAllCompleted()).length, 1);
    expect((await CardRepository().getAllCollectedCardIds()).length, 1);
    expect((await SettingsRepository().getSettings()).totalXp, 30);
  });

  testWidgets('confirming Reset wipes all progress', (tester) async {
    await ProgressRepository()
        .saveCompletion(lessonId: 'lesson_a', xpEarned: 30, score: 80);
    await CardRepository().collectCard('card_a');
    final settings = await SettingsRepository().getSettings();
    settings
      ..totalXp = 30
      ..streakDays = 3
      ..hapticsEnabled = false;
    await SettingsRepository().saveSettings(settings);

    await openProfile(tester);

    await tester.tap(find.text('Reset Progress'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Reset'));
    await settleLoaders(tester);

    expect(await ProgressRepository().getAllCompleted(), isEmpty);
    expect(await CardRepository().getAllCollectedCardIds(), isEmpty);
    final after = await SettingsRepository().getSettings();
    expect(after.totalXp, 0);
    expect(after.streakDays, 0);
    // Preferences are preserved.
    expect(after.hapticsEnabled, isFalse);

    expect(find.text('Progress reset.'), findsOneWidget);

    // Drain the 2-second auto-dismiss Timer the banner schedules, otherwise
    // the test framework reports a pending Timer at tear-down.
    await tester.pump(const Duration(seconds: 3));
  });
}
