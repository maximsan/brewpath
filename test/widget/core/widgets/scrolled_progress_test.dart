import 'package:brew_path/core/widgets/scrolled_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The one place the reduced-motion rule for a top bar's fade is written, so
/// it is asserted here once rather than on each bar that reads it.
Widget _harness({
  required bool isScrolled,
  required bool disableAnimations,
}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: disableAnimations),
    child: ScrolledProgress(
      isScrolled: isScrolled,
      duration: const Duration(milliseconds: 260),
      builder: (context, progress, child) => Text(
        progress.toStringAsFixed(2),
        textDirection: TextDirection.ltr,
      ),
    ),
  ),
);

void main() {
  testWidgets('starts at nothing, so a bar is invisible at rest', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(isScrolled: false, disableAnimations: false),
    );
    await tester.pumpAndSettle();

    expect(find.text('0.00'), findsOneWidget);
  });

  testWidgets('reduced motion arrives all the way in, in one frame', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(isScrolled: false, disableAnimations: true),
    );
    await tester.pumpAndSettle();

    await tester.pumpWidget(
      _harness(isScrolled: true, disableAnimations: true),
    );
    await tester.pump();

    expect(
      find.text('1.00'),
      findsOneWidget,
      reason:
          'a zero duration is safe on a TweenAnimationBuilder — it simply '
          'arrives on the next frame',
    );
  });

  testWidgets('with motion allowed it takes frames to get there', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(isScrolled: false, disableAnimations: false),
    );
    await tester.pumpAndSettle();

    await tester.pumpWidget(
      _harness(isScrolled: true, disableAnimations: false),
    );
    await tester.pump();

    expect(find.text('1.00'), findsNothing);

    await tester.pumpAndSettle();
    expect(find.text('1.00'), findsOneWidget);
  });
}
