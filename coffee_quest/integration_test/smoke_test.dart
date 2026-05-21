import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:coffee_quest/main.dart' as app;

/// End-to-end smoke flow: launch → play today's lesson → complete → see XP.
///
/// Assumes a clean install (no prior progress) — the first incomplete lesson
/// is `lesson_where_coffee`. CI runs this on a fresh simulator; for local
/// re-runs, erase the simulator first (Device → Erase All Content and Settings).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('open app, complete the first lesson, XP appears on Profile', (
    tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // Learn tab is the start destination.
    expect(find.text("Today's lesson"), findsOneWidget);

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
