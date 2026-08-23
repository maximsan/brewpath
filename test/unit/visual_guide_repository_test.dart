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
