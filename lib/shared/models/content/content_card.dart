import 'package:brew_path/shared/models/content/card_parts.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'content_card.freezed.dart';
part 'content_card.g.dart';

/// Marks a card as one that contributes to mastery.
///
/// Empty by design — the graded kinds share no field. It exists so that a
/// scoring seam can take `List<Gradable>` instead of `List<ContentCard>`, which
/// makes the wrong-denominator bug unrepresentable rather than merely
/// avoidable: counting an ungraded card into the total silently deflates every
/// score, and leaving a graded card out of it lets mastery exceed 100%. The
/// prototype shipped the second one — `flavor` scored while missing from the
/// graded list, so a perfect result was reachable with a wrong answer.
///
/// Do not delete this as ceremony. Without it the two lists are kept in step by
/// hand, which is exactly how that bug happened.
abstract class Gradable {}

/// A single card in a lesson, discriminated on its `kind` key.
///
/// The 15 variants are the kinds the prototype actually authors —
/// 14 lesson kinds plus `quiz`, which only mini-games use. `intro` and
/// `takeaway` are absent on purpose: renderers for them survive in the
/// prototype but no card uses either, having been superseded by `predict` and
/// `recall`.
///
/// Field names carry the prototype's vocabulary on the wire and are remapped to
/// idiomatic Dart here — the extractor renames nothing. A prototype-side rename
/// therefore surfaces as a runtime null rather than a compile error, which is
/// why `content_card_test.dart` deserializes every card the extractor emits.
@Freezed(unionKey: 'kind')
sealed class ContentCard with _$ContentCard {
  /// Opening card: a framing body plus one binary guess held at lesson scope.
  const factory ContentCard.predict({
    required String label,
    required String title,
    required String body,
    required String question,
    required List<String> options,
    @JsonKey(name: 'a') required String answer,
    required String hold,
  }) = PredictCard;

  /// Teaching card: a fill-in-the-blank sentence, prose, and a meta table.
  const factory ContentCard.concept({
    required String label,
    required String title,
    @ConceptFillConverter() required List<ConceptFillPart> fill,
    required List<String> paragraphs,
    required List<List<String>> meta,
  }) = ConceptCard;

  /// Full-bleed visual guide, savable to Saved under its own key.
  const factory ContentCard.visual({
    required String label,
    required String title,
    required String variant,
    required String caption,
    bool? mergeHeader,
    bool? captionTop,
  }) = VisualCard;

  /// Hands-on instruction card.
  const factory ContentCard.practical({
    required String tag,
    required String title,
    required List<String> paragraphs,
    required String note,
  }) = PracticalCard;

  /// Four-choice multiple choice.
  @Implements<Gradable>()
  const factory ContentCard.mcq({
    required String prompt,
    required List<Choice> choices,
    @JsonKey(name: 'explain') required String explanation,
  }) = McqCard;

  /// Select-all-that-apply, graded as a whole set.
  @Implements<Gradable>()
  const factory ContentCard.multi({
    required String prompt,
    required List<Choice> choices,
    @JsonKey(name: 'explain') required String explanation,
  }) = MultiCard;

  /// Closing check that resolves the opening prediction.
  @Implements<Gradable>()
  const factory ContentCard.recall({
    required String label,
    required String question,
    required List<Choice> choices,
    @JsonKey(name: 'explain') required String explanation,
    @JsonKey(name: 'line') required String takeaway,
  }) = RecallCard;

  /// Scenario card: a real situation, two options, and an outcome for each.
  @Implements<Gradable>()
  const factory ContentCard.decision({
    required String label,
    required String title,
    required String scenario,
    required String question,
    required List<DecisionOption> options,
    @JsonKey(name: 'right') required String rightExplanation,
    @JsonKey(name: 'wrong') required String wrongExplanation,
    String? note,
  }) = DecisionCard;

  /// Trait-to-answer pairing. Several traits may share an answer.
  @Implements<Gradable>()
  const factory ContentCard.match({
    required String prompt,
    required List<MatchPair> pairs,
  }) = MatchCard;

  /// Tap the items into order, then submit.
  @Implements<Gradable>()
  const factory ContentCard.sequence({
    required String prompt,
    required List<SequenceItem> items,
  }) = SequenceCard;

  /// Calibrate: drag to a value and check it against a target band.
  @Implements<Gradable>()
  const factory ContentCard.slider({
    required String prompt,
    required String leftLabel,
    required String rightLabel,
    required double target,
    required double tolerance,
    required List<String> scale,
    required String feedback,
  }) = SliderCard;

  /// A cup came out wrong — pick the one change that fixes it.
  @Implements<Gradable>()
  const factory ContentCard.tastefix({
    required List<String> tags,
    required String prompt,
    required String scenario,
    required List<Choice> choices,
    @JsonKey(name: 'explain') required String explanation,
  }) = TastefixCard;

  /// Call the process from the look of an unlabelled sample's green beans.
  @Implements<Gradable>()
  const factory ContentCard.bagpick({
    required String bag,
    required String origin,
    required String prompt,
    required BagpickBean bean,
    required List<String> options,
    required String answer,
    required String tell,
    required List<BagpickCue> cues,
    @JsonKey(name: 'explain') required String explanation,
  }) = BagpickCard;

  /// A tasting clue and four notes to choose from. [answer] indexes `choices`.
  @Implements<Gradable>()
  const factory ContentCard.flavor({
    required String clue,
    required String prompt,
    required List<Choice> choices,
    required int answer,
    @JsonKey(name: 'explain') required String explanation,
  }) = FlavorCard;

  /// True or false, one statement at a time.
  ///
  /// Unique to mini-games: no lesson authors this kind, which is why it is
  /// absent from the graded kinds the extractor publishes in the lessons bank
  /// (that set exists to cross-check *lesson* cards). It is graded all the
  /// same — a run counts its successes.
  @Implements<Gradable>()
  const factory ContentCard.quiz({
    required String statement,
    required bool answer,
    @JsonKey(name: 'explain') required String explanation,
  }) = QuizCard;

  /// Creates a [ContentCard] from decoded JSON, dispatching on `kind`.
  factory ContentCard.fromJson(Map<String, dynamic> json) =>
      _$ContentCardFromJson(json);
}
