import 'package:brew_path/app/app.dart';
import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/features/saved/presentation/saved_empty_view.dart';
import 'package:brew_path/features/saved/presentation/saved_screen.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:flutter/material.dart' show IconButton;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/widget_harness.dart';

/// The shelf end to end: what was saved is still on it after the app is built
/// again, and Reset takes it away.
///
/// The restart here is a **fresh app over the same store** — new widget tree,
/// new providers, the database untouched. #288 covers the bytes-on-disk half
/// with a real close-and-reopen; this is the half that ticket could not reach,
/// because the shelf did not exist yet.
void main() {
  setUp(useInMemoryDatabase);

  Future<void> save(String key) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await toggleSaved(
      container.read(snapshotRepositoryProvider),
      key: key,
      now: DateTime(2026, 8, 23),
    );
  }

  /// The header's Saved entry, whose tooltip grows a count once the shelf has
  /// something on it — so it is matched by prefix rather than exactly.
  Finder savedEntry() => find.byWidgetPredicate(
    (widget) =>
        widget is IconButton &&
        (widget.tooltip?.startsWith(SavedScreen.title) ?? false),
  );

  Future<void> openShelf(WidgetTester tester) async {
    await tester.tap(savedEntry());
    await settleLoaders(tester);
  }

  testWidgets('a term saved before the app started is on the shelf', (
    tester,
  ) async {
    await save('t:arabica');

    await pumpWithProviders(tester, const BrewPathApp());
    await openShelf(tester);

    expect(find.text('Arabica'), findsOneWidget);
  });

  testWidgets('the header shows the badge for what was saved earlier', (
    tester,
  ) async {
    await save('t:arabica');

    await pumpWithProviders(tester, const BrewPathApp());

    expect(find.byTooltip('${SavedScreen.title}, 1 item'), findsOneWidget);
  });

  testWidgets('Reset Progress empties the shelf', (tester) async {
    await save('t:arabica');
    final container = await pumpWithProviders(tester, const BrewPathApp());

    await container.read(accountWipeProvider).resetProgress();
    container.invalidate(savedKeysProvider);
    await settleLoaders(tester);

    await openShelf(tester);
    expect(find.byType(SavedEmptyView), findsOneWidget);
  });

  testWidgets('Reset Progress clears the header badge too', (tester) async {
    await save('t:arabica');
    final container = await pumpWithProviders(tester, const BrewPathApp());

    await container.read(accountWipeProvider).resetProgress();
    container.invalidate(savedKeysProvider);
    await settleLoaders(tester);

    expect(
      savedEntry(),
      findsOneWidget,
      reason: 'the button stays; only the count goes',
    );
    expect(find.byTooltip('${SavedScreen.title}, 1 item'), findsNothing);
  });
}
