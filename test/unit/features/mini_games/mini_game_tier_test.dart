import 'package:brew_path/features/mini_games/domain/mini_game_tier.dart';
import 'package:brew_path/shared/models/content/mini_game_format.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// The three games ADR-0007's free lesson list forces: Match teaches
/// `m1l2` Arabica vs Robusta, True or false teaches `m1l1` coffee basics,
/// Name the origin teaches `m1l3` what origin means.
const _expectedFreeIds = {
  'g-match',
  'g-quiz',
  'g-flavor-origin-signatures',
};

MiniGameFormat _game(String id, String moduleId) => MiniGameFormat(
  id: id,
  kind: 'quiz',
  moduleId: moduleId,
  title: id,
  topic: 'TOPIC',
  duration: '~2 MIN',
  blurb: 'Blurb.',
  steps: const ['One'],
);

/// The tier line, asserted against the **real shipped catalog** rather than a
/// fixture. A fixture would prove the function works; only the real bank
/// proves the free tier is the one the ADRs say it is.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('the rule', () {
    test('a free-module game opens without the course', () {
      expect(isMiniGameOpen(_game('g-x', 'm1'), hasCourse: false), isTrue);
    });

    test('a paid-module game does not', () {
      expect(isMiniGameOpen(_game('g-x', 'm3'), hasCourse: false), isFalse);
    });

    test('the course opens everything', () {
      for (final moduleId in ['m1', 'm2', 'm3', 'm4', 'm5']) {
        expect(
          isMiniGameOpen(_game('g-x', moduleId), hasCourse: true),
          isTrue,
          reason: '$moduleId stayed shut for a learner who paid',
        );
      }
    });
  });

  group('the shipped catalog', () {
    late List<MiniGameFormat> catalog;

    setUp(() async {
      catalog = await ContentRepository().getMiniGameFormats();
    });

    test('every game declares a module', () {
      expect(
        catalog.every((game) => game.moduleId.isNotEmpty),
        isTrue,
        reason: 'a game with no module cannot be placed on the tier line',
      );
    });

    test('the free set is exactly the three ADR-0007 forces', () {
      expect(freeMiniGameIds(catalog).toSet(), _expectedFreeIds);
    });

    test('every other game is locked without the course', () {
      final locked = [
        for (final game in catalog)
          if (!isMiniGameOpen(game, hasCourse: false)) game.id,
      ];

      expect(locked, hasLength(catalog.length - _expectedFreeIds.length));
      expect(locked.toSet().intersection(_expectedFreeIds), isEmpty);
    });

    test('the course opens every game in the catalog', () {
      expect(
        catalog.every((game) => isMiniGameOpen(game, hasCourse: true)),
        isTrue,
      );
    });

    /// ADR-0001, restated by ADR-0005 and recounted by ADR-0007. The record
    /// says the invariant "is invisible from every surface that could break
    /// it" — cutting a free game, swapping one, or re-picking the free lesson
    /// list each removes the free learner's streak path silently. This is the
    /// surface that notices.
    test(
      'ADR-0001: at least two free games, with distinct ids, so a free '
      'learner can reach a qualifying streak day on free content alone',
      () {
        final free = freeMiniGameIds(catalog);

        expect(
          free.toSet(),
          hasLength(greaterThanOrEqualTo(2)),
          reason:
              'the streak needs two *different* games in a day, and the '
              'free tier must be able to supply both',
        );
        expect(
          free,
          hasLength(free.toSet().length),
          reason: 'a duplicated id is one game, not two',
        );
      },
    );
  });
}
