import 'package:brew_path/features/lessons/presentation/cards/practical_card_view.dart';
import 'package:brew_path/shared/models/content/content_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A card as the course authors them — every authored `practical` carries a
/// tag, two paragraphs and a note.
const _brewStep =
    ContentCard.practical(
          tag: 'STEP 1',
          title: 'Weigh the coffee',
          paragraphs: [
            'Put the cup on the scale and zero it.',
            'Add coffee until the scale reads what the recipe asks.',
          ],
          note: 'Weigh the water too, not just the coffee.',
        )
        as PracticalCard;

/// The prototype defaults the eyebrow when a card carries no tag. Nothing
/// authored does, so this shape only ever arrives from content that omits it.
const _untagged =
    ContentCard.practical(
          tag: '',
          title: 'Rinse the filter',
          paragraphs: ['Run hot water through the paper before you brew.'],
          note: '',
        )
        as PracticalCard;

void main() {
  Widget wrap(PracticalCard card, {VoidCallback? onContinue}) => MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: PracticalCardView(
          card: card,
          onContinue: onContinue ?? () {},
        ),
      ),
    ),
  );

  testWidgets('shows the tag, the title and every paragraph', (tester) async {
    await tester.pumpWidget(wrap(_brewStep));

    expect(find.text('STEP 1'), findsOneWidget);
    expect(find.text('Weigh the coffee'), findsOneWidget);
    for (final paragraph in _brewStep.paragraphs) {
      expect(find.text(paragraph), findsOneWidget);
    }
  });

  testWidgets('a card with no tag still names itself', (tester) async {
    await tester.pumpWidget(wrap(_untagged));

    expect(
      find.text('HANDS ON'),
      findsOneWidget,
      reason: 'an untagged card falls back rather than showing a blank eyebrow',
    );
  });

  testWidgets('the note is shown, and says what it is', (tester) async {
    await tester.pumpWidget(wrap(_brewStep));

    // The design sets the label in small caps, as it does every card label.
    expect(find.text('WORTH KNOWING'), findsOneWidget);
    expect(find.text(_brewStep.note), findsOneWidget);
  });

  testWidgets('the note is read as one thing, not a label and a stray line', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(wrap(_brewStep));

    expect(
      find.bySemanticsLabel('Worth knowing. ${_brewStep.note}'),
      findsOneWidget,
      reason: 'a bare label followed by an unattached sentence reads as two',
    );
    handle.dispose();
  });

  testWidgets('the step is named in the accent, with the mark beside it', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(_brewStep));

    expect(
      find.byIcon(Icons.tune),
      findsOneWidget,
      reason: 'the design marks a hands-on card before it names the step',
    );
  });

  testWidgets('a card with no note shows no takeaway at all', (tester) async {
    await tester.pumpWidget(wrap(_untagged));

    expect(
      find.text('WORTH KNOWING'),
      findsNothing,
      reason: 'an empty note must not leave a labelled, empty block behind',
    );
  });

  testWidgets('continue is live on arrival — nothing here is answered', (
    tester,
  ) async {
    var continued = false;
    await tester.pumpWidget(
      wrap(_brewStep, onContinue: () => continued = true),
    );

    await tester.tap(find.text('Continue'));
    expect(
      continued,
      isTrue,
      reason: 'a hands-on card is read, not asked — it latches on arrival',
    );
  });
}
