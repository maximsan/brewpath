import 'package:brew_path/app/app_header.dart';
import 'package:brew_path/app/current_day.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The header on its own, for the things the whole-app test cannot reach —
/// chiefly the system's reduced-motion setting, which `BrewPathApp` builds its
/// own `MediaQuery` over.
Widget _harness({required bool isCollapsed, required bool disableAnimations}) {
  return ProviderScope(
    overrides: [
      currentDayProvider.overrideWithValue(DateTime(2026, 5, 8)),
    ],
    child: MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        // In a Column, as the shell places it: the header takes its natural
        // height and the tab gets the rest.
        child: Scaffold(
          body: Column(
            children: [
              AppHeader(
                location: AppRoutes.learn.path,
                isCollapsed: isCollapsed,
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    ),
  );
}

double _height(WidgetTester tester) =>
    tester.getSize(find.byType(AppHeader)).height;

void main() {
  testWidgets('collapsing drops the eyebrow and keeps the day', (tester) async {
    await tester.pumpWidget(
      _harness(isCollapsed: false, disableAnimations: true),
    );
    await tester.pumpAndSettle();
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('Friday, May 8'), findsOneWidget);
    final atRest = _height(tester);

    await tester.pumpWidget(
      _harness(isCollapsed: true, disableAnimations: true),
    );
    await tester.pumpAndSettle();

    expect(find.text('TODAY'), findsNothing);
    expect(
      find.text('Friday, May 8'),
      findsOneWidget,
      reason: 'the title is what the learner still needs on the way down',
    );
    expect(_height(tester), lessThan(atRest));
  });

  testWidgets('reduced motion settles the collapse in one frame', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(isCollapsed: false, disableAnimations: true),
    );
    await tester.pumpAndSettle();
    final atRest = _height(tester);

    await tester.pumpWidget(
      _harness(isCollapsed: true, disableAnimations: true),
    );
    await tester.pump();

    expect(
      _height(tester),
      lessThan(atRest),
      reason: 'no transition to wait out when the system asks for none',
    );
  });

  testWidgets('with motion allowed, the collapse takes frames', (tester) async {
    await tester.pumpWidget(
      _harness(isCollapsed: false, disableAnimations: false),
    );
    await tester.pumpAndSettle();
    final atRest = _height(tester);

    await tester.pumpWidget(
      _harness(isCollapsed: true, disableAnimations: false),
    );
    await tester.pump();

    expect(
      _height(tester),
      atRest,
      reason:
          'the first frame has not moved yet — this is what reduced '
          'motion is skipping',
    );
    await tester.pumpAndSettle();
    expect(_height(tester), lessThan(atRest));
  });
}
