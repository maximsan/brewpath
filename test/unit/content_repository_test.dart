import 'package:brew_path/features/lessons/presentation/cards/content_card_view.dart';
import 'package:brew_path/shared/models/content/content_card.dart';
import 'package:brew_path/shared/models/content/content_card_grading.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// The course the app actually ships, asserted against the bundled banks.
///
/// These run as a plain `test` rather than `testWidgets` on purpose: reading a
/// real asset through `rootBundle` inside a `testWidgets` fake-async zone
/// hangs, and the point of this file is to read the real assets.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ContentRepository repo;

  setUp(() => repo = ContentRepository());

  group('the course', () {
    test('is five modules in course order', () async {
      final modules = await repo.getModules();
      expect(modules.map((m) => m.id), ['m1', 'm2', 'm3', 'm4', 'm5']);
      expect(modules.map((m) => m.n), [1, 2, 3, 4, 5]);
    });

    test('is thirty-two lessons', () async {
      final lessons = await repo.getLessons();
      expect(lessons.length, 32);
    });

    test('opens on m1l1', () async {
      final lesson = await repo.getLessonById('m1l1');
      expect(lesson?.title, 'What coffee actually is');
    });

    test('gives every lesson a module that claims it', () async {
      final lessons = await repo.getLessons();
      final modules = await repo.getModules();
      final byId = {for (final module in modules) module.id: module};

      for (final lesson in lessons) {
        final owner = byId[lesson.moduleId];
        expect(owner, isNotNull, reason: '${lesson.id} has no owning module');
        expect(
          owner!.lessonIds,
          contains(lesson.id),
          reason: '${lesson.id} is not listed by ${owner.id}',
        );
      }
    });

    test('lists exactly its own lessons in every module', () async {
      final modules = await repo.getModules();
      final lessons = await repo.getLessons();
      final ids = lessons.map((l) => l.id).toSet();

      final claimed = <String>[];
      for (final module in modules) {
        for (final lessonId in module.lessonIds) {
          expect(ids, contains(lessonId), reason: '$lessonId does not exist');
          claimed.add(lessonId);
        }
      }
      expect(claimed.length, ids.length);
      expect(claimed.toSet().length, claimed.length, reason: 'claimed twice');
    });

    test('has no duplicate lesson ids', () async {
      final lessons = await repo.getLessons();
      final ids = lessons.map((l) => l.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('pays a flat ten points per lesson', () async {
      final lessons = await repo.getLessons();
      expect(lessons.map((l) => l.points).toSet(), {10});
    });
  });

  group('lesson cards', () {
    test('m1l1 is eight cards, five of them graded', () async {
      final lesson = await repo.getLessonById('m1l1');
      expect(lesson!.cards.length, 8);
      expect(gradedCards(lesson.cards).length, 5);
    });

    // The counts the two tickets were written against. Pinned, not derived:
    // a content edit that drops a card would otherwise slip past the
    // per-lesson property below, which only checks authored == playable and
    // is happy when both fall together.
    test(
      'the bank still carries the authored practical and multi cards',
      () async {
        final lessons = await repo.getLessons();
        final cards = lessons.expand((lesson) => lesson.cards);
        expect(cards.whereType<PracticalCard>().length, 5);
        expect(cards.whereType<MultiCard>().length, 10);
      },
    );

    test('practical and multi cards keep their authored order', () async {
      final lessons = await repo.getLessons();
      for (final lesson in lessons) {
        final authored = lesson.cards
            .where((card) => card is PracticalCard || card is MultiCard)
            .toList();
        final played = playableCards(
          lesson.cards,
        ).where((card) => card is PracticalCard || card is MultiCard).toList();
        expect(
          played,
          authored,
          reason:
              '${lesson.id} reorders cards the learner should meet in '
              'the order they were authored',
        );
      }
    });

    test('every authored practical and multi card reaches a learner', () async {
      final lessons = await repo.getLessons();
      for (final lesson in lessons) {
        final authored = lesson.cards
            .where((card) => card is PracticalCard || card is MultiCard)
            .length;
        final playable = playableCards(
          lesson.cards,
        ).where((card) => card is PracticalCard || card is MultiCard).length;
        expect(
          playable,
          authored,
          reason: '${lesson.id} drops a card the learner should see',
        );
      }
    });

    test('every playable multi card counts toward mastery', () async {
      final lessons = await repo.getLessons();
      var counted = 0;
      for (final lesson in lessons) {
        final played = playableCards(lesson.cards);
        final graded = gradedCards(played);
        for (final card in played.whereType<MultiCard>()) {
          expect(
            graded,
            contains(card),
            reason: '${lesson.id} plays a multi card it does not score',
          );
          counted++;
        }
      }
      expect(
        counted,
        greaterThan(0),
        reason:
            'the bank carries multi cards — a zero here means the '
            'assertion stopped testing anything',
      );
    });

    test('every lesson carries at least one card', () async {
      final lessons = await repo.getLessons();
      for (final lesson in lessons) {
        expect(lesson.cards, isNotEmpty, reason: '${lesson.id} has no cards');
      }
    });
  });

  group('collectibles', () {
    test('are thirty-seven, one per lesson plus one per module', () async {
      final cards = await repo.getCards();
      expect(cards.length, 37);
      expect(cards.where((c) => c.lessonId != null).length, 32);
      expect(cards.where((c) => c.moduleId != null).length, 5);
    });

    test('take their words from whatever unlocks them', () async {
      final card = await repo.getCardForLesson('m1l1');
      final lesson = await repo.getLessonById('m1l1');

      expect(card, isNotNull);
      expect(card!.id, 'c1');
      expect(card.title, lesson!.reward.title);
      expect(card.description, lesson.reward.summary);
      expect(card.fact, lesson.reward.fact);
      expect(card.moduleTag, 'Beans');
    });

    test('award exactly one card to every lesson', () async {
      final lessons = await repo.getLessons();
      for (final lesson in lessons) {
        expect(
          await repo.getCardForLesson(lesson.id),
          isNotNull,
          reason: '${lesson.id} awards no card',
        );
      }
    });

    test('award exactly one Module Reward card to every module', () async {
      final modules = await repo.getModules();
      for (final module in modules) {
        expect(
          await repo.getCardForModule(module.id),
          isNotNull,
          reason: '${module.id} awards no card',
        );
      }
    });

    test('name the module, not a lesson, on a Module Reward card', () async {
      final card = await repo.getCardForModule('m1');

      expect(card, isNotNull);
      expect(card!.moduleId, 'm1');
      expect(card.lessonId, isNull);
    });

    test('have no duplicate ids', () async {
      final cards = await repo.getCards();
      final ids = cards.map((c) => c.id).toList();
      expect(ids.toSet().length, ids.length);
    });
  });
}
