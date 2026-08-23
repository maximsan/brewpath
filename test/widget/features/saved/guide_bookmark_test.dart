import 'dart:ui' show Tristate;

import 'package:brew_path/features/path/presentation/visual_guide_sheet.dart';
import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/shared/models/content/visual_guide.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/widget_harness.dart';

/// A guide carries **both** an id and a subject, and they differ — which is
/// exactly the confusion the `g:` key has to get right.
const _roast = VisualGuide(
  id: 'g-roast',
  subject: 'roast',
  unlock: VisualGuideUnlock(lesson: 'm3l1'),
  label: 'VISUAL GUIDE',
  title: 'Roast Levels',
  summary: 'What the colour tells you.',
  fact: 'Darker is not stronger.',
);

Widget _wrap() => const MaterialApp(
  home: Scaffold(body: VisualGuideSheetBody(guide: _roast)),
);

void main() {
  setUp(useInMemoryDatabase);

  Finder bookmark() => find.ancestor(
    of: find.byIcon(Icons.bookmark_outline),
    matching: find.byType(IconButton),
  );

  testWidgets('a guide can be bookmarked from its sheet', (tester) async {
    await pumpWithProviders(tester, _wrap());

    expect(find.byTooltip('Save ${_roast.title}'), findsOneWidget);
  });

  testWidgets('the key is the guide subject, not its id', (tester) async {
    final container = await pumpWithProviders(tester, _wrap());

    await tester.tap(bookmark());
    await settleLoaders(tester);

    expect(
      await container.read(savedKeysProvider.future),
      {'g:roast'},
      reason:
          'keying by id would write g:g-roast and resolve to nothing, '
          'silently — #60 settled the referent as the subject',
    );
  });

  testWidgets('the bookmark announces its state', (tester) async {
    await pumpWithProviders(tester, _wrap());

    expect(
      tester.getSemantics(bookmark()).flagsCollection.isSelected,
      Tristate.isFalse,
    );

    await tester.tap(bookmark());
    await settleLoaders(tester);

    expect(
      tester
          .getSemantics(
            find.ancestor(
              of: find.byIcon(Icons.bookmark),
              matching: find.byType(IconButton),
            ),
          )
          .flagsCollection
          .isSelected,
      Tristate.isTrue,
    );
  });

  testWidgets('tapping again takes it off', (tester) async {
    final container = await pumpWithProviders(tester, _wrap());

    await tester.tap(bookmark());
    await settleLoaders(tester);
    await tester.tap(find.byIcon(Icons.bookmark));
    await settleLoaders(tester);

    expect(await container.read(savedKeysProvider.future), isEmpty);
  });

  testWidgets('the sheet still shows what it is for', (tester) async {
    // The bookmark shares its row with the kind label; neither displaces the
    // other.
    await pumpWithProviders(tester, _wrap());

    expect(find.text('VISUAL GUIDE'), findsOneWidget);
    expect(find.text(_roast.summary), findsOneWidget);
  });
}
