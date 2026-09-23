import 'dart:io';

import 'package:brew_path/core/widgets/scroll_flag_scope.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// What each screen passes for `threshold`, keyed by the file that passes it.
///
/// Read off the source, because the question is which screens leave the
/// default at all — and `lib/core/widgets/` is left out: those two declare the
/// parameter and forward it rather than choosing a value.
Map<String, String> _thresholdsChosenInLib() {
  final chosen = <String, String>{};
  final files = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .where((file) => !file.path.startsWith('lib/core/widgets/'));

  for (final file in files) {
    final passed = RegExp(
      r'^\s*threshold: (.+),$',
      multiLine: true,
    ).firstMatch(file.readAsStringSync());
    if (passed != null) chosen[file.path] = passed.group(1)!;
  }
  return chosen;
}

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
  test('the design gives three screens their own threshold, and no others', () {
    // A fourth screen quietly leaving the default is the drift this catches:
    // the bar is shared, so a threshold picked at one call site is invisible
    // at the others.
    expect(_thresholdsChosenInLib(), {
      'lib/features/saved/presentation/saved_screen.dart':
          '_shelfScrollThreshold',
      'lib/features/dictionary/presentation/term_of_day_screen.dart':
          'OffTokens.floatBarScrollFlag.value',
      'lib/features/mini_games/presentation/mini_game_intro_screen.dart':
          'OffTokens.floatBarScrollFlag.value',
    });
    expect(scrollFlagThreshold, 40);
    expect(OffTokens.floatBarScrollFlag.value, 8);
  });

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
