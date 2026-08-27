/// Builders for the content models, so a test names only what it is about.
///
/// Every test used to hand-roll its own module and lesson, which meant a field
/// added to either was a change in a dozen files and a test's *subject* was
/// buried in eight lines of scaffolding it did not care about.
library;

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

/// A card kind with no renderer, for testing what a lesson does with one.
///
/// `slider` because it is the kind furthest from having one — it belongs to
/// #333 and nothing in flight touches it. Whichever renderer lands next, point
/// this at a kind that still has none rather than deleting the tests it feeds:
/// they cover what a lesson does with an undrawable card, not this kind.
ContentCard testUnplayableCard() => const ContentCard.slider(
  prompt: 'How fine did you grind?',
  leftLabel: 'Coarse',
  rightLabel: 'Fine',
  target: 0.6,
  tolerance: 0.1,
  scale: ['Coarse', 'Medium', 'Fine'],
  feedback: 'No renderer draws this kind yet.',
);

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
