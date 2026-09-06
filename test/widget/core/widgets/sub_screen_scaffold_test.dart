import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/header_chrome.dart';
import 'package:brew_path/core/widgets/page_large_title.dart';
import 'package:brew_path/core/widgets/scroll_flag_scope.dart';
import 'package:brew_path/core/widgets/sub_header.dart';
import 'package:brew_path/core/widgets/sub_screen_scaffold.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A page under the design's bar: a large title, then enough rows to scroll.
Widget _page({
  String title = 'Settings',
  String? eyebrow,
  Object? resetKey,
  VoidCallback? onBack,
  Widget? trailing,
  AppIcon mark = AppIcon.back,
  bool isRinged = false,
  double designScrollPad = SubHeader.designScrollPad,
  double threshold = scrollFlagThreshold,
  ScrollController? controller,
}) {
  return MaterialApp(
    theme: ThemeData(extensions: const [MoodColors.darkRoast]),
    home: MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: SubScreenScaffold(
        title: title,
        eyebrow: eyebrow,
        resetKey: resetKey,
        mark: mark,
        trailing: trailing,
        isRinged: isRinged,
        designScrollPad: designScrollPad,
        threshold: threshold,
        onBack: onBack ?? () {},
        body: (context, scrollPadding) => ListView(
          controller: controller,
          padding: scrollPadding,
          children: [
            PageLargeTitle(title),
            for (var row = 0; row < 30; row++)
              SizedBox(height: 40, child: Text('row $row')),
          ],
        ),
      ),
    ),
  );
}

/// The bar's own copy of the title — the one inside [SubHeader], not the
/// page's.
Finder _barTitle(String title) =>
    find.descendant(of: find.byType(SubHeader), matching: find.text(title));

/// The mark on the way back.
Finder _backMark() => find.descendant(
  of: find.byType(SubHeader),
  matching: find.byType(IconMark),
);

/// Where the bar ends: its chrome's box, less the fade it draws below itself.
double _barBottom(WidgetTester tester) =>
    tester.getRect(find.byType(HeaderChrome)).bottom - HeaderChrome.fadeHeight;

Future<void> _scrollPast(WidgetTester tester) async {
  await tester.drag(find.byType(ListView), const Offset(0, -200));
  await tester.pumpAndSettle();
}

void main() {
  group('the threshold', () {
    test('is not crossed by a few pixels of settle', () {
      expect(isScrolledPast(0), isFalse);
      expect(isScrolledPast(scrollFlagThreshold), isFalse);
    });

    test('and is crossed once the content has really moved', () {
      expect(isScrolledPast(scrollFlagThreshold + 1), isTrue);
    });

    testWidgets('a page the design gives its own waits for it', (tester) async {
      // The Saved shelf: 72 where every other page's bar arrives at 40.
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(_page(threshold: 72, controller: controller));
      await tester.pumpAndSettle();

      controller.jumpTo(60);
      await tester.pumpAndSettle();
      expect(
        _barTitle('Settings'),
        findsNothing,
        reason: "past the default, short of this page's own threshold",
      );

      controller.jumpTo(80);
      await tester.pumpAndSettle();
      expect(_barTitle('Settings'), findsOneWidget);
    });
  });

  testWidgets('at rest the page is titled by the page, not by the bar', (
    tester,
  ) async {
    await tester.pumpWidget(_page());
    await tester.pumpAndSettle();

    expect(find.byType(PageLargeTitle), findsOneWidget);
    expect(
      _barTitle('Settings'),
      findsNothing,
      reason: 'the design keeps the bar wordless until the page scrolls',
    );
    expect(
      find.text('Settings'),
      findsOneWidget,
      reason: 'titled once, which is the whole point of the pair',
    );
  });

  testWidgets('scrolled, the bar takes the title over', (tester) async {
    await tester.pumpWidget(_page());
    await tester.pumpAndSettle();

    await _scrollPast(tester);

    expect(_barTitle('Settings'), findsOneWidget);
  });

  testWidgets('scrolling back to the top puts it away again', (tester) async {
    await tester.pumpWidget(_page());
    await tester.pumpAndSettle();
    await _scrollPast(tester);
    expect(_barTitle('Settings'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, 400));
    await tester.pumpAndSettle();

    expect(_barTitle('Settings'), findsNothing);
  });

  testWidgets('swapping the content clears the bar with it', (tester) async {
    // The failure this guards: a dictionary category drilled into, or a term
    // that links to another term, starts at the top again while the bar still
    // thinks it is scrolled — leaving a compact title stacked on top of an
    // un-scrolled large one.
    await tester.pumpWidget(_page(resetKey: 'beans'));
    await tester.pumpAndSettle();
    await _scrollPast(tester);
    expect(_barTitle('Settings'), findsOneWidget);

    await tester.pumpWidget(_page(resetKey: 'brewing'));
    await tester.pumpAndSettle();

    expect(
      _barTitle('Settings'),
      findsNothing,
      reason: 'the flag describes content that has gone',
    );
    expect(find.text('Settings'), findsOneWidget);
  });

  group('the room a page leaves for the bar', () {
    // No status bar in a test, so the page opens at the design's number less
    // the status bar the design measures it over.
    testWidgets("is the design's 108 under a large title", (tester) async {
      await tester.pumpWidget(_page());
      await tester.pumpAndSettle();

      expect(
        tester.getRect(find.byType(PageLargeTitle)).top,
        HeaderChrome.belowDesignStatusBar(SubHeader.designScrollPad),
      );
      expect(
        tester.getRect(find.byType(PageLargeTitle)).top,
        greaterThanOrEqualTo(SubHeader.height),
        reason:
            'a pushed page carries a control at every scroll position, '
            'so its title must clear the bar rather than open under it',
      );
    });

    testWidgets('and the shorter room where the design gives one', (
      tester,
    ) async {
      // The tree and the streak at 84, the grove at 100.
      await tester.pumpWidget(
        _page(designScrollPad: SubHeader.shortDesignScrollPad),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getRect(find.byType(PageLargeTitle)).top,
        HeaderChrome.belowDesignStatusBar(SubHeader.shortDesignScrollPad),
      );

      await tester.pumpWidget(_page(designScrollPad: 100));
      await tester.pumpAndSettle();
      expect(
        tester.getRect(find.byType(PageLargeTitle)).top,
        HeaderChrome.belowDesignStatusBar(100),
      );
    });
  });

  group('the way back', () {
    testWidgets('says what it does, and does it', (tester) async {
      var popped = 0;
      await tester.pumpWidget(_page(onBack: () => popped++));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Back'));
      expect(popped, 1);
    });

    testWidgets('says Close on a page you dismiss', (tester) async {
      await tester.pumpWidget(_page(mark: AppIcon.close));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Close'), findsOneWidget);
      expect(find.byTooltip('Back'), findsNothing);
    });

    testWidgets("draws its mark on the bar's inset, at the design's size", (
      tester,
    ) async {
      // The design's `.close-btn`: an 18px mark inside 4px of padding, the
      // box pulled 4 left so the mark sits on the bar's 20px inset, the box
      // bottom on the bar's 10px inset.
      await tester.pumpWidget(_page());
      await tester.pumpAndSettle();

      final mark = tester.getRect(_backMark());
      expect(mark.width, 18);
      expect(mark.left, 20);
      expect(_barBottom(tester) - mark.bottom, 10 + 4);
    });

    testWidgets('answers a touch beyond the box it draws', (tester) async {
      // The design widens the touch area to 44 without moving anything: a
      // tap in the inset under the mark, or above it, still leaves the page.
      var popped = 0;
      await tester.pumpWidget(_page(onBack: () => popped++));
      await tester.pumpAndSettle();

      final mark = tester.getRect(_backMark());
      await tester.tapAt(Offset(mark.center.dx, _barBottom(tester) - 2));
      await tester.tapAt(Offset(mark.center.dx, mark.top - 6));
      expect(popped, 2);
    });

    testWidgets(
      'is ringed at 32 when asked, so it balances a trailing control',
      (
        tester,
      ) async {
        await tester.pumpWidget(
          _page(
            isRinged: true,
            trailing: const Icon(Icons.bookmark_border, key: Key('fav')),
          ),
        );
        await tester.pumpAndSettle();

        final control = tester.getRect(find.byTooltip('Back'));
        expect(control.width, 32);
        expect(control.height, 32);
        expect(control.left, 20);
        expect(_barBottom(tester) - control.bottom, 10);
      },
    );
  });

  testWidgets('an eyebrow rides above the title, and only when given', (
    tester,
  ) async {
    await tester.pumpWidget(_page(eyebrow: 'Beans'));
    await tester.pumpAndSettle();
    await _scrollPast(tester);

    expect(_barTitle('BEANS'), findsOneWidget);

    await tester.pumpWidget(_page());
    await tester.pumpAndSettle();
    await _scrollPast(tester);

    expect(
      find.descendant(of: find.byType(SubHeader), matching: find.text('')),
      findsNothing,
      reason: 'the design draws no eyebrow line where there is no eyebrow',
    );
  });

  testWidgets('trailing controls sit on the right of the bar', (tester) async {
    await tester.pumpWidget(
      _page(trailing: const Icon(Icons.bookmark_border, key: Key('fav'))),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getCenter(find.byKey(const Key('fav'))).dx,
      greaterThan(tester.getCenter(find.byTooltip('Back')).dx),
    );
  });
}
