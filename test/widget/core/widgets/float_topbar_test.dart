import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/widgets/float_topbar.dart';
import 'package:brew_path/core/widgets/header_chrome.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {bool disableAnimations = false}) => MaterialApp(
  theme: AppTheme.darkRoast,
  home: Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(disableAnimations: disableAnimations),
      child: Scaffold(body: child),
    ),
  ),
);

/// A bar over a page that has moved, for the tests that read what it paints.
Widget _scrolledBar({bool disableAnimations = false}) => _host(
  const FloatTopbar(
    icon: AppIcon.close,
    label: 'Close',
    onPressed: _doNothing,
    isScrolled: true,
  ),
  disableAnimations: disableAnimations,
);

void _doNothing() {}

/// Every box the bar paints itself with.
Iterable<BoxDecoration> _painted(WidgetTester tester) => tester
    .widgetList<DecoratedBox>(
      find.descendant(
        of: find.byType(FloatTopbar),
        matching: find.byType(DecoratedBox),
      ),
    )
    .map((box) => box.decoration)
    .whereType<BoxDecoration>();

/// The bar's own fill, read off the band it rules.
Color? _fill(WidgetTester tester) =>
    _painted(tester).firstWhere((box) => box.border != null).color;

/// How strongly the gradient below the hairline starts.
double _fadeOpacity(WidgetTester tester) {
  final gradient = _painted(
    tester,
  ).firstWhere((box) => box.gradient != null).gradient!;
  return gradient.colors.first.a;
}

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

    testWidgets('draws no fade below its hairline at rest', (tester) async {
      await tester.pumpWidget(
        _host(
          const FloatTopbar(
            icon: AppIcon.close,
            label: 'Close',
            onPressed: _doNothing,
            isScrolled: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(_fadeOpacity(tester), 0);
    });

    testWidgets('and scrolled, fades a band below it the height the design '
        'draws', (tester) async {
      await tester.pumpWidget(_scrolledBar());
      await tester.pumpAndSettle();

      // The band the design fades from `color-mix(in oklab, bg 88%,
      // transparent)` to transparent, so nothing is seen crossing a bare edge.
      expect(_fadeOpacity(tester), MoodColors.headerFadeOpacity);
      expect(
        tester.getSize(find.byType(FloatTopbar)).height,
        FloatTopbar.height + HeaderChrome.fadeHeight,
      );
    });

    testWidgets('and under reduced motion the fade is a cut', (tester) async {
      await tester.pumpWidget(
        _host(
          const FloatTopbar(
            icon: AppIcon.close,
            label: 'Close',
            onPressed: _doNothing,
            isScrolled: false,
          ),
          disableAnimations: true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.pumpWidget(_scrolledBar(disableAnimations: true));
      await tester.pump();

      expect(_fadeOpacity(tester), MoodColors.headerFadeOpacity);
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

    testWidgets('fades below its hairline from the first frame too', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const FloatTopbar.sealed(
            icon: AppIcon.close,
            label: 'Close',
            onPressed: _doNothing,
          ),
        ),
      );

      // The design ties the fade to the fill, so a bar that is filled before
      // anything moves has its fade before anything moves.
      expect(_fadeOpacity(tester), MoodColors.headerFadeOpacity);
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
