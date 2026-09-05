/// Where a mini-game run starts.
library;

import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/lessons/domain/lesson_destination.dart';

/// Opening [formatId]'s intro, the first screen of a run.
///
/// Deliberately the intro and not the player: the intro states how the game is
/// played, and a learner sent here by Keep Sharp may never have opened this
/// format before. The run records itself on reaching its results (§5, #59).
RouteDestination miniGameRun(String formatId) => RouteDestination(
  name: AppRoutes.miniGameIntro.name,
  pathParams: {'gameId': formatId},
  startsActivity: true,
);
