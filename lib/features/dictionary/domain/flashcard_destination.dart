/// Where a flashcard review starts.
library;

import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/lessons/domain/lesson_destination.dart';

/// Opening the drill, named once for all four of its entry points — Keep
/// Sharp resolves it as a destination, and the practice row, the dictionary
/// chip and the shelf's study row push it.
///
/// It replaced a `pushFlashcards` helper that navigated by route name: a
/// review spends one of a free day's two activities (#216), and a second way
/// in that carried no destination had no way to say so.
///
/// Nothing to parameterise either way: the deck is the learner's saved terms
/// wherever they were standing when they asked for it.
// Not `const`: Dart cannot evaluate a field access on a const object inside a
// const expression, which is the same reason `learnTab` and `pathTab` are
// final. Naming the route beats repeating its string either way.
final RouteDestination flashcardReview = RouteDestination(
  name: AppRoutes.flashcards.name,
  startsActivity: true,
);
