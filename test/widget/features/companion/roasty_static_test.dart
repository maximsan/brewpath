import 'package:coffee_quest/features/companion/domain/roasty_state.dart';
import 'package:coffee_quest/features/companion/presentation/roasty.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child, {bool disableAnimations = false}) => MediaQuery(
  data: MediaQueryData(disableAnimations: disableAnimations),
  child: Directionality(
    textDirection: TextDirection.ltr,
    child: Center(child: child),
  ),
);

void main() {
  testWidgets('an animated idle keeps the controller running', (tester) async {
    await tester.pumpWidget(_wrap(const Roasty(state: RoastyState.idle)));
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.hasRunningAnimations, isTrue);
  });

  testWidgets('animate:false renders a static frame', (tester) async {
    await tester.pumpWidget(
      _wrap(const Roasty(state: RoastyState.idle, animate: false)),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.hasRunningAnimations, isFalse);
    expect(find.byType(Roasty), findsOneWidget);
  });

  testWidgets('reduced motion forces static even with animate:true', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const Roasty(state: RoastyState.idle),
        disableAnimations: true,
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.hasRunningAnimations, isFalse);
  });
}
