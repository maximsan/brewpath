import 'package:brew_path/features/lessons/presentation/cards/content_card_view.dart';
import 'package:brew_path/features/mini_games/domain/mini_game_run.dart';
import 'package:brew_path/shared/models/content/content_card.dart';
import 'package:brew_path/shared/models/content/mini_game_format.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// The guard that keeps the playable registry honest about what it has not
/// considered.
///
/// [playableMiniGameIds] is an allowlist on purpose — a game plays because
/// someone said so, never incidentally because its kind happens to render
/// (#121). The price of that choice is the failure this file exists to stop: a
/// game added to the catalog does not join the list, nothing reads the two
/// together, and the game sits on the shelf offering a dead button. It happened
/// to `g-match-washed-natural` and `g-quiz-roast-basics`, which rendered from
/// the day they were authored and entered the catalog three days after the
/// list was last written (#311).
///
/// So the rule is stated the other way round: a game whose rounds can all be
/// drawn is playable **unless someone named a reason it is not**. An addition
/// to the catalog then fails this suite until it is ruled on — the "someone
/// said so" property expressed as something a build can check rather than
/// something a reviewer must remember.
///
/// Asserted against the **real shipped banks**, in the style of the tier test:
/// a fixture would only prove the rule holds over invented data, where the
/// real catalog proves the shelf a learner sees is the shelf that works.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<MiniGameFormat> catalog;
  late Map<String, List<ContentCard>> banks;

  setUp(() async {
    final content = ContentRepository();
    catalog = await content.getMiniGameFormats();
    banks = {
      for (final game in catalog)
        game.id: await content.getMiniGameRounds(game.id),
    };
  });

  /// Whether every round of [gameId] can be drawn by this build.
  ///
  /// Asked of the rounds themselves rather than of a list of kind names, so the
  /// answer comes from the same exhaustive switch the player uses. A kind that
  /// gains a renderer flips this with no second list to keep in step.
  bool rendersFully(String gameId) {
    final rounds = banks[gameId] ?? const <ContentCard>[];
    return rounds.isNotEmpty && rounds.every(hasRenderer);
  }

  test('every game that can be drawn is playable, or says why not', () {
    final unruled = [
      for (final game in catalog)
        if (rendersFully(game.id) &&
            !playableMiniGameIds.contains(game.id) &&
            !deliberatelyNotPlayable.containsKey(game.id))
          game.id,
    ];

    expect(
      unruled,
      isEmpty,
      reason:
          'These games render but are not playable, and no reason is recorded. '
          'Either add them to playableMiniGameIds, or name them in '
          'deliberatelyNotPlayable with the reason they are held back.',
    );
  });

  test('nothing playable strands the learner on a round it cannot draw', () {
    // The converse, and the worse of the two failures: a game listed as
    // playable whose rounds cannot be drawn opens its intro, offers Play, and
    // then meets the learner mid-run with "This round cannot be shown yet".
    final broken = [
      for (final id in playableMiniGameIds)
        if (!rendersFully(id)) id,
    ];

    expect(
      broken,
      isEmpty,
      reason: 'a playable game must be able to draw every round of its bank',
    );
  });

  test('the two games that were switched off now play', () {
    // Named rather than left to the rule above. These two are the evidence the
    // rule was needed, so a regression on them should say so by name instead of
    // arriving as a count in a list.
    expect(playableMiniGameIds, contains('g-quiz-roast-basics'));
    expect(playableMiniGameIds, contains('g-match-washed-natural'));
  });

  test('a held-back game is held back with a reason, never a blank', () {
    for (final entry in deliberatelyNotPlayable.entries) {
      expect(
        entry.value.trim(),
        isNotEmpty,
        reason: '${entry.key} is held back with no reason recorded',
      );
      expect(
        playableMiniGameIds,
        isNot(contains(entry.key)),
        reason: '${entry.key} is both held back and playable',
      );
    }
  });
}
