import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:coffee_quest/main.dart' as app;

/// End-to-end smoke flow:
///   1. cold-launch → onboarding (loading → welcome → goal → brewer → learn),
///   2. complete today's lesson → see XP on Profile.
///
/// Assumes a clean install (no prior progress). The onboarding gate sends
/// new users through /welcome on first run.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('cold launch routes through onboarding then into Learn', (
    tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // Loading screen runs a Roasty wake-up loop; tap-anywhere skip after
    // the first cycle. Pump enough to cross the 6-step state machine.
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    if (find.text('TAP ANYWHERE TO CONTINUE').evaluate().isNotEmpty) {
      await tester.tap(find.text('TAP ANYWHERE TO CONTINUE'));
      await tester.pumpAndSettle();
    }

    // Welcome screen.
    expect(find.text('COFFEE QUEST'), findsOneWidget);
    final plantSeed = find.widgetWithText(FilledButton, 'Plant your seed');
    await tester.ensureVisible(plantSeed);
    await tester.pump();
    await tester.tap(plantSeed);
    await tester.pumpAndSettle();

    // Goal pick.
    expect(find.text('What brings you here?'), findsOneWidget);
    await tester.tap(find.text('Brew better at home'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();

    // Brewer pick.
    expect(find.text('What do you brew with?'), findsOneWidget);
    await tester.tap(find.text('V60'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();

    // Lands on Learn.
    expect(find.text("Today's lesson"), findsOneWidget);
  });

  testWidgets('returning user lands on Learn without onboarding screens', (
    tester,
  ) async {
    // Relies on the previous test having marked onboarding complete in the
    // shared Drift DB (same simulator process).
    app.main();
    await tester.pumpAndSettle();

    // Loading screen briefly; auto-advances to Learn since onboarding is done.
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    expect(find.text('What brings you here?'), findsNothing);
    expect(find.text("Today's lesson"), findsOneWidget);
  });

  testWidgets('play today\'s lesson, complete, see XP on Profile', (
    tester,
  ) async {
    // Open today's lesson from the card (its subtitle is the lesson title).
    await tester.tap(find.text('Where Coffee Comes From'));
    await tester.pumpAndSettle();

    // Lesson screen shows the step progress indicator.
    expect(find.textContaining('Step 1 of'), findsOneWidget);

    // Answer the multiple-choice step correctly, then advance.
    await tester.tap(find.text('The Bean Belt'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();

    // Completion screen shows the XP reward.
    expect(find.text('Lesson complete!'), findsOneWidget);
    expect(find.textContaining('XP'), findsWidgets);

    // Continue back to the Learn tab.
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();

    // Profile tab now reflects the earned XP.
    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();
    expect(find.text('Total XP'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
  });
}
