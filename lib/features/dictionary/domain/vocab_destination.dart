/// Where a vocab drill starts.
library;

import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/lessons/domain/lesson_destination.dart';

/// Opening *Guess the term*, from wherever the learner found it.
///
/// The drill's own setup is the first screen, not a round: the deck and the
/// length are the learner's to choose, and a Keep Sharp tap that dealt a round
/// immediately would take that choice away.
///
/// Not `const`: Dart cannot evaluate a field access on a const object inside a
/// const expression, and naming the route rather than repeating its string is
/// worth more here than the constant.
final RouteDestination vocabGame = RouteDestination(
  name: AppRoutes.vocabGame.name,
);
