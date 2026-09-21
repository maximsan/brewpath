import 'package:brew_path/core/widgets/balanced_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _style = TextStyle(fontSize: 10, height: 1);
const _heading = 'Why two Ethiopias taste different';
const _box = 250.0;

Widget _harness({required bool boldText}) {
  return MediaQuery(
    data: MediaQueryData(boldText: boldText),
    child: const Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: SizedBox(
          width: _box,
          child: BalancedText(_heading, style: _style),
        ),
      ),
    ),
  );
}

double _laidOutWidth(WidgetTester tester) =>
    tester.getSize(find.byType(RichText)).width;

void main() {
  testWidgets('a heading that wraps is laid out narrower than its room', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(boldText: false));

    expect(_laidOutWidth(tester), lessThan(_box));
  });

  testWidgets('under Bold Text it hands the line back unbalanced', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(boldText: false));
    final balanced = _laidOutWidth(tester);

    await tester.pumpWidget(_harness(boldText: true));

    expect(
      _laidOutWidth(tester),
      greaterThan(balanced),
      reason:
          'the weight Bold Text paints is not one this can measure with, so '
          'it does not narrow a box against the wrong letterforms',
    );
    expect(_laidOutWidth(tester), _box);
  });
}
