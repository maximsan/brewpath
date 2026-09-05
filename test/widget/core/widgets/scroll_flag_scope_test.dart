import 'package:brew_path/core/widgets/scroll_flag_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A page that says whether it has scrolled, over a list, optionally with a
/// second list nested inside a row of it.
Widget _host({Object? resetKey, bool nested = false}) => MaterialApp(
  home: Scaffold(
    body: ScrollFlagScope(
      resetKey: resetKey,
      builder: (context, {required isScrolled}) => Column(
        children: [
          Text(isScrolled ? 'scrolled' : 'at rest'),
          Expanded(
            child: ListView(
              key: const Key('outer'),
              children: [
                if (nested)
                  SizedBox(
                    height: 80,
                    child: ListView(
                      key: const Key('inner'),
                      scrollDirection: Axis.horizontal,
                      children: List<Widget>.generate(
                        30,
                        (index) => SizedBox(width: 80, child: Text('x$index')),
                      ),
                    ),
                  ),
                ...List<Widget>.generate(
                  40,
                  (index) => SizedBox(height: 40, child: Text('$index')),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
);

void main() {
  testWidgets('reports the crossing to whatever it wraps', (tester) async {
    await tester.pumpWidget(_host());
    expect(find.text('at rest'), findsOneWidget);

    await tester.drag(find.byKey(const Key('outer')), const Offset(0, -200));
    await tester.pump();

    expect(find.text('scrolled'), findsOneWidget);
  });

  testWidgets('a scroller inside the content cannot flip the page bar', (
    tester,
  ) async {
    // The design's rule, written there as "currentTarget, not target": a
    // carousel inside a page is not the page moving.
    await tester.pumpWidget(_host(nested: true));

    await tester.drag(find.byKey(const Key('inner')), const Offset(-200, 0));
    await tester.pump();

    expect(find.text('at rest'), findsOneWidget);
  });

  testWidgets('swapping the content clears the flag', (tester) async {
    await tester.pumpWidget(_host(resetKey: 'beans'));
    await tester.drag(find.byKey(const Key('outer')), const Offset(0, -200));
    await tester.pump();
    expect(find.text('scrolled'), findsOneWidget);

    await tester.pumpWidget(_host(resetKey: 'brewing'));
    await tester.pump();

    expect(
      find.text('at rest'),
      findsOneWidget,
      reason: 'the flag described content that has gone',
    );
  });

  testWidgets('a rebuild with the same key leaves the flag alone', (
    tester,
  ) async {
    await tester.pumpWidget(_host(resetKey: 'beans'));
    await tester.drag(find.byKey(const Key('outer')), const Offset(0, -200));
    await tester.pump();
    expect(find.text('scrolled'), findsOneWidget);

    await tester.pumpWidget(_host(resetKey: 'beans'));
    await tester.pump();

    expect(
      find.text('scrolled'),
      findsOneWidget,
      reason: 'nothing changed underneath, so the bar has no reason to go',
    );
  });
}
