import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/widgets/fill_slot.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mood = MoodColors.darkRoast;

  Future<void> pump(WidgetTester tester, Widget slot) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.darkRoast,
      home: Scaffold(body: Center(child: slot)),
    ),
  );

  Text textOf(WidgetTester tester) => tester.widget<Text>(find.byType(Text));

  BoxDecoration decorationOf(WidgetTester tester) =>
      tester.widget<Container>(find.byType(Container)).decoration!
          as BoxDecoration;

  testWidgets('a right answer is named in the learned colour', (tester) async {
    await pump(
      tester,
      const FillSlot(word: 'Seed', state: FillSlotState.right),
    );

    expect(find.text('Seed'), findsOneWidget);
    expect(textOf(tester).style?.color, mood.sage);
    expect(decorationOf(tester).border?.bottom.color, mood.sage);
  });

  testWidgets('a wrong answer is named in the alert colour', (tester) async {
    await pump(
      tester,
      const FillSlot(word: 'Skin', state: FillSlotState.wrong),
    );

    expect(textOf(tester).style?.color, mood.berry);
    expect(decorationOf(tester).border?.bottom.color, mood.berry);
  });

  testWidgets('the word is set in mono, so a slot reads as a slot', (
    tester,
  ) async {
    await pump(
      tester,
      const FillSlot(word: 'Seed', state: FillSlotState.right),
    );

    expect(textOf(tester).style?.fontFamily, AppFace.mono.family);
  });

  testWidgets('a slot keeps the sentence face when it inherits', (
    tester,
  ) async {
    await pump(
      tester,
      const FillSlot(
        word: 'Seed',
        state: FillSlotState.right,
        inherit: true,
      ),
    );

    expect(
      textOf(tester).style?.fontFamily,
      isNot(AppFace.mono.family),
      reason: 'inside display type the slot keeps the sentence it sits in',
    );
  });

  testWidgets('a short word still holds the slot open', (tester) async {
    await pump(tester, const FillSlot(word: 'Oil', state: FillSlotState.right));

    expect(
      tester.getSize(find.byType(Container)).width,
      greaterThanOrEqualTo(FillSlot.minWidth),
      reason: 'the design pins a minimum so slots do not jitter between words',
    );
  });
}
