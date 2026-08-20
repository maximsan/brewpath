import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/features/challenges/presentation/challenge_log_sheet.dart';
import 'package:brew_path/shared/models/content/brew_challenge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/content_fixtures.dart';

/// The app's first modal bottom sheet.
void main() {
  /// Opens the sheet on a host that ignores the result.
  Future<void> openSheet(
    WidgetTester tester, {
    BrewChallenge? challenge,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkRoast,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showChallengeLogSheet(
                  context: context,
                  challenge: challenge ?? testChallenge(),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  /// The done button's callback — null while it is disabled.
  VoidCallback? doneAction(WidgetTester tester) => tester
      .widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Mark as done'),
      )
      .onPressed;

  testWidgets('asks the challenge its own question', (tester) async {
    await openSheet(tester);

    expect(find.text('Two cups, two ratios'), findsOneWidget);
    expect(find.text('WHICH CUP WON?'), findsOneWidget);
    expect(find.text('Preferred 1:15'), findsOneWidget);
    expect(find.text('Hard to tell'), findsOneWidget);
  });

  testWidgets('cannot be logged until an outcome is picked', (tester) async {
    await openSheet(tester);
    expect(doneAction(tester), isNull);

    await tester.tap(find.text('Preferred 1:15'));
    await tester.pumpAndSettle();

    expect(doneAction(tester), isNotNull);
  });

  testWidgets('re-tapping the chosen outcome clears it again', (tester) async {
    await openSheet(tester);

    await tester.tap(find.text('Preferred 1:15'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Preferred 1:15'));
    await tester.pumpAndSettle();

    expect(doneAction(tester), isNull);
  });

  testWidgets('resolves with the outcome the learner picked', (tester) async {
    ChallengeLogResult? result;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkRoast,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async => result = await showChallengeLogSheet(
                  context: context,
                  challenge: testChallenge(),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Preferred 1:17'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mark as done'));
    await tester.pumpAndSettle();

    expect((result! as ChallengeLogged).reaction, 'Preferred 1:17');
  });

  testWidgets('dismissing resolves with nothing at all', (tester) async {
    ChallengeLogResult? result;
    var resolved = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkRoast,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await showChallengeLogSheet(
                    context: context,
                    challenge: testChallenge(),
                  );
                  resolved = true;
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Pick an outcome first, then leave without committing to it: looking is
    // free, and only "Mark as done" is a claim that the brew happened.
    await tester.tap(find.text('Preferred 1:15'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(resolved, isTrue);
    expect(result, isNull);
  });

  testWidgets('lays out a record that authors only two outcomes', (
    tester,
  ) async {
    // `bc-m1l1` carries two. Nothing may assume three.
    await openSheet(
      tester,
      challenge: testChallenge(
        id: 'bc-m1l1',
        prompt: 'DID YOU FIND IT?',
        reactions: const ['Found it', 'Bag didn’t say'],
      ),
    );

    expect(find.text('Found it'), findsOneWidget);
    expect(find.text('Bag didn’t say'), findsOneWidget);
    expect(find.text('Hard to tell'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('save for later is a different answer from logging', (
    tester,
  ) async {
    ChallengeLogResult? result;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkRoast,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async => result = await showChallengeLogSheet(
                  context: context,
                  challenge: testChallenge(),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Available without picking anything: parking is not a claim about a brew.
    await tester.tap(find.text('Save for later'));
    await tester.pumpAndSettle();

    expect(result, isA<ChallengeSavedForLater>());
  });
}
