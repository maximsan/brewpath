import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/widgets/sticky_action_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tall enough that it cannot fit any test viewport, so the scrolling cases
/// are really scrolling.
Widget _tallContent({int rows = 40}) => Column(
  children: [
    for (var index = 0; index < rows; index++)
      SizedBox(height: 40, child: Text('row $index')),
  ],
);

Widget _host(
  Widget content, {
  VoidCallback? onPressed,
  QuietLink? link,
  bool darkRoast = false,
  // Separate from a null `onPressed`, which is the disabled state under test —
  // defaulting the callback would quietly make that case untestable.
  bool enabled = true,
}) => MaterialApp(
  theme: darkRoast ? AppTheme.darkRoast : AppTheme.cupping,
  home: Scaffold(
    body: StickyActionBar(
      label: 'Start Keep Sharp',
      onPressed: enabled ? (onPressed ?? () {}) : null,
      link: link,
      content: content,
    ),
  ),
);

/// The pinned bar's own rectangle, found by the gradient it paints.
Rect _barRect(WidgetTester tester) => tester.getRect(
  find
      .descendant(
        of: find.byType(StickyActionBar),
        matching: find.byType(DecoratedBox),
      )
      .last,
);

/// The gradient the bar paints itself over.
LinearGradient _gradient(WidgetTester tester) {
  final decorated = tester.widgetList<DecoratedBox>(
    find.descendant(
      of: find.byType(StickyActionBar),
      matching: find.byType(DecoratedBox),
    ),
  );
  return decorated
      .map((box) => box.decoration)
      .whereType<BoxDecoration>()
      .map((decoration) => decoration.gradient)
      .whereType<LinearGradient>()
      .single;
}

void main() {
  group('the bar and its action', () {
    testWidgets('shows the content and the action', (tester) async {
      await tester.pumpWidget(_host(const Text('You finished Foundations')));

      expect(find.text('You finished Foundations'), findsOneWidget);
      expect(find.text('Start Keep Sharp'), findsOneWidget);
    });

    testWidgets('the action is announced as a button and fires once', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(const Text('body'), onPressed: () => taps++),
      );

      // Found once, not twice: nothing offstage duplicates the label, which a
      // space-reserving copy of the bar would have done.
      expect(find.text('Start Keep Sharp'), findsOneWidget);
      await tester.tap(find.text('Start Keep Sharp'));
      await tester.pumpAndSettle();

      expect(taps, 1);
    });

    testWidgets('a disabled action is still shown, not hidden', (tester) async {
      await tester.pumpWidget(_host(const Text('body'), enabled: false));

      expect(find.text('Start Keep Sharp'), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
    });
  });

  group('one primary action, and at most a quiet link', () {
    testWidgets('the link renders beneath the action when given', (
      tester,
    ) async {
      var followed = 0;
      await tester.pumpWidget(
        _host(
          const Text('body'),
          link: QuietLink(label: 'Back', onTap: () => followed++),
        ),
      );

      expect(find.text('Back'), findsOneWidget);
      expect(
        tester.getRect(find.text('Back')).top,
        greaterThan(tester.getRect(find.text('Start Keep Sharp')).bottom),
        reason: 'the quiet link sits under the action, never beside it',
      );

      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      expect(followed, 1);
    });

    testWidgets('no link means no second action in the bar', (tester) async {
      await tester.pumpWidget(_host(const Text('body')));

      // The API takes one label and one optional link, so a second primary
      // action is not expressible — this pins that nothing renders one anyway.
      expect(find.byType(FilledButton), findsOneWidget);
      expect(
        find.byType(TextButton),
        findsNothing,
        reason: 'a bar with no link still drew the quiet slot',
      );
    });
  });

  group('content scrolls beneath the bar', () {
    testWidgets('a long screen can be scrolled to its true end', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_tallContent()));

      await tester.drag(find.byType(Scrollable), const Offset(0, -4000));
      await tester.pumpAndSettle();

      // The last row must clear the bar at the end of the scroll. Without the
      // bar's own height reserved below the content, it sits behind the bar
      // and no amount of scrolling reveals it.
      final lastRow = find.text('row 39');
      expect(lastRow, findsOneWidget);
      expect(
        tester.getRect(lastRow).bottom,
        lessThanOrEqualTo(_barRect(tester).top),
        reason: 'the bar permanently hides the last of the content',
      );
    });

    testWidgets('mid-scroll, content passes behind the bar', (tester) async {
      // The whole point of the gradient. A footer that content stopped above
      // would satisfy every other test here.
      await tester.pumpWidget(_host(_tallContent()));

      await tester.drag(find.byType(Scrollable), const Offset(0, -600));
      await tester.pump();

      final bar = _barRect(tester);
      final overlapped = [
        for (var index = 0; index < 40; index++)
          if (tester.any(find.text('row $index')))
            tester.getRect(find.text('row $index')),
      ].where((row) => row.bottom > bar.top && row.top < bar.bottom);

      expect(
        overlapped,
        isNotEmpty,
        reason: 'no content is behind the bar, so it is not an overlay',
      );
    });

    testWidgets('short content is centred rather than pinned to the top', (
      tester,
    ) async {
      // The design centres a short moment (`margin: auto 0`) and scrolls a
      // long one; a completion screen is usually the former.
      await tester.pumpWidget(_host(const Text('body')));

      final body = tester.getRect(find.text('body'));
      final viewport = tester.getRect(find.byType(StickyActionBar));
      expect(
        body.center.dy,
        greaterThan(viewport.top + viewport.height / 4),
        reason: 'short content was pinned to the top instead of centred',
      );
    });
  });

  group('the gradient', () {
    testWidgets('fades from the page background to transparent', (
      tester,
    ) async {
      await tester.pumpWidget(_host(const Text('body')));

      final gradient = _gradient(tester);
      expect(gradient.begin, Alignment.bottomCenter);
      expect(gradient.end, Alignment.topCenter);
      expect(gradient.colors.last.a, 0, reason: 'the top must be transparent');
    });

    testWidgets('takes the page background from the mood, not a literal', (
      tester,
    ) async {
      await tester.pumpWidget(_host(const Text('body')));
      final cupping = _gradient(tester).colors.first;

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(_host(const Text('body'), darkRoast: true));
      final darkRoast = _gradient(tester).colors.first;

      expect(
        cupping,
        isNot(darkRoast),
        reason: 'the gradient is the same colour in both moods',
      );
    });
  });
}
