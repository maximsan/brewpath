import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/widgets/module_glyph.dart';
import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/features/path/presentation/path_node_card.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/content_fixtures.dart';

final _module = testModule(
  id: 'm5',
  n: 5,
  title: 'Brew',
  iconName: 'brewing',
  lessonIds: const ['m5l1', 'm5l2'],
);

ModuleWithProgress _item({required int done, required bool locked}) =>
    ModuleWithProgress(
      module: _module,
      completedCount: done,
      totalCount: 2,
      isLocked: locked,
    );

Future<void> _pump(
  WidgetTester tester,
  ModuleWithProgress item, {
  VoidCallback? onTap,
}) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.darkRoast,
    home: Scaffold(
      body: PathNodeCard(item: item, onTap: onTap ?? () {}),
    ),
  ),
);

Color? _glyphColour(WidgetTester tester) => tester
    .widget<Icon>(
      find.descendant(
        of: find.byType(ModuleGlyph),
        matching: find.byType(Icon),
      ),
    )
    .color;

void main() {
  group('locked', () {
    testWidgets('mutes the glyph and shows the locked hint', (tester) async {
      await _pump(tester, _item(done: 0, locked: true));

      expect(_glyphColour(tester), MoodColors.darkRoast.inkMute);
      expect(find.text('Locked'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      // The rail beside this card already carries the lock mark, so the card
      // itself keeps its trailing slot empty rather than doubling it up.
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });
  });

  group('locked and fully counted', () {
    testWidgets('still reads as locked, never as complete', (tester) async {
      await _pump(tester, _item(done: 2, locked: true));

      expect(_glyphColour(tester), MoodColors.darkRoast.inkMute);
      expect(find.text('Locked'), findsOneWidget);
    });
  });

  group('in progress', () {
    testWidgets('accents the glyph and keeps the chevron', (tester) async {
      await _pump(tester, _item(done: 1, locked: false));

      expect(_glyphColour(tester), MoodColors.darkRoast.accent);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('shows the lesson count above a progress bar', (tester) async {
      await _pump(tester, _item(done: 1, locked: false));

      expect(find.text('1 / 2 lessons'), findsOneWidget);
      expect(
        tester
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .value,
        0.5,
      );
    });

    testWidgets('taps through to the module', (tester) async {
      var taps = 0;
      await _pump(tester, _item(done: 1, locked: false), onTap: () => taps++);

      await tester.tap(find.byType(PathNodeCard));
      await tester.pump();

      expect(taps, 1);
    });
  });

  group('complete', () {
    testWidgets('leaves the glyph the same accent as in progress', (
      tester,
    ) async {
      await _pump(tester, _item(done: 2, locked: false));

      expect(_glyphColour(tester), MoodColors.darkRoast.accent);
    });

    testWidgets('drops the trailing chevron rather than swapping it', (
      tester,
    ) async {
      await _pump(tester, _item(done: 2, locked: false));

      expect(find.byIcon(Icons.chevron_right), findsNothing);
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });

    testWidgets('drops the status line under the title', (tester) async {
      await _pump(tester, _item(done: 2, locked: false));

      expect(find.text('Complete'), findsNothing);
      expect(find.textContaining('lessons'), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.text(_module.title), findsOneWidget);
    });
  });
}
