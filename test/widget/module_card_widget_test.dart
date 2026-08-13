import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/core/widgets/module_glyph.dart';
import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/features/learn/presentation/module_card_widget.dart';
import 'package:brew_path/shared/models/module_model.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _module = ModuleModel(
  id: 'module_roast',
  title: 'Roasting',
  description: 'Desc',
  iconName: 'ic_roast',
  lessonIds: ['l1', 'l2'],
);

ModuleWithProgress _item({required int done, required bool locked}) =>
    ModuleWithProgress(
      module: _module,
      completedCount: done,
      totalCount: 2,
      isLocked: locked,
    );

Future<void> _pump(WidgetTester tester, ModuleWithProgress item) =>
    tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkRoast,
        home: Scaffold(body: ModuleCardWidget(item: item)),
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
    testWidgets('mutes the glyph and marks the row with a lock', (
      tester,
    ) async {
      await _pump(tester, _item(done: 0, locked: true));

      expect(_glyphColour(tester), MoodColors.darkRoast.inkMute);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.text('Locked'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('tapping surfaces the unlock hint instead of navigating', (
      tester,
    ) async {
      await _pump(tester, _item(done: 0, locked: true));

      await tester.tap(find.byType(ModuleCardWidget));
      await tester.pump();

      expect(find.text(AppLabels.lockedModuleMessage), findsOneWidget);
    });
  });

  group('locked and fully counted', () {
    testWidgets('still reads as locked, never as complete', (tester) async {
      // Reachable when a content update adds a lesson to the prerequisite:
      // this module re-locks with its own tally untouched. Completion is
      // signalled by going quiet, so without the guard the row would render
      // with no lock, no status line and no chevron — yet a tap still says
      // "locked".
      await _pump(tester, _item(done: 2, locked: true));

      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.text('Locked'), findsOneWidget);
    });
  });

  group('in progress', () {
    testWidgets('accents the glyph and keeps the chevron', (tester) async {
      await _pump(tester, _item(done: 1, locked: false));

      expect(_glyphColour(tester), MoodColors.darkRoast.accent);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsNothing);
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
  });

  group('complete', () {
    testWidgets('leaves the glyph the same accent as in progress', (
      tester,
    ) async {
      await _pump(tester, _item(done: 2, locked: false));

      // Completion is not colour-signalled: the finished row is the
      // in-progress row minus its trailing mark and its count line.
      expect(_glyphColour(tester), MoodColors.darkRoast.accent);
    });

    testWidgets('drops the trailing chevron rather than swapping it', (
      tester,
    ) async {
      await _pump(tester, _item(done: 2, locked: false));

      expect(find.byIcon(Icons.chevron_right), findsNothing);
      expect(find.byIcon(Icons.check_circle), findsNothing);
      expect(find.byIcon(Icons.lock_outline), findsNothing);
    });

    testWidgets('drops the lesson-count line and its progress bar', (
      tester,
    ) async {
      await _pump(tester, _item(done: 2, locked: false));

      expect(find.textContaining('lessons'), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.text('Roasting'), findsOneWidget);
    });

    testWidgets('still announces completion to a screen reader', (
      tester,
    ) async {
      await _pump(tester, _item(done: 2, locked: false));

      // Nothing visual is left to read once the chevron and count line go, so
      // the state has to reach assistive tech through the title's label.
      expect(
        tester.widget<Text>(find.byType(Text).first).semanticsLabel,
        AppLabels.moduleCompleteSemantics('Roasting'),
      );
    });
  });
}
