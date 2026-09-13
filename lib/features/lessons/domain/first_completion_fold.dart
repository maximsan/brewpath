/// What a lesson's first completion writes, as one fold over the progress it
/// found — pure, so the shape of the write is asserted without a store.
library;

import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/features/progress/domain/tree_growth.dart';
import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/models/module_model.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_scopes.dart';
import 'package:flutter/foundation.dart';

/// The course as the fold reads it: its modules and its collectibles.
typedef CourseBank = ({List<ModuleModel> modules, List<CoffeeCardModel> cards});

/// The progress a first completion leaves, and what only the fold's input
/// could tell about it: where the tree stood, and what the run handed over.
@immutable
class FirstCompletionFold {
  /// Creates a [FirstCompletionFold].
  const FirstCompletionFold({
    required this.progress,
    required this.stageBefore,
    this.card,
    this.closedModule,
    this.moduleCard,
  });

  /// The progress to write.
  final ClearedByReset progress;

  /// The tree's stored stage before this completion.
  final int stageBefore;

  /// The collectible the lesson hands over, or null when it has none.
  final CoffeeCardModel? card;

  /// The module this completion was the last lesson of, or null.
  final ModuleModel? closedModule;

  /// The Module Reward [closedModule] pays, or null when there is none or
  /// no module closed.
  final CoffeeCardModel? moduleCard;
}

/// Folds a first completion of [lesson] on [day] into [found].
///
/// One fold, so the completion, the card it hands over, the stage the tree
/// reaches and the Module Reward a closed module pays are one write: a
/// learner who closed the app between two writes would otherwise hold a
/// finished lesson whose card, tree or module reward never arrived.
FirstCompletionFold foldFirstCompletion(
  ClearedByReset found, {
  required LessonModel lesson,
  required int day,
  required MasteryResult mastery,
  required CourseBank course,
}) {
  final card = course.cards
      .where((candidate) => candidate.lessonId == lesson.id)
      .firstOrNull;
  var next = found.withLessonCompleted(lesson.id, day: day, mastery: mastery);
  if (card != null) next = next.withCollectible(card.id);

  final module = course.modules
      .where((candidate) => candidate.id == lesson.moduleId)
      .firstOrNull;
  final closed =
      module != null &&
          module.lessonIds.every(next.completedLessons.containsKey)
      ? module
      : null;
  final moduleCard = closed == null
      ? null
      : course.cards
            .where((candidate) => candidate.moduleId == closed.id)
            .firstOrNull;
  if (moduleCard != null) next = next.withCollectible(moduleCard.id);

  final stage = treeStageForProgress(
    completed: next.completedLessons.length,
    moduleSizes: moduleSizesInOrder(course.modules),
  );
  return FirstCompletionFold(
    progress: next.withTreeStageAtLeast(stage),
    stageBefore: found.treeStage,
    card: card,
    closedModule: closed,
    moduleCard: moduleCard,
  );
}
