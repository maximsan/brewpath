/// Telling the five Module Rewards apart from the thirty-two lesson cards.
library;

import 'package:brew_path/shared/models/coffee_card_model.dart';

/// Whether [card] is a Module Reward.
///
/// The source is the collectibles bank's own `unlock.module` pointer, carried
/// onto the card as [CoffeeCardModel.moduleId] and set by nothing else — a
/// lesson card's owning module lives in `moduleTag`. The extractor rules
/// exactly one pointer per collectible, so this needs no second condition.
bool isModuleReward(CoffeeCardModel card) => card.moduleId != null;

/// How many of the [owned] cards are Module Rewards.
///
/// Derived on every read rather than marked when a card is earned: what kind
/// of card an id names is a fact about the content, and a stored marker would
/// need a merge rule and a reset path of its own.
int moduleRewardCount(Iterable<CoffeeCardModel> owned) =>
    owned.where(isModuleReward).length;
