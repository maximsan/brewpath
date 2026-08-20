import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/features/challenges/presentation/active_challenge_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/content_fixtures.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    String effort = 'Next brews · 5 min',
    bool reduceMotion = false,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.darkRoast,
      home: Scaffold(
        body: ActiveChallengeCard(challenge: testChallenge(effort: effort)),
      ),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
        child: child!,
      ),
    ),
  );

  testWidgets('names itself, the brew, and what it asks for', (tester) async {
    await pump(tester);

    expect(find.text('COFFEE CHALLENGE'), findsOneWidget);
    expect(find.text('Two cups, two ratios'), findsOneWidget);
    expect(
      find.text('Brew the same coffee twice at two different ratios.'),
      findsOneWidget,
    );
    expect(find.text('Next brews · 5 min'), findsOneWidget);
  });

  testWidgets('reads as one sentence to a screen reader', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester);

    expect(
      find.bySemanticsLabel(
        RegExp('Coffee Challenge. Two cups, two ratios..*Next brews.*5 min'),
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('renders an effort string that authors only one half', (
    tester,
  ) async {
    await pump(tester, effort: 'Next brews');

    // No stray separator for a half that was never written.
    expect(find.text('Next brews'), findsOneWidget);
  });

  testWidgets('is identical under reduced motion, having no motion', (
    tester,
  ) async {
    await pump(tester, reduceMotion: true);
    await tester.pump();

    expect(tester.hasRunningAnimations, isFalse);
    expect(find.text('Two cups, two ratios'), findsOneWidget);
  });
}
