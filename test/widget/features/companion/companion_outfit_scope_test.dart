import 'package:brew_path/app/app.dart';
import 'package:brew_path/features/companion/application/companion_outfit.dart';
import 'package:brew_path/features/companion/domain/roasty_state.dart';
import 'package:brew_path/features/companion/presentation/companion_outfit_scope.dart';
import 'package:brew_path/features/companion/presentation/roasty.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/widget_harness.dart';

// What makes the outfit app-wide: a Roasty three hosts deep reads it without
// anyone threading it through, and a Roasty with no scope over it is the plain
// bean — which is what a free learner, and every unrelated widget test, sees.
const _dressed = CompanionConfig(
  roast: 'dark',
  hat: 'beanie',
  gear: 'scarf',
  sprout: 'flower',
);

/// A mascot buried under hosts that know nothing about outfits.
Widget _buriedRoasty() => const Padding(
  padding: EdgeInsets.all(4),
  child: Center(
    child: DecoratedBox(
      decoration: BoxDecoration(),
      child: Roasty(state: RoastyState.idle, size: 40, animate: false),
    ),
  ),
);

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    Directionality(textDirection: TextDirection.ltr, child: child),
  );
  await tester.pump();
}

void main() {
  testWidgets('the app installs the scope over every route', (tester) async {
    await useInMemoryDatabase();
    await pumpWithProviders(
      tester,
      const BrewPathApp(),
      container: ProviderContainer(
        overrides: [
          companionOutfitProvider.overrideWith((ref) async => _dressed),
        ],
      ),
    );

    final scope = find.byType(CompanionOutfitScope);
    expect(
      scope,
      findsOneWidget,
      reason:
          'delete the scope from the app root and every screen goes plain — '
          'which is the failure mode this feature exists to prevent',
    );
    expect(
      tester.widget<CompanionOutfitScope>(scope).outfit,
      _dressed,
      reason: 'the scope is fed by the provider, not by a hard-coded outfit',
    );
  });

  testWidgets('a mascot under the scope wears what it carries', (tester) async {
    await _pump(
      tester,
      CompanionOutfitScope(outfit: _dressed, child: _buriedRoasty()),
    );

    expect(CompanionOutfitScope.of(_context(tester)), _dressed);
  });

  testWidgets('a mascot with no scope over it is the plain bean', (
    tester,
  ) async {
    await _pump(tester, _buriedRoasty());

    expect(CompanionOutfitScope.of(_context(tester)), CompanionConfig.initial);
  });

  testWidgets('an outfit passed to one mascot overrides the scope for it', (
    tester,
  ) async {
    // The Studio's preview: one dressed mascot inside an app wearing another.
    const previewed = CompanionConfig(
      roast: 'light',
      hat: 'cap',
      gear: 'none',
      sprout: 'none',
    );

    await _pump(
      tester,
      const CompanionOutfitScope(
        outfit: _dressed,
        child: Roasty(
          state: RoastyState.idle,
          size: 40,
          animate: false,
          outfit: previewed,
        ),
      ),
    );

    expect(tester.widget<Roasty>(find.byType(Roasty)).outfit, previewed);
  });

  testWidgets('changing the outfit rebuilds what is under it', (tester) async {
    await _pump(
      tester,
      CompanionOutfitScope(
        outfit: CompanionConfig.initial,
        child: _buriedRoasty(),
      ),
    );
    expect(CompanionOutfitScope.of(_context(tester)), CompanionConfig.initial);

    await _pump(
      tester,
      CompanionOutfitScope(outfit: _dressed, child: _buriedRoasty()),
    );

    expect(CompanionOutfitScope.of(_context(tester)), _dressed);
  });
}

/// The buried mascot's own context — the one that has to resolve the scope.
BuildContext _context(WidgetTester tester) =>
    tester.element(find.byType(Roasty));
