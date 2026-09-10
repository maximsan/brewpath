import 'dart:async';

import 'package:brew_path/app/app.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/features/monetization/domain/plus_gate_trigger.dart';
import 'package:brew_path/features/monetization/presentation/plus_pill.dart';
import 'package:brew_path/features/profile/presentation/widgets/profile_entry_card.dart';
import 'package:brew_path/features/progress/presentation/coffee_tree.dart';
import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/features/saved/domain/saved_shelf.dart';
import 'package:brew_path/features/saved/presentation/saved_entry_card.dart';
import 'package:brew_path/features/saved/presentation/saved_screen.dart';
import 'package:brew_path/features/companion/presentation/roasty.dart';
import 'package:brew_path/features/studio/domain/dress_companion.dart';
import 'package:brew_path/features/studio/presentation/roasty_door_tile.dart';
import 'package:brew_path/features/studio/presentation/studio_door_tile.dart';
import 'package:brew_path/features/studio/presentation/studio_screen.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/find_mark.dart';
import '../../../support/widget_harness.dart';

/// Saves [keys] the way the app does, before the tab is opened.
Future<void> seedSaved(List<String> keys) async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  for (final key in keys) {
    await toggleSaved(
      container.read(snapshotRepositoryProvider),
      key: key,
      now: DateTime(2026, 8, 30),
      isPlus: false,
      visible: 0,
    );
  }
}

void main() {
  setUp(useInMemoryDatabase);

  Future<void> openProfile(WidgetTester tester) async {
    // Tall surface so the Profile slivers lay out inside the viewport —
    // otherwise virtualization keeps the lower cards out of the widget tree.
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpWithProviders(tester, const BrewPathApp());
    await tester.tap(findMark(AppIcon.leaf, active: false));
    await settleLoaders(tester);
  }

  testWidgets('a free learner meets the plain bean on the wardrobe door', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await dressCompanion(
      container.read(snapshotRepositoryProvider),
      outfit: const CompanionConfig(
        roast: 'espresso',
        hat: 'beanie',
        gear: 'headphones',
        sprout: 'cherry',
      ),
      now: DateTime(2026, 9, 11),
    );

    await openProfile(tester);

    final door = tester.widget<Roasty>(
      find.descendant(
        of: find.byType(RoastyDoorTile),
        matching: find.byType(Roasty),
      ),
    );
    expect(
      door.outfit,
      CompanionConfig.initial,
      reason: 'the gate hides the wardrobe on the door as well as behind it',
    );
  });

  testWidgets('the three entries close the screen, in the design order', (
    tester,
  ) async {
    await openProfile(tester);

    expect(find.byType(ProfileEntryCard), findsNWidgets(3));
    expect(
      tester.getTopLeft(find.byType(StudioDoorTile)).dy,
      lessThan(tester.getTopLeft(find.byType(RoastyDoorTile)).dy),
      reason: 'the grove door opens the Studio, and the wardrobe follows it',
    );
    expect(
      tester.getTopLeft(find.byType(RoastyDoorTile)).dy,
      lessThan(tester.getTopLeft(find.byType(SavedEntryCard)).dy),
      reason: 'the design stacks the Studio doors above Saved',
    );
    // Neither is owed for v1: the design gates both off.
    expect(find.text('Challenge a friend'), findsNothing);
    expect(find.text('Browse courses'), findsNothing);
  });

  testWidgets('each entry carries its well, kicker, title and support line', (
    tester,
  ) async {
    await openProfile(tester);

    // The Studio's well holds the planted grove, not a glyph — a door onto
    // something the learner owns.
    expect(
      find.descendant(
        of: find.byType(StudioDoorTile),
        matching: find.byType(CoffeeTree),
      ),
      findsOneWidget,
    );
    expect(find.text('GROVE'), findsOneWidget);
    expect(find.text('Choose your plant'), findsOneWidget);
    // Daylight is the resting light, so the design names only the species.
    expect(find.text('Arabica'), findsOneWidget);

    // Saved's well holds the filled bookmark. The header carries the resting
    // one, which is why `active` is what tells the two apart.
    expect(
      find.descendant(
        of: find.byType(SavedEntryCard),
        matching: findMark(AppIcon.bookmark, active: true),
      ),
      findsOneWidget,
    );
    expect(find.text('SAVED'), findsOneWidget);
    expect(find.text('Your favorites'), findsOneWidget);
    expect(find.text('0 saved to revisit'), findsOneWidget);
  });

  testWidgets('the Saved card counts what the shelf holds', (tester) async {
    // A term and a lesson — two kinds, so the count is the shelf's rows rather
    // than one group's.
    await seedSaved(['t:arabica', 'l:m1l1']);
    await openProfile(tester);

    expect(find.text('2 saved to revisit'), findsOneWidget);
  });

  testWidgets('a key nothing resolves is not counted', (tester) async {
    // The shelf skips a row it cannot draw, so the card must not promise it.
    await seedSaved(['t:arabica', 't:no-such-term']);
    await openProfile(tester);

    expect(find.text('1 saved to revisit'), findsOneWidget);
  });

  testWidgets('an unresolved shelf is not reported as an empty one', (
    tester,
  ) async {
    // "0 saved to revisit" under a learner's full shelf is a wrong count, not
    // an absent one. The header's badge can hide while it waits; a sentence
    // cannot, so it waits for a number before claiming one.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          savedShelfProvider.overrideWith(
            (ref) => Completer<List<SavedGroup>>().future,
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: SavedEntryCard())),
      ),
    );
    await tester.pump();

    expect(find.byType(SavedEntryCard), findsOneWidget);
    expect(find.textContaining('saved to revisit'), findsNothing);
  });

  testWidgets('the Saved card opens the shelf', (tester) async {
    await seedSaved(['t:arabica']);
    await openProfile(tester);

    await tester.tap(find.byType(SavedEntryCard));
    await settleLoaders(tester);

    expect(find.byType(SavedScreen), findsOneWidget);
    expect(find.text('Arabica'), findsOneWidget);
  });

  testWidgets('the gated entry wears the pill and raises the gate', (
    tester,
  ) async {
    await openProfile(tester);

    // A fresh learner owns nothing, so both Studio doors are gated — and
    // Saved, which is free for everyone, wears no pill beside it.
    for (final door in [
      find.byType(StudioDoorTile),
      find.byType(RoastyDoorTile),
    ]) {
      expect(
        find.descendant(of: door, matching: find.byType(PlusPill)),
        findsOneWidget,
      );
    }
    expect(
      find.descendant(
        of: find.byType(SavedEntryCard),
        matching: find.byType(PlusPill),
      ),
      findsNothing,
    );

    await tester.tap(find.byType(StudioDoorTile));
    await settleLoaders(tester);

    expect(find.text(const LockedStudio().header), findsOneWidget);
    expect(find.byType(StudioScreen), findsNothing);
  });
}
