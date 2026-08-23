import 'dart:io';

import 'package:brew_path/app/app.dart';
import 'package:brew_path/app/app_header.dart';
import 'package:brew_path/features/dictionary/presentation/term_detail_screen.dart';
import 'package:brew_path/features/profile/domain/settings_providers.dart';
import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/features/saved/presentation/saved_empty_view.dart';
import 'package:brew_path/features/saved/presentation/saved_screen.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/widget_harness.dart';

/// The shelf end to end: what was saved is still on it after a **real**
/// restart, and Reset — the one the Settings button runs — takes it away.
///
/// The database is a file that is closed and reopened between the write and
/// the app, so this asserts survival rather than only that no provider cached
/// the answer. #288 covers the same claim below the widget layer; this is the
/// half it could not reach, because the shelf did not exist yet.
void main() {
  late Directory dir;
  late File file;

  setUp(() async {
    await useInMemoryDatabase();
    dir = Directory.systemTemp.createTempSync('brewpath_shelf_');
    file = File('${dir.path}/progress.sqlite');
  });

  tearDown(() => dir.deleteSync(recursive: true));

  /// Writes [key] to a file-backed store, then **closes it** — so what the app
  /// opens next is the file, not a live handle.
  Future<void> saveThenClose(String key) async {
    final writing = AppDatabase(NativeDatabase(file));
    AppDatabaseService.instance = writing;
    await seedOnboarded(writing);
    await toggleSaved(
      SnapshotRepository(),
      key: key,
      now: DateTime(2026, 8, 23),
    );
    await writing.close();

    // The restart: a second database over the same bytes.
    final reopened = AppDatabase(NativeDatabase(file));
    AppDatabaseService.instance = reopened;
    addTearDown(reopened.close);
  }

  /// A real [WidgetRef] out of the mounted tree: a `ConsumerWidget`'s element
  /// *is* one, so this drives the app's own reset with the app's own ref
  /// rather than a container standing in for it.
  WidgetRef refFrom(WidgetTester tester) =>
      tester.element(find.byType(AppHeader)) as WidgetRef;

  /// The header's Saved entry, whose tooltip grows a count once the shelf holds
  /// something — so it is matched by prefix rather than exactly.
  Finder savedEntry() => find.byWidgetPredicate(
    (widget) =>
        widget is IconButton &&
        (widget.tooltip?.startsWith(SavedScreen.title) ?? false),
  );

  Future<void> openShelf(WidgetTester tester) async {
    await tester.tap(savedEntry());
    await settleLoaders(tester);
  }

  testWidgets('a term saved before the restart is on the shelf after it', (
    tester,
  ) async {
    await saveThenClose('t:arabica');

    await pumpWithProviders(tester, const BrewPathApp());
    await openShelf(tester);

    expect(find.text('Arabica'), findsOneWidget);
  });

  testWidgets('the header badge survives the restart too', (tester) async {
    await saveThenClose('t:arabica');

    await pumpWithProviders(tester, const BrewPathApp());

    expect(find.byTooltip('${SavedScreen.title}, 1 item'), findsOneWidget);
  });

  testWidgets('a term row opens the full entry', (tester) async {
    await saveThenClose('t:arabica');
    await pumpWithProviders(tester, const BrewPathApp());
    await openShelf(tester);

    await tester.tap(find.text('Arabica'));
    await settleLoaders(tester);

    expect(find.byType(TermDetailScreen), findsOneWidget);
  });

  testWidgets('Reset Progress empties the shelf and the badge', (
    tester,
  ) async {
    await saveThenClose('t:arabica');
    await pumpWithProviders(tester, const BrewPathApp());
    expect(find.byTooltip('${SavedScreen.title}, 1 item'), findsOneWidget);

    // The app's own reset path — the function the Settings button calls —
    // rather than a hand-rolled invalidation. Invalidating here would assert
    // the test's work rather than the app's, which is exactly how the missing
    // `savedKeysProvider` invalidation stayed hidden the first time.
    //
    // Driven from a tab root rather than by walking into Settings: leaving
    // Settings resumes the header's paused subscription and flushes the
    // invalidated chain during the transition's build, which the framework
    // asserts on. That is a real defect, filed separately — it is not what
    // this test is for, and reproducing it here would only hide this
    // assertion behind that one.
    await resetProgress(refFrom(tester));
    await settleLoaders(tester);

    expect(
      find.byTooltip('${SavedScreen.title}, 1 item'),
      findsNothing,
      reason: 'the shelf goes with the progress it recorded',
    );
    expect(
      savedEntry(),
      findsOneWidget,
      reason: 'the button stays; only the count goes',
    );

    await openShelf(tester);
    expect(find.byType(SavedEmptyView), findsOneWidget);
  });
}
