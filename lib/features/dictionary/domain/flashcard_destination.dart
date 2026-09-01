/// Where a flashcard review starts.
library;

import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/lessons/domain/lesson_destination.dart';

/// Opening the drill, for a caller that resolves a destination rather than
/// navigating — which is Keep Sharp, and only Keep Sharp. The three screen
/// entry points push through `BuildContext.pushFlashcards`.
///
/// Nothing to parameterise either way: the deck is the learner's saved terms
/// wherever they were standing when they asked for it.
// Not `const`: Dart cannot evaluate a field access on a const object inside a
// const expression, which is the same reason `learnTab` and `pathTab` are
// final. Naming the route beats repeating its string either way.
final RouteDestination flashcardReview = RouteDestination(
  name: AppRoutes.flashcards.name,
);
