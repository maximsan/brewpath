import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/swipe/swipe_hint_providers.dart';
import 'package:brew_path/core/widgets/focus_revealed_button.dart';
import 'package:brew_path/features/challenges/presentation/active_challenge_card.dart';
import 'package:brew_path/features/challenges/presentation/challenge_park_chevron.dart';
import 'package:brew_path/features/challenges/presentation/challenge_park_geometry.dart';
import 'package:brew_path/features/challenges/presentation/challenge_park_track.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/content_fixtures.dart';
import '../../../support/widget_harness.dart';

void main() {
  late SnapshotRepository snapshots;

  setUp(() async {
    await useInMemoryDatabase();
    snapshots = SnapshotRepository();
  });

  Future<void> pump(
    WidgetTester tester, {
    String effort = 'Next brews · 5 min',
    bool reduceMotion = false,
  }) async {
    await pumpWithProviders(
      tester,
      MaterialApp(
        theme: AppTheme.darkRoast,
        home: Scaffold(
          body: ActiveChallengeCard(challenge: testChallenge(effort: effort)),
        ),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(disableAnimations: reduceMotion),
          child: child!,
        ),
      ),
    );
  }

  Future<Set<String>> parked() async =>
      (await snapshots.read()).clearedByReset.challengesSaved.value;

  Finder card() => find.byType(Card);

  testWidgets('names itself, the brew, and what it asks for', (tester) async {
    await pump(tester);

    expect(find.text('COFFEE CHALLENGE'), findsOneWidget);
    expect(find.text('Two cups, two ratios'), findsOneWidget);
    expect(
      find.text('Brew the same coffee twice at two different ratios.'),
      findsOneWidget,
    );
    expect(find.text('Next brews · 5 min'), findsOneWidget);
  });

  testWidgets('sets its title one step below a lesson title', (tester) async {
    await pump(tester);

    // The design's own number, not the rung's: read off `AppText.subtitle`
    // this could only ever agree with itself, and a rung edit would pass.
    expect(
      tester.widget<Text>(find.text('Two cups, two ratios')).style?.fontSize,
      22.0,
      reason:
          'one step below a lesson title, because the challenge is optional',
    );
  });

  testWidgets('reads as one sentence to a screen reader', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester);

    expect(
      find.bySemanticsLabel(
        RegExp('Coffee Challenge. Two cups, two ratios..*Next brews.*5 min'),
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('renders an effort string that authors only one half', (
    tester,
  ) async {
    await pump(tester, effort: 'Next brews');

    // No stray separator for a half that was never written.
    expect(find.text('Next brews'), findsOneWidget);
  });

  group('parking by sliding the card aside', () {
    testWidgets('a right swipe past the threshold parks the challenge', (
      tester,
    ) async {
      await pump(tester);

      await tester.drag(card(), const Offset(challengeParkAt + 10, 0));
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );

      expect(await parked(), contains(testChallenge().id));
    });

    testWidgets('short of the threshold parks nothing', (tester) async {
      await pump(tester);

      await tester.drag(card(), const Offset(challengeParkAt - 20, 0));
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );

      expect(await parked(), isEmpty);
    });

    testWidgets('a wrong-way drag resists and commits nothing', (tester) async {
      await pump(tester);
      final centre = tester.getTopLeft(card()).dx;

      final gesture = await tester.startGesture(tester.getCenter(card()));
      await gesture.moveBy(const Offset(-120, 0));
      await tester.pump();

      final resisted = centre - tester.getTopLeft(card()).dx;
      expect(resisted, greaterThan(0), reason: 'it moves, so it is not dead');
      expect(resisted, lessThan(120 / 2), reason: 'damped, so it resists');

      await gesture.up();
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      expect(await parked(), isEmpty);
    });

    testWidgets('the destination reads whole before the card commits', (
      tester,
    ) async {
      await pump(tester);

      final gesture = await tester.startGesture(tester.getCenter(card()));
      await gesture.moveBy(const Offset(challengeParkAt, 0));
      await tester.pump();

      final track = tester.widget<Opacity>(
        find.descendant(
          of: find.byType(ChallengeParkTrack),
          matching: find.byType(Opacity),
        ),
      );
      expect(track.opacity, 1);

      // The threshold is set by the label, and the label only pays for it by
      // sitting at the left edge: a centred one stays under the card for the
      // whole gesture, however far 104 uncovers. Its width against the strip
      // is real type metrics, which a stub font cannot measure — the
      // screenshot is what checks that.
      final trackBox = tester.getRect(find.byType(ChallengeParkTrack));
      expect(
        tester.getTopLeft(find.text('FOR LATER')).dx - trackBox.left,
        AppSpacing.sm,
        reason: 'left-aligned at the track inset, never centred',
      );

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('the card flies off before Today lets it go', (tester) async {
      await pump(tester);
      final centre = tester.getTopLeft(card()).dx;

      await tester.drag(card(), const Offset(challengeParkAt + 10, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 160));

      expect(
        tester.getTopLeft(card()).dx,
        greaterThan(centre + challengeParkAt),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('and stays gone once it has landed, however long the store '
        'takes', (tester) async {
      await pump(tester);

      await tester.drag(card(), const Offset(challengeParkAt + 10, 0));
      await tester.pump();
      // The flight is over and the queue write has not landed: the store
      // never answers under the fake clock, which is the window a device has
      // for a frame or more. The card that just left must not be back.
      await tester.pump(
        challengeParkExitDuration + const Duration(milliseconds: 20),
      );
      await tester.pump();

      expect(card(), findsNothing);
      expect(find.text('Log Result'), findsNothing);
    });
  });

  group('the chevron', () {
    testWidgets('stands on the card and never disappears', (tester) async {
      await pump(tester);

      expect(find.byType(ChallengeParkChevron), findsOneWidget);
      final chevron = tester.widget<ChallengeParkChevron>(
        find.byType(ChallengeParkChevron),
      );
      expect(
        challengeChevronOpacity(
          hinting: chevron.hinting,
          used: chevron.used,
        ),
        greaterThan(0),
      );
    });

    testWidgets('never runs across the words it is inviting', (tester) async {
      await pump(tester);

      final chevron = tester.getRect(find.byType(ChallengeParkChevron));
      final instruction = tester.getRect(
        find.text('Brew the same coffee twice at two different ratios.'),
      );

      expect(
        instruction.right,
        lessThanOrEqualTo(chevron.left),
        reason:
            'the chevron sits at the card’s vertical middle, which is '
            'where the instruction runs',
      );
    });

    testWidgets('is quieter once the gesture has been used', (tester) async {
      await pumpWithProviders(
        tester,
        MaterialApp(
          theme: AppTheme.darkRoast,
          home: Scaffold(body: ActiveChallengeCard(challenge: testChallenge())),
        ),
        container: ProviderContainer(
          overrides: [
            swipesUsedProvider.overrideWith((ref) async => {'challenge'}),
          ],
        ),
      );

      expect(
        tester
            .widget<ChallengeParkChevron>(
              find.byType(ChallengeParkChevron),
            )
            .used,
        isTrue,
      );
    });
  });

  testWidgets('the focus-revealed control is a point until it takes focus', (
    tester,
  ) async {
    await pump(tester);

    expect(
      tester.getSize(find.byType(FocusRevealedButton)),
      const Size(1, 1),
      reason: 'a full-width invisible strip is still something to land on',
    );
  });

  testWidgets('but assistive technology can still press it', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester);

    tester.semantics.tap(find.semantics.byLabel('Save for later'));
    await tester.pumpAndSettle();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );

    expect(await parked(), contains(testChallenge().id));
    semantics.dispose();
  });

  testWidgets('parks from the focus-revealed control, not the log sheet', (
    tester,
  ) async {
    await pump(tester);

    final semantics = tester.ensureSemantics();
    tester.semantics.tap(find.semantics.byLabel('Save for later'));
    await tester.pumpAndSettle();
    semantics.dispose();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );

    expect(await parked(), contains(testChallenge().id));
    // The sheet is titled with the challenge; so is the card, which has
    // left. Nothing on screen names it, so no sheet was raised.
    expect(find.text(testChallenge().title), findsNothing);
  });

  testWidgets('is identical under reduced motion, having no motion', (
    tester,
  ) async {
    await pump(tester, reduceMotion: true);
    await tester.pump();

    expect(tester.hasRunningAnimations, isFalse);
    expect(find.text('Two cups, two ratios'), findsOneWidget);
  });
}
