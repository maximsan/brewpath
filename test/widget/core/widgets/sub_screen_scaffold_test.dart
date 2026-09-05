import 'package:brew_path/core/icons/app_icon.dart';
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

  testWidgets('the page opens below the bar, not behind it', (tester) async {
    await tester.pumpWidget(_page());
    await tester.pumpAndSettle();

    expect(
      tester.getRect(find.byType(PageLargeTitle)).top,
      greaterThanOrEqualTo(SubHeader.height),
      reason:
          'a pushed page carries a control at every scroll position, so its '
          'title must clear the bar rather than open under it',
    );
  });

  testWidgets('the way back says what it does, and does it', (tester) async {
    var popped = 0;
    await tester.pumpWidget(_page(onBack: () => popped++));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Back'));
    expect(popped, 1);
  });

  testWidgets('a page you dismiss says Close instead', (tester) async {
    await tester.pumpWidget(_page(mark: AppIcon.close));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.byTooltip('Back'), findsNothing);
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
