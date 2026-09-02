import 'package:brew_path/features/progress/domain/activity_recorder.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/snapshot/daily_activity.dart';

/// Records one **finished** review — every card in the deck seen.
///
/// The review pays nothing: no points, no tree growth, no cards, and no
/// grading of any kind. What it leaves behind is that it happened, which is
/// what marks the day active (#33) and spends one unit of the free daily
/// allowance (#65).
///
/// Once per finished review, never per card. A card is not an activity, and a
/// deck of twelve is one day's practice rather than twelve.
///
/// No subject: the type has one review, not one per anything. `subject` names
/// *which* thing was completed where a type has several — a game id, a lesson
/// id — and inventing one here would put a value in the record that nothing
/// could ever ask a question about.
Future<void> recordFlashcardReview(
  SnapshotRepository repository,
  DateTime now,
) => recordActivity(
  repository,
  type: ActivityType.flashcards,
  subject: '',
  now: now,
);
