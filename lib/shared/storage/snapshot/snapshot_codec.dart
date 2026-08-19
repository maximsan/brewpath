/// Decoding helpers shared by the snapshot's scopes.
///
/// Split out of the scope definitions so each file has one job: the scopes
/// declare *what the snapshot holds*, this declares *how it survives a round
/// trip*. Every decoder is total — a missing or malformed value reads as the
/// zero value rather than throwing, because the store is an unvalidated blob
/// and a payload that fails to parse must degrade instead of bricking launch.
library;

import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';
import 'package:brew_path/shared/storage/snapshot/timestamped.dart';

/// The Unix epoch, and the stamp an absent last-writer-wins field reads as.
const epochMillis = 0;

/// Every key in [json] that is not in [known], kept so a build that does not
/// understand a newer field still writes it back untouched.
Map<String, dynamic> unknownKeys(
  Map<String, dynamic> json,
  Set<String> known,
) => {
  for (final entry in json.entries)
    if (!known.contains(entry.key)) entry.key: entry.value,
};

/// Reads a nested object, or an empty one when the value is missing or is not
/// an object at all.
Map<String, dynamic> objectOrEmpty(Object? raw) =>
    raw is Map ? Map<String, dynamic>.from(raw) : const {};

/// Reads a `key → day` map, dropping entries whose value is not a day number.
Map<String, int> dayMapFromJson(Object? raw) {
  if (raw is! Map) return const {};
  return {
    for (final entry in raw.entries)
      if (entry.value is int) '${entry.key}': entry.value as int,
  };
}

/// Reads a `lesson id → {correct, total}` map.
Map<String, MasteryResult> masteryMapFromJson(Object? raw) {
  if (raw is! Map) return const {};
  return {
    for (final entry in raw.entries)
      if (entry.value is Map)
        '${entry.key}': MasteryResult(
          correct: objectOrEmpty(entry.value)['correct'] as int? ?? 0,
          total: objectOrEmpty(entry.value)['total'] as int? ?? 0,
        ),
  };
}

/// Writes a `lesson id → {correct, total}` map.
Map<String, dynamic> masteryMapToJson(Map<String, MasteryResult> results) => {
  for (final entry in results.entries)
    entry.key: {'correct': entry.value.correct, 'total': entry.value.total},
};

/// Reads a `challenge id → reaction` map.
Map<String, ChallengeReaction> reactionMapFromJson(Object? raw) {
  if (raw is! Map) return const {};
  return {
    for (final entry in raw.entries)
      if (entry.value is Map)
        '${entry.key}': ChallengeReaction.fromJson(objectOrEmpty(entry.value)),
  };
}

/// Writes a `challenge id → reaction` map.
Map<String, dynamic> reactionMapToJson(
  Map<String, ChallengeReaction> reactions,
) => {
  for (final entry in reactions.entries) entry.key: entry.value.toJson(),
};

/// Reads a `day → entries` map. JSON object keys are always strings,
/// so the day is parsed back and unparseable keys are dropped.
Map<int, Set<String>> dayEntriesFromJson(Object? raw) {
  if (raw is! Map) return const {};
  final parsed = <int, Set<String>>{};
  for (final entry in raw.entries) {
    final day = int.tryParse('${entry.key}');
    if (day != null) parsed[day] = stringSetFromJson(entry.value);
  }
  return parsed;
}

/// Writes a `day → entries` map.
Map<String, dynamic> dayEntriesToJson(Map<int, Set<String>> byDay) => {
  for (final entry in byDay.entries) '${entry.key}': sortedList(entry.value),
};

/// Reads a set of ids.
Set<String> stringSetFromJson(Object? raw) =>
    raw is List ? raw.whereType<String>().toSet() : const {};

/// Reads a set of day numbers.
Set<int> intSetFromJson(Object? raw) =>
    raw is List ? raw.whereType<int>().toSet() : const {};

/// Sets are unordered, so encoding sorts them. Without this the same state
/// produces different bytes on different runs, which makes a stored payload
/// look changed when nothing was written.
List<T> sortedList<T extends Comparable<T>>(Set<T> values) =>
    values.toList()..sort();

/// Reads a last-writer-wins field wrapping a set of ids.
Timestamped<Set<String>> stampedSetFromJson(Object? raw) {
  final field = objectOrEmpty(raw);
  return Timestamped(
    value: stringSetFromJson(field['value']),
    updatedAt: field['updatedAt'] as int? ?? epochMillis,
    writerId: field['writerId'] as String? ?? '',
  );
}

/// Reads the active-challenge field, which is nullable where the others are
/// not — no challenge in play is a legitimate value, not an absent one.
Timestamped<ActiveChallenge?> stampedChallengeFromJson(Object? raw) {
  final field = objectOrEmpty(raw);
  return Timestamped(
    value: field['value'] is Map
        ? ActiveChallenge.fromJson(objectOrEmpty(field['value']))
        : null,
    updatedAt: field['updatedAt'] as int? ?? epochMillis,
    writerId: field['writerId'] as String? ?? '',
  );
}

/// Reads a last-writer-wins field wrapping an object, falling back to
/// [fallback] when the payload is missing or malformed.
Timestamped<T> stampedObjectFromJson<T>(
  Object? raw,
  T Function(Map<String, dynamic>) parse,
  T fallback,
) {
  final field = objectOrEmpty(raw);
  return Timestamped(
    value: field['value'] is Map
        ? parse(objectOrEmpty(field['value']))
        : fallback,
    updatedAt: field['updatedAt'] as int? ?? epochMillis,
    writerId: field['writerId'] as String? ?? '',
  );
}
