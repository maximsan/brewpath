import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/widgets/app_text_field.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The design's single-line field: a `--surface` well inside a 1px hairline
/// that takes `--accent` while focused, `border-radius: 12`, and nothing else
/// — no floating label, no helper row, no counter, no underline.
///
/// Each of those is something Material's `InputDecoration` draws by default,
/// so they are asserted absent rather than assumed: the whole reason this is
/// not a decorated `TextField` is that they have to be switched off.
BoxDecoration _well(WidgetTester tester) {
  final boxes = tester.widgetList<DecoratedBox>(
    find.descendant(
      of: find.byType(AppTextField),
      matching: find.byType(DecoratedBox),
    ),
  );
  return boxes
      .map((box) => box.decoration)
      .whereType<BoxDecoration>()
      .firstWhere((decoration) => decoration.border != null);
}

void main() {
  Future<void> pump(
    WidgetTester tester, {
    ThemeData? theme,
    int? maxLength,
    bool disableAnimations = false,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: theme ?? AppTheme.darkRoast,
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: Scaffold(
          body: AppTextField(
            placeholder: 'Your first name',
            maxLength: maxLength,
            onChanged: (_) {},
          ),
        ),
      ),
    ),
  );

  testWidgets('rests as a surface well on a rule hairline', (tester) async {
    await pump(tester);

    final decoration = _well(tester);
    expect(decoration.color, MoodColors.darkRoast.surface);
    expect(decoration.border!.top.color, MoodColors.darkRoast.rule);
  });

  testWidgets('takes the accent while focused, and gives it back', (
    tester,
  ) async {
    await pump(tester);

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    expect(_well(tester).border!.top.color, MoodColors.darkRoast.accent);

    // Unfocus by handing focus to nothing — the field is the only node.
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    expect(_well(tester).border!.top.color, MoodColors.darkRoast.rule);
  });

  testWidgets('follows the mood it is rendered in', (tester) async {
    await pump(tester, theme: AppTheme.cupping);

    expect(_well(tester).color, MoodColors.cupping.surface);
  });

  testWidgets('draws none of the chrome Material would add', (tester) async {
    await pump(tester, maxLength: 24);

    final decoration = tester
        .widget<TextField>(find.byType(TextField))
        .decoration!;
    expect(decoration.labelText, isNull, reason: 'the design has no label');
    expect(decoration.border, InputBorder.none);
    expect(
      decoration.counterText,
      '',
      reason: 'a counter is a second line under a field that has only one',
    );
    // The cap still applies — only its counter is suppressed. Read off the
    // `EditableText` the field actually drives: `AppTextField` passes no
    // controller, so `TextField.controller` is null and asserting through it
    // would pass on a field with no cap at all.
    await tester.enterText(find.byType(TextField), 'a' * 30);
    await tester.pump();
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      'a' * 24,
    );
  });

  testWidgets('names itself to a screen reader exactly once', (tester) async {
    // Counted, not merely found. Both the wrapper and the placeholder can
    // name this field, and when both do a reader says the name twice and
    // offers a node it cannot type into — which is what it did before the
    // hint's semantics were excluded.
    final handle = tester.ensureSemantics();
    await pump(tester);

    final fields = collectAllSemanticsNodesFrom(
      tester.binding.rootElement!.findRenderObject()!.debugSemantics!,
    ).where((node) => node.flagsCollection.isTextField).toList();

    expect(fields, hasLength(1));
    expect(
      tester.getSemantics(find.byType(TextField)),
      matchesSemantics(
        label: 'Your first name',
        isTextField: true,
        isFocusable: true,
        isEnabled: true,
        hasEnabledState: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
      reason: 'the node a reader lands on must be the one it can type into',
    );
    handle.dispose();
  });

  testWidgets('a caller may name it something other than its placeholder', (
    tester,
  ) async {
    // The Settings name sheet does exactly this: the field prompts "Your
    // first name" and the sheet calls it "Your name".
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkRoast,
        home: Scaffold(
          body: AppTextField(
            placeholder: 'Your first name',
            semanticsLabel: 'Your name',
            onChanged: (_) {},
          ),
        ),
      ),
    );

    final fields = collectAllSemanticsNodesFrom(
      tester.binding.rootElement!.findRenderObject()!.debugSemantics!,
    ).where((node) => node.flagsCollection.isTextField).toList();

    expect(fields, hasLength(1));
    expect(fields.single.label, 'Your name');
    handle.dispose();
  });

  testWidgets('does not animate the focus fade under reduced motion', (
    tester,
  ) async {
    await pump(tester, disableAnimations: true);

    expect(find.byType(AnimatedContainer), findsNothing);
    expect(_well(tester).border!.top.color, MoodColors.darkRoast.rule);
  });
}
