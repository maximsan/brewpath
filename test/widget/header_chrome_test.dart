import 'dart:io';

import 'package:brew_path/app/header_chrome.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The bar chrome on its own: what it paints, what it costs at rest, and the
/// fact that a finger on it still belongs to the page underneath.
Widget _harness({
  required bool isScrolled,
  bool disableAnimations = true,
  ScrollController? controller,
}) {
  return MaterialApp(
    theme: ThemeData(extensions: const [MoodColors.darkRoast]),
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            ListView.builder(
              controller: controller,
              itemCount: 40,
              itemBuilder: (context, index) =>
                  SizedBox(height: 40, child: Text('row $index')),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: HeaderChrome(
                height: HeaderChrome.tabHeight,
                isScrolled: isScrolled,
                child: const Text('bar'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// The decoration the bar paints itself with.
BoxDecoration _fill(WidgetTester tester) =>
    tester
            .widgetList<DecoratedBox>(find.byType(DecoratedBox))
            .firstWhere(
              (box) => (box.decoration as BoxDecoration).border != null,
            )
            .decoration
        as BoxDecoration;

void main() {
  test('stands as tall as the design draws it, over the inset it measures', () {
    // The design writes the tab bar's height including the status bar it is
    // drawn over. On a device that band is the top inset instead, so the
    // constant here is the difference — and both halves are read back out of
    // the bundle rather than trusted.
    final drawn = RegExp(
      r'StickyHeaderChrome scrolled=\{scrolled\} height=\{(\d+)\}',
    ).firstMatch(File('prototype/screens.jsx').readAsStringSync());
    final statusBar = RegExp(
      r'\.status-bar\s*\{[^}]*height:\s*(\d+)px',
    ).firstMatch(File('prototype/index.html').readAsStringSync());

    expect(drawn, isNotNull, reason: 'the bundle no longer sizes its tab bar');
    expect(statusBar, isNotNull, reason: 'the bundle has no status bar to sit');

    expect(
      HeaderChrome.tabHeight,
      double.parse(drawn!.group(1)!) - double.parse(statusBar!.group(1)!),
    );
  });

  testWidgets('at rest it paints nothing and pays for no filter', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(isScrolled: false));
    await tester.pumpAndSettle();

    expect(
      _fill(tester).color?.a ?? 0,
      0,
      reason: 'the design keeps the bar transparent until the page moves',
    );
    expect(_fill(tester).border!.bottom.color.a, 0);
    expect(
      find.byType(BackdropFilter),
      findsNothing,
      reason:
          'a BackdropFilter costs a saveLayer at any sigma, so an invisible '
          'bar must not mount one at all',
    );
  });

  testWidgets('scrolled, it fills, rules and blurs', (tester) async {
    await tester.pumpWidget(_harness(isScrolled: true));
    await tester.pumpAndSettle();

    expect(
      _fill(tester).color,
      MoodColors.darkRoast.headerFill.color,
      reason: 'the bar is the page pulled over itself at the design opacity',
    );
    expect(_fill(tester).border!.bottom.color, MoodColors.darkRoast.rule);
    expect(find.byType(BackdropFilter), findsOneWidget);
  });

  testWidgets('reduced motion arrives filled in one frame', (tester) async {
    await tester.pumpWidget(_harness(isScrolled: false));
    await tester.pumpAndSettle();

    await tester.pumpWidget(_harness(isScrolled: true));
    await tester.pump();

    expect(_fill(tester).color, MoodColors.darkRoast.headerFill.color);
  });

  testWidgets('a drag that starts on the bar still scrolls the page', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _harness(isScrolled: true, controller: controller),
    );
    await tester.pumpAndSettle();

    // Started inside the bar's own box: the design gives the chrome no pointer
    // events, because the page goes on underneath it.
    await tester.dragFrom(
      tester.getCenter(find.byType(HeaderChrome)),
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();

    expect(controller.offset, greaterThan(0));
  });
}
