import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/visual_guide_repository.dart';
import 'package:flutter_test/flutter_test.dart';

// The unlock table — which lesson earns which guide — is deliberately not
// duplicated here. It is a property of the authored course, proved in the
// extractor's validators; these prove the app applies whatever the bank says.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late VisualGuideRepository guides;
  late ContentRepository content;

  setUp(() {
    guides = VisualGuideRepository();
    content = ContentRepository();
  });

  test('are eight, one per subject', () async {
    final list = await guides.getGuides();
    expect(list, hasLength(8));
    expect(
      list.map((guide) => guide.subject).toSet(),
      hasLength(8),
      reason: 'a subject appearing twice would shelve the same guide twice',
    );
  });

  test('each carries the words its sheet renders', () async {
    for (final guide in await guides.getGuides()) {
      expect(guide.label, isNotEmpty, reason: guide.id);
      expect(guide.title, isNotEmpty, reason: guide.id);
      expect(guide.summary, isNotEmpty, reason: guide.id);
      expect(guide.fact, isNotEmpty, reason: guide.id);
    }
  });

  // The words were authored all along; the extractor cut each entry before
  // them because they sat inside JSX it could not parse (#271). A bank that
  // silently loses the prose again looks exactly like one that never had it.
  test('the guides that gloss their table carry a note per term', () async {
    final bySubject = {
      for (final guide in await guides.getGuides()) guide.subject: guide,
    };

    for (final subject in ['roast', 'grind']) {
      final notes = bySubject[subject]!.notes;
      expect(notes, hasLength(3), reason: subject);
      for (final note in notes) {
        expect(note.term, isNotEmpty, reason: subject);
        expect(
          note.detail,
          isNotEmpty,
          reason: '$subject: a term with no gloss is the gap this closed',
        );
      }
    }
  });

  test('the guides that close on a thought carry it', () async {
    final bySubject = {
      for (final guide in await guides.getGuides()) guide.subject: guide,
    };

    for (final subject in ['ratio', 'variety', 'caffeine', 'distribution']) {
      expect(bySubject[subject]!.note, isNotEmpty, reason: subject);
    }

    // Anatomy's drawing is the reference — its cross-section says what a
    // closing paragraph would, so it having none is correct, not missing.
    expect(bySubject['anatomy']!.note, isNull);
    expect(bySubject['anatomy']!.notes, isEmpty);
  });

  // Six layers were authored beside the drawing that reads them, in a file the
  // guide join never opened, so the anatomy guide shipped as a title and three
  // meta rows. Asserted against the shipped bank, never a fixture: a fixture
  // would have passed the whole time the content was missing.
  test('the cherry arrives with its six layers, outside in', () async {
    final bySubject = {
      for (final guide in await guides.getGuides()) guide.subject: guide,
    };
    final layers = bySubject['anatomy']!.layers;

    expect(layers, hasLength(6));
    expect(layers.map((layer) => layer.number), [
      '01',
      '02',
      '03',
      '04',
      '05',
      '06',
    ]);
    expect(
      layers[2].name,
      'Mucilage',
      reason: 'the section opens on 03 — the layer the processes argue over',
    );
    expect(layers.last.name, 'Seed');

    for (final layer in layers) {
      expect(layer.latin, isNotEmpty, reason: layer.number);
      expect(layer.fate, isNotEmpty, reason: layer.number);
      expect(layer.note, isNotEmpty, reason: layer.number);
    }
  });

  test('the servings table carries a serving and a figure per brew', () async {
    final bySubject = {
      for (final guide in await guides.getGuides()) guide.subject: guide,
    };
    final rows = bySubject['caffeine']!.rows;

    expect(rows, hasLength(4));
    expect(rows.map((row) => row.name), [
      'Decaf',
      'Espresso',
      'Drip coffee',
      'Cold brew',
    ]);
    for (final row in rows) {
      expect(
        row.serving,
        isNotEmpty,
        reason: '${row.name} — the guide is titled Caffeine, Per Serving',
      );
      expect(row.milligrams, greaterThan(0), reason: row.name);
    }
    expect(
      rows.map((row) => row.milligrams).toList(),
      orderedEquals(rows.map((row) => row.milligrams).toList()..sort()),
      reason: 'the table climbs, and the bars are drawn against the largest',
    );
  });

  test('only the guides that authored them carry them', () async {
    for (final guide in await guides.getGuides()) {
      expect(
        guide.layers.isNotEmpty,
        guide.subject == 'anatomy',
        reason: '${guide.id} layers',
      );
      expect(
        guide.rows.isNotEmpty,
        guide.subject == 'caffeine',
        reason: '${guide.id} rows',
      );
    }
  });

  test('each unlocks at a lesson that resolves', () async {
    final lessonIds = {
      for (final lesson in await content.getLessons()) lesson.id,
    };
    for (final guide in await guides.getGuides()) {
      expect(
        lessonIds,
        contains(guide.unlockLessonId),
        reason: '${guide.id} unlocks at ${guide.unlockLessonId}',
      );
    }
  });

  test('the roast and grind guides explain each of their levels', () async {
    // Only these two guides carry levels in the design; every other guide's
    // drawing is its own explanation, so an empty list there is correct.
    final bySubject = {
      for (final guide in await guides.getGuides()) guide.subject: guide,
    };
    for (final subject in const ['roast', 'grind']) {
      final notes = bySubject[subject]!.notes;
      expect(notes, isNotEmpty, reason: '$subject draws its levels explained');
      for (final note in notes) {
        expect(note.term.trim(), isNotEmpty, reason: subject);
        expect(note.detail.trim(), isNotEmpty, reason: subject);
      }
    }
  });

  test('no guide is a collectible, and the collection is unchanged', () async {
    final cards = await content.getCards();
    final guideIds = {for (final guide in await guides.getGuides()) guide.id};

    expect(
      cards.map((card) => card.id).toSet().intersection(guideIds),
      isEmpty,
      reason: 'a guide is never listed beside a collectible',
    );
    expect(cards, hasLength(37));
  });
}
