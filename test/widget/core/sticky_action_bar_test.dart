import 'dart:ui' show Tristate;

import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/widgets/sticky_action_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tall enough that it cannot fit any test viewport, so the scrolling cases
/// are really scrolling.
Widget _tallContent({int rows = 40}) => Column(
  children: [
    for (var index = 0; index < rows; index++)
      SizedBox(
        // Keyed, and asserted on by key rather than by its text: under a large
        // text scale the label outgrows this box, and the Text's own rect would
        // then measure the overflow rather than the row.
        key: ValueKey('row $index'),
        height: 40,
        child: Text('row $index'),
      ),
  ],
);

/// The last row of [_tallContent], as laid out.
Finder get _lastRow => find.byKey(const ValueKey('row 39'));

Widget _host(
  Widget content, {
  VoidCallback? onPressed,
  QuietLink? link,
  Widget? preface,
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
      preface: preface,
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
      expect(_lastRow, findsOneWidget);
      expect(
        tester.getRect(_lastRow).bottom,
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

  // The design pins a whole card above the action on the lesson ending — the
  // Coffee Challenge offer — and a support paragraph on the duel. Both travel
  // with the action rather than with the scrolling content, so the gradient
  // sits behind them.
  group('the preface', () {
    const offer = Key('offer');

    testWidgets('sits inside the bar, above the action', (tester) async {
      await tester.pumpWidget(
        _host(
          _tallContent(),
          preface: const SizedBox(key: offer, height: 60),
        ),
      );
      await tester.pumpAndSettle();

      final bar = _barRect(tester);
      final card = tester.getRect(find.byKey(offer));
      expect(card.top, greaterThanOrEqualTo(bar.top));
      expect(
        card.bottom,
        lessThanOrEqualTo(tester.getRect(find.byType(FilledButton)).top),
      );
    });

    testWidgets('grows the room reserved under the content', (tester) async {
      await tester.pumpWidget(_host(_tallContent()));
      await tester.pumpAndSettle();
      final plain = _barRect(tester).height;

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        _host(
          _tallContent(),
          preface: const SizedBox(key: offer, height: 60),
        ),
      );
      await tester.pumpAndSettle();

      expect(_barRect(tester).height, greaterThan(plain));
      await tester.drag(find.byType(Scrollable), const Offset(0, -4000));
      await tester.pumpAndSettle();
      expect(
        tester.getRect(_lastRow).bottom,
        lessThanOrEqualTo(_barRect(tester).top),
        reason: 'the preface grew the bar but not the room reserved under it',
      );
    });

    testWidgets('no preface leaves no gap where one would go', (tester) async {
      await tester.pumpWidget(_host(_tallContent()));
      await tester.pumpAndSettle();
      final plain = _barRect(tester).height;

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        _host(_tallContent(), preface: const SizedBox.shrink()),
      );
      await tester.pumpAndSettle();

      // A screen whose lesson carries no challenge renders `SizedBox.shrink`
      // here, and must be indistinguishable from one that never had a slot.
      expect(_barRect(tester).height, plain);
    });
  });

  group('the reserved room follows the bar, not a guess', () {
    testWidgets('a quiet link makes the bar taller, and room grows with it', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_tallContent()));
      await tester.pumpAndSettle();
      final plain = _barRect(tester).height;

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        _host(
          _tallContent(),
          link: const QuietLink(label: 'Back', onTap: null),
        ),
      );
      await tester.pumpAndSettle();

      expect(_barRect(tester).height, greaterThan(plain));
      await tester.drag(find.byType(Scrollable), const Offset(0, -4000));
      await tester.pumpAndSettle();
      expect(
        tester.getRect(_lastRow).bottom,
        lessThanOrEqualTo(_barRect(tester).top),
        reason: 'the link grew the bar but not the room reserved under it',
      );
    });

    testWidgets('the text scale growing after mount still clears the bar', (
      tester,
    ) async {
      // Turned up *after* the first frame on purpose. A bar measured only in
      // initState, or only on a widget update, is already correct when the
      // scale is set before mounting — so a test that scaled up front would
      // pass against the stale implementation and prove nothing.
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final barContent = _tallContent();

      await tester.pumpWidget(
        _host(barContent, link: const QuietLink(label: 'Back', onTap: null)),
      );
      await tester.pumpAndSettle();

      tester.platformDispatcher.textScaleFactorTestValue = 3;
      await tester.pumpAndSettle();

      await tester.drag(find.byType(Scrollable), const Offset(0, -8000));
      await tester.pumpAndSettle();

      expect(
        tester.getRect(_lastRow).bottom,
        lessThanOrEqualTo(_barRect(tester).top),
        reason:
            'the bar grew with the text scale but the room under it '
            'did not, so the last line is stranded behind it',
      );
    });
  });

  group('a screen reader gets the bar', () {
    testWidgets('the action is a button, by name', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const Text('body')));

      final node = tester
          .getSemantics(find.text('Start Keep Sharp'))
          .getSemanticsData();
      expect(node.label, 'Start Keep Sharp');
      expect(node.flagsCollection.isButton, isTrue);
      expect(node.hasAction(SemanticsAction.tap), isTrue);

      handle.dispose();
    });

    testWidgets('a disabled action says so rather than going quiet', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const Text('body'), enabled: false));

      final node = tester
          .getSemantics(find.text('Start Keep Sharp'))
          .getSemanticsData();
      expect(node.flagsCollection.isButton, isTrue);
      expect(
        node.flagsCollection.isEnabled,
        // Tristate, not a bool: "disabled" and "not a control at all" are
        // different answers, and only the first is right here.
        Tristate.isFalse,
        reason: 'a disabled action must read as disabled, not as absent',
      );

      handle.dispose();
    });

    testWidgets('the quiet link is its own button', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          const Text('body'),
          link: QuietLink(label: 'Back', onTap: () {}),
        ),
      );

      final node = tester.getSemantics(find.text('Back')).getSemanticsData();
      expect(node.label, 'Back');
      expect(node.flagsCollection.isButton, isTrue);

      handle.dispose();
    });
  });

  group('the bar absorbs the taps it covers', () {
    testWidgets('content behind the fade is not tappable through it', (
      tester,
    ) async {
      // A gradient paints nothing solid, so it is fair to ask whether the fade
      // is a hole a learner can tap through into the content scrolling under
      // it. It is not — the bar wins the hit test for its whole rectangle,
      // including the padding above and below the button. Nothing was added to
      // make that true, which is exactly why it is pinned here: it is a
      // property of the composition, and a refactor could take it away without
      // any other test noticing.
      var behind = 0;
      await tester.pumpWidget(
        _host(
          Column(
            children: [
              for (var index = 0; index < 40; index++)
                SizedBox(
                  key: ValueKey('tap $index'),
                  height: 40,
                  // Width matters: a ColoredBox has no intrinsic width, and a
                  // Column centres its children, so without this the tap
                  // targets are zero-wide and the test proves nothing.
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () => behind++,
                    child: const ColoredBox(color: Color(0xFF000000)),
                  ),
                ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Control first: the content really is tappable where the bar is not,
      // so a zero below means the bar absorbed the tap rather than that
      // nothing was listening.
      await tester.tapAt(const Offset(200, 100));
      await tester.pumpAndSettle();
      expect(behind, 1, reason: 'the fixture is not tappable at all');

      final bar = _barRect(tester);
      // A point inside the bar's fade, above the button and clear of it.
      await tester.tapAt(Offset(bar.center.dx, bar.top + 1));
      await tester.pumpAndSettle();

      expect(behind, 1, reason: 'a tap fell through the bar to the content');
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
