/// The completion moment's Module Reward count.
library;

import 'package:brew_path/features/cards/domain/cards_providers.dart';

/// How many Module Rewards the learner owns, out of [collection].
///
/// Derived on every read, never marked when a card is earned: a stored marker
/// would need a merge rule and a reset path of its own (#149).
int collectedModuleRewards(Iterable<CardWithCollection> collection) =>
    collection
        .where((entry) => entry.isCollected && entry.card.isModuleReward)
        .length;
