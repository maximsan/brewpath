import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/features/monetization/domain/course_entitlement.dart';
import 'package:brew_path/features/monetization/domain/plus_copy.dart';
import 'package:brew_path/features/monetization/domain/plus_gate_trigger.dart';
import 'package:brew_path/features/saved/domain/saved_cap.dart';
import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/features/saved/presentation/saved_bookmark_button.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/find_mark.dart';
import '../../../support/widget_harness.dart';

/// A full free shelf — **real** term ids, because the cap judges the rows the
/// shelf would draw. Keys that resolve to nothing are not rows, so a shelf of
/// invented ids is an empty shelf and would never be full.
const _full = ['t:arabica', 't:robusta', 't:cultivar', 't:typica', 't:bloom'];
const _sixth = 't:crema';

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
    expect(findMark(AppIcon.bookmark, active: false), findsOneWidget);
    // The refusal is the Plus gate now, not a snackbar.
    expect(find.text(PlusCopy.title), findsOneWidget);
  });

  testWidgets('the refusal names the cap and offers Plus', (tester) async {
    await pump(tester);

    await tester.tap(find.byType(IconButton));
    await settleLoaders(tester);

    // An offer, not an error: the sheet opens on what was hit, and names the
    // cap that stopped them.
    expect(
      find.text(const SavedShelfFull(cap: savedFreeMax).header),
      findsOneWidget,
    );
    expect(find.text(PlusCopy.buy), findsOneWidget);
  });

  testWidgets('with Plus the sixth save takes', (tester) async {
    final container = await pump(tester, isPlus: true);

    await tester.tap(find.byType(IconButton));
    await settleLoaders(tester);

    expect(await container.read(savedKeysProvider.future), {..._full, _sixth});
    expect(find.text(PlusCopy.title), findsNothing);
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
            body: SavedBookmarkButton(savedKey: 't:arabica', label: 'Arabica'),
          ),
        ),
      ),
    );
    await settleLoaders(tester);

    await tester.tap(find.byType(IconButton));
    await settleLoaders(tester);

    expect(
      await container.read(savedKeysProvider.future),
      {'t:robusta', 't:cultivar', 't:typica', 't:bloom'},
    );
    expect(find.text(PlusCopy.title), findsNothing);
  });
}
