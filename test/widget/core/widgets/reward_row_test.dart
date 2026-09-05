import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/widgets/reward_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.darkRoast,
  home: Scaffold(body: child),
);

void main() {
  group('a row', () {
    testWidgets('says what happened, and what it means', (tester) async {
      await tester.pumpWidget(
        _host(
          const RewardRow(
            label: 'Freeze earned',
            detail: 'One missed day is covered.',
          ),
        ),
      );

      expect(find.text('Freeze earned'), findsOneWidget);
      expect(find.text('One missed day is covered.'), findsOneWidget);
    });

    testWidgets('stands without a detail', (tester) async {
      await tester.pumpWidget(_host(const RewardRow(label: 'Freeze earned')));

      expect(find.text('Freeze earned'), findsOneWidget);
    });

    testWidgets('is a button only when it opens onto something', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(const RewardRow(label: 'Freeze earned', detail: 'Covered.')),
      );

      expect(
        tester.getSemantics(find.byType(RewardRow)).flagsCollection.isButton,
        isFalse,
        reason: 'a row that cannot be pressed must not announce itself as one',
      );
    });

    testWidgets('and is one when it does', (tester) async {
      var pressed = 0;
      await tester.pumpWidget(
        _host(
          RewardRow(
            label: 'New card',
            detail: 'The Coffee Cherry',
            onPress: () => pressed++,
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(RewardRow)).flagsCollection.isButton,
        isTrue,
      );

      await tester.tap(find.byType(RewardRow));
      expect(pressed, 1);
    });

    testWidgets('announces itself as one sentence, not three fragments', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          const RewardRow(label: 'New card', detail: 'The Coffee Cherry'),
        ),
      );

      expect(
        find.bySemanticsLabel('New card. The Coffee Cherry'),
        findsOneWidget,
      );
      handle.dispose();
    });
  });

  group('the list', () {
    testWidgets('draws a hairline between rows, and nowhere else', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const RewardList(
            rows: [
              RewardRow(label: 'one'),
              RewardRow(label: 'two'),
              RewardRow(label: 'three'),
            ],
          ),
        ),
      );

      expect(
        find.byType(Divider),
        findsNWidgets(2),
        reason:
            'three rows have two gaps — no line above the first or below '
            'the last, which is what makes the list read as open',
      );
    });

    testWidgets('a single row wears no chrome at all', (tester) async {
      await tester.pumpWidget(
        _host(const RewardList(rows: [RewardRow(label: 'one')])),
      );

      expect(find.byType(Divider), findsNothing);
    });

    testWidgets('an empty list takes up no height', (tester) async {
      await tester.pumpWidget(
        _host(
          const Column(
            children: [
              Text('above'),
              RewardList(rows: []),
              Text('below'),
            ],
          ),
        ),
      );

      // Not merely "the list is absent" — a screen that paid nothing must
      // show no band where the list would have been.
      expect(tester.getRect(find.byType(RewardList)).height, 0);
      expect(
        tester.getRect(find.text('below')).top,
        tester.getRect(find.text('above')).bottom,
      );
    });
  });
}
