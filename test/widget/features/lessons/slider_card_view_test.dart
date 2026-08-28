import 'package:brew_path/features/lessons/presentation/cards/grinder_dial_view.dart';
import 'package:brew_path/features/lessons/presentation/cards/slider_card_view.dart';
import 'package:brew_path/features/lessons/presentation/cards/slider_dial.dart';
import 'package:brew_path/shared/models/content/content_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

/// A shipped grind round — the axis that draws the collar, with the answer at
/// the fine end and the handle resting well outside its band.
const _espressoGrind =
    ContentCard.slider(
          prompt: 'How fine should you grind for espresso?',
          leftLabel: 'FINER',
          rightLabel: 'COARSER',
          target: 28,
          tolerance: 11,
          scale: [
            'Powder — chokes the machine',
            'Fine — espresso',
            'Table salt — moka, AeroPress',
            'Sea salt — pour-over',
            'Breadcrumbs — French press',
          ],
          feedback: 'Espresso lives at the fine end, just above powder.',
        )
        as SliderCard;

/// A round on any other axis, which draws the track alone.
const _waterTemperature =
    ContentCard.slider(
          prompt: 'How hot should the brew water be?',
          leftLabel: 'COOLER',
          rightLabel: 'HOTTER',
          target: 72,
          tolerance: 13,
          scale: [
            'Below 80 °C — sour and flat',
            '85 °C — under-extracts easily',
            '90 °C — safe for dark roasts',
            '93–96 °C — just off the boil',
            'Rolling boil — scorches the bed',
          ],
          feedback: 'Just off the boil, around 93 to 96 °C.',
        )
        as SliderCard;

class _Signals {
  int solved = 0;
  int continued = 0;
}

/// Pumps the renderer with no host around it — the point of it living in the
/// shared card layer is that it needs none.
Future<void> _pumpCard(
  WidgetTester tester,
  SliderCard card,
  _Signals signals,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: SliderCardView(
            card: card,
            onSolved: () => signals.solved++,
            onContinue: () => signals.continued++,
          ),
        ),
      ),
    ),
  );
}

/// Drags the handle to [value] on the card's own scale.
Future<void> _dragTo(WidgetTester tester, double value) async {
  final rail = tester.getRect(find.byType(Slider));
  await tester.tapAt(
    Offset(rail.left + rail.width * (value / sliderTrackMax), rail.center.dy),
  );
  await tester.pump();
}

Future<void> _check(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(FilledButton, 'Check answer'));
  await tester.pump();
}

bool _continueEnabled(WidgetTester tester) =>
    tester
        .widget<FilledButton>(find.widgetWithText(FilledButton, 'Continue'))
        .onPressed !=
    null;

/// Every value the semantics tree currently speaks.
///
/// Collected from the tree rather than read off the `Slider`'s own node: the
/// value is set by a render object inside the widget, so asking the widget for
/// it finds the wrapper above and reads back a blank.
List<String> _spokenValues(WidgetTester tester) {
  final values = <String>[];
  void visit(SemanticsNode node) {
    if (node.value.isNotEmpty) values.add(node.value);
    node.visitChildren((child) {
      visit(child);
      return true;
    });
  }

  visit(tester.getSemantics(find.byType(SliderCardView)));
  return values;
}

void main() {
  testWidgets('opens with the prompt, the ends and the learner own setting', (
    tester,
  ) async {
    await _pumpCard(tester, _waterTemperature, _Signals());

    expect(find.text(_waterTemperature.prompt), findsOneWidget);
    expect(find.text('COOLER'), findsOneWidget);
    expect(find.text('HOTTER'), findsOneWidget);
    // The handle rests dead centre, so the readout names the middle band.
    expect(find.text('Your setting'), findsOneWidget);
    expect(find.text('90 °C — safe for dark roasts'), findsOneWidget);
  });

  testWidgets('nothing can be committed until the dial is moved', (
    tester,
  ) async {
    await _pumpCard(tester, _waterTemperature, _Signals());

    final gated = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Check answer'),
    );
    expect(
      gated.onPressed,
      isNull,
      reason: 'the resting value is not an answer the learner gave',
    );
  });

  testWidgets('a setting inside the band pays exactly one success signal', (
    tester,
  ) async {
    final signals = _Signals();
    await _pumpCard(tester, _waterTemperature, signals);

    await _dragTo(tester, 72);
    await _check(tester);

    expect(signals.solved, 1);
    expect(find.text('DIALED IN'), findsOneWidget);
    expect(find.text(_waterTemperature.feedback), findsOneWidget);
  });

  testWidgets('a setting outside it pays nothing and reacts in-card', (
    tester,
  ) async {
    final signals = _Signals();
    await _pumpCard(tester, _waterTemperature, signals);

    await _dragTo(tester, 10);
    await _check(tester);

    expect(signals.solved, 0);
    expect(find.text('NOT QUITE'), findsOneWidget);
    // The round still explains itself: being wrong is the whole consequence.
    expect(find.text(_waterTemperature.feedback), findsOneWidget);
  });

  testWidgets('the answer latches — the rail freezes and cannot re-score', (
    tester,
  ) async {
    final signals = _Signals();
    await _pumpCard(tester, _waterTemperature, signals);

    await _dragTo(tester, 10);
    await _check(tester);
    // A second run at it: drag onto the answer and look for a way to commit.
    await _dragTo(tester, 72);

    expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNull);
    expect(find.text('Check answer'), findsNothing);
    expect(signals.solved, 0);
  });

  testWidgets('continue is gated on the commit, not on being right', (
    tester,
  ) async {
    final signals = _Signals();
    await _pumpCard(tester, _waterTemperature, signals);

    // The shell swaps one button rather than drawing two, so before the commit
    // there is no way forward at all.
    expect(find.widgetWithText(FilledButton, 'Continue'), findsNothing);

    await _dragTo(tester, 10);
    await _check(tester);

    expect(_continueEnabled(tester), isTrue);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));

    expect(
      signals.continued,
      1,
      reason: 'moving on is moving on, whatever the learner scored',
    );
  });

  testWidgets('the commit swaps the readout to the target it was graded on', (
    tester,
  ) async {
    await _pumpCard(tester, _waterTemperature, _Signals());

    await _dragTo(tester, 10);
    await _check(tester);

    expect(find.text('Your setting'), findsNothing);
    expect(find.text('Target'), findsOneWidget);
    expect(find.text('93–96 °C — just off the boil'), findsOneWidget);
  });

  testWidgets('the grind axis draws the collar and no other axis does', (
    tester,
  ) async {
    await _pumpCard(tester, _espressoGrind, _Signals());
    expect(find.byType(GrinderDialView), findsOneWidget);

    await _pumpCard(tester, _waterTemperature, _Signals());
    expect(find.byType(GrinderDialView), findsNothing);
  });

  testWidgets('the verdict is announced, and the setting is spoken as a band', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _pumpCard(tester, _waterTemperature, _Signals());

    expect(
      _spokenValues(tester),
      contains('90 °C — safe for dark roasts'),
      reason: 'a raw 50 tells a learner who cannot see the scale nothing',
    );

    await _dragTo(tester, 72);
    await _check(tester);

    expect(find.bySemanticsLabel('DIALED IN'), findsOneWidget);
    handle.dispose();
  });
}
