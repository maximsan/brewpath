import 'dart:ui' show Tristate;

import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/monetization/domain/course_entitlement.dart';
import 'package:brew_path/features/monetization/domain/plus_gate_trigger.dart';
import 'package:brew_path/features/progress/presentation/coffee_tree.dart';
import 'package:brew_path/features/studio/presentation/studio_door_tile.dart';
import 'package:brew_path/features/studio/presentation/studio_screen.dart';
import 'package:brew_path/features/studio/presentation/widgets/light_pill.dart';
import 'package:brew_path/features/studio/presentation/widgets/plant_row.dart';
import 'package:brew_path/features/studio/presentation/widgets/plus_pill.dart';
import 'package:brew_path/features/studio/presentation/widgets/studio_door.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../support/widget_harness.dart';

/// The Studio door and the grove chooser, driven end to end.
///
/// One test per claim the ticket makes, all against the real content banks and
/// a real in-memory snapshot — the grove is content plus a stored value, and a
/// faked bank would prove neither.
///
/// Entitlement is overridden rather than faked at the payments layer:
/// `courseEntitlement` is the app's single answer to "has Plus", and the no-op
/// service reports free, so the Plus path exists only by override. That is the
/// seam #89 records.
void main() {
  setUp(useInMemoryDatabase);

  Widget host({required bool isPlus}) => ProviderScope(
    overrides: [courseEntitlementProvider.overrideWith((_) async => isPlus)],
    child: MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: '/studio',
        routes: [
          GoRoute(
            path: '/studio',
            name: AppRoutes.studio.name,
            builder: (_, _) => const StudioScreen(),
          ),
        ],
      ),
    ),
  );

  Future<void> settle(WidgetTester tester) => settleLoaders(tester);

  /// The chooser is taller than a test viewport, so a target has to be brought
  /// on screen before it can be tapped, and `settleLoaders` run again for the
  /// scroll — Drift and `rootBundle` are real async, which a fake-async pump
  /// alone cannot advance.
  Future<void> tapAfterScroll(WidgetTester tester, Finder target) async {
    await tester.ensureVisible(target);
    await settle(tester);
    await tester.tap(target);
    await settle(tester);
  }

  testWidgets('the chooser opens on what is planted', (tester) async {
    await tester.pumpWidget(host(isPlus: true));
    await settle(tester);

    // The default grove is Arabica in Daylight, so that is what it shows and
    // there is nothing to apply.
    expect(find.text('Arabica'), findsWidgets);
    final confirm = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Already planted'),
    );
    expect(confirm.onPressed, isNull, reason: 'nothing has changed yet');
  });

  testWidgets('picking a plant updates the copy and wakes the confirm', (
    tester,
  ) async {
    await tester.pumpWidget(host(isPlus: true));
    await settle(tester);

    await tapAfterScroll(tester, find.widgetWithText(PlantRow, 'Robusta'));

    // The panel above follows the pick — the binomial is the tell that the
    // whole copy block changed, not just the row's own highlight.
    expect(find.text('Coffea canephora'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Plant in my grove'), findsOne);
  });

  testWidgets('picking a light wakes the confirm too', (tester) async {
    await tester.pumpWidget(host(isPlus: true));
    await settle(tester);

    await tapAfterScroll(tester, find.widgetWithText(LightPill, 'Moonlit'));

    expect(find.widgetWithText(FilledButton, 'Plant in my grove'), findsOne);
  });

  testWidgets('changing back to what is planted puts the confirm to sleep', (
    tester,
  ) async {
    await tester.pumpWidget(host(isPlus: true));
    await settle(tester);

    await tapAfterScroll(tester, find.widgetWithText(PlantRow, 'Robusta'));
    await tapAfterScroll(tester, find.widgetWithText(PlantRow, 'Arabica'));

    final confirm = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Already planted'),
    );
    expect(confirm.onPressed, isNull);
  });

  testWidgets('applying persists the grove', (tester) async {
    await tester.pumpWidget(host(isPlus: true));
    await settle(tester);

    await tapAfterScroll(tester, find.widgetWithText(PlantRow, 'Robusta'));
    await tapAfterScroll(
      tester,
      find.widgetWithText(FilledButton, 'Plant in my grove'),
    );

    final stored =
        (await SnapshotRepository().read()).clearedByDeleteOnly.grove.value;
    expect(stored.variety, 'robusta');
  });

  testWidgets('backing out without applying leaves the grove alone', (
    tester,
  ) async {
    await tester.pumpWidget(host(isPlus: true));
    await settle(tester);

    await tapAfterScroll(tester, find.widgetWithText(PlantRow, 'Liberica'));
    // Leave without confirming — the bar's back button, which is the only
    // IconButton the chooser draws.
    await tester.tap(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byType(IconButton),
      ),
    );
    await settle(tester);

    final stored =
        (await SnapshotRepository().read()).clearedByDeleteOnly.grove.value;
    expect(stored, Grove.initial, reason: 'a draft is not a write');
  });

  testWidgets('rows and pills announce which is chosen', (tester) async {
    await tester.pumpWidget(host(isPlus: true));
    await settle(tester);

    final chosen = tester.getSemantics(
      find.widgetWithText(PlantRow, 'Arabica'),
    );
    expect(chosen.flagsCollection.isSelected, Tristate.isTrue);

    final other = tester.getSemantics(find.widgetWithText(PlantRow, 'Robusta'));
    expect(other.flagsCollection.isSelected, Tristate.isFalse);
  });

  testWidgets('a free learner gets the lock, not the chooser', (tester) async {
    // Pumps `StudioDoorTile`, which is where the entitlement branch lives.
    // Building `StudioDoor` by hand and passing `locked: true` would only
    // prove that a callback I wrote in the test fires.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          courseEntitlementProvider.overrideWith((_) async => false),
        ],
        child: const MaterialApp(
          home: Scaffold(body: StudioDoorTile()),
        ),
      ),
    );
    await settle(tester);

    expect(find.byType(PlusPill), findsOneWidget);

    await tester.tap(find.byType(StudioDoor));
    await settle(tester);

    // The Plus gate, not a snackbar and not the chooser. Asserted on the
    // trigger's own header so this test breaks if the Studio starts raising
    // some other gate — the sheet's contents are #89's to test.
    expect(find.text(const LockedStudio().header), findsOneWidget);
    expect(find.byType(StudioScreen), findsNothing);
  });

  testWidgets('the door names what is planted, and Plus learners see no pill', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          courseEntitlementProvider.overrideWith((_) async => true),
        ],
        child: const MaterialApp(
          home: Scaffold(body: StudioDoorTile()),
        ),
      ),
    );
    await settle(tester);

    // Daylight is the resting light, so the design names only the species.
    expect(find.text('Arabica'), findsOneWidget);
    expect(find.byType(PlusPill), findsNothing);
  });

  testWidgets('the pills announce which light is chosen', (tester) async {
    await tester.pumpWidget(host(isPlus: true));
    await settle(tester);

    final chosen = tester.getSemantics(
      find.widgetWithText(LightPill, 'Daylight'),
    );
    expect(chosen.flagsCollection.isSelected, Tristate.isTrue);

    final other = tester.getSemantics(
      find.widgetWithText(LightPill, 'Moonlit'),
    );
    expect(other.flagsCollection.isSelected, Tristate.isFalse);
  });

  testWidgets('nothing on the surface animates, so reduced motion is moot', (
    tester,
  ) async {
    // The criterion is "reduced motion is respected". It is respected by
    // there being no motion: every tree here is passed `animate: false`, so
    // `CoffeeTree`'s own `disableAnimations` check never has to save it.
    // Asserted rather than assumed, because a later edit that lets the
    // preview sway would satisfy no test and break the criterion silently.
    await tester.pumpWidget(host(isPlus: true));
    await settle(tester);

    final trees = tester.widgetList<CoffeeTree>(find.byType(CoffeeTree));
    expect(trees, isNotEmpty);
    expect(trees.every((tree) => !tree.animate), isTrue);
  });

  testWidgets('a planted grove survives a fresh read', (tester) async {
    // The write is the whole point of the feature, so it is checked from a
    // scope that never saw the chooser — which is what a restart is.
    await tester.pumpWidget(host(isPlus: true));
    await settle(tester);

    await tapAfterScroll(tester, find.widgetWithText(PlantRow, 'Liberica'));
    await tapAfterScroll(
      tester,
      find.widgetWithText(FilledButton, 'Plant in my grove'),
    );

    final reread = await SnapshotRepository().read();
    expect(reread.clearedByDeleteOnly.grove.value.variety, 'liberica');
  });
}
