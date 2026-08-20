import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/features/challenges/presentation/challenge_recap_sheet.dart';
import 'package:brew_path/features/companion/application/companion_providers.dart';
import 'package:brew_path/features/companion/domain/companion_lines.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/content_fixtures.dart';

/// One deterministic phrase, so the assertion is not a coin flip.
const _lines = CompanionLines({
  'challengeComplete': ['You actually brewed it.'],
});

void main() {
  Future<ChallengeRecapChoice?> openRecap(
    WidgetTester tester, {
    int points = 5,
    bool reduceMotion = true,
  }) async {
    ChallengeRecapChoice? choice;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          companionLinesProvider.overrideWith((ref) async => _lines),
        ],
        child: MaterialApp(
          theme: AppTheme.darkRoast,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(disableAnimations: reduceMotion),
            child: child!,
          ),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async => choice = await showChallengeRecapSheet(
                    context: context,
                    challenge: testChallenge(),
                    pointsAwarded: points,
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    // Never pumpAndSettle with Roasty on screen — it idles forever.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    return choice;
  }

  testWidgets('celebrates the brew and names what it paid', (tester) async {
    await openRecap(tester);

    expect(find.text('Two cups, two ratios'), findsOneWidget);
    expect(find.text('You actually brewed it.'), findsOneWidget);
    expect(find.text('+5 points'), findsOneWidget);
  });

  testWidgets('a replay celebrates without claiming a payout', (tester) async {
    await openRecap(tester, points: 0);

    expect(find.text('You actually brewed it.'), findsOneWidget);
    expect(find.textContaining('points'), findsNothing);
  });

  testWidgets('offers to run it again', (tester) async {
    await openRecap(tester);

    expect(find.text('Brew it again'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('renders its end state under reduced motion', (tester) async {
    await openRecap(tester);
    // Past the sheet's own entry transition, nothing should still be moving:
    // the companion holds a static frame rather than running a shortened
    // celebration.
    await tester.pump(const Duration(seconds: 1));

    expect(tester.hasRunningAnimations, isFalse);
    expect(find.text('You actually brewed it.'), findsOneWidget);
  });
}
