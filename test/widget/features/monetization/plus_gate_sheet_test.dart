import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/widgets/ghost_button.dart';
import 'package:brew_path/features/monetization/domain/plus_copy.dart';
import 'package:brew_path/features/monetization/domain/plus_gate_trigger.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch_provider.dart';
import 'package:brew_path/features/monetization/presentation/plus_gate_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/widget_harness.dart';

/// The sheet a lock raises: what it says, the one way to buy, the way to
/// decline, and what it refuses to offer.
void main() {
  setUp(useInMemoryDatabase);

  /// A counted pitch, so the sheet's assertions do not wait on the banks.
  const pitch = PlusPitch(
    remainingLessons: 29,
    lockedGames: 4,
    referenceTerms: 8,
    savedFreeCap: 5,
  );

  Future<void> openWith(WidgetTester tester, PlusGateTrigger trigger) async {
    final container = ProviderContainer(
      overrides: [plusPitchProvider.overrideWith((ref) async => pitch)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.cupping,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showPlusGate(context, trigger),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('it opens on what was just hit', (tester) async {
    await openWith(tester, const SavedShelfFull(cap: 5));

    // The header leads, above the pitch — the sheet answers the question the
    // learner asked rather than a generic one.
    expect(find.text('Your free shelf is full at 5.'), findsOneWidget);
    expect(find.text(PlusCopy.title), findsOneWidget);
  });

  testWidgets('a locked game names the module that teaches it', (tester) async {
    await openWith(tester, const LockedGame(moduleTitle: 'Roasting'));

    expect(find.text('Taught in Roasting.'), findsOneWidget);
  });

  testWidgets('a locked lesson names the lesson', (tester) async {
    await openWith(tester, const LockedLesson(title: 'Why altitude matters'));

    expect(
      find.text('"Why altitude matters" is part of the full course.'),
      findsOneWidget,
    );
  });

  testWidgets('the pitch is ranked, course first', (tester) async {
    await openWith(tester, const SavedShelfFull(cap: 5));

    final bullets = PlusCopy.bulletsFor(pitch);
    final positions = [
      for (final bullet in bullets)
        tester.getTopLeft(find.text(bullet.title)).dy,
    ];
    expect(
      positions,
      orderedEquals(<double>[...positions]..sort()),
      reason: 'the course must sit above practice, and practice above skins',
    );
    expect(find.textContaining('29 more lessons'), findsOneWidget);
  });

  testWidgets('there is exactly one way to buy', (tester) async {
    await openWith(tester, const SavedShelfFull(cap: 5));

    expect(find.text(PlusCopy.buy), findsOneWidget);

    // The three things the design's sheet carries that v1 must not: an ad
    // path, a trial, and a plan chooser.
    //
    // Matched on **whole words**. This began as `textContaining('ad')`, which
    // passed by luck — it would have fired on *Loading*, *already* or *ahead*
    // and failed with a message about advertising. A substring is the wrong
    // shape for a rule about vocabulary.
    final forbidden = RegExp(
      r'\b(ads?|advert\w*|trial|month(ly)?|year(ly)?|subscri\w+)\b',
      caseSensitive: false,
    );
    final onScreen = tester
        .widgetList<Text>(find.byType(Text))
        .map((text) => text.data ?? '')
        .where(forbidden.hasMatch)
        .toList();

    expect(
      onScreen,
      isEmpty,
      reason:
          'v1 sells one non-consumable: no ad path, no trial, no plan '
          'chooser. Found: ${onScreen.join(' | ')}',
    );
  });

  testWidgets('Restore, Terms and Privacy are present', (tester) async {
    await openWith(tester, const SavedShelfFull(cap: 5));

    // The App Store requires all three of a non-consumable.
    expect(find.text(PlusCopy.restore), findsOneWidget);
    expect(find.text(PlusCopy.terms), findsOneWidget);
    expect(find.text(PlusCopy.privacy), findsOneWidget);
  });

  testWidgets('declining is a button, not a swipe to discover', (tester) async {
    await openWith(tester, const SavedShelfFull(cap: 5));

    // The design puts a ghost under the buy action on every gate. The sheet
    // was always dismissible by the handle or the scrim; what was missing was
    // an exit the learner could see.
    expect(
      find.widgetWithText(GhostButton, PlusCopy.notNow),
      findsOneWidget,
    );

    await tester.tap(find.text(PlusCopy.notNow));
    await tester.pumpAndSettle();

    expect(find.text(PlusCopy.title), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('dismissing changes nothing', (tester) async {
    await openWith(tester, const SavedShelfFull(cap: 5));

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.text(PlusCopy.title), findsNothing);
    // Back where they were, with nothing bought.
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('the sheet announces itself by name', (tester) async {
    final handle = tester.ensureSemantics();
    await openWith(tester, const SavedShelfFull(cap: 5));

    expect(find.bySemanticsLabel(PlusCopy.title), findsWidgets);
    handle.dispose();
  });

  testWidgets('each bullet is heard as one item', (tester) async {
    final handle = tester.ensureSemantics();
    await openWith(tester, const SavedShelfFull(cap: 5));

    // Title and body merged: two fragments would lose the ranking that the
    // ordering exists to convey.
    for (final bullet in PlusCopy.bulletsFor(pitch)) {
      expect(
        find.bySemanticsLabel('${bullet.title}. ${bullet.body}'),
        findsOneWidget,
      );
    }
    handle.dispose();
  });
}
