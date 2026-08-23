import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/features/path/presentation/visual_guide_sheet.dart';
import 'package:brew_path/shared/models/content/visual_guide.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/widget_harness.dart';

/// What a guide's entry shows once opened.
///
/// The prose is the part worth pinning. Guides shipped for a while with their
/// table and their fact and none of the sentences explaining them, which reads
/// as a legend rather than a reference — the words existed the whole time,
/// inside markup the extractor could not reach.
VisualGuide _guide({List<VisualGuideNote> notes = const [], String? note}) =>
    VisualGuide(
      id: 'g-roast',
      subject: 'roast',
      unlock: const VisualGuideUnlock(lesson: 'm3l1'),
      label: 'ROAST',
      title: 'Roast Levels',
      summary: 'Light to dark: how the roast shifts taste.',
      fact: 'There is no best roast.',
      meta: const [
        ['LIGHT', 'Bright · acidic'],
        ['DARK', 'Bitter · smoky'],
      ],
      notes: notes,
      note: note,
    );

/// Pumped under a real provider scope and an in-memory database, because the
/// sheet's header carries a `SavedBookmarkButton` — a Riverpod consumer that
/// reads the saved shelf. The body is otherwise pure presentation; the scope is
/// here for that one child, and the bookmark's own behaviour is covered by its
/// own test rather than re-asserted here.
Future<void> _open(WidgetTester tester, VisualGuide guide) async {
  await pumpWithProviders(
    tester,
    MaterialApp(
      theme: AppTheme.darkRoast,
      home: Scaffold(body: VisualGuideSheetBody(guide: guide)),
    ),
  );
}

void main() {
  setUp(useInMemoryDatabase);

  testWidgets('a table row carries the sentence that explains it', (
    tester,
  ) async {
    await _open(
      tester,
      _guide(
        notes: const [
          VisualGuideNote(
            term: 'Light',
            detail: 'Acidic and fruity. Can taste sharp if under-extracted.',
          ),
          VisualGuideNote(
            term: 'Dark',
            detail: 'Heavier and bolder. Turns harsh easily.',
          ),
        ],
      ),
    );

    expect(
      find.text('Acidic and fruity. Can taste sharp if under-extracted.'),
      findsOneWidget,
    );
    expect(
      find.text('Heavier and bolder. Turns harsh easily.'),
      findsOneWidget,
    );
  });

  testWidgets('the term is named once, not once per column', (tester) async {
    await _open(
      tester,
      _guide(
        notes: const [
          VisualGuideNote(term: 'Light', detail: 'Acidic and fruity.'),
        ],
      ),
    );

    // The gloss joins the row it belongs to, so the table is not shadowed by a
    // second list repeating every label.
    expect(find.text('LIGHT'), findsOneWidget);
  });

  testWidgets('the gloss sits under the value it qualifies', (tester) async {
    await _open(
      tester,
      _guide(
        notes: const [
          VisualGuideNote(term: 'Light', detail: 'Acidic and fruity.'),
        ],
      ),
    );

    final valueY = tester.getTopLeft(find.text('Bright · acidic')).dy;
    final glossY = tester.getTopLeft(find.text('Acidic and fruity.')).dy;
    expect(glossY, greaterThan(valueY));
  });

  testWidgets('a gloss is matched by name, not by position', (tester) async {
    // Authored in the opposite order to the table, which is legal: the two
    // sides live in different registries and nothing orders them together.
    await _open(
      tester,
      _guide(
        notes: const [
          VisualGuideNote(term: 'Dark', detail: 'Heavier and bolder.'),
          VisualGuideNote(term: 'Light', detail: 'Acidic and fruity.'),
        ],
      ),
    );

    final lightY = tester.getTopLeft(find.text('Acidic and fruity.')).dy;
    final darkY = tester.getTopLeft(find.text('Heavier and bolder.')).dy;
    expect(
      lightY,
      lessThan(darkY),
      reason: 'each gloss should follow its own row, not the authored order',
    );
  });

  testWidgets('a closing thought is shown when the guide has one', (
    tester,
  ) async {
    const closing =
        'Ratio changes strength first — a bad cup is usually a grind problem.';
    await _open(tester, _guide(note: closing));

    expect(find.text(closing), findsOneWidget);
  });

  testWidgets('a guide whose drawing is the reference shows only its table', (
    tester,
  ) async {
    // Anatomy carries neither gloss nor closing thought: its cross-section is
    // the explanation, so their absence is correct rather than missing.
    await _open(tester, _guide());

    expect(find.text('Bright · acidic'), findsOneWidget);
    expect(find.text('There is no best roast.'), findsOneWidget);
  });
}
