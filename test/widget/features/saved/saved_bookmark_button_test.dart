import 'dart:ui' show Tristate;

import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/features/saved/domain/saved_key.dart';
import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/features/saved/presentation/saved_bookmark_button.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/find_mark.dart';
import '../../../support/widget_harness.dart';

const _key = 't:arabica';

Widget _wrap() => MaterialApp(
  theme: AppTheme.cupping,
  home: const Scaffold(
    body: SavedBookmarkButton(savedKey: _key, label: 'Arabica'),
  ),
);

void main() {
  setUp(useInMemoryDatabase);

  testWidgets('starts empty and fills when tapped', (tester) async {
    final container = await pumpWithProviders(tester, _wrap());

    expect(findMark(AppIcon.bookmark, active: false), findsOneWidget);

    await tester.tap(find.byType(IconButton));
    await settleLoaders(tester);

    expect(findMark(AppIcon.bookmark, active: true), findsOneWidget);
    expect(await container.read(savedKeysProvider.future), {_key});
  });

  testWidgets('empties again when tapped a second time', (tester) async {
    final container = await pumpWithProviders(tester, _wrap());

    await tester.tap(find.byType(IconButton));
    await settleLoaders(tester);
    await tester.tap(find.byType(IconButton));
    await settleLoaders(tester);

    expect(findMark(AppIcon.bookmark, active: false), findsOneWidget);
    expect(await container.read(savedKeysProvider.future), isEmpty);
  });

  testWidgets('announces its state rather than only drawing it', (
    tester,
  ) async {
    await pumpWithProviders(tester, _wrap());

    // `isSelected`, which is the flag a selectable `IconButton` publishes —
    // the point is that the state reaches a screen reader at all, not which
    // of the two state flags the framework picks for it.
    // One tristate carries both halves: `none` would mean the button has no
    // selected state to announce at all, which is the failure being guarded
    // against — a bookmark whose state is only a colour.
    final before = tester.getSemantics(find.byType(IconButton));
    expect(
      before.flagsCollection.isSelected,
      Tristate.isFalse,
      reason: 'an unsaved bookmark announces a state, and that state is off',
    );

    await tester.tap(find.byType(IconButton));
    await settleLoaders(tester);

    final after = tester.getSemantics(find.byType(IconButton));
    expect(after.flagsCollection.isSelected, Tristate.isTrue);
  });

  testWidgets('names what it saves, so two bookmarks are distinguishable', (
    tester,
  ) async {
    await pumpWithProviders(tester, _wrap());

    expect(find.byTooltip('Save Arabica'), findsOneWidget);

    await tester.tap(find.byType(IconButton));
    await settleLoaders(tester);

    expect(find.byTooltip('Remove Arabica from Saved'), findsOneWidget);
  });

  testWidgets('writes the key the grammar defines', (tester) async {
    final container = await pumpWithProviders(tester, _wrap());

    await toggleSaved(
      container.read(snapshotRepositoryProvider),
      key: formatSavedKey(SavedKind.term, 'arabica'),
      now: DateTime(2026, 8, 23),
      isPlus: false,
      visible: 0,
    );
    container.invalidate(savedKeysProvider);

    expect(
      await container.read(savedKeysProvider.future),
      {_key},
      reason: 'the grammar and the writer must agree on the stored spelling',
    );
  });
}
