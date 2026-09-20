// What the row under the deck gives each control: a collapsed one nothing,
// a standing one its share — so Finish has the whole row on the last card.
import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/features/dictionary/presentation/flashcard_deck_controls.dart';
import 'package:brew_path/features/dictionary/presentation/flashcards_copy.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const double _rowWidth = 400;

Future<void> _pump(
  WidgetTester tester, {
  required bool isOnFirst,
  required bool isOnLast,
}) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.cupping,
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: _rowWidth,
          child: FlashcardDeckControls(
            isOnFirst: isOnFirst,
            isOnLast: isOnLast,
            onPrevious: () {},
            onNext: () {},
          ),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('Finish has the whole row on the last card', (tester) async {
    await _pump(tester, isOnFirst: false, isOnLast: true);

    final finish = tester.getRect(
      find.ancestor(
        of: find.text(FlashcardsCopy.finish),
        matching: find.byType(PrimaryButton),
      ),
    );
    // All but the collapsed way back's own hairline and the gap beside it.
    const collapsed = 1 + AppSpacing.xs;
    expect(
      finish.width,
      moreOrLessEquals(_rowWidth - collapsed, epsilon: 1),
      reason: 'the collapsed way back takes no share of the row',
    );
  });

  testWidgets('a control given focus stands up and takes its share', (
    tester,
  ) async {
    await _pump(tester, isOnFirst: false, isOnLast: true);

    // The first focusable in traversal order is the way back.
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();

    final previous = tester.getRect(
      find.ancestor(
        of: find.text(FlashcardsCopy.previousCard),
        matching: find.byType(OutlinedButton),
      ),
    );
    expect(previous.height, FlashcardDeckControls.revealedHeight);
    expect(
      previous.width,
      greaterThan(_rowWidth / 3),
      reason: "the design's `flex: 1` beside Finish",
    );
    expect(
      tester.getRect(find.text(FlashcardsCopy.finish)).center.dx,
      greaterThan(_rowWidth / 2),
      reason: 'Finish moves over to share the row',
    );
  });
}
