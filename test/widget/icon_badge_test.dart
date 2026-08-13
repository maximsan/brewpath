import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/widgets/icon_badge.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child, {ThemeData? theme}) => MaterialApp(
  theme: theme ?? AppTheme.darkRoast,
  home: Scaffold(body: Center(child: child)),
);

BoxDecoration _decorationOf(WidgetTester tester) {
  final box = tester.widget<Container>(
    find
        .ancestor(of: find.byType(Icon), matching: find.byType(Container))
        .first,
  );
  return box.decoration! as BoxDecoration;
}

Size _sizeOf(WidgetTester tester) =>
    tester.getSize(find.byType(IconBadge).first);

void main() {
  group('shape', () {
    testWidgets('circle badges are circular', (tester) async {
      await tester.pumpWidget(
        _app(const IconBadge.circle(icon: Icons.coffee, size: 96)),
      );

      expect(_decorationOf(tester).shape, BoxShape.circle);
      expect(_decorationOf(tester).borderRadius, isNull);
    });

    testWidgets('rounded badges default to the chrome radius', (tester) async {
      await tester.pumpWidget(
        _app(const IconBadge.rounded(icon: Icons.coffee, size: 56)),
      );

      final decoration = _decorationOf(tester);
      expect(decoration.shape, BoxShape.rectangle);
      expect(
        decoration.borderRadius,
        BorderRadius.circular(AppRadii.chrome),
      );
    });

    testWidgets('rounded badges honour an explicit radius', (tester) async {
      // 12 is the bottom of the 12–20 slack `AppRadii` documents around
      // `chrome`, so the example stays inside the design's own language.
      await tester.pumpWidget(
        _app(const IconBadge.rounded(icon: Icons.coffee, size: 44, radius: 12)),
      );

      expect(_decorationOf(tester).borderRadius, BorderRadius.circular(12));
    });
  });

  group('colour', () {
    testWidgets('defaults to the mood accent on accent ink', (tester) async {
      await tester.pumpWidget(
        _app(const IconBadge.rounded(icon: Icons.coffee, size: 48)),
      );

      expect(_decorationOf(tester).color, MoodColors.darkRoast.accent);
      expect(
        tester.widget<Icon>(find.byType(Icon)).color,
        MoodColors.darkRoast.accentInk,
      );
    });

    testWidgets('honours explicit background and foreground', (tester) async {
      await tester.pumpWidget(
        _app(
          const IconBadge.rounded(
            icon: Icons.help_outline,
            size: 56,
            background: Color(0xFF102030),
            foreground: Color(0xFF405060),
          ),
        ),
      );

      expect(_decorationOf(tester).color, const Color(0xFF102030));
      expect(
        tester.widget<Icon>(find.byType(Icon)).color,
        const Color(0xFF405060),
      );
    });

    testWidgets('the default colours follow the mood', (tester) async {
      await tester.pumpWidget(
        _app(
          const IconBadge.circle(icon: Icons.coffee, size: 56),
          theme: AppTheme.cupping,
        ),
      );
      await tester.pumpAndSettle();

      expect(_decorationOf(tester).color, MoodColors.cupping.accent);
      expect(
        tester.widget<Icon>(find.byType(Icon)).color,
        MoodColors.cupping.accentInk,
      );
    });
  });

  group('geometry', () {
    testWidgets('lays out at the requested size', (tester) async {
      await tester.pumpWidget(
        _app(const IconBadge.rounded(icon: Icons.coffee, size: 44)),
      );

      expect(_sizeOf(tester), const Size(44, 44));
    });

    testWidgets('passes the icon size through when given', (tester) async {
      await tester.pumpWidget(
        _app(
          const IconBadge.circle(icon: Icons.coffee, size: 96, iconSize: 48),
        ),
      );

      expect(tester.widget<Icon>(find.byType(Icon)).size, 48);
    });

    testWidgets('leaves the icon size to the theme when omitted', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(const IconBadge.rounded(icon: Icons.coffee, size: 48)),
      );

      expect(tester.widget<Icon>(find.byType(Icon)).size, isNull);
    });
  });

  group('semantics', () {
    testWidgets('forwards a semantic label to the icon', (tester) async {
      await tester.pumpWidget(
        _app(
          const IconBadge.circle(
            icon: Icons.coffee,
            size: 56,
            semanticLabel: 'Espresso',
          ),
        ),
      );

      expect(
        tester.widget<Icon>(find.byType(Icon)).semanticLabel,
        'Espresso',
      );
    });

    testWidgets('stays unlabelled when no label is given', (tester) async {
      await tester.pumpWidget(
        _app(const IconBadge.circle(icon: Icons.coffee, size: 56)),
      );

      expect(tester.widget<Icon>(find.byType(Icon)).semanticLabel, isNull);
    });
  });
}
