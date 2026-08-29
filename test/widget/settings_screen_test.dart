import 'package:brew_path/app/app.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/widgets/settings_nav_row.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/profile/domain/daily_reminder.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_copy.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_sub_screen.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/shared/repositories/card_repository.dart';
import 'package:brew_path/shared/repositories/progress_repository.dart';
import 'package:brew_path/shared/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/find_mark.dart';
import '../support/widget_harness.dart';

void main() {
  setUp(useInMemoryDatabase);

  Future<void> openSettings(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpWithProviders(tester, const BrewPathApp());
    await tester.tap(findMark(AppIcon.leaf, active: false));
    await settleLoaders(tester);
    await tester.tap(findMark(AppIcon.gear));
    await settleLoaders(tester);
  }

  testWidgets("carries the design's four sections, in its order", (
    tester,
  ) async {
    // The order is the design's (`prototype/screens.jsx:526-562`): Appearance
    // leads, the preference toggles are filed under Practice beside the
    // reminder they belong with, and Account and Support are pure navigation.
    await openSettings(tester);

    final sections = tester
        .widgetList<SmallcapsLabel>(find.byType(SmallcapsLabel))
        .map((label) => label.text)
        .toList();

    expect(sections, [
      SettingsCopy.appearanceSection,
      SettingsCopy.practiceSection,
      SettingsCopy.accountSection,
      SettingsCopy.supportSection,
    ]);
  });

  testWidgets('closes on the centred version line, not an About row', (
    tester,
  ) async {
    await openSettings(tester);

    expect(find.byType(SettingsVersionLine), findsOneWidget);
    // The design's line is a version, not a build: `BrewPath · v0.1 · …`
    // (`prototype/screens.jsx:559`). The build number belongs on About, with
    // the rest of the fine print.
    expect(find.textContaining('V1.0.0'), findsOneWidget);
    expect(find.textContaining('+1'), findsNothing);
  });

  testWidgets('draws no leading icon on any settings row', (tester) async {
    // `NavRow` has no icon slot at all (`prototype/settings.jsx:149`); the
    // rows had grown six stock Material glyphs the design never drew.
    await openSettings(tester);

    for (final row in tester.widgetList<SettingsNavRow>(
      find.byType(SettingsNavRow),
    )) {
      expect(
        find.descendant(
          of: find.byWidget(row),
          matching: find.byType(Icon),
        ),
        findsNothing,
        reason: '${row.label} drew a glyph the design does not have',
      );
    }
  });

  testWidgets('haptics toggle flips and persists via SettingsController', (
    tester,
  ) async {
    await openSettings(tester);

    Finder hapticsRow() => find.ancestor(
      of: find.text(SettingsCopy.hapticsRow),
      matching: find.byType(SettingsNavRow),
    );

    expect(tester.widget<SettingsNavRow>(hapticsRow()).toggleValue, isTrue);

    await tester.tap(find.text(SettingsCopy.hapticsRow));
    await settleLoaders(tester);

    expect(tester.widget<SettingsNavRow>(hapticsRow()).toggleValue, isFalse);
  });

  testWidgets('the reminder row reads Off until it is asked for', (
    tester,
  ) async {
    // A time is only a setting while the switch above it is on: a row showing
    // 8:00 AM with notifications off promises something that never arrives.
    await openSettings(tester);

    Finder reminderRow() => find.ancestor(
      of: find.text(SettingsCopy.reminderRow),
      matching: find.byType(SettingsNavRow),
    );

    expect(tester.widget<SettingsNavRow>(reminderRow()).value, 'Off');
    expect(tester.widget<SettingsNavRow>(reminderRow()).isDimmed, isTrue);

    await tester.tap(find.text(SettingsCopy.notificationsRow));
    await settleLoaders(tester);

    expect(
      tester.widget<SettingsNavRow>(reminderRow()).value,
      DailyReminder.defaultTime,
    );
    expect(tester.widget<SettingsNavRow>(reminderRow()).isDimmed, isFalse);
  });

  testWidgets('picking a time stores it and turns the reminder on', (
    tester,
  ) async {
    await openSettings(tester);

    await tester.tap(find.text(SettingsCopy.reminderRow));
    await tester.pumpAndSettle();

    expect(find.text(DailyReminder.sheetTitle), findsOneWidget);

    await tester.tap(find.text('6:30 AM'));
    await tester.pump();
    await tester.tap(find.text(DailyReminder.sheetAction));
    await settleLoaders(tester);

    final stored = await SettingsRepository().getSettings();
    expect(stored.dailyReminderTime, '6:30 AM');
    expect(stored.notificationsEnabled, isTrue);
  });

  testWidgets('Reset Progress is gated behind a confirmation dialog', (
    tester,
  ) async {
    // Seed progress so we can prove the dialog Cancel path is a true no-op.
    await ProgressRepository().saveCompletion(
      lessonId: 'lesson_a',
      xpEarned: 30,
      mastery: const MasteryResult(correct: 4, total: 5),
    );
    await CardRepository().collectCard('card_a');

    await openSettings(tester);

    await tester.tap(find.text(SettingsCopy.resetProgressRow));
    await tester.pumpAndSettle();
    expect(find.text('Reset all progress?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Reset all progress?'), findsNothing);
    expect((await ProgressRepository().getAllCompleted()).length, 1);
    expect((await CardRepository().getAllCollectedCardIds()).length, 1);
    // The payout survives on the record the total is summed off.
    expect((await ProgressRepository().getAllCompleted()).single.xpEarned, 30);
  });

  testWidgets('confirming Reset wipes all progress', (tester) async {
    await ProgressRepository().saveCompletion(
      lessonId: 'lesson_a',
      xpEarned: 30,
      mastery: const MasteryResult(correct: 4, total: 5),
    );
    await CardRepository().collectCard('card_a');
    final settings = await SettingsRepository().getSettings();
    settings.hapticsEnabled = false;
    await SettingsRepository().saveSettings(settings);

    await openSettings(tester);

    await tester.tap(find.text(SettingsCopy.resetProgressRow));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Reset'));
    await settleLoaders(tester);

    expect(await ProgressRepository().getAllCompleted(), isEmpty);
    expect(await CardRepository().getAllCollectedCardIds(), isEmpty);
    final after = await SettingsRepository().getSettings();
    // Preferences are preserved.
    expect(after.hapticsEnabled, isFalse);

    expect(find.text('Progress reset.'), findsOneWidget);

    // Drain the 2-second auto-dismiss Timer the banner schedules.
    await tester.pump(const Duration(seconds: 3));
  });
}
