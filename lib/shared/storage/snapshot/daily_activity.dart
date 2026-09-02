/// The per-day completion record the free daily allowance counts against.
///
/// Each entry is **one completion**, not one kind of completion. A set keyed
/// on type would collapse two vocab rounds — or two replays of one lesson —
/// into a single mark, and the cap has to see two (#65, carried in #104).
///
/// Entries are strings because that is the wire form the whole record merges
/// in: a day's entries union across devices, and a set of scalars unions with
/// no decode step in the middle. Everything here is pure — the token that
/// makes an entry unique is minted by the caller, so a test can supply its
/// own and get the same record every run.
library;

import 'dart:math';

/// What a completion was. The wire form is the enum's name, so a value added
/// here is readable by any build that knows it and inert in one that does not.
enum ActivityType {
  /// A lesson completed for the first time.
  lesson,

  /// A replay of an already-completed lesson.
  replay,

  /// One completed standalone mini-game run.
  miniGame,

  /// One vocab round, written when Guess the term finishes one.
  vocab,

  /// One flashcard review, written when every card in the deck has been seen.
  flashcards,
}

/// An entry's decoded parts. The type is null for an entry written by a
/// build that knows a type this one does not — carried, not understood.
typedef ActivityEntry = ({ActivityType? type, String subject});

/// Separates an entry's parts.
const String _fieldSeparator = ':';

/// How many days the record keeps. Nothing reads beyond today; yesterday is
/// kept so a completion either side of local midnight is never lost to a
/// clock that moved while the app was open.
const int _keptDays = 2;

/// Upper bound of the random half of a minted token.
const int _tokenRandomBound = 0x10000;

final Random _tokenRandom = Random();

/// A token unique enough that two real completions never collapse under the
/// union merge — including the same completion on two devices in the same
/// microsecond.
///
/// The only impure function here, and deliberately separate from
/// [activityEntry] so everything that *builds* a record stays testable.
String mintActivityToken() =>
    '${DateTime.now().microsecondsSinceEpoch}'
    '-${_tokenRandom.nextInt(_tokenRandomBound)}';

/// One completion event.
///
/// [subject] names what was completed where the type has one — a game id, a
/// lesson id — and is empty where it does not. It is encoded **last** so a
/// subject containing the separator cannot truncate the fields before it.
String activityEntry({
  required ActivityType type,
  required String token,
  String subject = '',
}) {
  assert(
    !token.contains(_fieldSeparator),
    'a token with a separator in it would split into the subject',
  );
  return '${type.name}$_fieldSeparator$token$_fieldSeparator$subject';
}

/// Decodes [entry] in one pass.
ActivityEntry parseActivityEntry(String entry) {
  final parts = entry.split(_fieldSeparator);
  final name = parts.first;
  final type = ActivityType.values
      .where((candidate) => candidate.name == name)
      .firstOrNull;
  // Everything past the token is subject, so a separator inside it survives.
  final subject = parts.length > 2
      ? parts.sublist(2).join(_fieldSeparator)
      : '';
  return (type: type, subject: subject);
}

/// The distinct games played among [entries].
///
/// The streak rule is unchanged in meaning by the move off `miniGamePlays`:
/// two *different* completed mini-games mark the day, so two runs of one game
/// still read as one here while the allowance counts them as two.
Set<String> distinctMiniGameIds(Iterable<String> entries) {
  final ids = <String>{};
  for (final raw in entries) {
    final entry = parseActivityEntry(raw);
    if (entry.type == ActivityType.miniGame && entry.subject.isNotEmpty) {
      ids.add(entry.subject);
    }
  }
  return ids;
}

/// How many *different* mini-games mark a day (§5, #59).
const int miniGamesPerQualifyingDay = 2;

/// Whether a day's [entries] qualify it on mini-games alone.
///
/// Two different completed games. One run is not enough, the same game twice
/// counts once, and a third different game adds nothing — the anti-farm rule,
/// derived from what is stored rather than stored as a flag, so changing it
/// needs no migration.
bool miniGamesMarkTheDay(Iterable<String> entries) =>
    distinctMiniGameIds(entries).length >= miniGamesPerQualifyingDay;

/// Drops days nothing will read again.
///
/// **Not wired yet, deliberately.** Nothing writes an activity event in this
/// build, so there is nothing to prune; the trim belongs to whichever code
/// first appends one, which is where the record is already being rebuilt.
/// The two places it must *not* go: `mergeSnapshot`, which is pure and proved
/// against laws a clock would break, and `SnapshotRepository`, which would
/// then return something other than what it was handed.
///
/// Best-effort only: a peer still holding an older day re-adds it on the next
/// union merge, which is harmless because nothing reads beyond today. Days
/// ahead of [today] are kept — another device's clock may be ahead, and
/// dropping them would delete real completions.
Map<int, Set<String>> pruneDailyActivity(
  Map<int, Set<String>> record, {
  required int today,
}) => {
  for (final entry in record.entries)
    if (entry.key > today - _keptDays) entry.key: entry.value,
};
