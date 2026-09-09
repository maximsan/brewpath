import 'package:brew_path/features/cards/domain/module_rewards.dart';
import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:flutter_test/flutter_test.dart';

CoffeeCardModel card(String id, {String? lessonId, String? moduleId}) =>
    CoffeeCardModel(
      id: id,
      title: id,
      description: '',
      fact: '',
      moduleTag: 'Beans',
      iconName: 'bean',
      kind: 'botanical',
      lessonId: lessonId,
      moduleId: moduleId,
    );

final List<CoffeeCardModel> _lessonCards = [
  card('c1', lessonId: 'm1l1'),
  card('c2', lessonId: 'm1l2'),
  card('c3', lessonId: 'm2l1'),
];

final List<CoffeeCardModel> _moduleCards = [
  card('cM1', moduleId: 'm1'),
  card('cM2', moduleId: 'm2'),
];

void main() {
  group('isModuleReward', () {
    test('a card a module awards is one', () {
      expect(isModuleReward(card('cM1', moduleId: 'm1')), isTrue);
    });

    test('a card a lesson awards is not, though its module is known', () {
      expect(isModuleReward(card('c1', lessonId: 'm1l1')), isFalse);
    });
  });

  group('moduleRewardCount', () {
    test('counts the module cards owned and none of the lesson cards', () {
      expect(moduleRewardCount([..._lessonCards, _moduleCards.first]), 1);
    });

    test('a full collection counts every module card', () {
      expect(moduleRewardCount([..._lessonCards, ..._moduleCards]), 2);
    });

    test('lesson cards alone count none', () {
      expect(moduleRewardCount(_lessonCards), 0);
    });

    test('owning nothing counts none', () {
      expect(moduleRewardCount(const []), 0);
    });
  });
}
