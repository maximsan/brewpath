import 'package:brew_path/shared/models/content/collectible.dart';
import 'package:brew_path/shared/repositories/content_assembly.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/content_fixtures.dart';

/// The two joins the banks do not store, and what they do when the content
/// cannot support them.
///
/// Both throw rather than degrade. The banks are bundled with the app, so a
/// broken one is a build defect — and every quiet fallback here produces
/// something indistinguishable on screen from content that simply loaded:
/// a course with fewer lessons, or a card with no words.
void main() {
  final module = testModule();

  group('lessonOwners', () {
    test('inverts the module list into lesson id → module id', () {
      expect(lessonOwners([module]), {'m1l1': 'm1', 'm1l2': 'm1'});
    });

    test('is empty for a course with no modules', () {
      expect(lessonOwners([]), isEmpty);
    });
  });

  group('assembleLessons', () {
    Map<String, dynamic> record(String id) => {
      'id': id,
      'moduleLabel': 'MODULE 1 · BEANS',
      'title': id,
      'points': 10,
      'time': 3,
      'cards': <Map<String, dynamic>>[],
      'reward': {'title': 'A Card', 'summary': 'What.', 'fact': 'True.'},
    };

    test('resolves the owning module onto every lesson', () {
      final lessons = assembleLessons([record('m1l1')], [module]);
      expect(lessons.single.moduleId, 'm1');
    });

    test('throws when no module claims a lesson', () {
      expect(
        () => assembleLessons([record('m9l9')], [module]),
        throwsA(isA<ContentFormatException>()),
      );
    });
  });

  group('assembleCards', () {
    final lesson = testLesson();

    Collectible collectible({String? lessonId, String? moduleId}) =>
        Collectible(
          id: 'c1',
          unlock: CollectibleUnlock(lessonId: lessonId, moduleId: moduleId),
          kind: 'botanical',
        );

    test("takes a lesson card's words from that lesson's reward", () {
      final cards = assembleCards(
        collectibles: [collectible(lessonId: 'm1l1')],
        lessons: [lesson],
        modules: [module],
      );

      expect(cards.single.title, lesson.reward.title);
      expect(cards.single.description, lesson.reward.summary);
      expect(cards.single.fact, lesson.reward.fact);
      expect(cards.single.lessonId, 'm1l1');
      expect(cards.single.moduleId, isNull);
      expect(cards.single.moduleTag, module.title);
    });

    test("takes a module card's words from that module's reward", () {
      final cards = assembleCards(
        collectibles: [collectible(moduleId: 'm1')],
        lessons: [lesson],
        modules: [module],
      );

      expect(cards.single.title, module.reward.title);
      expect(cards.single.moduleId, 'm1');
      expect(cards.single.lessonId, isNull);
    });

    test('throws when a collectible names neither source', () {
      expect(
        () => assembleCards(
          collectibles: [collectible()],
          lessons: [lesson],
          modules: [module],
        ),
        throwsA(isA<ContentFormatException>()),
      );
    });

    test('throws when a collectible names both sources', () {
      expect(
        () => assembleCards(
          collectibles: [collectible(lessonId: 'm1l1', moduleId: 'm1')],
          lessons: [lesson],
          modules: [module],
        ),
        throwsA(isA<ContentFormatException>()),
      );
    });

    test('throws on a pointer to a lesson that does not exist', () {
      expect(
        () => assembleCards(
          collectibles: [collectible(lessonId: 'm9l9')],
          lessons: [lesson],
          modules: [module],
        ),
        throwsA(isA<ContentFormatException>()),
      );
    });

    test('throws on a pointer to a module that does not exist', () {
      expect(
        () => assembleCards(
          collectibles: [collectible(moduleId: 'm9')],
          lessons: [lesson],
          modules: [module],
        ),
        throwsA(isA<ContentFormatException>()),
      );
    });
  });
}
