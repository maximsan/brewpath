import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/features/mini_games/domain/course_entitlement.dart';
import 'package:brew_path/features/saved/domain/saved_cap.dart';
import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/features/saved/presentation/saved_bookmark_button.dart';
import 'package:brew_path/features/saved/presentation/saved_gate.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/widget_harness.dart';

/// A full free shelf, none of which is the key under test.
const _full = ['t:a', 't:b', 't:c', 't:d', 't:e'];
const _sixth = 't:arabica';

void main() {
  setUp(useInMemoryDatabase);

  Future<ProviderContainer> pump(
    WidgetTester tester, {
    bool isPlus = false,
  }) async {
    final container = ProviderContainer(
      overrides: [
        courseEntitlementProvider.overrideWith((ref) async => isPlus),
      ],
    );
    addTearDown(container.dispose);
    for (final key in _full) {
      await toggleSaved(
        container.read(snapshotRepositoryProvider),
        key: key,
        now: DateTime(2026, 8, 23),
        isPlus: true,
        visible: 0,
      );
    }
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.cupping,
          home: const Scaffold(
            body: SavedBookmarkButton(savedKey: _sixth, label: 'Arabica'),
          ),
        ),
      ),
    );
    await settleLoaders(tester);
    return container;
  }

  testWidgets('a sixth save is refused, and says why', (tester) async {
    final container = await pump(tester);

    await tester.tap(find.byType(IconButton));
    await settleLoaders(tester);

    expect(
      await container.read(savedKeysProvider.future),
      _full.toSet(),
      reason: 'nothing moved',
    );
    expect(find.byIcon(Icons.bookmark_outline), findsOneWidget);
    expect(find.text(savedCapMessage), findsOneWidget);
  });

  testWidgets('the refusal names the cap and offers Plus', (tester) async {
    await pump(tester);

    await tester.tap(find.byType(IconButton));
    await settleLoaders(tester);

    // An offer, not an error.
    expect(find.textContaining('$savedFreeMax'), findsOneWidget);
    expect(find.textContaining('Plus'), findsOneWidget);
  });

  testWidgets('with Plus the sixth save takes', (tester) async {
    final container = await pump(tester, isPlus: true);

    await tester.tap(find.byType(IconButton));
    await settleLoaders(tester);

    expect(await container.read(savedKeysProvider.future), {..._full, _sixth});
    expect(find.text(savedCapMessage), findsNothing);
  });

  testWidgets('an already-saved item still unsaves at the cap', (tester) async {
    // The bookmark must never go inert: the cap is checked on the add path
    // only, so giving something back is always allowed.
    final container = await pump(tester);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: SavedBookmarkButton(savedKey: 't:a', label: 'A'),
          ),
        ),
      ),
    );
    await settleLoaders(tester);

    await tester.tap(find.byType(IconButton));
    await settleLoaders(tester);

    expect(
      await container.read(savedKeysProvider.future),
      {'t:b', 't:c', 't:d', 't:e'},
    );
    expect(find.text(savedCapMessage), findsNothing);
  });
}
