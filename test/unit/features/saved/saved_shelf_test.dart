import 'package:brew_path/features/saved/domain/saved_key.dart';
import 'package:brew_path/features/saved/domain/saved_shelf.dart';
import 'package:flutter_test/flutter_test.dart';

/// Candidates arrive in content order; the derivation must preserve it.
const _terms = <SavedCandidate>[
  (id: 'arabica', title: 'Arabica', subtitle: 'BEANS AND BOTANY'),
  (id: 'bloom', title: 'Bloom', subtitle: 'BREWING'),
  (id: 'crema', title: 'Crema', subtitle: 'BREWING'),
];
const _lessons = <SavedCandidate>[
  (id: 'm1l1', title: 'What coffee actually is', subtitle: 'MODULE 1 · BEANS'),
  (id: 'm2l1', title: 'Washed and natural', subtitle: 'MODULE 2 · PROCESSING'),
];
const _guides = <SavedCandidate>[
  (id: 'roast', title: 'Roast Levels', subtitle: 'VISUAL GUIDE'),
  (id: 'grind', title: 'Grind Size', subtitle: 'VISUAL GUIDE'),
];

List<SavedGroup> shelf(Set<String> keys) => deriveSavedShelf(
  keys: keys,
  terms: _terms,
  lessons: _lessons,
  guides: _guides,
);

void main() {
  test('an empty shelf has no groups at all', () {
    expect(shelf(const {}), isEmpty);
  });

  test('groups come in a fixed order: terms, lessons, guides', () {
    final groups = shelf(const {'g:roast', 'l:m1l1', 't:arabica'});

    expect(
      [for (final group in groups) group.kind],
      [SavedKind.term, SavedKind.lesson, SavedKind.guide],
      reason: "the order is the design's, not the order they were saved in",
    );
  });

  test('a kind with nothing saved produces no group', () {
    final groups = shelf(const {'t:arabica'});

    expect([for (final group in groups) group.kind], [SavedKind.term]);
  });

  test('items keep content order rather than save order', () {
    // 'crema' saved first, but it is third in the bank.
    final groups = shelf(const {'t:crema', 't:arabica'});

    expect(
      [for (final item in groups.single.items) item.id],
      [
        'arabica',
        'crema',
      ],
    );
  });

  test('a key nothing resolves is skipped rather than shown broken', () {
    final groups = shelf(const {'t:arabica', 't:no-such-term', 'l:gone'});

    expect(groups.single.items.map((item) => item.id), ['arabica']);
  });

  test('a key of an unknown kind is skipped', () {
    // `c:` was never a key; neither is anything else.
    expect(shelf(const {'c:c1', 'x:y'}), isEmpty);
  });

  test('a row carries the title and subtitle it was given', () {
    final item = shelf(const {'l:m2l1'}).single.items.single;

    expect(item.title, 'Washed and natural');
    expect(item.subtitle, 'MODULE 2 · PROCESSING');
  });

  test('a row carries the key that unsaves it', () {
    final item = shelf(const {'g:grind'}).single.items.single;

    expect(item.key, 'g:grind');
  });

  test('each group is labelled for its heading', () {
    final groups = shelf(const {'t:arabica', 'l:m1l1', 'g:roast'});

    expect(
      [for (final group in groups) group.label],
      [
        'Dictionary terms',
        'Lessons',
        'Visual guides',
      ],
    );
  });

  group('savedShelfCount', () {
    test('counts what the shelf will actually show', () {
      final groups = shelf(const {'t:arabica', 'l:m1l1', 'g:roast'});

      expect(savedShelfCount(groups), 3);
    });

    test('does not count a key nothing resolves', () {
      // The badge must never promise a row the shelf cannot draw.
      final groups = shelf(const {'t:arabica', 't:no-such-term'});

      expect(savedShelfCount(groups), 1);
    });

    test('an empty shelf counts zero', () {
      expect(savedShelfCount(shelf(const {})), 0);
    });
  });
}
