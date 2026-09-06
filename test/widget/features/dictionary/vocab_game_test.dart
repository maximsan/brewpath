// The drill end to end: setup, a round, the score — and what reaching the
// score writes down.
import 'dart:async';

import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/core/widgets/drill_results_view.dart';
import 'package:brew_path/core/widgets/pick_card.dart';
import 'package:brew_path/core/widgets/roast_meter.dart';
import 'package:brew_path/features/dictionary/domain/vocab_providers.dart';
import 'package:brew_path/features/dictionary/domain/vocab_round.dart';
import 'package:brew_path/features/dictionary/domain/vocab_setup.dart';
import 'package:brew_path/features/dictionary/presentation/vocab/vocab_copy.dart';
import 'package:brew_path/features/dictionary/presentation/vocab/vocab_game_screen.dart';
import 'package:brew_path/features/dictionary/presentation/vocab/vocab_teaching_view.dart';
import 'package:brew_path/features/monetization/domain/plus_copy.dart';
import 'package:brew_path/features/progress/domain/activity_recorder.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/storage/snapshot/daily_activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../support/widget_harness.dart';

/// Eight real terms from the shipped dictionary, four in each of two real
/// categories — enough for the Quick round, and enough that a same-category
/// wrong answer always exists. Copied from
/// `assets/content/generated/dictionary_terms.json` so a question in a test
/// reads exactly as one in the app does.
const List<DictionaryTerm> _accessible = [
  DictionaryTerm(
    id: 'arabica',
    term: 'Arabica',
    categoryId: 'beans',
    shortExplanation:
        'The coffee species behind most specialty coffee — sweeter, more '
        'aromatic, and more delicate to grow.',
  ),
  DictionaryTerm(
    id: 'robusta',
    term: 'Robusta',
    categoryId: 'beans',
    shortExplanation:
        'A tougher coffee species with nearly double the caffeine — bolder, '
        'more bitter, and easier to farm.',
  ),
  DictionaryTerm(
    id: 'cherry',
    term: 'Coffee Cherry',
    categoryId: 'beans',
    shortExplanation:
        'The fruit of the coffee plant. Each cherry usually holds two seeds '
        '— the “beans” we roast.',
  ),
  DictionaryTerm(
    id: 'bean-belt',
    term: 'Bean Belt',
    categoryId: 'beans',
    shortExplanation:
        'The band around the equator, roughly 25°N to 25°S, where coffee '
        'grows best.',
  ),
  DictionaryTerm(
    id: 'espresso',
    term: 'Espresso',
    categoryId: 'espresso',
    shortExplanation:
        'A small, concentrated coffee pulled by forcing hot water through '
        'finely ground coffee under about 9 bars of pressure.',
  ),
  DictionaryTerm(
    id: 'crema',
    term: 'Crema',
    categoryId: 'espresso',
    shortExplanation:
        'The reddish-brown foam on top of an espresso shot, made of '
        'emulsified oils and CO₂.',
  ),
  DictionaryTerm(
    id: 'tamp',
    term: 'Tamp',
    categoryId: 'espresso',
    shortExplanation:
        'Pressing the espresso grounds flat and firm in the portafilter for '
        'an even shot.',
  ),
  DictionaryTerm(
    id: 'portafilter',
    term: 'Portafilter',
    categoryId: 'espresso',
    shortExplanation:
        'The handled basket that holds the coffee grounds and locks into an '
        'espresso machine.',
  ),
];

VocabPools _pools({
  List<DictionaryTerm>? accessible,
  int saved = 0,
  int missed = 0,
  bool hasCourse = false,
}) {
  final pool = accessible ?? _accessible;
  return VocabPools(
    accessible: pool,
    saved: pool.take(saved).toList(),
    // Taken from the far end, so a fixture with both decks full does not make
    // them the same terms and hide a deck that reads the wrong list.
    missed: pool.reversed.take(missed).toList(),
    // Every saved term here is one the pool reaches, which is what these
    // tests are about; the out-of-reach split is #468's, on Flashcards.
    savedEligible: saved,
    hasCourse: hasCourse,
    categoryLabels: const {
      'beans': 'Beans and Botany',
      'espresso': 'Espresso',
    },
  );
}

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  VocabPools? pools,
}) async {
  tester.view.physicalSize = const Size(500, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await useInMemoryDatabase();

  final container = ProviderContainer(
    overrides: [
      vocabPoolsProvider.overrideWith((ref) async => pools ?? _pools()),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: VocabGameScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

/// Answers the question on screen, correctly or not, and moves on.
Future<void> answer(WidgetTester tester, {required bool correctly}) async {
  final asked = _accessible.firstWhere(
    (term) => find.text(term.shortExplanation).evaluate().isNotEmpty,
    orElse: () => throw StateError('no question on screen'),
  );
  final name = asked.term;

  final choices = find.byType(OutlinedButton);
  final labels = [
    for (var index = 0; index < choices.evaluate().length; index++)
      tester
          .widget<Text>(
            find
                .descendant(of: choices.at(index), matching: find.byType(Text))
                .first,
          )
          .data,
  ];
  final wanted = correctly
      ? labels.indexOf(name)
      : labels.indexWhere((label) => label != name);

  await tester.tap(choices.at(wanted));
  await tester.pumpAndSettle();
}

/// Bounded pumps rather than `pumpAndSettle`: the results screen's companion
/// animates indefinitely, so settling would never return.
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> playThrough(
  WidgetTester tester, {
  required int rounds,
  bool correctly = true,
}) async {
  for (var round = 0; round < rounds; round++) {
    await answer(tester, correctly: correctly);
    final isLast = round == rounds - 1;
    await tester.tap(find.text(isLast ? VocabCopy.seeScore : VocabCopy.next));
    if (isLast) {
      await settle(tester);
    } else {
      await tester.pumpAndSettle();
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('leaving the drill', () {
    testWidgets('close returns where the drill was opened from', (
      tester,
    ) async {
      // Both entry points push, so Close pops: a learner who was browsing the
      // dictionary gets the dictionary back rather than being dropped on Today
      // having lost their place.
      await useInMemoryDatabase();

      final router = GoRouter(
        initialLocation: '/learn',
        routes: [
          GoRoute(
            path: '/learn',
            name: AppRoutes.learn.name,
            builder: (_, _) => const Scaffold(body: Text('where I was')),
            routes: [
              GoRoute(
                path: AppRoutes.vocabGame.path,
                name: AppRoutes.vocabGame.name,
                builder: (_, _) => const VocabGameScreen(),
              ),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vocabPoolsProvider.overrideWith((ref) async => _pools()),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      unawaited(router.pushNamed<void>(AppRoutes.vocabGame.name));
      await tester.pumpAndSettle();
      expect(find.text(VocabCopy.start), findsOneWidget);

      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();

      expect(find.text('where I was'), findsOneWidget);
    });
  });

  group('setup', () {
    testWidgets('opens on the deck and length choices', (tester) async {
      await _pump(tester);

      expect(find.text(VocabCopy.title), findsOneWidget);
      expect(find.text(VocabCopy.deckHeading.toUpperCase()), findsOneWidget);
      expect(find.text(VocabCopy.lengthHeading.toUpperCase()), findsOneWidget);
      expect(find.text(VocabCopy.start), findsOneWidget);
    });

    testWidgets('offers only the lengths the pool can fill', (tester) async {
      // Eight terms: Quick and Standard fit, Deep does not — and the one that
      // does not is shown dimmed rather than hidden, so the ladder is legible.
      await _pump(tester);

      for (final length in vocabLengths) {
        expect(find.text('$length'), findsOneWidget);
      }
      expect(
        find.text(VocabCopy.lengthNames[vocabLengths.first]!),
        findsOneWidget,
      );
    });

    testWidgets('the saved deck is unavailable until four are saved', (
      tester,
    ) async {
      await _pump(tester, pools: _pools(saved: vocabMinimumPool - 1));

      expect(find.textContaining(VocabCopy.savedDeckShort), findsOneWidget);
    });

    testWidgets('a full saved shelf opens the deck and is the default', (
      tester,
    ) async {
      await _pump(tester, pools: _pools(saved: vocabMinimumPool));

      expect(find.textContaining(VocabCopy.savedDeckReady), findsOneWidget);
    });

    testWidgets("a free learner's All deck is not called the glossary", (
      tester,
    ) async {
      await _pump(tester);

      expect(find.textContaining(VocabCopy.yourTermsDeck), findsOneWidget);
      expect(find.textContaining(VocabCopy.yourTermsNote), findsOneWidget);
      expect(find.textContaining(VocabCopy.allDeckNote), findsNothing);
    });

    testWidgets('a paying learner is told they get the whole glossary', (
      tester,
    ) async {
      // The deck must not tell them the free learner's story: theirs really
      // is every term, reference entries included.
      await _pump(tester, pools: _pools(hasCourse: true));

      expect(find.textContaining(VocabCopy.allDeck), findsOneWidget);
      expect(find.textContaining(VocabCopy.allDeckNote), findsOneWidget);
      expect(find.textContaining(VocabCopy.yourTermsNote), findsNothing);
    });

    testWidgets('the misses deck is unavailable until four are owed', (
      tester,
    ) async {
      await _pump(tester, pools: _pools(missed: vocabMinimumPool - 1));

      expect(find.textContaining(VocabCopy.missesDeck), findsOneWidget);
      expect(find.textContaining(VocabCopy.missesDeckShort), findsOneWidget);

      final deck = tester.widget<PickCard>(
        find.ancestor(
          of: find.textContaining(VocabCopy.missesDeck),
          matching: find.byType(PickCard),
        ),
      );
      expect(deck.onTap, isNull);
    });

    testWidgets('four owed reviews open the deck, with its count', (
      tester,
    ) async {
      await _pump(tester, pools: _pools(missed: vocabMinimumPool));

      expect(find.textContaining(VocabCopy.missesDeckReady), findsOneWidget);
      expect(
        find.text('${VocabCopy.missesDeck} · $vocabMinimumPool'),
        findsOneWidget,
      );
    });

    testWidgets('the misses deck is never the opening default', (
      tester,
    ) async {
      // Saved is, when it is full. A drill should open on what the learner
      // chose to study rather than on what they got wrong.
      await _pump(
        tester,
        pools: _pools(saved: vocabMinimumPool, missed: vocabMinimumPool),
      );

      final misses = tester.widget<PickCard>(
        find.ancestor(
          of: find.textContaining(VocabCopy.missesDeck),
          matching: find.byType(PickCard),
        ),
      );
      final saved = tester.widget<PickCard>(
        find.ancestor(
          of: find.textContaining(VocabCopy.savedDeck),
          matching: find.byType(PickCard),
        ),
      );

      expect(misses.selected, isFalse);
      expect(saved.selected, isTrue);
    });

    testWidgets('a short misses deck says how it grows, not how saving does', (
      tester,
    ) async {
      await _pump(tester, pools: _pools(missed: vocabMinimumPool));

      await tester.tap(find.textContaining(VocabCopy.missesDeck));
      await tester.pumpAndSettle();

      expect(find.text(VocabCopy.longerMissRoundsHint), findsOneWidget);
      expect(find.text(VocabCopy.longerRoundsHint), findsNothing);
    });

    testWidgets('a choice the rules cannot offer is disabled, not just faint', (
      tester,
    ) async {
      // Eight terms, so Deep 12 cannot be filled and the Saved deck is short.
      // A dimmed card that still answers taps reads to a screen reader as a
      // button that does nothing.
      await _pump(tester);

      final deep = tester.widget<PickCard>(
        find.ancestor(
          of: find.text('${vocabLengths.last}'),
          matching: find.byType(PickCard),
        ),
      );
      final savedDeck = tester.widget<PickCard>(
        find.ancestor(
          of: find.textContaining(VocabCopy.savedDeck),
          matching: find.byType(PickCard),
        ),
      );

      expect(deep.onTap, isNull);
      expect(savedDeck.onTap, isNull);
    });
  });

  group('playing a round', () {
    testWidgets('start deals a question with four choices', (tester) async {
      await _pump(tester);

      await tester.tap(find.text(VocabCopy.start));
      await tester.pumpAndSettle();

      expect(find.text(VocabCopy.questionLead.toUpperCase()), findsOneWidget);
      expect(find.byType(OutlinedButton), findsNWidgets(vocabChoiceCount));
      expect(find.byType(RoastMeter), findsOneWidget);
    });

    testWidgets('the way on is disabled until the question is answered', (
      tester,
    ) async {
      await _pump(tester);
      await tester.tap(find.text(VocabCopy.start));
      await tester.pumpAndSettle();

      final button = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text(VocabCopy.next),
          matching: find.byType(FilledButton),
        ),
      );

      expect(button.onPressed, isNull);
    });

    testWidgets('a wrong answer still names the right term', (tester) async {
      await _pump(tester);
      await tester.tap(find.text(VocabCopy.start));
      await tester.pumpAndSettle();

      await answer(tester, correctly: false);

      expect(find.textContaining('NOT QUITE'), findsOneWidget);
      expect(find.text(VocabCopy.readEntry.toUpperCase()), findsNothing);
      expect(find.text(VocabCopy.readEntry), findsOneWidget);
    });
  });

  group('the score', () {
    testWidgets('a clean run scores every round', (tester) async {
      await _pump(tester);
      await tester.tap(find.text(VocabCopy.start));
      await tester.pumpAndSettle();

      await playThrough(tester, rounds: vocabLengths.first);

      expect(find.byType(DrillResultsView), findsOneWidget);
      expect(
        find.text('${vocabLengths.first} / ${vocabLengths.first}'),
        findsOneWidget,
      );
    });

    testWidgets('a run of wrong answers scores none of them', (tester) async {
      await _pump(tester);
      await tester.tap(find.text(VocabCopy.start));
      await tester.pumpAndSettle();

      await playThrough(tester, rounds: vocabLengths.first, correctly: false);

      expect(find.text('0 / ${vocabLengths.first}'), findsOneWidget);
    });

    testWidgets('change round returns to setup', (tester) async {
      await _pump(tester);
      await tester.tap(find.text(VocabCopy.start));
      await tester.pumpAndSettle();
      await playThrough(tester, rounds: vocabLengths.first);

      await tester.tap(find.text(VocabCopy.changeRound));
      await tester.pumpAndSettle();

      expect(find.text(VocabCopy.start), findsOneWidget);
    });
  });

  group('what answering writes to the review deck', () {
    testWidgets('a wrong answer adds the term, in any deck', (tester) async {
      final container = await _pump(tester);
      await tester.tap(find.text(VocabCopy.start));
      await tester.pumpAndSettle();

      final asked = _accessible.firstWhere(
        (term) => find.text(term.shortExplanation).evaluate().isNotEmpty,
      );
      await answer(tester, correctly: false);
      await tester.pumpAndSettle();

      final misses = (await container.read(snapshotRepositoryProvider).read())
          .clearedByReset
          .missedTerms;

      expect(misses[asked.id]!.isMissed, isTrue);
    });

    testWidgets('a correct answer clears the term, in any deck', (
      tester,
    ) async {
      final container = await _pump(tester);
      await tester.tap(find.text(VocabCopy.start));
      await tester.pumpAndSettle();

      final asked = _accessible.firstWhere(
        (term) => find.text(term.shortExplanation).evaluate().isNotEmpty,
      );
      await answer(tester, correctly: true);
      await tester.pumpAndSettle();

      final misses = (await container.read(snapshotRepositoryProvider).read())
          .clearedByReset
          .missedTerms;

      expect(misses[asked.id]!.isMissed, isFalse);
    });

    testWidgets('the score says what this drill added, and only this one', (
      tester,
    ) async {
      await _pump(tester);
      await tester.tap(find.text(VocabCopy.start));
      await tester.pumpAndSettle();
      await playThrough(tester, rounds: vocabLengths.first, correctly: false);

      expect(
        find.textContaining(VocabCopy.missesAdded(vocabLengths.first).trim()),
        findsOneWidget,
      );

      // A second, clean drill must not report the first one's misses — the
      // prototype's count accumulates across replays.
      await tester.tap(find.text(VocabCopy.playAgain));
      await tester.pumpAndSettle();
      await playThrough(tester, rounds: vocabLengths.first);

      expect(find.textContaining('review deck'), findsNothing);
    });

    testWidgets('an abandoned drill still keeps the answers given', (
      tester,
    ) async {
      // The deck is not the drill's score: a question answered wrong was
      // answered wrong, whether or not the learner stayed for the total.
      final container = await _pump(tester);
      await tester.tap(find.text(VocabCopy.start));
      await tester.pumpAndSettle();

      await answer(tester, correctly: false);
      await tester.pumpAndSettle();

      final progress = (await container.read(snapshotRepositoryProvider).read())
          .clearedByReset;

      expect(progress.missedTerms, hasLength(1));
      expect(progress.dailyActivity, isEmpty);
    });
  });

  group('what a finished drill records', () {
    testWidgets('reaching the score writes one qualifying activity', (
      tester,
    ) async {
      final container = await _pump(tester);
      await tester.tap(find.text(VocabCopy.start));
      await tester.pumpAndSettle();

      await playThrough(tester, rounds: vocabLengths.first);
      await settle(tester);

      final progress = (await container.read(snapshotRepositoryProvider).read())
          .clearedByReset;
      final today = epochDay(DateTime.now());

      expect(progress.dailyActivity[today], hasLength(1));
      expect(
        parseActivityEntry(progress.dailyActivity[today]!.single).type,
        ActivityType.vocab,
      );
      expect(progress.activeDays, contains(today));
    });

    testWidgets('a free day with one left deals one round, not two', (
      tester,
    ) async {
      // One activity already done, so the round below is the day's second and
      // *Play again* would be the third. It re-deals in place without
      // navigating, so only the screen's own check refuses it (#216).
      final container = await _pump(tester);
      await recordActivity(
        container.read(snapshotRepositoryProvider),
        type: ActivityType.flashcards,
        subject: '',
        now: DateTime.now(),
      );

      await tester.tap(find.text(VocabCopy.start));
      await tester.pumpAndSettle();
      await playThrough(tester, rounds: vocabLengths.first);
      await settle(tester);

      await tester.tap(find.text(VocabCopy.playAgain));
      await settle(tester);

      expect(find.text(PlusCopy.title), findsOneWidget);
      final progress = (await container.read(snapshotRepositoryProvider).read())
          .clearedByReset;
      expect(
        progress.dailyActivity[epochDay(DateTime.now())],
        hasLength(2),
        reason: 'the refused round must not deal, and so must not record',
      );
    });

    testWidgets('an abandoned drill records nothing', (tester) async {
      final container = await _pump(tester);
      await tester.tap(find.text(VocabCopy.start));
      await tester.pumpAndSettle();

      // One question answered, then the learner leaves.
      await answer(tester, correctly: true);

      final progress = (await container.read(snapshotRepositoryProvider).read())
          .clearedByReset;

      expect(progress.dailyActivity, isEmpty);
      expect(progress.activeDays, isEmpty);
    });
  });

  group('a pool too small to drill', () {
    testWidgets('shows the teaching state and never pads the round', (
      tester,
    ) async {
      await _pump(
        tester,
        pools: _pools(accessible: _accessible.take(3).toList()),
      );

      expect(find.byType(VocabTeachingView), findsOneWidget);
      expect(find.text(VocabCopy.teachingTitle), findsOneWidget);
      expect(find.text(VocabCopy.start), findsNothing);
    });
  });
}
