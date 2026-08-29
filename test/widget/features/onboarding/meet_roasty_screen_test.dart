import 'package:brew_path/features/companion/domain/roasty_state.dart';
import 'package:brew_path/features/companion/presentation/roasty.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/intro_router.dart';

Future<void> _pumpMeetRoasty(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp.router(
        routerConfig: introRouter(initialLocation: '/meet-roasty'),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  testWidgets('carries the companion copy Welcome used to wear', (
    tester,
  ) async {
    await _pumpMeetRoasty(tester);

    expect(find.text('YOUR COMPANION'), findsOneWidget);
    expect(find.text('Meet Roasty.'), findsOneWidget);
    expect(
      find.textContaining('Your talisman for the journey.'),
      findsOneWidget,
    );
  });

  testWidgets('this is the screen Roasty belongs on, smiling', (tester) async {
    await _pumpMeetRoasty(tester);

    final roasty = tester.widget<Roasty>(find.byType(Roasty));
    expect(roasty.state, RoastyState.correct);
  });

  testWidgets('the v1 CTA reads Start learning and moves the flow on', (
    tester,
  ) async {
    await _pumpMeetRoasty(tester);

    // Not `Set up my path` — that label is the v2 branch into the question
    // flow, which ADR-0010 keeps out of v1.
    expect(find.text('Set up my path'), findsNothing);

    final cta = find.widgetWithText(FilledButton, 'Start learning');
    expect(cta, findsOneWidget);

    await tester.ensureVisible(cta);
    await tester.pump();
    await tester.tap(cta);
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.text(nextStepStub), findsOneWidget);
  });

  testWidgets('ships no dead controls', (tester) async {
    await _pumpMeetRoasty(tester);

    expect(find.textContaining('Restore'), findsNothing);
    // `Skip — take me to lessons` is the v2 branch's escape hatch; v1 has one
    // way forward.
    expect(find.textContaining('Skip'), findsNothing);
  });
}
