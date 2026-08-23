import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/widgets/app_sheet.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The sheet primitive's contract, pinned once here rather than against
/// whichever caller happened to be written first.
///
/// Everything asserted below is something a learner or a screen reader can
/// observe: the title that appears, the name the sheet is announced by, the
/// handle, whether long content scrolls instead of overflowing, and whether the
/// sheet slides or is simply there. Nothing here asserts the widget tree's
/// shape, which can change while the sheet behaves identically.
void main() {
  /// Pumps a screen with one button that opens a sheet, and taps it.
  Future<void> openSheet(
    WidgetTester tester, {
    required Widget content,
    String title = 'Sheet title',
    bool reduceMotion = false,
    bool settle = true,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkRoast,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(disableAnimations: reduceMotion),
          child: child!,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showAppSheet<void>(
                  context: context,
                  title: title,
                  builder: (_) => content,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }

  testWidgets('the sheet opens on its title, above the content', (
    tester,
  ) async {
    await openSheet(
      tester,
      title: 'Washed, natural, honey',
      content: const Text('body copy'),
    );

    expect(find.text('Washed, natural, honey'), findsOneWidget);
    expect(find.text('body copy'), findsOneWidget);

    final titleY = tester.getTopLeft(find.text('Washed, natural, honey')).dy;
    final bodyY = tester.getTopLeft(find.text('body copy')).dy;
    expect(titleY, lessThan(bodyY));
  });

  testWidgets('the sheet is announced by the same string it shows', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();

    await openSheet(
      tester,
      title: 'Reading a bag label',
      content: const Text('body copy'),
    );

    // The region carries the name, and the visible heading carries the same
    // one — one string feeds both, so they cannot drift apart.
    expect(
      find.bySemanticsLabel('Reading a bag label'),
      findsWidgets,
      reason: 'the sheet should be announced by its title',
    );

    handle.dispose();
  });

  testWidgets('a drag handle is present on every sheet', (tester) async {
    await openSheet(tester, content: const Text('body copy'));

    // The handle is the one decorated box drawn in the mood's rule colour.
    const mood = MoodColors.darkRoast;
    final handles = tester.widgetList<Container>(find.byType(Container)).where((
      container,
    ) {
      final decoration = container.decoration;
      return decoration is BoxDecoration && decoration.color == mood.rule;
    });

    expect(handles, isNotEmpty, reason: 'the sheet should show a drag handle');
  });

  testWidgets('long content scrolls inside the sheet rather than overflowing', (
    tester,
  ) async {
    await openSheet(
      tester,
      content: Column(
        children: List.generate(
          40,
          (index) => SizedBox(height: 40, child: Text('row $index')),
        ),
      ),
    );

    // No overflow was thrown, and the content moves under a drag.
    expect(tester.takeException(), isNull);

    final firstRowY = tester.getTopLeft(find.text('row 0')).dy;
    await tester.drag(find.text('row 0'), const Offset(0, -200));
    await tester.pump();

    expect(tester.getTopLeft(find.text('row 0')).dy, lessThan(firstRowY));
  });

  testWidgets('with reduced motion the sheet is at rest on the first frame', (
    tester,
  ) async {
    await openSheet(
      tester,
      title: 'Settled',
      content: const Text('body copy'),
      reduceMotion: true,
      settle: false,
    );

    final atOnce = tester.getTopLeft(find.text('Settled')).dy;
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.text('Settled')).dy,
      atOnce,
      reason: 'a reduced-motion sheet should not travel after its first frame',
    );
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('without reduced motion the sheet still slides in', (
    tester,
  ) async {
    await openSheet(
      tester,
      title: 'Sliding',
      content: const Text('body copy'),
      settle: false,
    );

    final entering = tester.getTopLeft(find.text('Sliding')).dy;
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.text('Sliding')).dy,
      lessThan(entering),
      reason: 'the default transition should still animate the sheet upward',
    );
  });

  testWidgets('a sheet opened from inside a sheet stacks, and unwinds to it', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkRoast,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showAppSheet<void>(
                  context: context,
                  title: 'First',
                  builder: (inner) => TextButton(
                    onPressed: () => showAppSheet<void>(
                      context: inner,
                      title: 'Second',
                      builder: (_) => const Text('second body'),
                    ),
                    child: const Text('go deeper'),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('go deeper'));
    await tester.pumpAndSettle();

    // Both are mounted: the second stacks above the first rather than
    // replacing it — the navigator stack is the z-order.
    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsOneWidget);

    // Popping the inner one leaves the outer intact.
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pop();
    await tester.pumpAndSettle();

    expect(find.text('Second'), findsNothing);
    expect(find.text('First'), findsOneWidget);
  });
}
