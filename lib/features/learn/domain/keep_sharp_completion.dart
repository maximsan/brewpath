/// Keep Sharp's acknowledgement rule: whether today's recommended practice
/// type has met its **own** completion rule, derived per-day from existing
/// activity records and stored nowhere (#129).
///
/// Keep Sharp is a pointer at an activity, not an activity — completing the
/// underlying practice is what the streak and any counters consume. This file
/// only answers "did the recommended type's rule get met today?".
library;

import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/learn/domain/keep_sharp.dart';
import 'package:brew_path/shared/storage/progress_record.dart';

/// The mini-games streak rule: two *different* games in a day (§5). One game
/// twice is one game.
const int _twoDifferentGames = 2;

/// Whether [type]'s own completion rule is met, given today's derived facts.
///
/// Types whose activity leaves no record cannot be derived and never
/// acknowledge — the gap belongs on the spec issue, never in a new counter.
bool keepSharpRuleMet(
  PracticeType type, {
  required int distinctGamesToday,
  required bool replayedToday,
}) => switch (type) {
  PracticeType.miniGames => distinctGamesToday >= _twoDifferentGames,
  PracticeType.lessonReplay => replayedToday,
  // No surface, no records; a surface that registers brings its own rule
  // input the same way the two above do.
  PracticeType.vocabGame || PracticeType.flashcards => false,
};

/// Whether any lesson was replayed today: the practice path stamps
/// `lastPracticeXpDate` with the local day of a lesson's first replay each
/// day, so one stamp dated today is exactly one completed replay today.
bool anyReplayToday(Iterable<ProgressRecord> records, DateTime now) =>
    records.any((record) {
      final practicedAt = record.lastPracticeXpDate;
      return practicedAt != null && isSameDay(practicedAt, now);
    });
