import 'package:brew_path/features/companion/presentation/roasty.dart';
import 'package:brew_path/features/studio/domain/dress_companion.dart';
import 'package:brew_path/features/studio/presentation/roasty_studio_screen.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/widget_harness.dart';

// The wardrobe as a learner meets it: pick, see it, confirm. The preview is
// asserted through the outfit the mascot is handed, because what a painter put
// on the canvas is not readable from a widget test.
/// Reduced motion throughout: Roasty's idle loop never settles, so
/// `pumpAndSettle` would time out on the preview rather than on anything the
/// test is about.
Future<void> _pump(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: const RoastyStudioScreen(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
      ),
    ),
  );
  await _settle(tester);
}

/// Pumps until the banks have arrived, in real time — they come off the
/// bundle, which a fake-async pump cannot advance.
Future<void> _settle(WidgetTester tester) async {
  for (var frame = 0; frame < 20; frame++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
    if (find.byType(Roasty).evaluate().isNotEmpty) return;
  }
}

CompanionConfig _previewed(WidgetTester tester) =>
    tester.widget<Roasty>(find.byType(Roasty)).outfit!;

void main() {
  final snapshots = SnapshotRepository();

  setUp(useInMemoryDatabase);

  testWidgets('opens on the four axes the banks ship', (tester) async {
    await _pump(tester);

    expect(find.text('ROAST'), findsOneWidget);
    expect(find.text('HAT'), findsOneWidget);
    expect(find.text('ACCESSORY'), findsOneWidget);
    expect(find.text('SPROUT'), findsOneWidget);
    // One label off each axis, to prove the rows are fed from the banks.
    expect(find.text('Espresso'), findsOneWidget);
    expect(find.text('Field hat'), findsOneWidget);
    expect(find.text('Headphones'), findsOneWidget);
    expect(find.text('Blossom'), findsOneWidget);
  });

  testWidgets('opens on what Roasty already has on', (tester) async {
    await dressCompanion(
      snapshots,
      outfit: const CompanionConfig(
        roast: 'dark',
        hat: 'cap',
        gear: 'scarf',
        sprout: 'sprig',
      ),
      now: DateTime.now(),
    );

    await _pump(tester);

    expect(_previewed(tester).hat, 'cap');
    expect(find.text('Looking sharp'), findsOneWidget);
  });

  testWidgets('picking an axis updates the preview live', (tester) async {
    await _pump(tester);
    expect(_previewed(tester).roast, 'medium');

    await tester.tap(find.text('Espresso'));
    await tester.pump();

    expect(_previewed(tester).roast, 'espresso');
    // The other three are untouched by a pick on one.
    expect(_previewed(tester).hat, CompanionConfig.initial.hat);
  });

  testWidgets('the confirm is dead until something changes', (tester) async {
    await _pump(tester);

    expect(find.text('Looking sharp'), findsOneWidget);
    expect(find.text('Apply look'), findsNothing);

    await tester.tap(find.text('Beanie'));
    await tester.pump();

    expect(find.text('Apply look'), findsOneWidget);
  });

  testWidgets('confirming persists the outfit', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Shades'));
    await tester.pump();
    // The confirm sits below the fold on a test-sized screen; a raw tap would
    // land outside the viewport and silently miss.
    await tester.ensureVisible(find.text('Apply look'));
    await tester.pump();
    await tester.tap(find.text('Apply look'));
    for (var frame = 0; frame < 20; frame++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }

    final stored = (await snapshots.read()).clearedByDeleteOnly.companion;
    expect(stored.value.gear, 'sunglasses');
  });

  testWidgets('picking back to what is worn kills the confirm again', (
    tester,
  ) async {
    await _pump(tester);

    await tester.tap(find.text('Espresso'));
    await tester.pump();
    expect(find.text('Apply look'), findsOneWidget);

    await tester.tap(find.text('Medium'));
    await tester.pump();

    expect(find.text('Looking sharp'), findsOneWidget);
  });
}
