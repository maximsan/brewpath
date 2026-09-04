import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/path/presentation/visual_guide_sheet.dart';
import 'package:brew_path/shared/models/content/visual_guide.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/widget_harness.dart';

/// What a guide's entry shows once opened.
///
/// The prose is the part worth pinning. Guides shipped for a while with their
/// fact and none of the sentences explaining their levels, which reads as a
/// legend rather than a reference — the words existed the whole time, inside
/// markup the extractor could not reach.
VisualGuide _guide({List<VisualGuideNote> notes = const [], String? note}) =>
    VisualGuide(
      id: 'g-roast',
      subject: 'roast',
      unlock: const VisualGuideUnlock(lesson: 'm3l1'),
      label: 'ROAST',
      title: 'Roast Levels',
      summary: 'Light to dark: how the roast shifts taste.',
      fact: 'There is no best roast.',
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

  testWidgets('each level is shown with the sentence that explains it', (
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

  testWidgets('a level is named once, beside its own sentence', (
    tester,
  ) async {
    await _open(
      tester,
      _guide(
        notes: const [
          VisualGuideNote(term: 'Light', detail: 'Acidic and fruity.'),
        ],
      ),
    );

    // The level's name is set in smallcaps, which upper-cases the text.
    expect(find.text('LIGHT'), findsOneWidget);
    final termY = tester.getTopLeft(find.text('LIGHT')).dy;
    final detailY = tester.getTopLeft(find.text('Acidic and fruity.')).dy;
    expect(
      detailY,
      greaterThanOrEqualTo(termY),
      reason: 'the sentence sits in the same row as the level it explains',
    );
  });

  testWidgets('levels are shown in the order the design lists them', (
    tester,
  ) async {
    await _open(
      tester,
      _guide(
        notes: const [
          VisualGuideNote(term: 'Dark', detail: 'Heavier and bolder.'),
          VisualGuideNote(term: 'Light', detail: 'Acidic and fruity.'),
        ],
      ),
    );

    final darkY = tester.getTopLeft(find.text('Heavier and bolder.')).dy;
    final lightY = tester.getTopLeft(find.text('Acidic and fruity.')).dy;
    expect(darkY, lessThan(lightY), reason: 'authored order is drawn order');
  });

  testWidgets('a closing thought is shown when the guide has one', (
    tester,
  ) async {
    const closing =
        'Ratio changes strength first — a bad cup is usually a grind problem.';
    await _open(tester, _guide(note: closing));

    expect(find.text(closing), findsOneWidget);
  });

  testWidgets('a guide whose drawing is the reference shows summary and fact', (
    tester,
  ) async {
    // Anatomy carries neither level notes nor a closing thought: its
    // cross-section is the explanation, so their absence is correct rather
    // than missing, and the sheet is the summary, the drawing and the fact.
    await _open(tester, _guide());

    expect(
      find.text('Light to dark: how the roast shifts taste.'),
      findsOneWidget,
    );
    expect(find.text('There is no best roast.'), findsOneWidget);
    expect(
      find.byType(SmallcapsLabel),
      findsOneWidget,
      reason: 'the kind label only',
    );
  });
}
