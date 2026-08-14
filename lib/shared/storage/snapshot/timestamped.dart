import 'package:flutter/foundation.dart';

/// A value carrying its own write time, for the snapshot's last-writer-wins
/// fields.
///
/// **Why per-field rather than one snapshot-level timestamp.** Union and max
/// fields converge regardless of arrival order, so they need no clock at all.
/// Last-writer-wins is the only class that *discards*, and resolving it against
/// a snapshot-level `updatedAt` lets a device that never touched the field beat
/// the one that did:
///
/// ```text
/// 09:00  iPad  — removes a saved term   (favourites changes)
/// 10:00  phone — finishes a lesson      (favourites untouched)
///        merge: phone's snapshot is newer, so phone's favourites win
///               → the 09:00 removal is undone
/// ```
///
/// Only the fields that can legitimately go backwards carry one of these.
@immutable
class Timestamped<T> {
  /// Creates a [Timestamped].
  const Timestamped({
    required this.value,
    required this.updatedAt,
    this.writerId = '',
  });

  /// The value itself.
  final T value;

  /// The device that wrote this field, breaking ties when [updatedAt] matches.
  ///
  /// **On the field, not the envelope, and that is load-bearing.** An
  /// envelope-level tie-break is not associative: a merged snapshot carries one
  /// device id while its fields came from several, so `(a ⊕ b) ⊕ c` and
  /// `a ⊕ (b ⊕ c)` can resolve the same tie differently and the devices never
  /// converge. Carrying the writer with the value it wrote keeps the comparator
  /// a pure function of field data.
  final String writerId;

  /// When this field was last written, as milliseconds since the Unix epoch.
  ///
  /// An `int` rather than a `DateTime` for three reasons: it is the wire form,
  /// so encoding is identity; `DateTime` has no const constructor, so a
  /// `DateTime` field would forbid the const empty scopes that make Reset a
  /// single assignment; and comparison is total with no timezone to get wrong.
  ///
  /// Wall-clock, with a known limit: a device whose clock is badly wrong wins
  /// every last-writer-wins field until it is corrected. A per-field write
  /// counter would be immune, and was declined — iOS keeps NTP time, the loss
  /// is one favourites edit or a tree skin, and the comparator lives in one
  /// place so the swap stays cheap.
  final int updatedAt;

  /// This field's JSON form. [encodeValue] handles the payload, since only the
  /// caller knows how its own value serialises.
  Map<String, dynamic> toJson(Object? Function(T value) encodeValue) => {
    'value': encodeValue(value),
    'updatedAt': updatedAt,
    'writerId': writerId,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Timestamped<T> &&
          other.updatedAt == updatedAt &&
          other.writerId == writerId &&
          _valuesEqual(other.value, value);

  @override
  int get hashCode => Object.hash(_valueHash(value), updatedAt, writerId);

  @override
  String toString() => 'Timestamped($value @ $updatedAt by $writerId)';
}

/// Sets are compared by content: one of the last-writer-wins payloads is a set
/// of ids, and identity equality would make every merge look like a change.
/// The other payloads are value types with their own `==`.
bool _valuesEqual(Object? a, Object? b) =>
    a is Set && b is Set ? setEquals(a, b) : a == b;

int _valueHash(Object? value) =>
    value is Set ? Object.hashAllUnordered(value) : value.hashCode;
