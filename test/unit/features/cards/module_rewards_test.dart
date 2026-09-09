import 'package:brew_path/features/cards/domain/cards_providers.dart';
import 'package:brew_path/features/cards/domain/module_rewards.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/content_fixtures.dart';

CardWithCollection lessonCard(String id, {required bool collected}) =>
    CardWithCollection(
      card: testCoffeeCard(id: id),
      isCollected: collected,
    );

CardWithCollection moduleCard(String id, {required bool collected}) =>
    CardWithCollection(
      card: testCoffeeCard(id: id, lessonId: null, moduleId: 'm1'),
      isCollected: collected,
    );

void main() {
  group('CoffeeCardModel.isModuleReward', () {
    test('a card a module awards is one', () {
      expect(moduleCard('cM1', collected: true).card.isModuleReward, isTrue);
    });

    test('a card a lesson awards is not, though its module is known', () {
      final card = testCoffeeCard();

      expect(card.moduleTag, isNotEmpty);
      expect(card.isModuleReward, isFalse);
    });
  });

  group('collectedModuleRewards', () {
    test('counts the module cards owned and none of the lesson cards', () {
      expect(
        collectedModuleRewards([
          lessonCard('c1', collected: true),
          lessonCard('c2', collected: true),
          moduleCard('cM1', collected: true),
        ]),
        1,
      );
    });

    test('a module card the learner has not earned does not count', () {
      expect(
        collectedModuleRewards([
          moduleCard('cM1', collected: true),
          moduleCard('cM2', collected: false),
        ]),
        1,
      );
    });

    test('lesson cards alone count none', () {
      expect(
        collectedModuleRewards([
          lessonCard('c1', collected: true),
          lessonCard('c2', collected: true),
        ]),
        0,
      );
    });

    test('an empty collection counts none', () {
      expect(collectedModuleRewards(const []), 0);
    });
  });
}
