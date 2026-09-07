import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/replay_mark.dart';
import 'package:brew_path/features/learn/presentation/practice/replay_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/find_mark.dart';

Future<int> _pump(
  WidgetTester tester, {
  String? meta = '~2 min',
  bool locked = false,
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
          sub: 'Arabica vs Robusta',
          meta: meta,
          locked: locked,
          onTap: () => taps++,
        ),
      ),
    ),
  );
  await tester.tap(find.text('Match the facts'));
  return taps;
}

void main() {
  testWidgets('letters the eyebrow and the meta line as smallcaps', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('ARABICA VS ROBUSTA'), findsOneWidget);
    expect(find.text('Match the facts'), findsOneWidget);
    expect(find.text('~2 MIN'), findsOneWidget);
  });

  testWidgets('ends in the replay mark, and taps', (tester) async {
    final taps = await _pump(tester);

    expect(find.byType(ReplayMark), findsOneWidget);
    expect(findMark(AppIcon.lock), findsNothing);
    expect(taps, 1);
  });

  testWidgets('a locked row ends in a lock and says nothing else', (
    tester,
  ) async {
    await _pump(tester, meta: null, locked: true);

    expect(findMark(AppIcon.lock), findsOneWidget);
    expect(find.byType(ReplayMark), findsNothing);
    expect(find.textContaining('MIN'), findsNothing);
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
      find.bySemanticsLabel(
        'Match the facts. Arabica vs Robusta. ~2 min. Replay.',
      ),
      findsOneWidget,
    );

    await _pump(tester, meta: null, locked: true);
    expect(
      find.bySemanticsLabel(
        'Match the facts. Arabica vs Robusta. Part of Foundations.',
      ),
      findsOneWidget,
    );
    handle.dispose();
  });
}
