/// Where a vocab drill starts.
library;

import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/lessons/domain/lesson_destination.dart';

/// Opening *Guess the term* at its setup, not at a round: the deck and the
/// length are the learner's to choose.
///
/// Not `const`: Dart cannot evaluate a field access on a const object inside a
/// const expression.
final RouteDestination vocabGame = RouteDestination(
  name: AppRoutes.vocabGame.name,
);
