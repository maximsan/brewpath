import 'package:brew_path/app/app.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/widgets/confirm_sheet.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/core/widgets/settings_nav_row.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/profile/domain/learner_name.dart';
import 'package:brew_path/features/profile/domain/reset_summary.dart';
import 'package:brew_path/features/profile/domain/settings_providers.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_confirmations.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_copy.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_sub_screen.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/features/progress/domain/progress_write.dart';
import 'package:brew_path/shared/repositories/settings_repository.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/find_mark.dart';
import '../support/progress_seed.dart';
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
    // The order is the design's: Appearance
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
    // The design's line is a version, not a build: `BrewPath · v0.1 · …`.
    // The build number belongs on About, with
    // the rest of the fine print.
    expect(find.textContaining('V1.0.0'), findsOneWidget);
    expect(find.textContaining('+1'), findsNothing);
  });

  testWidgets('draws no leading icon on any settings row', (tester) async {
    // `NavRow` has no icon slot at all; the
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

  testWidgets('the sound and haptics toggles flip and are written down', (
    tester,
  ) async {
    // The only place either one lives now: #429 deleted Profile's Customize
    // grid, which drew a second pair of controls over this same record.
    await openSettings(tester);

    Finder row(String label) => find.ancestor(
      of: find.text(label),
      matching: find.byType(SettingsNavRow),
    );

    for (final label in [SettingsCopy.soundRow, SettingsCopy.hapticsRow]) {
      expect(
        tester.widget<SettingsNavRow>(row(label)).toggleValue,
        isTrue,
        reason: '$label starts on',
      );

      await tester.tap(find.text(label));
      await settleLoaders(tester);

      expect(
        tester.widget<SettingsNavRow>(row(label)).toggleValue,
        isFalse,
        reason: '$label did not follow its own tap',
      );
    }

    final stored = await SettingsRepository().getSettings();
    expect(stored.soundEnabled, isFalse);
    expect(stored.hapticsEnabled, isFalse);
  });

  testWidgets('the reminder rows are not on Settings until reminders exist', (
    tester,
  ) async {
    // #443: a switch that stores a preference nothing reads is the inert row
    // the repo forbids, so both rows are hidden until a reminder can arrive.
    await openSettings(tester);

    expect(find.text(SettingsCopy.notificationsRow), findsNothing);
    expect(find.text(SettingsCopy.reminderRow), findsNothing);
  });

  testWidgets('the Name row sets, changes and clears what Profile greets by', (
    tester,
  ) async {
    // ADR-0010 keeps the optional onboarding name step on condition that the
    // answer can be changed afterwards. This row is that condition.
    final container = await pumpWithProviders(tester, const BrewPathApp());
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Finder nameRow() => find.ancestor(
      of: find.text(SettingsCopy.nameRow),
      matching: find.byType(SettingsNavRow),
    );
    Future<void> toProfile() async {
      await tester.tap(findMark(AppIcon.leaf, active: false));
      await settleLoaders(tester);
    }

    Future<void> toSettings() async {
      await tester.tap(findMark(AppIcon.gear));
      await settleLoaders(tester);
    }

    Future<void> saveName(String name) async {
      await tester.tap(find.text(SettingsCopy.nameRow));
      await tester.pumpAndSettle();
      expect(find.text(LearnerName.sheetTitle), findsWidgets);
      await tester.enterText(find.byType(TextField), name);
      await tester.pump();
      await tester.tap(find.text(LearnerName.sheetAction));
      await settleLoaders(tester);
    }

    await toProfile();
    expect(find.text('Hello there.'), findsOneWidget);
    await toSettings();
    expect(tester.widget<SettingsNavRow>(nameRow()).value, LearnerName.notSet);

    // Set.
    await saveName('Maya');
    expect(tester.widget<SettingsNavRow>(nameRow()).value, 'Maya');
    expect((await SettingsRepository().getSettings()).learnerName, 'Maya');
    await tester.tap(findMark(AppIcon.back));
    await settleLoaders(tester);
    expect(find.text('Hello, Maya.'), findsOneWidget);

    // Change: the sheet opens holding the stored name.
    await toSettings();
    await tester.tap(find.text(SettingsCopy.nameRow));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'Maya'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Mia');
    await tester.pump();
    await tester.tap(find.text(LearnerName.sheetAction));
    await settleLoaders(tester);
    expect(tester.widget<SettingsNavRow>(nameRow()).value, 'Mia');
    await tester.tap(findMark(AppIcon.back));
    await settleLoaders(tester);
    expect(find.text('Hello, Mia.'), findsOneWidget);

    // Clear. The sheet keeps the design's rule — Save is dead while the field
    // is blank — so a blank sheet changes nothing; the clear goes through the
    // same seam the row writes, and the greeting falls back to its plain form.
    await toSettings();
    await tester.tap(find.text(SettingsCopy.nameRow));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '   ');
    await tester.pump();
    expect(
      tester
          .widget<PrimaryButton>(
            find.ancestor(
              of: find.text(LearnerName.sheetAction),
              matching: find.byType(PrimaryButton),
            ),
          )
          .onPressed,
      isNull,
      reason: 'a blank sheet is not a request to be greeted by nobody',
    );
    await tester.tap(find.text(LearnerName.sheetAction), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect((await SettingsRepository().getSettings()).learnerName, 'Mia');
    await tester.tapAt(const Offset(200, 20));
    await tester.pumpAndSettle();

    await container
        .read(settingsControllerProvider.notifier)
        .setLearnerName('');
    await settleLoaders(tester);
    expect(tester.widget<SettingsNavRow>(nameRow()).value, LearnerName.notSet);
    expect((await SettingsRepository().getSettings()).learnerName, isNull);
    await tester.tap(findMark(AppIcon.back));
    await settleLoaders(tester);
    expect(find.text('Hello there.'), findsOneWidget);
  });

  testWidgets('the destructive block draws Delete account, inert', (
    tester,
  ) async {
    // Ruled on #395: the design lists the row, and there is no account to
    // delete — Firebase is gated off. It is drawn so the block is the design's
    // shape, and it must not act, because acting would mean promising
    // something the app cannot do.
    await openSettings(tester);

    final row = tester.widget<SettingsNavRow>(
      find.ancestor(
        of: find.text(SettingsCopy.deleteAccountRow),
        matching: find.byType(SettingsNavRow),
      ),
    );

    expect(row.isDimmed, isTrue);
    expect(row.onTap, isNull);
    expect(
      tester.getSemantics(find.text(SettingsCopy.deleteAccountRow)),
      isNot(isSemantics(isButton: true)),
      reason: 'a row that cannot act must not be announced as a button',
    );

    await tester.tap(find.text(SettingsCopy.deleteAccountRow));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Reset Progress is gated behind a confirm sheet', (tester) async {
    // Seed progress so we can prove the Keep path is a true no-op.
    final snapshots = SnapshotRepository();
    await seedCompletedLesson(
      snapshots,
      'lesson_a',
      mastery: const MasteryResult(correct: 4, total: 5),
    );
    await seedCollectible(snapshots, 'card_a');

    await openSettings(tester);

    await tester.tap(find.text(SettingsCopy.resetProgressRow));
    await settleLoaders(tester);
    expect(find.text(ResetCopy.title), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);

    await tester.tap(find.text(ConfirmSheetCopy.keepMyProgress));
    await tester.pumpAndSettle();
    expect(find.text(ResetCopy.title), findsNothing);
    final kept = (await snapshots.read()).clearedByReset;
    expect(kept.completedLessons.keys, ['lesson_a']);
    expect(kept.ownedCollectibles, {'card_a'});
    // The result it was scored on survives with it.
    expect(
      kept.bestResults['lesson_a'],
      const MasteryResult(correct: 4, total: 5),
    );
  });

  testWidgets("the sheet itemises this learner's own figures", (tester) async {
    // The seven measures are the point of the sheet: seeing *1 day* is what
    // makes someone stop, where a list of storage fields would not.
    final snapshots = SnapshotRepository();
    await seedCompletedLesson(snapshots, 'm1l1');
    await seedCollectible(snapshots, 'c1');

    await openSettings(tester);
    await tester.tap(find.text(SettingsCopy.resetProgressRow));
    await settleLoaders(tester);

    expect(find.text(ResetCopy.body), findsOneWidget);
    expect(find.text(ResetCopy.closingLine), findsOneWidget);
    for (final label in [
      ResetSummaryCopy.streak,
      ResetSummaryCopy.points,
      ResetSummaryCopy.lessons,
      ResetSummaryCopy.cards,
      ResetSummaryCopy.challenges,
      ResetSummaryCopy.saved,
      ResetSummaryCopy.tree,
    ]) {
      expect(find.text(label), findsOneWidget, reason: '$label is missing');
    }
    expect(find.text('1 day'), findsOneWidget);
    expect(find.text('Lessons completed'), findsOneWidget);
    expect(find.text('Back to Seed'), findsOneWidget);

    await tester.tap(find.text(ConfirmSheetCopy.keepMyProgress));
    await tester.pumpAndSettle();
  });

  testWidgets('confirming Reset wipes all progress', (tester) async {
    final snapshots = SnapshotRepository();
    await seedCompletedLesson(
      snapshots,
      'lesson_a',
      mastery: const MasteryResult(correct: 4, total: 5),
    );
    await seedCollectible(snapshots, 'card_a');
    final settings = await SettingsRepository().getSettings();
    settings
      ..hapticsEnabled = false
      ..learnerName = 'Maya';
    await SettingsRepository().saveSettings(settings);

    await openSettings(tester);

    await tester.tap(find.text(SettingsCopy.resetProgressRow));
    await settleLoaders(tester);
    await tester.tap(find.text(ResetCopy.confirm));
    await settleLoaders(tester);

    final wiped = (await snapshots.read()).clearedByReset;
    expect(wiped.completedLessons, isEmpty);
    expect(wiped.ownedCollectibles, isEmpty);
    final after = await SettingsRepository().getSettings();
    // Preferences are preserved, and so is the name: it is account data, not
    // progress.
    expect(after.hapticsEnabled, isFalse);
    expect(after.learnerName, 'Maya');

    expect(find.text(ResetCopy.banner), findsOneWidget);

    // Drain the 2-second auto-dismiss Timer the banner schedules.
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('figures that will not resolve still raise the sheet', (
    tester,
  ) async {
    // A destructive row that did nothing would be worse than one whose list is
    // missing: the paragraph names the loss on its own.
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpWithProviders(
      tester,
      const BrewPathApp(),
      container: ProviderContainer(
        overrides: [
          resetSummaryProvider.overrideWith(
            (ref) => Future<List<ResetMeasure>>.error(StateError('no banks')),
          ),
        ],
      ),
    );
    await tester.tap(findMark(AppIcon.leaf, active: false));
    await settleLoaders(tester);
    await tester.tap(findMark(AppIcon.gear));
    await settleLoaders(tester);

    await tester.tap(find.text(SettingsCopy.resetProgressRow));
    await settleLoaders(tester);

    expect(find.text(ResetCopy.title), findsOneWidget);
    expect(find.text(ResetCopy.confirm), findsOneWidget);
    expect(find.text(ResetSummaryCopy.streak), findsNothing);
    expect(find.text(ResetCopy.closingLine), findsNothing);

    await tester.tap(find.text(ConfirmSheetCopy.keepMyProgress));
    await tester.pumpAndSettle();
  });

  testWidgets('a reset takes the tree and the challenge count with it', (
    tester,
  ) async {
    // Two of the seven the sheet promises by name, and the two that went
    // stalest before ADR-0031: this asks Profile, not the snapshot, so it
    // fails whether the cause is a missing refresh or a stream that skipped
    // them.
    final snapshots = SnapshotRepository();
    await updateProgress(
      snapshots,
      (progress) => progress
          .withTreeStageAtLeast(5)
          .withChallengeLogged('bc-m1', reaction: 'Preferred 1:15', day: 0),
      now: DateTime.now(),
    );

    await openSettings(tester);
    await tester.tap(find.text(SettingsCopy.resetProgressRow));
    await settleLoaders(tester);
    await tester.tap(find.text(ResetCopy.confirm));
    await settleLoaders(tester);
    await tester.tap(findMark(AppIcon.back));
    await settleLoaders(tester);

    expect(find.textContaining('Stage 1 · Seed'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(r'Coffee Challenges, 0 of \d+ brewed')),
      findsOneWidget,
    );

    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('Restart onboarding asks on the same sheet, plain', (
    tester,
  ) async {
    // Two adjacent rows must not mix a sheet and a dialog. Nothing is thrown
    // away here, so the sheet carries no lines and no berry.
    await openSettings(tester);

    await tester.tap(find.text(SettingsCopy.restartOnboardingRow));
    await tester.pumpAndSettle();

    expect(find.text(RestartOnboardingCopy.title), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text(ResetSummaryCopy.streak), findsNothing);
    expect(
      tester
          .widget<FilledButton>(
            find.ancestor(
              of: find.text(RestartOnboardingCopy.confirm),
              matching: find.byType(FilledButton),
            ),
          )
          .style!
          .backgroundColor!
          .resolve({}),
      isNot(MoodColors.darkRoast.berry),
    );

    await tester.tap(find.text(RestartOnboardingCopy.cancel));
    await tester.pumpAndSettle();
    expect(find.text(RestartOnboardingCopy.title), findsNothing);
  });

  testWidgets('confirming Restart onboarding returns to Welcome', (
    tester,
  ) async {
    await openSettings(tester);

    await tester.tap(find.text(SettingsCopy.restartOnboardingRow));
    await tester.pumpAndSettle();
    await tester.tap(find.text(RestartOnboardingCopy.confirm));
    await settleLoaders(tester);

    expect(
      (await SettingsRepository().getSettings()).onboardingCompleted,
      isFalse,
    );
    expect(find.text(SettingsCopy.title), findsNothing);
  });
}
