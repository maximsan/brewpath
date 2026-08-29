/// Builders for the content models, so a test names only what it is about.
///
/// Every test used to hand-roll its own module and lesson, which meant a field
/// added to either was a change in a dozen files and a test's *subject* was
/// buried in eight lines of scaffolding it did not care about.
library;

import 'package:brew_path/features/cards/domain/cards_providers.dart';
import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:brew_path/shared/models/content/brew_challenge.dart';
import 'package:brew_path/shared/models/content/card_parts.dart';
import 'package:brew_path/shared/models/content/content_card.dart';
import 'package:brew_path/shared/models/content/content_reward.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/models/module_model.dart';

/// A reward with filler words.
ContentReward testReward({String title = 'A Card'}) => ContentReward(
  title: title,
  summary: 'What it is.',
  fact: 'Something true about it.',
);

/// A module holding [lessonIds], at course position [n].
ModuleModel testModule({
  String id = 'm1',
  int n = 1,
  String title = 'Beans',
  String iconName = 'beans',
  List<String> lessonIds = const ['m1l1', 'm1l2'],
}) => ModuleModel(
  id: id,
  n: n,
  label: 'MODULE $n · ${title.toUpperCase()}',
  iconName: iconName,
  title: title,
  lessons: [
    for (final lessonId in lessonIds)
      ModuleLesson(id: lessonId, title: lessonId, points: 10, time: 3),
  ],
  reward: testReward(title: '$title Field Guide'),
);

/// A lesson carrying [cards], defaulting to one ungraded and one graded.
LessonModel testLesson({
  String id = 'm1l1',
  String moduleId = 'm1',
  String title = 'What coffee actually is',
  int points = 10,
  int time = 3,
  List<ContentCard>? cards,
}) => LessonModel(
  id: id,
  moduleId: moduleId,
  moduleLabel: 'MODULE 1 · BEANS',
  title: title,
  points: points,
  time: time,
  cards: cards ?? [testConceptCard(), testMcqCard()],
  reward: testReward(),
);

/// A collectible card as the screens receive it, already joined to its words.
CoffeeCardModel testCoffeeCard({
  String id = 'c1',
  String title = 'The Coffee Cherry',
  String moduleTag = 'Beans',
  String? lessonId = 'm1l1',
  String? moduleId,
}) => CoffeeCardModel(
  id: id,
  title: title,
  description: 'What it is.',
  fact: 'Something true about it.',
  moduleTag: moduleTag,
  iconName: 'beans',
  lessonId: lessonId,
  moduleId: moduleId,
);

/// A collectible paired with whether the learner holds it, in the shape the
/// Cards tab receives them.
CardWithCollection testCardWithCollection(
  String id, {
  required bool collected,
  String moduleTag = 'Beans',
}) => CardWithCollection(
  card: testCoffeeCard(id: id, title: 'Card $id', moduleTag: moduleTag),
  isCollected: collected,
);

/// An ungraded card — reading it can never cost a learner a mark.
ContentCard testConceptCard({String title = 'The cherry, the seed'}) =>
    ContentCard.concept(
      label: 'CONCEPT',
      title: title,
      fill: const [FillLiteral('A coffee bean is really a seed.')],
      paragraphs: const ['A coffee plant grows small red cherries.'],
      meta: const [
        ['LOOKS LIKE', 'cherry'],
      ],
    );

/// A graded card whose first choice is the correct one.
ContentCard testMcqCard({String prompt = 'What is a coffee bean?'}) =>
    ContentCard.mcq(
      prompt: prompt,
      choices: const [
        Choice(text: 'A seed', isCorrect: true),
        Choice(text: 'A berry'),
      ],
      explanation: 'It is the seed of a fruit.',
    );

// `testUnplayableCard` stood here — a card of whatever kind had no renderer
// yet, so a lesson could be asked what it does with one. It named `slider`
// last, and asked to be retargeted rather than deleted whenever a renderer
// landed.
//
// There is nothing left to retarget it at: with `slider` and `sequence` built
// (#124) every kind of the union draws, so an undrawable card cannot be
// constructed at all. What it guarded is now a compile-time fact — the two
// exhaustive switches in `content_card_view.dart` break the build when a kind
// is added — and `content_card_view_test.dart` pins them to each other.

/// A Coffee Challenge. Defaults to a lesson-scoped record naming no lesson —
/// the shape the bank allows but the rules refuse to earn.
BrewChallenge testChallenge({
  String id = 'bc-m1',
  ChallengeScope scope = ChallengeScope.lesson,
  String moduleId = 'm1',
  String cardId = 'cM1',
  String title = 'Two cups, two ratios',
  String effort = 'Next brews · 5 min',
  String prompt = 'WHICH CUP WON?',
  List<String> reactions = const [
    'Preferred 1:15',
    'Preferred 1:17',
    'Hard to tell',
  ],
  String? lessonId,
}) => BrewChallenge(
  id: id,
  scope: scope,
  moduleId: moduleId,
  cardId: cardId,
  title: title,
  instruction: 'Brew the same coffee twice at two different ratios.',
  effort: effort,
  prompt: prompt,
  reactions: reactions,
  lessonId: lessonId,
);
