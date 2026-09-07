import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/features/learn/presentation/practice/practice_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, {bool isLast = false}) =>
    tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkRoast,
        home: Scaffold(
          body: PracticeGroup(
            label: 'Games',
            count: 15,
            isLast: isLast,
            children: const [Text('a row'), Text('another row')],
          ),
        ),
      ),
    );

Future<void> _toggle(WidgetTester tester) async {
  await tester.tap(find.text('Games'));
  await tester.pump();
  await tester.pump(PracticeGroup.turnDuration);
}

void main() {
  testWidgets('arrives closed, with its name and count', (tester) async {
    await _pump(tester);

    expect(find.text('Games'), findsOneWidget);
    expect(find.text('15'), findsOneWidget);
    expect(find.text('a row'), findsNothing);
  });

  testWidgets('opens on a tap and closes on another', (tester) async {
    await _pump(tester);

    await _toggle(tester);
    expect(find.text('a row'), findsOneWidget);
    expect(find.text('another row'), findsOneWidget);

    await _toggle(tester);
    expect(find.text('a row'), findsNothing);
  });

  testWidgets('is announced as a button that expands', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester);

    final header = find.bySemanticsLabel('Games, 15');
    expect(header, findsOneWidget);
    expect(
      tester.getSemantics(header),
      isSemantics(isButton: true, hasExpandedState: true, isExpanded: false),
    );

    await _toggle(tester);
    expect(tester.getSemantics(header), isSemantics(isExpanded: true));
    handle.dispose();
  });

  testWidgets('draws a rule under it unless it is the last group', (
    tester,
  ) async {
    await _pump(tester);
    expect(find.byType(Divider), findsOneWidget);

    await _pump(tester, isLast: true);
    expect(find.byType(Divider), findsNothing);
  });
}
