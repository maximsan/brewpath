import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/mini_games/presentation/mini_game_intro_screen.dart';
import 'package:brew_path/features/mini_games/presentation/mini_game_player_screen.dart';
import 'package:brew_path/features/mini_games/presentation/mini_games_catalog_widget.dart';
import 'package:brew_path/shared/models/content/card_parts.dart';
import 'package:brew_path/shared/models/content/content_card.dart';
import 'package:brew_path/shared/models/content/mini_game_format.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/widget_harness.dart';

MiniGameFormat _format(String id, String title, {String topic = 'TOPIC'}) =>
    MiniGameFormat(
      id: id,
      kind: 'quiz',
      title: title,
      topic: topic,
      duration: '~1 MIN',
      blurb: 'Blurb for $title.',
      steps: const ['Read it', 'Answer it', 'Learn from it'],
    );

/// The catalog: g-quiz plays, the rest are listed only.
final List<MiniGameFormat> _formats = [
  _format('g-quiz', 'True or false', topic: 'COFFEE BASICS'),
  _format('g-match', 'Match the facts'),
  _format('g-flavor', 'Name the flavor notes'),
  _format('g-bagpick', 'Read the green bean'),
  _format('g-tastefix', 'Fix the cup'),
  _format('g-calibrate', 'Dial it in'),
  _format('g-sequence', 'Put it in order'),
];

/// Four of the six answer `true`, so always tapping True scores exactly 4 —
/// proving the run counts successes rather than rounds played.
const _trueRounds = 4;
const _rounds = <ContentCard>[
  ContentCard.quiz(statement: 'S1', answer: true, explanation: 'E1'),
  ContentCard.quiz(statement: 'S2', answer: true, explanation: 'E2'),
  ContentCard.quiz(statement: 'S3', answer: false, explanation: 'E3'),
  ContentCard.quiz(statement: 'S4', answer: true, explanation: 'E4'),
  ContentCard.quiz(statement: 'S5', answer: false, explanation: 'E5'),
  ContentCard.quiz(statement: 'S6', answer: true, explanation: 'E6'),
];

/// Two boards: enough to prove one faulted round scores zero while the run
/// still completes.
const _matchRounds = <ContentCard>[
  ContentCard.match(
    prompt: 'Board one',
    pairs: [
      MatchPair(left: 'Sweeter', right: 'Arabica'),
      MatchPair(left: 'More caffeine', right: 'Robusta'),
    ],
  ),
  ContentCard.match(
    prompt: 'Board two',
    pairs: [
      MatchPair(left: 'Low grown', right: 'Robusta'),
      MatchPair(left: 'Floral', right: 'Arabica'),
    ],
  ),
];

class _FakeContentRepository extends ContentRepository {
  @override
  Future<List<MiniGameFormat>> getMiniGameFormats() async => _formats;

  @override
  Future<List<ContentCard>> getMiniGameRounds(String formatId) async =>
      switch (formatId) {
        'g-quiz' => _rounds,
        'g-match' => _matchRounds,
        _ => const [],
      };
}

Future<void> _pump(
  WidgetTester tester, {
  bool disableAnimations = false,
}) async {
  tester.view.physicalSize = const Size(500, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final router = GoRouter(
    initialLocation: AppRoutes.learn.path,
    routes: [
      GoRoute(
        path: AppRoutes.learn.path,
        name: AppRoutes.learn.name,
        builder: (_, _) => Scaffold(
          body: SingleChildScrollView(
            child: MiniGamesCatalogWidget(formats: _formats),
          ),
        ),
        routes: [
          GoRoute(
            path: AppRoutes.miniGameIntro.path,
            name: AppRoutes.miniGameIntro.name,
            builder: (_, state) =>
                MiniGameIntroScreen(formatId: state.pathParameters['gameId']!),
            routes: [
              GoRoute(
                path: AppRoutes.miniGamePlay.path,
                name: AppRoutes.miniGamePlay.name,
                builder: (_, state) => MiniGamePlayerScreen(
                  formatId: state.pathParameters['gameId']!,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        contentRepositoryProvider.overrideWithValue(_FakeContentRepository()),
      ],
      child: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: MaterialApp.router(routerConfig: router),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Bounded pumps rather than `pumpAndSettle`: the results screen's companion
/// animates indefinitely, so settling would never return.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

/// Answers one round by tapping True, then continues.
Future<void> _answerTrueAndContinue(WidgetTester tester) async {
  await tester.tap(find.text('True'));
  await _settle(tester);
  await tester.tap(find.text('Continue'));
  await _settle(tester);
}

/// Clears the board on screen. [faultFirst] makes one wrong drop before
/// placing correctly, which must cost the round its score without stopping
/// the run.
Future<void> _clearBoard(
  WidgetTester tester,
  List<(String fact, String target)> pairs, {
  bool faultFirst = false,
}) async {
  if (faultFirst) {
    final (fact, target) = pairs.first;
    final wrong = pairs.firstWhere((pair) => pair.$2 != target).$2;
    await tester.tap(find.text(fact));
    await _settle(tester);
    await tester.tap(find.widgetWithText(OutlinedButton, wrong));
    await _settle(tester);
  }
  for (final (fact, target) in pairs) {
    await tester.tap(find.text(fact));
    await _settle(tester);
    await tester.tap(find.widgetWithText(OutlinedButton, target));
    await _settle(tester);
  }
  await tester.tap(find.text('Continue'));
  await _settle(tester);
}

void main() {
  // A finished run now records itself on the snapshot, so the flow needs a
  // store to write into.
  setUp(useInMemoryDatabase);

  testWidgets('the catalog lists every game name-led, in catalog order', (
    tester,
  ) async {
    await _pump(tester);

    for (final format in _formats) {
      expect(find.text(format.title), findsOneWidget);
    }
    expect(find.text('COFFEE BASICS'), findsOneWidget);
    expect(find.text('~1 MIN'), findsNWidgets(_formats.length));
  });

  testWidgets('a game with no renderer reaches its intro and cannot start', (
    tester,
  ) async {
    await _pump(tester);

    await tester.tap(find.text('Read the green bean'));
    await _settle(tester);

    // The row opened its intro like any other — the renderer gap is the
    // intro's to disclose, not the row's.
    expect(find.text('HOW TO PLAY'), findsOneWidget);
    expect(find.text('Play'), findsNothing);

    final action = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Not playable yet'),
    );
    expect(
      action.onPressed,
      isNull,
      reason: 'a game with no renderer must not start a run',
    );
  });

  testWidgets('every row opens its intro', (tester) async {
    for (final format in _formats) {
      await _pump(tester);
      await tester.tap(find.text(format.title));
      await _settle(tester);

      expect(
        find.text('HOW TO PLAY'),
        findsOneWidget,
        reason: '${format.id} did not reach its intro',
      );
    }
  });

  testWidgets('g-quiz plays catalog → intro → six rounds → results', (
    tester,
  ) async {
    await _pump(tester);

    await tester.tap(find.text('True or false'));
    await _settle(tester);

    // Intro: blurb and the three how-to-play steps, before any round runs.
    expect(find.text('Blurb for True or false.'), findsOneWidget);
    expect(find.text('Read it'), findsOneWidget);
    expect(find.text('Answer it'), findsOneWidget);

    await tester.tap(find.text('Play'));
    await _settle(tester);

    for (var round = 0; round < _rounds.length; round++) {
      expect(find.text('Continue'), findsOneWidget);
      await _answerTrueAndContinue(tester);
    }

    // Results: successes only, over rounds played.
    expect(find.text('$_trueRounds / ${_rounds.length}'), findsOneWidget);
    expect(find.text('Play again'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('continue is gated until the round latches', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('True or false'));
    await _settle(tester);
    await tester.tap(find.text('Play'));
    await _settle(tester);

    final continueButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Continue'),
    );
    expect(continueButton.onPressed, isNull);

    await tester.tap(find.text('True'));
    await _settle(tester);

    final latched = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Continue'),
    );
    expect(latched.onPressed, isNotNull);
  });

  testWidgets('Play again starts a fresh run at the first round', (
    tester,
  ) async {
    await _pump(tester);
    await tester.tap(find.text('True or false'));
    await _settle(tester);
    await tester.tap(find.text('Play'));
    await _settle(tester);
    for (var round = 0; round < _rounds.length; round++) {
      await _answerTrueAndContinue(tester);
    }

    await tester.tap(find.text('Play again'));
    await _settle(tester);

    expect(find.text('Play again'), findsNothing);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('results render statically under reduced motion', (tester) async {
    await _pump(tester, disableAnimations: true);
    await tester.tap(find.text('True or false'));
    await _settle(tester);
    await tester.tap(find.text('Play'));
    await _settle(tester);
    for (var round = 0; round < _rounds.length; round++) {
      await _answerTrueAndContinue(tester);
    }

    expect(find.text('$_trueRounds / ${_rounds.length}'), findsOneWidget);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('g-match plays, and a faulted board scores zero', (
    tester,
  ) async {
    await _pump(tester);

    await tester.tap(find.text('Match the facts'));
    await _settle(tester);
    await tester.tap(find.text('Play'));
    await _settle(tester);

    // Whichever board comes first this run, clear it the hard way.
    final firstIsBoardOne = find.text('Board one').evaluate().isNotEmpty;
    final first = firstIsBoardOne
        ? [('Sweeter', 'Arabica'), ('More caffeine', 'Robusta')]
        : [('Low grown', 'Robusta'), ('Floral', 'Arabica')];
    final second = firstIsBoardOne
        ? [('Low grown', 'Robusta'), ('Floral', 'Arabica')]
        : [('Sweeter', 'Arabica'), ('More caffeine', 'Robusta')];

    await _clearBoard(tester, first, faultFirst: true);
    await _clearBoard(tester, second);

    // The run completed, and the shortfall shows: one of two boards scored.
    expect(find.text('1 / 2'), findsOneWidget);
    expect(find.text('Play again'), findsOneWidget);
  });

  testWidgets('Done returns to where the learner came from', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('True or false'));
    await _settle(tester);
    await tester.tap(find.text('Play'));
    await _settle(tester);
    for (var round = 0; round < _rounds.length; round++) {
      await _answerTrueAndContinue(tester);
    }

    await tester.tap(find.text('Done'));
    await _settle(tester);

    expect(find.text('Match the facts'), findsOneWidget);
  });
}
