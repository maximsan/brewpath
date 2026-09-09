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

  group('a sealed bar', () {
    testWidgets('is filled from the first frame, never scroll-dependent', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          FloatTopbar.sealed(
            icon: AppIcon.close,
            label: 'Close',
            onPressed: () {},
          ),
        ),
      );

      expect(_fill(tester), MoodColors.darkRoast.bg);
    });

    testWidgets('pays for no filter — an opaque page hides what passes under', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          FloatTopbar.sealed(
            icon: AppIcon.close,
            label: 'Close',
            onPressed: () {},
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
      );
    });
  });

  group('the room it leaves', () {
    /// A device inset, so the two helpers are read over a real status bar
    /// rather than over zero.
    const statusBar = 59.0;

    Future<EdgeInsets> roomFor(
      WidgetTester tester,
      EdgeInsets Function(BuildContext) read,
    ) async {
      late EdgeInsets room;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkRoast,
          home: MediaQuery(
            data: const MediaQueryData(
              padding: EdgeInsets.only(top: statusBar),
            ),
            child: Builder(
              builder: (context) {
                room = read(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      return room;
    }

    testWidgets('opens a scroll where the design opens it', (tester) async {
      final room = await roomFor(
        tester,
        (context) => FloatTopbar.scrollPadding(
          context,
          designScrollPad: FloatTopbar.runDesignScrollPad,
          inset: 24,
        ),
      );

      // The design's 134 is measured from the top of the screen, over its own
      // 54px status bar; the device's inset replaces that.
      expect(room.top, statusBar + (134 - 54));
      expect(room.left, 24);
      expect(room.bottom, 24);
    });

    testWidgets('covers the bar, and no further, for a body with a gutter', (
      tester,
    ) async {
      final room = await roomFor(tester, FloatTopbar.barRoom);

      // Stops at the hairline: the body's own gutter carries the rest of the
      // design's pad, and content leaves at the bar's edge rather than below
      // it.
      expect(room.top, statusBar + FloatTopbar.height);
    });
  });

  group('the grid', () {
    testWidgets('carries a centre and a trailing control', (tester) async {
      await tester.pumpWidget(
        _host(
          FloatTopbar.sealed(
            icon: AppIcon.close,
            label: 'Close',
            onPressed: () {},
            centre: const Text('01 / 08'),
            trailing: IconButton(
              onPressed: () {},
              tooltip: 'Save',
              icon: const Icon(Icons.bookmark_border),
            ),
          ),
        ),
      );

      expect(find.text('01 / 08'), findsOneWidget);
      expect(find.byTooltip('Save'), findsOneWidget);
    });

    testWidgets('centres the middle even with no trailing control', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          FloatTopbar.sealed(
            icon: AppIcon.close,
            label: 'Close',
            onPressed: () {},
            centre: const Text('01 / 08'),
          ),
        ),
      );

      // The design reserves the third column whether or not it holds
      // anything, so a bar with one side control does not push its centre off
      // centre.
      final bar = tester.getRect(find.byType(FloatTopbar));
      expect(
        tester.getCenter(find.text('01 / 08')).dx,
        moreOrLessEquals(bar.center.dx, epsilon: 0.5),
      );
    });
  });
}
