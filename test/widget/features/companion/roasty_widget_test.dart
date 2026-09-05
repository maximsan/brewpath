import 'package:brew_path/features/companion/domain/roasty_state.dart';
import 'package:brew_path/features/companion/presentation/roasty.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: Center(child: child),
);

void main() {
  testWidgets('renders each Roasty state without exceptions', (tester) async {
    for (final state in RoastyState.values) {
      // The points pose is the only one that needs an amount, and the only
      // one allowed to be given one.
      await tester.pumpWidget(
        _wrap(
          Roasty(
            state: state,
            size: 120,
            pointsAmount: state == RoastyState.points ? 12 : null,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        find.byType(Roasty),
        findsOneWidget,
        reason: 'failed to render state $state',
      );
    }
  });

  testWidgets('rebuilds when state changes (replay path)', (tester) async {
    var key = 0;
    Widget build(RoastyState s) =>
        _wrap(Roasty(state: s, size: 120, replayKey: key));

    await tester.pumpWidget(build(RoastyState.idle));
    await tester.pump(const Duration(milliseconds: 100));

    await tester.pumpWidget(build(RoastyState.correct));
    await tester.pump(const Duration(milliseconds: 50));

    key++;
    await tester.pumpWidget(build(RoastyState.correct));
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(Roasty), findsOneWidget);
  });

  testWidgets('the points pose and its amount cannot be split', (tester) async {
    // The mascot names no payout of its own (#16), so the amount arrives from
    // the caller — and a burst with nothing in it is half the pose.
    expect(
      () => Roasty(state: RoastyState.points, size: 120),
      throwsAssertionError,
    );
    expect(
      () => Roasty(state: RoastyState.correct, size: 120, pointsAmount: 12),
      throwsAssertionError,
    );

    await tester.pumpWidget(
      _wrap(
        const Roasty(state: RoastyState.points, size: 120, pointsAmount: 12),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(Roasty), findsOneWidget);
  });
}
