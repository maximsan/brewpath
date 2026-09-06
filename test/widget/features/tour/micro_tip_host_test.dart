import 'dart:async';

import 'package:brew_path/app/app.dart';
import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/widgets/app_sheet.dart';
import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/features/path/presentation/path_screen.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/features/progress/domain/streak_status.dart';
import 'package:brew_path/features/tour/domain/micro_tip.dart';
import 'package:brew_path/features/tour/presentation/micro_tip_card.dart';
import 'package:brew_path/shared/models/content/brew_challenge.dart';
import 'package:brew_path/shared/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/find_mark.dart';
import '../../../support/widget_harness.dart';

/// The micro-tip layer, driven through the whole app.
///
/// Driven that way for the same reason the Tour's own tests are: the layer
/// draws above the router, reads where the learner is from it, and writes what
/// it showed to the database. A test that pumped the card on its own would
/// prove only that it renders.
void main() {
  setUp(useInMemoryDatabase);

  /// Tall enough for the whole Learn list, as the other Learn tests use.
  void useTallViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  /// Clears the list the harness seeds, so the app boots owing every tip.
  Future<void> armEveryTip() async {
    final repository = SettingsRepository();
    final settings = await repository.getSettings()
      ..tipsSeen = '';
    await repository.saveSettings(settings);
  }

  Future<Set<String>> tipsSeenOnDisk() async =>
      MicroTipsSeen.decode((await SettingsRepository().getSettings()).tipsSeen);

  /// Pumps past the layer's quiet window without `pumpAndSettle`.
  ///
  /// Two clocks have to move: the pacing runs on timers, which only a pumped
  /// duration advances, and the seen-list write is real Drift, which only
  /// `runAsync` lets finish between frames.
  Future<void> letTipsSettle(
    WidgetTester tester, {
    Duration over = const Duration(seconds: 4),
  }) async {
    const step = Duration(milliseconds: 400);
    for (var elapsed = Duration.zero; elapsed < over; elapsed += step) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(step);
    }
  }

  Future<void> openTab(WidgetTester tester, AppIcon tab) async {
    await tester.tap(findMark(tab, active: false));
    await settleLoaders(tester);
  }

  Finder tipTitled(MicroTip tip) =>
      find.widgetWithText(MicroTipCard, tip.title);

  /// The card's X. Found by its place in the card rather than by a tooltip:
  /// the layer draws above the navigator's `Overlay`, so it has none.
  Finder dismissButton() => find.descendant(
    of: find.byType(MicroTipCard),
    matching: find.byType(IconButton),
  );

  testWidgets('the Path tab explains itself, once, and records that it did', (
    tester,
  ) async {
    useTallViewport(tester);
    await armEveryTip();

    await pumpWithProviders(tester, const BrewPathApp());
    await openTab(tester, AppIcon.route);
    await letTipsSettle(tester);

    expect(tipTitled(MicroTip.path), findsOneWidget);
    expect(find.text(MicroTip.path.eyebrow), findsOneWidget);
    expect(find.text(MicroTip.path.body), findsOneWidget);
    expect(
      await tipsSeenOnDisk(),
      contains(MicroTip.path.id),
      reason: 'a tip is spent the moment it shows, not when it is dismissed',
    );
  });

  testWidgets('leaving the tab retires the tip, and it never comes back', (
    tester,
  ) async {
    useTallViewport(tester);
    await armEveryTip();

    await pumpWithProviders(tester, const BrewPathApp());
    await openTab(tester, AppIcon.route);
    await letTipsSettle(tester);
    expect(tipTitled(MicroTip.path), findsOneWidget);

    await openTab(tester, AppIcon.cup);
    await tester.pump();
    expect(
      tipTitled(MicroTip.path),
      findsNothing,
      reason: 'moving on retires a visible tip',
    );

    await openTab(tester, AppIcon.route);
    await letTipsSettle(tester);
    expect(tipTitled(MicroTip.path), findsNothing);
  });

  testWidgets('the X hides the card without spending anything else', (
    tester,
  ) async {
    useTallViewport(tester);
    await armEveryTip();

    await pumpWithProviders(tester, const BrewPathApp());
    await openTab(tester, AppIcon.route);
    await letTipsSettle(tester);

    await tester.tap(dismissButton());
    await tester.pump();

    expect(tipTitled(MicroTip.path), findsNothing);
    // The X closes a tip; it does not close the layer. Everything else the
    // learner has not met is still owed to them.
    expect(await tipsSeenOnDisk(), {MicroTip.path.id});
  });

  testWidgets('the dictionary explains itself on its own index', (
    tester,
  ) async {
    useTallViewport(tester);
    await armEveryTip();

    await pumpWithProviders(tester, const BrewPathApp());
    await tester.tap(find.byIcon(Icons.menu_book_outlined));
    await settleLoaders(tester);
    await letTipsSettle(tester);

    expect(tipTitled(MicroTip.dictionary), findsOneWidget);
  });

  testWidgets(
    "the Learn tab says one thing at a time, in the design's order",
    (tester) async {
      useTallViewport(tester);
      await armEveryTip();

      // A challenge in play and a freeze held — two beats at once, which is
      // exactly the case the order exists for. Overridden rather than
      // arranged, because what is under test is the layer, not how a snapshot
      // comes to hold seven active days.
      final container = ProviderContainer(
        overrides: [
          activeChallengeProvider.overrideWith(
            (ref) async => const BrewChallenge(
              id: 'bc-m1l1',
              scope: ChallengeScope.lesson,
              moduleId: 'm1',
              cardId: 'c-m1l1',
              title: 'Two brews, one bean',
              instruction: 'Brew the same bean two ways.',
              effort: 'Next brews · 5 min',
              prompt: 'WHICH CUP WON?',
              reactions: ['The first', 'The second'],
              lessonId: 'm1l1',
            ),
          ),
          streakStatusProvider.overrideWith(
            (ref) async => const StreakStatus(
              streak: 7,
              freezeHeld: true,
              daysToNextFreeze: null,
              freezesSpent: 0,
              frozenDays: {},
            ),
          ),
        ],
      );

      await pumpWithProviders(
        tester,
        const BrewPathApp(),
        container: container,
      );
      await letTipsSettle(tester);

      expect(tipTitled(MicroTip.brew), findsOneWidget);
      expect(tipTitled(MicroTip.freeze), findsNothing);

      await tester.tap(dismissButton());
      await tester.pump();

      // The wait after a dismissal is the design's twelve seconds, and it is
      // what keeps the second tip from reading as a continuation of the first.
      await letTipsSettle(tester, over: const Duration(seconds: 8));
      expect(tipTitled(MicroTip.freeze), findsNothing);

      await letTipsSettle(tester, over: const Duration(seconds: 8));
      expect(tipTitled(MicroTip.freeze), findsOneWidget);
    },
  );

  testWidgets('nothing is said, or spent, under a sheet', (tester) async {
    useTallViewport(tester);
    await armEveryTip();

    await pumpWithProviders(tester, const BrewPathApp());
    await openTab(tester, AppIcon.route);

    // Opened through the app's one sheet door, which is the door every gate
    // uses. A tip counts as seen the moment it shows, so one that appeared
    // behind a sheet would be spent without ever having been read.
    unawaited(
      showAppSheet<void>(
        context: tester.element(find.byType(PathScreen)),
        title: 'A gate, or any other sheet',
        builder: (_) => const SizedBox.shrink(),
      ),
    );
    await tester.pumpAndSettle();
    await letTipsSettle(tester);

    expect(find.byType(MicroTipCard), findsNothing);
    expect(await tipsSeenOnDisk(), isEmpty);

    // And it is owed, not lost: closing the sheet lets the tip through.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    await letTipsSettle(tester);

    expect(tipTitled(MicroTip.path), findsOneWidget);
  });

  testWidgets('nothing is said inside a lesson', (tester) async {
    useTallViewport(tester);
    await armEveryTip();

    final container = ProviderContainer(
      overrides: [
        streakStatusProvider.overrideWith(
          (ref) async => const StreakStatus(
            streak: 7,
            freezeHeld: true,
            daysToNextFreeze: null,
            freezesSpent: 0,
            frozenDays: {},
          ),
        ),
      ],
    );

    await pumpWithProviders(tester, const BrewPathApp(), container: container);
    await tester.tap(find.widgetWithText(FilledButton, AppLabels.beginLesson));
    await settleLoaders(tester);
    await letTipsSettle(tester);

    expect(find.byType(MicroTipCard), findsNothing);
    expect(await tipsSeenOnDisk(), isEmpty);
  });
}
