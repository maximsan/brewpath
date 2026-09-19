import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/widgets/confirm_sheet.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every word the sheet itself renders — the page under it is excluded by
/// descending from the sheet's route, so only what the sheet drew is asserted.
Set<String> _sheetText(WidgetTester tester) => tester
    .widgetList<Text>(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.byType(Text),
      ),
    )
    .map((text) => text.data)
    .whereType<String>()
    .where((line) => line.trim().isNotEmpty)
    .toSet();

void main() {
  const lines = [
    ConfirmLine(label: 'Daily streak', value: '12 days'),
    ConfirmLine(label: 'Points earned', value: '340 pts'),
  ];

  bool? answer;

  Future<void> openSheet(
    WidgetTester tester, {
    ConfirmActions actions = const ConfirmActions.destructive(
      confirm: 'Reset everything',
    ),
    String? body,
    ConfirmStakes stakes = const ConfirmStakes(),
  }) async {
    answer = null;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.cupping,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  answer = await showConfirmSheet(
                    context: context,
                    title: 'Start again from seed?',
                    actions: actions,
                    body: body,
                    stakes: stakes,
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Color fillOf(WidgetTester tester, String label) {
    final button = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text(label),
        matching: find.byType(FilledButton),
      ),
    );
    return button.style!.backgroundColor!.resolve({})!;
  }

  testWidgets('the confirm resolves true and the cancel resolves false', (
    tester,
  ) async {
    await openSheet(tester);
    await tester.tap(find.text('Reset everything'));
    await tester.pumpAndSettle();
    expect(answer, isTrue);

    await openSheet(tester);
    await tester.tap(find.text(ConfirmSheetCopy.keepMyProgress));
    await tester.pumpAndSettle();
    expect(answer, isFalse);
  });

  testWidgets('a sheet dismissed without an answer is a no', (tester) async {
    await openSheet(tester);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(answer, isFalse);
  });

  testWidgets('the lines carry their label and value to a screen reader', (
    tester,
  ) async {
    await openSheet(
      tester,
      stakes: const ConfirmStakes(lines: lines, closingLine: 'And the rest.'),
    );

    // A row is one announcement: read apart, "Daily streak" and "12 days" are
    // two unrelated fragments in a list of fourteen.
    expect(
      tester.getSemantics(find.text('Daily streak')),
      matchesSemantics(label: 'Daily streak\n12 days'),
    );
  });

  testWidgets('a sheet without stakes says only what it was given', (
    tester,
  ) async {
    // The assertion is the whole text of the sheet, not the absence of one
    // widget: a list that crept back in under any other shape fails here.
    await openSheet(tester, body: 'Nothing is lost.');

    expect(
      _sheetText(tester),
      {
        'Start again from seed?',
        'Nothing is lost.',
        'Reset everything',
        ConfirmSheetCopy.keepMyProgress,
      },
    );
  });

  testWidgets('the stakes add the list and its closing line, and nothing '
      'else', (tester) async {
    await openSheet(
      tester,
      body: 'Nothing is lost.',
      stakes: const ConfirmStakes(lines: lines, closingLine: 'And the rest.'),
    );

    expect(
      _sheetText(tester),
      {
        'Start again from seed?',
        'Nothing is lost.',
        'Daily streak',
        '12 days',
        'Points earned',
        '340 pts',
        'And the rest.',
        'Reset everything',
        ConfirmSheetCopy.keepMyProgress,
      },
    );
  });

  testWidgets('a destructive confirm is filled with berry', (tester) async {
    await openSheet(tester);

    expect(fillOf(tester, 'Reset everything'), MoodColors.cupping.berry);
  });

  testWidgets('a plain confirm keeps the accent', (tester) async {
    await openSheet(
      tester,
      actions: const ConfirmActions(confirm: 'Restart', cancel: 'Cancel'),
    );

    expect(fillOf(tester, 'Restart'), MoodColors.cupping.accent);
    expect(find.text('Cancel'), findsOneWidget);
  });
}
