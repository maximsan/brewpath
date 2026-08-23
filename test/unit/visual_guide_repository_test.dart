import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/visual_guide_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// The guides the app actually ships, asserted against the bundled bank.
///
/// The unlock *table* — which lesson earns which guide — is deliberately not
/// duplicated here. It is a property of the authored course, proved in the
/// extractor's validators against the real lessons; these tests prove the app
/// applies whatever the bank says.
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

  /// The prose the guides shipped without.
  ///
  /// The words were authored all along; the extractor cut each entry before
  /// them because they sat inside JSX it could not parse. The prototype moved
  /// them into data fields (#271), and these assert the app actually carries
  /// them — a bank that silently loses the prose again looks exactly like a
  /// bank that never had it.
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

  test('each meta table is two or three label/value pairs', () async {
    for (final guide in await guides.getGuides()) {
      expect(
        guide.metaRows.length,
        inInclusiveRange(2, 3),
        reason:
            '${guide.id} — two guides carry two rows, so three is not a rule',
      );
      for (final row in guide.metaRows) {
        expect(row.label, isNotEmpty, reason: guide.id);
        expect(row.value, isNotEmpty, reason: guide.id);
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
