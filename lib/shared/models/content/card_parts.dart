import 'package:freezed_annotation/freezed_annotation.dart';

part 'card_parts.freezed.dart';
part 'card_parts.g.dart';

// The nested value types a `ContentCard` variant is built from.
//
// Field names come from the prototype's vocabulary and are remapped here rather
// than in the extractor, which renames nothing: `t` is a choice's text, `l`/`r`
// the two sides of a pairing, `a`/`o` a blank's answer and its options.

/// One option in a multiple-choice, select-all, taste-fix or flavour card.
@freezed
abstract class Choice with _$Choice {
  /// Creates a [Choice].
  const factory Choice({
    @JsonKey(name: 't') required String text,
    @JsonKey(name: 'correct') @Default(false) bool isCorrect,
  }) = _Choice;

  /// Creates a [Choice] from decoded JSON.
  factory Choice.fromJson(Map<String, dynamic> json) => _$ChoiceFromJson(json);
}

/// One of the two courses of action a `decision` card offers.
@freezed
abstract class DecisionOption with _$DecisionOption {
  /// Creates a [DecisionOption].
  const factory DecisionOption({
    @JsonKey(name: 't') required String text,
    @JsonKey(name: 'sub') String? subtitle,
    @JsonKey(name: 'correct') @Default(false) bool isCorrect,
  }) = _DecisionOption;

  /// Creates a [DecisionOption] from decoded JSON.
  factory DecisionOption.fromJson(Map<String, dynamic> json) =>
      _$DecisionOptionFromJson(json);
}

/// One trait-to-answer pairing in a `match` card. Several traits may share an
/// answer, so [right] is not unique across a card's pairs.
@freezed
abstract class MatchPair with _$MatchPair {
  /// Creates a [MatchPair].
  const factory MatchPair({
    @JsonKey(name: 'l') required String left,
    @JsonKey(name: 'r') required String right,
  }) = _MatchPair;

  /// Creates a [MatchPair] from decoded JSON.
  factory MatchPair.fromJson(Map<String, dynamic> json) =>
      _$MatchPairFromJson(json);
}

/// One item in a `sequence` card. [order] is its correct 1-based position.
@freezed
abstract class SequenceItem with _$SequenceItem {
  /// Creates a [SequenceItem].
  const factory SequenceItem({
    required String label,
    required int order,
  }) = _SequenceItem;

  /// Creates a [SequenceItem] from decoded JSON.
  factory SequenceItem.fromJson(Map<String, dynamic> json) =>
      _$SequenceItemFromJson(json);
}

/// How a `bagpick` card's green beans are drawn: two hex colours, a mottling
/// step, and whether chaff clings to the crease.
@freezed
abstract class BagpickBean with _$BagpickBean {
  /// Creates a [BagpickBean].
  const factory BagpickBean({
    required String body,
    required String crease,
    required int mottle,
    required bool chaff,
  }) = _BagpickBean;

  /// Creates a [BagpickBean] from decoded JSON.
  factory BagpickBean.fromJson(Map<String, dynamic> json) =>
      _$BagpickBeanFromJson(json);
}

/// One inspectable clue on a `bagpick` card. The card's `tell` names the [id]
/// of the cue that actually settles the answer.
@freezed
abstract class BagpickCue with _$BagpickCue {
  /// Creates a [BagpickCue].
  const factory BagpickCue({
    required String id,
    required String label,
    required String text,
  }) = _BagpickCue;

  /// Creates a [BagpickCue] from decoded JSON.
  factory BagpickCue.fromJson(Map<String, dynamic> json) =>
      _$BagpickCueFromJson(json);
}

/// One segment of a `concept` card's fill-in-the-blank sentence.
///
/// The sentence is authored as a mixed list — plain runs of text interleaved
/// with the blanks the reader taps — so a segment is either literal prose or a
/// blank carrying its own answer and options.
@freezed
sealed class ConceptFillPart with _$ConceptFillPart {
  /// A run of sentence text that is shown as-is.
  const factory ConceptFillPart.literal(String text) = FillLiteral;

  /// A tappable blank. The sentence always resolves correctly, so [options] is
  /// the pair offered and [answer] is the one that stays.
  const factory ConceptFillPart.blank({
    required String answer,
    required List<String> options,
    required String label,
  }) = FillBlank;
}

/// Reads a `concept` card's `fill` list, whose elements are heterogeneous.
///
/// json_serializable cannot infer a union from an untagged element, so the two
/// shapes are discriminated here: a bare string is prose, a map is a blank.
class ConceptFillConverter implements JsonConverter<ConceptFillPart, Object?> {
  /// Creates a [ConceptFillConverter].
  const ConceptFillConverter();

  @override
  ConceptFillPart fromJson(Object? json) {
    if (json is String) return ConceptFillPart.literal(json);
    final blank = json! as Map<String, dynamic>;
    return ConceptFillPart.blank(
      answer: blank['a'] as String,
      options: (blank['o'] as List<dynamic>).cast<String>(),
      label: blank['label'] as String,
    );
  }

  @override
  Object? toJson(ConceptFillPart part) => switch (part) {
    FillLiteral(:final text) => text,
    FillBlank(:final answer, :final options, :final label) => <String, dynamic>{
      'a': answer,
      'o': options,
      'label': label,
    },
  };
}
