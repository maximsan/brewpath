import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/disclosure_mark.dart';
import 'package:brew_path/features/learn/presentation/practice/practice_sub_group.dart';
import 'package:brew_path/shared/theme/app_motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/find_mark.dart';

Future<void> _pump(
  WidgetTester tester, {
  bool locked = false,
  bool openAtFirst = false,
  int count = 2,
}) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.cupping,
    home: Scaffold(
      body: PracticeSubGroup(
        label: 'Match',
        count: count,
        locked: locked,
        openAtFirst: openAtFirst,
        mark: const FlutterLogo(),
        children: const [Text('a row'), Text('another row')],
      ),
    ),
  ),
);

Future<void> _toggle(WidgetTester tester) async {
  await tester.tap(find.text('MATCH'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('arrives shut, with its mark, its name and a caret', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.byType(FlutterLogo), findsOneWidget);
    expect(find.text('MATCH'), findsOneWidget);
    expect(find.byType(DisclosureMark), findsOneWidget);
    expect(find.text('a row'), findsNothing);
    expect(find.text('2'), findsNothing, reason: 'the count is not drawn');
  });

  testWidgets('a lone module arrives open', (tester) async {
    await _pump(tester, openAtFirst: true);

    expect(find.text('a row'), findsOneWidget);
    expect(find.text('another row'), findsOneWidget);
  });

  testWidgets('opens on a tap and shuts on another', (tester) async {
    await _pump(tester);

    await _toggle(tester);
    expect(find.text('a row'), findsOneWidget);

    await _toggle(tester);
    expect(find.text('a row'), findsNothing);
  });

  testWidgets('the header is a 44-high tap target', (tester) async {
    await _pump(tester);

    expect(
      tester.getSize(find.byType(InkWell)).height,
      greaterThanOrEqualTo(44),
    );
  });

  testWidgets('a locked sub-group carries the lock and dims its name', (
    tester,
  ) async {
    await _pump(tester, locked: true);

    expect(findMark(AppIcon.lock), findsOneWidget);
    expect(
      tester
          .widget<Opacity>(
            find.ancestor(
              of: find.text('MATCH'),
              matching: find.byType(Opacity),
            ),
          )
          .opacity,
      0.55,
    );

    await _pump(tester);
    expect(findMark(AppIcon.lock), findsNothing);
  });

  testWidgets('a locked sub-group still opens: every row is an offer', (
    tester,
  ) async {
    await _pump(tester, locked: true);

    await _toggle(tester);
    expect(find.text('a row'), findsOneWidget);
  });

  testWidgets('the caret turns over the disclosure move', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('MATCH'));
    await tester.pump();
    await tester.pump(AppMotion.disclosure);

    expect(
      tester.widget<AnimatedRotation>(find.byType(AnimatedRotation)).turns,
      0.5,
    );
  });

  testWidgets('is announced with its count, as a button that expands', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _pump(tester);

    final header = find.bySemanticsLabel('Match. 2 items.');
    expect(header, findsOneWidget);
    expect(
      tester.getSemantics(header),
      isSemantics(isButton: true, hasExpandedState: true, isExpanded: false),
    );

    await _pump(tester, count: 1);
    expect(find.bySemanticsLabel('Match. 1 item.'), findsOneWidget);
    handle.dispose();
  });

  testWidgets("a locked sub-group is announced in the locked row's words", (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, locked: true);

    expect(
      find.bySemanticsLabel('Match. 2 items. Part of Foundations.'),
      findsOneWidget,
    );
    handle.dispose();
  });
}
