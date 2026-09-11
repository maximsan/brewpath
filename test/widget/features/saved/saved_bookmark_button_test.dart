import 'dart:ui' show Tristate;

import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/features/saved/domain/saved_key.dart';
import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/features/saved/presentation/saved_bookmark_button.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/find_mark.dart';
import '../../../support/widget_harness.dart';

const _key = 't:arabica';

Widget _wrap({bool ringed = false}) => MaterialApp(
  theme: AppTheme.cupping,
  home: Scaffold(
    body: SavedBookmarkButton(savedKey: _key, label: 'Arabica', ringed: ringed),
  ),
);

OutlinedBorder _shapeOf(WidgetTester tester) => tester
    .widget<IconButton>(find.byType(IconButton))
    .style!
    .shape!
    .resolve({})!;

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

  testWidgets("in a top bar it wears the design's ring", (tester) async {
    await pumpWithProviders(tester, _wrap(ringed: true));
    const mood = MoodColors.cupping;

    final unsaved = _shapeOf(tester) as RoundedRectangleBorder;
    expect(unsaved.side.color, mood.rule);
    expect(
      tester.widget<IconMark>(find.byType(IconMark)).size,
      16,
      reason: 'the design sets the ringed mark at size={16}',
    );
    expect(tester.getSize(find.byType(IconButton)), const Size(32, 32));

    await tester.tap(find.byType(IconButton));
    await settleLoaders(tester);

    final saved = _shapeOf(tester) as RoundedRectangleBorder;
    expect(
      saved.side.color,
      mood.accent,
      reason: 'the ring turns accent once saved',
    );
  });

  testWidgets('elsewhere it stays bare', (tester) async {
    await pumpWithProviders(tester, _wrap());
    final style = tester.widget<IconButton>(find.byType(IconButton)).style!;
    expect(style.shape, isNull);
  });
}
