import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/widgets/visual_guide_art.dart';
import 'package:brew_path/features/lessons/presentation/cards/visual_card_view.dart';
import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/shared/models/content/content_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/find_mark.dart';
import '../../../support/widget_harness.dart';

/// The anatomy card, the one authored card that lifts its caption.
const _anatomy =
    ContentCard.visual(
          label: 'VISUAL GUIDE',
          title: 'Six layers, outside in',
          subject: 'anatomy',
          caption: 'The seed you brew is the last of six.',
          captionTop: true,
        )
        as VisualCard;

/// A card that leaves its caption under the drawing, as most authored ones do.
const _roast =
    ContentCard.visual(
          label: 'VISUAL GUIDE',
          title: 'Light to dark',
          subject: 'roast',
          caption: 'Roast moves taste before you brew a thing.',
        )
        as VisualCard;

void main() {
  setUp(useInMemoryDatabase);

  Widget wrap(VisualCard card, {VoidCallback? onContinue}) => MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: VisualCardView(
          card: card,
          onContinue: onContinue ?? () {},
        ),
      ),
    ),
  );

  testWidgets('renders the card, its drawing and its caption', (tester) async {
    await pumpWithProviders(tester, wrap(_roast));
    await settleLoaders(tester);

    expect(find.text('Light to dark'), findsOneWidget);
    expect(find.text(_roast.caption), findsOneWidget);
    expect(find.byType(VisualGuideArt), findsOneWidget);
  });

  testWidgets('the drawing is asked for at its full size', (tester) async {
    await pumpWithProviders(tester, wrap(_roast));
    await settleLoaders(tester);

    final art = tester.widget<VisualGuideArt>(find.byType(VisualGuideArt));
    expect(art.subject, 'roast');
    expect(
      art.size,
      VisualGuideArtSize.full,
      reason: 'the thumbnail size belongs beside a Reference row',
    );
  });

  testWidgets('the framed block is the drawing and nothing else', (
    tester,
  ) async {
    await pumpWithProviders(tester, wrap(_roast));
    await settleLoaders(tester);

    expect(find.text('Light to dark'), findsOneWidget);
    expect(
      find.text('Roast Levels'),
      findsNothing,
      reason: 'the card states the kind and title above the frame already',
    );
    expect(
      find.text('VISUAL GUIDE'),
      findsOneWidget,
      reason: 'the kind is said once, by the card, not again inside the frame',
    );
  });

  testWidgets('captionTop puts the caption above the drawing', (tester) async {
    await pumpWithProviders(tester, wrap(_anatomy));
    await settleLoaders(tester);

    final caption = tester.getTopLeft(find.text(_anatomy.caption)).dy;
    final art = tester.getTopLeft(find.byType(VisualGuideArt)).dy;
    expect(caption, lessThan(art));
  });

  testWidgets('without the flag the caption follows the drawing', (
    tester,
  ) async {
    await pumpWithProviders(tester, wrap(_roast));
    await settleLoaders(tester);

    final caption = tester.getTopLeft(find.text(_roast.caption)).dy;
    final art = tester.getTopLeft(find.byType(VisualGuideArt)).dy;
    expect(caption, greaterThan(art));
  });

  testWidgets('continue is live on arrival — nothing here is answered', (
    tester,
  ) async {
    var continued = false;
    await pumpWithProviders(
      tester,
      wrap(_roast, onContinue: () => continued = true),
    );
    await settleLoaders(tester);

    await tester.tap(find.text('Continue'));
    expect(
      continued,
      isTrue,
      reason: 'a reference is shown, not asked — it latches on arrival',
    );
  });

  testWidgets('the guide can be kept from the lesson that teaches it', (
    tester,
  ) async {
    final container = await pumpWithProviders(tester, wrap(_roast));
    await settleLoaders(tester);

    await tester.tap(find.text('SAVE THIS GUIDE'));
    await settleLoaders(tester);

    expect(
      await container.read(savedKeysProvider.future),
      {'g:roast'},
      reason:
          'the card and the sheet write one key, so saving in either place '
          'is the same act — and it is the subject, never the id',
    );
  });

  testWidgets('the save control is worded here, and says where it went', (
    tester,
  ) async {
    await pumpWithProviders(tester, wrap(_roast));
    await settleLoaders(tester);

    expect(find.text('SAVE THIS GUIDE'), findsOneWidget);
    expect(findMark(AppIcon.bookmark), findsOneWidget);

    await tester.tap(find.text('SAVE THIS GUIDE'));
    await settleLoaders(tester);

    expect(
      find.text('SAVED — REVIEW ANYTIME IN SAVED'),
      findsOneWidget,
      reason: 'the words are the confirmation — they name the shelf it is on',
    );
  });

  testWidgets('the drawing is kept out of the semantics tree', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpWithProviders(tester, wrap(_roast));
    await settleLoaders(tester);

    expect(
      find.bySemanticsLabel('roast'),
      findsNothing,
      reason: 'an unlabelled shape read aloud is worse than none',
    );
    handle.dispose();
  });
}
