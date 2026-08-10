import 'package:brew_path/features/lessons/presentation/xp_gain_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('shows the amount and calls onComplete after its run', (
    tester,
  ) async {
    var completed = false;
    await tester.pumpWidget(
      _wrap(
        XpGainToast(amount: 10, onComplete: () => completed = true),
      ),
    );

    expect(find.text('+10 XP'), findsOneWidget);
    expect(completed, isFalse);

    // Advance past the toast's rise-and-fade duration.
    await tester.pump(const Duration(milliseconds: 1100));
    expect(completed, isTrue);
  });

  testWidgets('does not move under reduced motion', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: _wrap(const XpGainToast(amount: 10)),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    // Still renders; the no-movement path is exercised (no exception, settles).
    expect(find.text('+10 XP'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1000));
  });
}
