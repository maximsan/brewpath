import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/widgets/float_topbar.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.darkRoast,
  home: Scaffold(body: child),
);

/// The bar's own fill, read off the box it paints.
Color? _fill(WidgetTester tester) =>
    (tester
                .widget<DecoratedBox>(
                  find.descendant(
                    of: find.byType(FloatTopbar),
                    matching: find.byType(DecoratedBox),
                  ),
                )
                .decoration
            as BoxDecoration)
        .color;

void main() {
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

      // The header's own token, not an opaque page: the design writes this bar
      // and the sticky header with the same fill, and the same filter behind
      // it.
      expect(_fill(tester), MoodColors.darkRoast.headerFill.color);
      expect(
        find.descendant(
          of: find.byType(FloatTopbar),
          matching: find.byType(BackdropFilter),
        ),
        findsOneWidget,
      );
    });

    testWidgets('and pays for no filter while it is invisible', (tester) async {
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
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(FloatTopbar),
          matching: find.byType(BackdropFilter),
        ),
        findsNothing,
        reason: 'a BackdropFilter costs a saveLayer at any sigma',
      );
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
}
