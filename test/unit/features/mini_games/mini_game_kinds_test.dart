import 'package:brew_path/features/mini_games/domain/mini_game_kinds.dart';
import 'package:brew_path/shared/models/content/mini_game_format.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:flutter_test/flutter_test.dart';

MiniGameFormat _game(String id, String kind) => MiniGameFormat(
  id: id,
  kind: kind,
  moduleId: 'm1',
  title: id,
  topic: 'TOPIC',
  duration: '~2 MIN',
  blurb: 'Blurb.',
  steps: const ['One', 'Two'],
);

/// The shelf's arrangement, decided without a widget. What a learner notices
/// is that the groups are always in the same places and that no game is ever
/// missing from them — both are assertions about this function alone.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('groups come back in the fixed order, not catalog order', () {
    final groups = groupCatalogByKind([
      _game('g-sequence', 'sequence'),
      _game('g-match', 'match'),
      _game('g-quiz', 'quiz'),
    ]);

    expect(
      groups.map((group) => group.label),
      ['Match', 'True or false', 'Sequence'],
    );
  });

  test('games keep catalog order inside their group', () {
    final groups = groupCatalogByKind([
      _game('g-match', 'match'),
      _game('g-quiz', 'quiz'),
      _game('g-match-washed-natural', 'match'),
    ]);

    expect(groups.first.label, 'Match');
    expect(
      groups.first.games.map((game) => game.id),
      ['g-match', 'g-match-washed-natural'],
    );
  });

  test('a kind with no games leaves no heading behind', () {
    final groups = groupCatalogByKind([_game('g-quiz', 'quiz')]);

    expect(groups, hasLength(1));
    expect(groups.single.label, 'True or false');
  });

  test('an empty catalog groups into nothing', () {
    expect(groupCatalogByKind(const []), isEmpty);
  });

  test('a game of an unlisted kind is kept, never dropped', () {
    final groups = groupCatalogByKind([
      _game('g-quiz', 'quiz'),
      _game('g-mystery', 'mystery'),
    ]);

    expect(groups.map((group) => group.label), ['True or false', 'mystery']);
    expect(groups.last.games.single.id, 'g-mystery');
  });

  test('grouping never loses or duplicates a game', () async {
    final catalog = await ContentRepository().getMiniGameFormats();
    final grouped = [
      for (final group in groupCatalogByKind(catalog))
        for (final game in group.games) game.id,
    ];

    expect(grouped, hasLength(catalog.length));
    expect(grouped.toSet(), catalog.map((game) => game.id).toSet());
  });

  test(
    'every shipped game has a declared kind, so none needs the fallback',
    () async {
      final catalog = await ContentRepository().getMiniGameFormats();
      final declared = {for (final kind in miniGameKinds) kind.kind};

      expect(
        catalog.map((game) => game.kind).toSet().difference(declared),
        isEmpty,
        reason:
            'a shipped kind missing from miniGameKinds would render its raw '
            'kind string as a heading',
      );
    },
  );

  test('the shipped catalog groups into the seven kinds, in order', () async {
    final groups = groupCatalogByKind(
      await ContentRepository().getMiniGameFormats(),
    );

    expect(groups.map((group) => group.label), [
      'Match',
      'True or false',
      'Name the note',
      'Blind bag',
      'Taste fix',
      'Calibrate',
      'Sequence',
    ]);
  });
}
