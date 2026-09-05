import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/widgets/float_topbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.darkRoast,
  home: Scaffold(body: child),
);

/// The bar's own fill, read off the container it animates.
Color? _fill(WidgetTester tester) => tester
    .widget<AnimatedContainer>(
      find.descendant(
        of: find.byType(FloatTopbar),
        matching: find.byType(AnimatedContainer),
      ),
    )
    .decoration
    .let();

extension on Decoration? {
  Color? let() => this is BoxDecoration ? (this! as BoxDecoration).color : null;
}

void main() {
  group('the threshold', () {
    test('is not crossed by a few pixels of settle', () {
      expect(floatTopbarIsScrolled(0), isFalse);
      expect(floatTopbarIsScrolled(floatTopbarThreshold), isFalse);
    });

    test('and is crossed once the content has really moved', () {
      expect(floatTopbarIsScrolled(floatTopbarThreshold + 1), isTrue);
    });
  });

  group('the bar', () {
    testWidgets('is transparent at rest, over the celebration', (tester) async {
      await tester.pumpWidget(
        _host(
          FloatTopbar(
            icon: AppIcon.close,
            label: 'Close',
            onPressed: () {},
            isScrolled: false,
          ),
        ),
      );

      expect(_fill(tester)?.a, 0);
    });

    testWidgets('and takes the header fill once content is under it', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          FloatTopbar(
            icon: AppIcon.close,
            label: 'Close',
            onPressed: () {},
            isScrolled: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(_fill(tester), isNotNull);
      expect(_fill(tester)?.a, 1);
    });

    testWidgets('carries its label for the reader and the tooltip', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          FloatTopbar(
            icon: AppIcon.back,
            label: 'Flip back',
            onPressed: () {},
            isScrolled: false,
          ),
        ),
      );

      expect(find.byTooltip('Flip back'), findsOneWidget);
    });
  });

  group('the scroll scope', () {
    testWidgets('reports the crossing to whatever it wraps', (tester) async {
      await tester.pumpWidget(
        _host(
          FloatTopbarScrollScope(
            builder: (context, {required isScrolled}) => Column(
              children: [
                Text(isScrolled ? 'scrolled' : 'at rest'),
                Expanded(
                  child: ListView(
                    children: List<Widget>.generate(
                      40,
                      (index) => SizedBox(height: 40, child: Text('$index')),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('at rest'), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pump();

      expect(find.text('scrolled'), findsOneWidget);
    });
  });
}
