/// Keep Sharp's acknowledgement rule: whether today's recommended practice
/// type has met its **own** completion rule, derived per-day from existing
/// activity records and stored nowhere (#129).
///
/// Keep Sharp is a pointer at an activity, not an activity — completing the
/// underlying practice is what the streak and any counters consume. This file
/// only answers "did the recommended type's rule get met today?".
library;

import 'package:brew_path/features/learn/domain/keep_sharp.dart';
import 'package:brew_path/shared/storage/snapshot/daily_activity.dart';

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
  required bool vocabRoundToday,
}) => switch (type) {
  PracticeType.miniGames => distinctGamesToday >= _twoDifferentGames,
  PracticeType.lessonReplay => replayedToday,
  // One finished round, which is the rule the card states.
  PracticeType.vocabGame => vocabRoundToday,
  // No surface, no records; a surface that registers brings its own rule
  // input the same way the three above do.
  PracticeType.flashcards => false,
};

/// Whether any lesson was replayed among [entries] — one day's activity.
///
/// Read off the activity record rather than off a payout ledger. It used to
/// ask whether a lesson carried a practice-payout stamp dated today, which
/// worked only for as long as replays were paid: the stamp existed to make the
/// once-a-day reward idempotent, and answering "was there a replay?" with it
/// meant a rule about practice quietly depended on a rule about money. Retiring
/// the payout would have taken this derivation with it, silently.
///
/// Every replay already records itself on the day (§3), which is the same set
/// [distinctMiniGameIds] and the streak read — so all three of Keep Sharp's
/// inputs now come from one source, and none of them is stored for this.
bool anyReplayToday(Iterable<String> entries) => entries.any(
  (entry) => parseActivityEntry(entry).type == ActivityType.replay,
);

/// Whether a vocab round was finished among [entries] — one day's activity.
///
/// Read off the same activity record every other rule here reads, so the
/// drill's acknowledgement needs no counter of its own.
bool anyVocabRoundToday(Iterable<String> entries) => entries.any(
  (entry) => parseActivityEntry(entry).type == ActivityType.vocab,
);
