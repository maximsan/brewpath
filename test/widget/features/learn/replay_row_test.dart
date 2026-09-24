import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/replay_mark.dart';
import 'package:brew_path/features/learn/presentation/practice/replay_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/find_mark.dart';

Future<int> _pump(
  WidgetTester tester, {
  String? sub = 'Arabica vs Robusta',
  bool locked = false,
  bool starts = false,
  Widget? icon,
}) async {
  var taps = 0;
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.darkRoast,
      home: Scaffold(
        body: ReplayRow(
          icon: icon,
          title: 'Match the facts',
          sub: sub,
          locked: locked,
          starts: starts,
          onTap: () => taps++,
        ),
      ),
    ),
  );
  await tester.tap(find.text('Match the facts'));
  return taps;
}

void main() {
  testWidgets('letters the eyebrow as smallcaps over the name', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('ARABICA VS ROBUSTA'), findsOneWidget);
    expect(find.text('Match the facts'), findsOneWidget);
  });

  testWidgets('a row without an eyebrow is its name alone', (tester) async {
    await _pump(tester, sub: null);

    expect(find.byType(Text), findsOneWidget);
    expect(find.text('Match the facts'), findsOneWidget);
  });

  testWidgets('ends in the replay mark, and taps', (tester) async {
    final taps = await _pump(tester);

    expect(find.byType(ReplayMark), findsOneWidget);
    expect(findMark(AppIcon.chevron), findsNothing);
    expect(findMark(AppIcon.lock), findsNothing);
    expect(taps, 1);
  });

  testWidgets('a row that starts something ends in a chevron', (
    tester,
  ) async {
    await _pump(tester, starts: true);

    expect(findMark(AppIcon.chevron), findsOneWidget);
    expect(find.byType(ReplayMark), findsNothing);
  });

  testWidgets('a locked row ends in a lock and nothing else', (tester) async {
    await _pump(tester, locked: true, starts: true);

    expect(findMark(AppIcon.lock), findsOneWidget);
    expect(findMark(AppIcon.chevron), findsNothing);
    expect(find.byType(ReplayMark), findsNothing);
  });

  testWidgets('draws the kind glyph only when given one', (tester) async {
    await _pump(tester);
    expect(find.byType(FlutterLogo), findsNothing);

    await _pump(tester, icon: const FlutterLogo());
    expect(find.byType(FlutterLogo), findsOneWidget);
  });

  testWidgets('is announced as one sentence, then what the tap does', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();

    await _pump(tester);
    expect(
      find.bySemanticsLabel('Match the facts. Arabica vs Robusta. Replay.'),
      findsOneWidget,
    );

    await _pump(tester, starts: true);
    expect(
      find.bySemanticsLabel('Match the facts. Arabica vs Robusta. Play.'),
      findsOneWidget,
    );

    await _pump(tester, sub: null);
    expect(find.bySemanticsLabel('Match the facts. Replay.'), findsOneWidget);

    await _pump(tester, locked: true, starts: true);
    expect(
      find.bySemanticsLabel(
        'Match the facts. Arabica vs Robusta. Part of Foundations.',
      ),
      findsOneWidget,
    );
    handle.dispose();
  });
}
