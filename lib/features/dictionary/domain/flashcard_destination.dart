/// Where a flashcard review starts.
library;

import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/lessons/domain/lesson_destination.dart';

/// Opening the drill.
///
/// One destination for all four ways in — the dictionary's chip, the shelf's
/// study row, the Learn tab's practice row and Keep Sharp — because the deck
/// is the learner's saved terms wherever they were standing when they asked
/// for it. There is nothing for a caller to parameterise and so nothing for a
/// caller to get wrong.
final RouteDestination flashcardReview = RouteDestination(
  name: AppRoutes.flashcards.name,
);
