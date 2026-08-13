import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/utils/module_icons.dart';
import 'package:brew_path/core/widgets/module_glyph.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child, {ThemeData? theme}) => MaterialApp(
  theme: theme ?? AppTheme.darkRoast,
  home: Scaffold(body: Center(child: child)),
);

Icon _iconOf(WidgetTester tester) => tester.widget<Icon>(
  find.descendant(of: find.byType(ModuleGlyph), matching: find.byType(Icon)),
);

void main() {
  group('glyph', () {
    testWidgets("draws the module's own icon", (tester) async {
      await tester.pumpWidget(
        _app(const ModuleGlyph(iconName: 'ic_roast', locked: false)),
      );

      expect(_iconOf(tester).icon, moduleIcon('ic_roast'));
    });

    testWidgets('keeps the module icon when locked, never a lock glyph', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(const ModuleGlyph(iconName: 'ic_roast', locked: true)),
      );

      // The design signals lock with colour here and puts the lock mark in the
      // row's trailing slot; the glyph stays the module's identity either way.
      expect(_iconOf(tester).icon, moduleIcon('ic_roast'));
      expect(_iconOf(tester).icon, isNot(Icons.lock_outline));
    });
  });

  group('colour', () {
    testWidgets('unlocked glyphs take the accent', (tester) async {
      await tester.pumpWidget(
        _app(const ModuleGlyph(iconName: 'ic_beans', locked: false)),
      );

      expect(_iconOf(tester).color, MoodColors.darkRoast.accent);
    });

    testWidgets('locked glyphs take the muted ink', (tester) async {
      await tester.pumpWidget(
        _app(const ModuleGlyph(iconName: 'ic_beans', locked: true)),
      );

      expect(_iconOf(tester).color, MoodColors.darkRoast.inkMute);
    });

    testWidgets('colours follow the mood', (tester) async {
      await tester.pumpWidget(
        _app(
          const ModuleGlyph(iconName: 'ic_beans', locked: false),
          theme: AppTheme.cupping,
        ),
      );

      expect(_iconOf(tester).color, MoodColors.cupping.accent);
    });
  });

  group('no container', () {
    testWidgets('paints no fill behind the glyph', (tester) async {
      await tester.pumpWidget(
        _app(const ModuleGlyph(iconName: 'ic_beans', locked: false)),
      );

      // The whole point of the widget: a bare glyph, not a filled well.
      expect(
        find.descendant(
          of: find.byType(ModuleGlyph),
          matching: find.byType(Container),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(ModuleGlyph),
          matching: find.byType(DecoratedBox),
        ),
        findsNothing,
      );
    });

    testWidgets('reserves a fixed column so titles align', (tester) async {
      await tester.pumpWidget(
        _app(const ModuleGlyph(iconName: 'ic_beans', locked: false)),
      );

      // The design's fixed 32-px glyph column, asserted as a rendered width so
      // the widget's own constant can't move without the test noticing.
      expect(tester.getSize(find.byType(ModuleGlyph)).width, 32);
    });
  });
}
