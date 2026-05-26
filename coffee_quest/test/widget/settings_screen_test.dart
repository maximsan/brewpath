import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coffee_quest/app/app.dart';
import 'package:coffee_quest/shared/repositories/card_repository.dart';
import 'package:coffee_quest/shared/repositories/progress_repository.dart';
import 'package:coffee_quest/shared/repositories/settings_repository.dart';

import '../support/widget_harness.dart';

void main() {
  setUp(useInMemoryDatabase);

  Future<void> openSettings(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpWithProviders(tester, const CoffeeQuestApp());
    await tester.tap(find.byIcon(Icons.person_outline));
    await settleLoaders(tester);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await settleLoaders(tester);
  }

  testWidgets('shows preferences, danger zone, and the app version', (
    tester,
  ) async {
    await openSettings(tester);

    expect(find.text('Settings'), findsOneWidget);
    expect(find.widgetWithText(SwitchListTile, 'Haptics'), findsOneWidget);
    expect(find.widgetWithText(SwitchListTile, 'Sound'), findsOneWidget);
    expect(find.text('Reset Progress'), findsOneWidget);
    expect(find.text('1.0.0+1'), findsOneWidget);
  });

  testWidgets('haptics toggle flips and persists via SettingsController', (
    tester,
  ) async {
    await openSettings(tester);

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
    await ProgressRepository().saveCompletion(
      lessonId: 'lesson_a',
      xpEarned: 30,
      score: 80,
    );
    await CardRepository().collectCard('card_a');
    final settings = await SettingsRepository().getSettings();
    settings.totalXp = 30;
    await SettingsRepository().saveSettings(settings);

    await openSettings(tester);

    await tester.tap(find.text('Reset Progress'));
    await tester.pumpAndSettle();
    expect(find.text('Reset all progress?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Reset all progress?'), findsNothing);
    expect((await ProgressRepository().getAllCompleted()).length, 1);
    expect((await CardRepository().getAllCollectedCardIds()).length, 1);
    expect((await SettingsRepository().getSettings()).totalXp, 30);
  });

  testWidgets('confirming Reset wipes all progress', (tester) async {
    await ProgressRepository().saveCompletion(
      lessonId: 'lesson_a',
      xpEarned: 30,
      score: 80,
    );
    await CardRepository().collectCard('card_a');
    final settings = await SettingsRepository().getSettings();
    settings
      ..totalXp = 30
      ..streakDays = 3
      ..hapticsEnabled = false;
    await SettingsRepository().saveSettings(settings);

    await openSettings(tester);

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

    // Drain the 2-second auto-dismiss Timer the banner schedules.
    await tester.pump(const Duration(seconds: 3));
  });
}
