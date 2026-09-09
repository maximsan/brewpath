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

  Text textOf(WidgetTester tester) => tester.widget<Text>(
    find.descendant(of: find.byType(FillSlot), matching: find.byType(Text)),
  );

  Color? ruleOf(WidgetTester tester) {
    final box = tester
        .widgetList<Container>(find.byType(Container))
        .firstWhere((container) => container.decoration != null);
    return (box.decoration! as BoxDecoration).border?.bottom.color;
  }

  bool paintsItsOwnRule(WidgetTester tester) => tester
      .widgetList<CustomPaint>(
        find.descendant(
          of: find.byType(FillSlot),
          matching: find.byType(CustomPaint),
        ),
      )
      .any((paint) => paint.foregroundPainter != null);

  group('the five states the design draws', () {
    testWidgets('empty waits in muted ink, under a rule it draws itself', (
      tester,
    ) async {
      await pump(tester, const FillSlot(state: FillSlotState.empty));

      expect(textOf(tester).style?.color, mood.inkMute);
      expect(
        paintsItsOwnRule(tester),
        isTrue,
        reason: 'the empty rule is dashed, and Border has no dash',
      );
    });

    testWidgets('filled locks in full ink', (tester) async {
      await pump(
        tester,
        const FillSlot(word: 'seed', state: FillSlotState.filled),
      );

      expect(textOf(tester).style?.color, mood.ink);
      expect(paintsItsOwnRule(tester), isFalse, reason: 'solid from here on');
    });

    testWidgets('a guess takes the accent — a claim, not a verdict', (
      tester,
    ) async {
      await pump(
        tester,
        const FillSlot(word: 'Skin', state: FillSlotState.guess),
      );

      expect(textOf(tester).style?.color, mood.accent);
      expect(ruleOf(tester), mood.accent);
    });

    testWidgets('right is named in the learned colour', (tester) async {
      await pump(
        tester,
        const FillSlot(word: 'seed', state: FillSlotState.right),
      );

      expect(textOf(tester).style?.color, mood.sage);
      expect(ruleOf(tester), mood.sage);
    });

    testWidgets('wrong is named in the alert colour', (tester) async {
      await pump(
        tester,
        const FillSlot(word: 'skin', state: FillSlotState.wrong),
      );

      expect(textOf(tester).style?.color, mood.berry);
      expect(ruleOf(tester), mood.berry);
    });
  });

  testWidgets('an empty slot holds its height with no word in it', (
    tester,
  ) async {
    await pump(tester, const FillSlot(state: FillSlotState.empty));
    final empty = tester.getSize(find.byType(FillSlot)).height;

    await pump(
      tester,
      const FillSlot(word: 'seed', state: FillSlotState.filled),
    );

    expect(
      tester.getSize(find.byType(FillSlot)).height,
      empty,
      reason: 'a sentence must not reflow as a word lands in the slot',
    );
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
      tester.getSize(find.byType(FillSlot)).width,
      greaterThanOrEqualTo(74.0),
      reason: 'the design pins a minimum so slots do not jitter between words',
    );
  });
}
