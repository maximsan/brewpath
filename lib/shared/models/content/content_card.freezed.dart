// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'content_card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
ContentCard _$ContentCardFromJson(
  Map<String, dynamic> json
) {
        switch (json['kind']) {
                  case 'predict':
          return PredictCard.fromJson(
            json
          );
                case 'concept':
          return ConceptCard.fromJson(
            json
          );
                case 'visual':
          return VisualCard.fromJson(
            json
          );
                case 'practical':
          return PracticalCard.fromJson(
            json
          );
                case 'mcq':
          return McqCard.fromJson(
            json
          );
                case 'multi':
          return MultiCard.fromJson(
            json
          );
                case 'recall':
          return RecallCard.fromJson(
            json
          );
                case 'decision':
          return DecisionCard.fromJson(
            json
          );
                case 'match':
          return MatchCard.fromJson(
            json
          );
                case 'sequence':
          return SequenceCard.fromJson(
            json
          );
                case 'slider':
          return SliderCard.fromJson(
            json
          );
                case 'tastefix':
          return TastefixCard.fromJson(
            json
          );
                case 'bagpick':
          return BagpickCard.fromJson(
            json
          );
                case 'flavor':
          return FlavorCard.fromJson(
            json
          );
                case 'quiz':
          return QuizCard.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'kind',
  'ContentCard',
  'Invalid union type "${json['kind']}"!'
);
        }
      
}

/// @nodoc
mixin _$ContentCard {



  /// Serializes this ContentCard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContentCard);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ContentCard()';
}


}

/// @nodoc
class $ContentCardCopyWith<$Res>  {
$ContentCardCopyWith(ContentCard _, $Res Function(ContentCard) __);
}


/// Adds pattern-matching-related methods to [ContentCard].
extension ContentCardPatterns on ContentCard {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PredictCard value)?  predict,TResult Function( ConceptCard value)?  concept,TResult Function( VisualCard value)?  visual,TResult Function( PracticalCard value)?  practical,TResult Function( McqCard value)?  mcq,TResult Function( MultiCard value)?  multi,TResult Function( RecallCard value)?  recall,TResult Function( DecisionCard value)?  decision,TResult Function( MatchCard value)?  match,TResult Function( SequenceCard value)?  sequence,TResult Function( SliderCard value)?  slider,TResult Function( TastefixCard value)?  tastefix,TResult Function( BagpickCard value)?  bagpick,TResult Function( FlavorCard value)?  flavor,TResult Function( QuizCard value)?  quiz,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PredictCard() when predict != null:
return predict(_that);case ConceptCard() when concept != null:
return concept(_that);case VisualCard() when visual != null:
return visual(_that);case PracticalCard() when practical != null:
return practical(_that);case McqCard() when mcq != null:
return mcq(_that);case MultiCard() when multi != null:
return multi(_that);case RecallCard() when recall != null:
return recall(_that);case DecisionCard() when decision != null:
return decision(_that);case MatchCard() when match != null:
return match(_that);case SequenceCard() when sequence != null:
return sequence(_that);case SliderCard() when slider != null:
return slider(_that);case TastefixCard() when tastefix != null:
return tastefix(_that);case BagpickCard() when bagpick != null:
return bagpick(_that);case FlavorCard() when flavor != null:
return flavor(_that);case QuizCard() when quiz != null:
return quiz(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PredictCard value)  predict,required TResult Function( ConceptCard value)  concept,required TResult Function( VisualCard value)  visual,required TResult Function( PracticalCard value)  practical,required TResult Function( McqCard value)  mcq,required TResult Function( MultiCard value)  multi,required TResult Function( RecallCard value)  recall,required TResult Function( DecisionCard value)  decision,required TResult Function( MatchCard value)  match,required TResult Function( SequenceCard value)  sequence,required TResult Function( SliderCard value)  slider,required TResult Function( TastefixCard value)  tastefix,required TResult Function( BagpickCard value)  bagpick,required TResult Function( FlavorCard value)  flavor,required TResult Function( QuizCard value)  quiz,}){
final _that = this;
switch (_that) {
case PredictCard():
return predict(_that);case ConceptCard():
return concept(_that);case VisualCard():
return visual(_that);case PracticalCard():
return practical(_that);case McqCard():
return mcq(_that);case MultiCard():
return multi(_that);case RecallCard():
return recall(_that);case DecisionCard():
return decision(_that);case MatchCard():
return match(_that);case SequenceCard():
return sequence(_that);case SliderCard():
return slider(_that);case TastefixCard():
return tastefix(_that);case BagpickCard():
return bagpick(_that);case FlavorCard():
return flavor(_that);case QuizCard():
return quiz(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PredictCard value)?  predict,TResult? Function( ConceptCard value)?  concept,TResult? Function( VisualCard value)?  visual,TResult? Function( PracticalCard value)?  practical,TResult? Function( McqCard value)?  mcq,TResult? Function( MultiCard value)?  multi,TResult? Function( RecallCard value)?  recall,TResult? Function( DecisionCard value)?  decision,TResult? Function( MatchCard value)?  match,TResult? Function( SequenceCard value)?  sequence,TResult? Function( SliderCard value)?  slider,TResult? Function( TastefixCard value)?  tastefix,TResult? Function( BagpickCard value)?  bagpick,TResult? Function( FlavorCard value)?  flavor,TResult? Function( QuizCard value)?  quiz,}){
final _that = this;
switch (_that) {
case PredictCard() when predict != null:
return predict(_that);case ConceptCard() when concept != null:
return concept(_that);case VisualCard() when visual != null:
return visual(_that);case PracticalCard() when practical != null:
return practical(_that);case McqCard() when mcq != null:
return mcq(_that);case MultiCard() when multi != null:
return multi(_that);case RecallCard() when recall != null:
return recall(_that);case DecisionCard() when decision != null:
return decision(_that);case MatchCard() when match != null:
return match(_that);case SequenceCard() when sequence != null:
return sequence(_that);case SliderCard() when slider != null:
return slider(_that);case TastefixCard() when tastefix != null:
return tastefix(_that);case BagpickCard() when bagpick != null:
return bagpick(_that);case FlavorCard() when flavor != null:
return flavor(_that);case QuizCard() when quiz != null:
return quiz(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String label,  String title,  String body,  String question,  List<String> options, @JsonKey(name: 'a')  String answer,  String hold)?  predict,TResult Function( String label,  String title, @ConceptFillConverter()  List<ConceptFillPart> fill,  List<String> paragraphs,  List<List<String>> meta)?  concept,TResult Function( String label,  String title, @JsonKey(name: 'visualGuide')  String subject,  String caption,  bool? mergeHeader,  bool? captionTop)?  visual,TResult Function( String tag,  String title,  List<String> paragraphs,  String note)?  practical,TResult Function( String prompt,  List<Choice> choices, @JsonKey(name: 'explain')  String explanation)?  mcq,TResult Function( String prompt,  List<Choice> choices, @JsonKey(name: 'explain')  String explanation)?  multi,TResult Function( String label,  String question,  List<Choice> choices, @JsonKey(name: 'explain')  String explanation, @JsonKey(name: 'line')  String takeaway)?  recall,TResult Function( String label,  String title,  String scenario,  String question,  List<DecisionOption> options, @JsonKey(name: 'right')  String rightExplanation, @JsonKey(name: 'wrong')  String wrongExplanation,  String? note)?  decision,TResult Function( String prompt,  List<MatchPair> pairs)?  match,TResult Function( String prompt,  List<SequenceItem> items)?  sequence,TResult Function( String prompt,  String leftLabel,  String rightLabel,  double target,  double tolerance,  List<String> scale,  String feedback)?  slider,TResult Function( List<String> tags,  String prompt,  String scenario,  List<Choice> choices, @JsonKey(name: 'explain')  String explanation)?  tastefix,TResult Function( String bag,  String origin,  String prompt,  BagpickBean bean,  List<String> options,  String answer,  String tell,  List<BagpickCue> cues, @JsonKey(name: 'explain')  String explanation)?  bagpick,TResult Function( String clue,  String prompt,  List<Choice> choices,  int answer, @JsonKey(name: 'explain')  String explanation)?  flavor,TResult Function( String statement,  bool answer, @JsonKey(name: 'explain')  String explanation)?  quiz,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PredictCard() when predict != null:
return predict(_that.label,_that.title,_that.body,_that.question,_that.options,_that.answer,_that.hold);case ConceptCard() when concept != null:
return concept(_that.label,_that.title,_that.fill,_that.paragraphs,_that.meta);case VisualCard() when visual != null:
return visual(_that.label,_that.title,_that.subject,_that.caption,_that.mergeHeader,_that.captionTop);case PracticalCard() when practical != null:
return practical(_that.tag,_that.title,_that.paragraphs,_that.note);case McqCard() when mcq != null:
return mcq(_that.prompt,_that.choices,_that.explanation);case MultiCard() when multi != null:
return multi(_that.prompt,_that.choices,_that.explanation);case RecallCard() when recall != null:
return recall(_that.label,_that.question,_that.choices,_that.explanation,_that.takeaway);case DecisionCard() when decision != null:
return decision(_that.label,_that.title,_that.scenario,_that.question,_that.options,_that.rightExplanation,_that.wrongExplanation,_that.note);case MatchCard() when match != null:
return match(_that.prompt,_that.pairs);case SequenceCard() when sequence != null:
return sequence(_that.prompt,_that.items);case SliderCard() when slider != null:
return slider(_that.prompt,_that.leftLabel,_that.rightLabel,_that.target,_that.tolerance,_that.scale,_that.feedback);case TastefixCard() when tastefix != null:
return tastefix(_that.tags,_that.prompt,_that.scenario,_that.choices,_that.explanation);case BagpickCard() when bagpick != null:
return bagpick(_that.bag,_that.origin,_that.prompt,_that.bean,_that.options,_that.answer,_that.tell,_that.cues,_that.explanation);case FlavorCard() when flavor != null:
return flavor(_that.clue,_that.prompt,_that.choices,_that.answer,_that.explanation);case QuizCard() when quiz != null:
return quiz(_that.statement,_that.answer,_that.explanation);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String label,  String title,  String body,  String question,  List<String> options, @JsonKey(name: 'a')  String answer,  String hold)  predict,required TResult Function( String label,  String title, @ConceptFillConverter()  List<ConceptFillPart> fill,  List<String> paragraphs,  List<List<String>> meta)  concept,required TResult Function( String label,  String title, @JsonKey(name: 'visualGuide')  String subject,  String caption,  bool? mergeHeader,  bool? captionTop)  visual,required TResult Function( String tag,  String title,  List<String> paragraphs,  String note)  practical,required TResult Function( String prompt,  List<Choice> choices, @JsonKey(name: 'explain')  String explanation)  mcq,required TResult Function( String prompt,  List<Choice> choices, @JsonKey(name: 'explain')  String explanation)  multi,required TResult Function( String label,  String question,  List<Choice> choices, @JsonKey(name: 'explain')  String explanation, @JsonKey(name: 'line')  String takeaway)  recall,required TResult Function( String label,  String title,  String scenario,  String question,  List<DecisionOption> options, @JsonKey(name: 'right')  String rightExplanation, @JsonKey(name: 'wrong')  String wrongExplanation,  String? note)  decision,required TResult Function( String prompt,  List<MatchPair> pairs)  match,required TResult Function( String prompt,  List<SequenceItem> items)  sequence,required TResult Function( String prompt,  String leftLabel,  String rightLabel,  double target,  double tolerance,  List<String> scale,  String feedback)  slider,required TResult Function( List<String> tags,  String prompt,  String scenario,  List<Choice> choices, @JsonKey(name: 'explain')  String explanation)  tastefix,required TResult Function( String bag,  String origin,  String prompt,  BagpickBean bean,  List<String> options,  String answer,  String tell,  List<BagpickCue> cues, @JsonKey(name: 'explain')  String explanation)  bagpick,required TResult Function( String clue,  String prompt,  List<Choice> choices,  int answer, @JsonKey(name: 'explain')  String explanation)  flavor,required TResult Function( String statement,  bool answer, @JsonKey(name: 'explain')  String explanation)  quiz,}) {final _that = this;
switch (_that) {
case PredictCard():
return predict(_that.label,_that.title,_that.body,_that.question,_that.options,_that.answer,_that.hold);case ConceptCard():
return concept(_that.label,_that.title,_that.fill,_that.paragraphs,_that.meta);case VisualCard():
return visual(_that.label,_that.title,_that.subject,_that.caption,_that.mergeHeader,_that.captionTop);case PracticalCard():
return practical(_that.tag,_that.title,_that.paragraphs,_that.note);case McqCard():
return mcq(_that.prompt,_that.choices,_that.explanation);case MultiCard():
return multi(_that.prompt,_that.choices,_that.explanation);case RecallCard():
return recall(_that.label,_that.question,_that.choices,_that.explanation,_that.takeaway);case DecisionCard():
return decision(_that.label,_that.title,_that.scenario,_that.question,_that.options,_that.rightExplanation,_that.wrongExplanation,_that.note);case MatchCard():
return match(_that.prompt,_that.pairs);case SequenceCard():
return sequence(_that.prompt,_that.items);case SliderCard():
return slider(_that.prompt,_that.leftLabel,_that.rightLabel,_that.target,_that.tolerance,_that.scale,_that.feedback);case TastefixCard():
return tastefix(_that.tags,_that.prompt,_that.scenario,_that.choices,_that.explanation);case BagpickCard():
return bagpick(_that.bag,_that.origin,_that.prompt,_that.bean,_that.options,_that.answer,_that.tell,_that.cues,_that.explanation);case FlavorCard():
return flavor(_that.clue,_that.prompt,_that.choices,_that.answer,_that.explanation);case QuizCard():
return quiz(_that.statement,_that.answer,_that.explanation);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String label,  String title,  String body,  String question,  List<String> options, @JsonKey(name: 'a')  String answer,  String hold)?  predict,TResult? Function( String label,  String title, @ConceptFillConverter()  List<ConceptFillPart> fill,  List<String> paragraphs,  List<List<String>> meta)?  concept,TResult? Function( String label,  String title, @JsonKey(name: 'visualGuide')  String subject,  String caption,  bool? mergeHeader,  bool? captionTop)?  visual,TResult? Function( String tag,  String title,  List<String> paragraphs,  String note)?  practical,TResult? Function( String prompt,  List<Choice> choices, @JsonKey(name: 'explain')  String explanation)?  mcq,TResult? Function( String prompt,  List<Choice> choices, @JsonKey(name: 'explain')  String explanation)?  multi,TResult? Function( String label,  String question,  List<Choice> choices, @JsonKey(name: 'explain')  String explanation, @JsonKey(name: 'line')  String takeaway)?  recall,TResult? Function( String label,  String title,  String scenario,  String question,  List<DecisionOption> options, @JsonKey(name: 'right')  String rightExplanation, @JsonKey(name: 'wrong')  String wrongExplanation,  String? note)?  decision,TResult? Function( String prompt,  List<MatchPair> pairs)?  match,TResult? Function( String prompt,  List<SequenceItem> items)?  sequence,TResult? Function( String prompt,  String leftLabel,  String rightLabel,  double target,  double tolerance,  List<String> scale,  String feedback)?  slider,TResult? Function( List<String> tags,  String prompt,  String scenario,  List<Choice> choices, @JsonKey(name: 'explain')  String explanation)?  tastefix,TResult? Function( String bag,  String origin,  String prompt,  BagpickBean bean,  List<String> options,  String answer,  String tell,  List<BagpickCue> cues, @JsonKey(name: 'explain')  String explanation)?  bagpick,TResult? Function( String clue,  String prompt,  List<Choice> choices,  int answer, @JsonKey(name: 'explain')  String explanation)?  flavor,TResult? Function( String statement,  bool answer, @JsonKey(name: 'explain')  String explanation)?  quiz,}) {final _that = this;
switch (_that) {
case PredictCard() when predict != null:
return predict(_that.label,_that.title,_that.body,_that.question,_that.options,_that.answer,_that.hold);case ConceptCard() when concept != null:
return concept(_that.label,_that.title,_that.fill,_that.paragraphs,_that.meta);case VisualCard() when visual != null:
return visual(_that.label,_that.title,_that.subject,_that.caption,_that.mergeHeader,_that.captionTop);case PracticalCard() when practical != null:
return practical(_that.tag,_that.title,_that.paragraphs,_that.note);case McqCard() when mcq != null:
return mcq(_that.prompt,_that.choices,_that.explanation);case MultiCard() when multi != null:
return multi(_that.prompt,_that.choices,_that.explanation);case RecallCard() when recall != null:
return recall(_that.label,_that.question,_that.choices,_that.explanation,_that.takeaway);case DecisionCard() when decision != null:
return decision(_that.label,_that.title,_that.scenario,_that.question,_that.options,_that.rightExplanation,_that.wrongExplanation,_that.note);case MatchCard() when match != null:
return match(_that.prompt,_that.pairs);case SequenceCard() when sequence != null:
return sequence(_that.prompt,_that.items);case SliderCard() when slider != null:
return slider(_that.prompt,_that.leftLabel,_that.rightLabel,_that.target,_that.tolerance,_that.scale,_that.feedback);case TastefixCard() when tastefix != null:
return tastefix(_that.tags,_that.prompt,_that.scenario,_that.choices,_that.explanation);case BagpickCard() when bagpick != null:
return bagpick(_that.bag,_that.origin,_that.prompt,_that.bean,_that.options,_that.answer,_that.tell,_that.cues,_that.explanation);case FlavorCard() when flavor != null:
return flavor(_that.clue,_that.prompt,_that.choices,_that.answer,_that.explanation);case QuizCard() when quiz != null:
return quiz(_that.statement,_that.answer,_that.explanation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class PredictCard implements ContentCard {
  const PredictCard({required this.label, required this.title, required this.body, required this.question, required final  List<String> options, @JsonKey(name: 'a') required this.answer, required this.hold, final  String? $type}): _options = options,$type = $type ?? 'predict';
  factory PredictCard.fromJson(Map<String, dynamic> json) => _$PredictCardFromJson(json);

 final  String label;
 final  String title;
 final  String body;
 final  String question;
 final  List<String> _options;
 List<String> get options {
  if (_options is EqualUnmodifiableListView) return _options;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_options);
}

@JsonKey(name: 'a') final  String answer;
 final  String hold;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of ContentCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PredictCardCopyWith<PredictCard> get copyWith => _$PredictCardCopyWithImpl<PredictCard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PredictCardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PredictCard&&(identical(other.label, label) || other.label == label)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.question, question) || other.question == question)&&const DeepCollectionEquality().equals(other._options, _options)&&(identical(other.answer, answer) || other.answer == answer)&&(identical(other.hold, hold) || other.hold == hold));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,title,body,question,const DeepCollectionEquality().hash(_options),answer,hold);

@override
String toString() {
  return 'ContentCard.predict(label: $label, title: $title, body: $body, question: $question, options: $options, answer: $answer, hold: $hold)';
}


}

/// @nodoc
abstract mixin class $PredictCardCopyWith<$Res> implements $ContentCardCopyWith<$Res> {
  factory $PredictCardCopyWith(PredictCard value, $Res Function(PredictCard) _then) = _$PredictCardCopyWithImpl;
@useResult
$Res call({
 String label, String title, String body, String question, List<String> options,@JsonKey(name: 'a') String answer, String hold
});




}
/// @nodoc
class _$PredictCardCopyWithImpl<$Res>
    implements $PredictCardCopyWith<$Res> {
  _$PredictCardCopyWithImpl(this._self, this._then);

  final PredictCard _self;
  final $Res Function(PredictCard) _then;

/// Create a copy of ContentCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? label = null,Object? title = null,Object? body = null,Object? question = null,Object? options = null,Object? answer = null,Object? hold = null,}) {
  return _then(PredictCard(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,options: null == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as List<String>,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,hold: null == hold ? _self.hold : hold // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class ConceptCard implements ContentCard {
  const ConceptCard({required this.label, required this.title, @ConceptFillConverter() required final  List<ConceptFillPart> fill, required final  List<String> paragraphs, required final  List<List<String>> meta, final  String? $type}): _fill = fill,_paragraphs = paragraphs,_meta = meta,$type = $type ?? 'concept';
  factory ConceptCard.fromJson(Map<String, dynamic> json) => _$ConceptCardFromJson(json);

 final  String label;
 final  String title;
 final  List<ConceptFillPart> _fill;
@ConceptFillConverter() List<ConceptFillPart> get fill {
  if (_fill is EqualUnmodifiableListView) return _fill;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fill);
}

 final  List<String> _paragraphs;
 List<String> get paragraphs {
  if (_paragraphs is EqualUnmodifiableListView) return _paragraphs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_paragraphs);
}

 final  List<List<String>> _meta;
 List<List<String>> get meta {
  if (_meta is EqualUnmodifiableListView) return _meta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_meta);
}


@JsonKey(name: 'kind')
final String $type;


/// Create a copy of ContentCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConceptCardCopyWith<ConceptCard> get copyWith => _$ConceptCardCopyWithImpl<ConceptCard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConceptCardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConceptCard&&(identical(other.label, label) || other.label == label)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._fill, _fill)&&const DeepCollectionEquality().equals(other._paragraphs, _paragraphs)&&const DeepCollectionEquality().equals(other._meta, _meta));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,title,const DeepCollectionEquality().hash(_fill),const DeepCollectionEquality().hash(_paragraphs),const DeepCollectionEquality().hash(_meta));

@override
String toString() {
  return 'ContentCard.concept(label: $label, title: $title, fill: $fill, paragraphs: $paragraphs, meta: $meta)';
}


}

/// @nodoc
abstract mixin class $ConceptCardCopyWith<$Res> implements $ContentCardCopyWith<$Res> {
  factory $ConceptCardCopyWith(ConceptCard value, $Res Function(ConceptCard) _then) = _$ConceptCardCopyWithImpl;
@useResult
$Res call({
 String label, String title,@ConceptFillConverter() List<ConceptFillPart> fill, List<String> paragraphs, List<List<String>> meta
});




}
/// @nodoc
class _$ConceptCardCopyWithImpl<$Res>
    implements $ConceptCardCopyWith<$Res> {
  _$ConceptCardCopyWithImpl(this._self, this._then);

  final ConceptCard _self;
  final $Res Function(ConceptCard) _then;

/// Create a copy of ContentCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? label = null,Object? title = null,Object? fill = null,Object? paragraphs = null,Object? meta = null,}) {
  return _then(ConceptCard(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,fill: null == fill ? _self._fill : fill // ignore: cast_nullable_to_non_nullable
as List<ConceptFillPart>,paragraphs: null == paragraphs ? _self._paragraphs : paragraphs // ignore: cast_nullable_to_non_nullable
as List<String>,meta: null == meta ? _self._meta : meta // ignore: cast_nullable_to_non_nullable
as List<List<String>>,
  ));
}


}

/// @nodoc
@JsonSerializable()

class VisualCard implements ContentCard {
  const VisualCard({required this.label, required this.title, @JsonKey(name: 'visualGuide') required this.subject, required this.caption, this.mergeHeader, this.captionTop, final  String? $type}): $type = $type ?? 'visual';
  factory VisualCard.fromJson(Map<String, dynamic> json) => _$VisualCardFromJson(json);

 final  String label;
 final  String title;
/// The axis this guide names — `roast`, `grind`, `variety` — and the value
/// its `g:` save key carries.
///
/// The bank calls it `visualGuide`; the glossary calls the concept a
/// **subject**, and reserves *variant* for a mini-game format. Mapped here
/// the way `glyph` → `iconName` is, so neither name has to bend.
@JsonKey(name: 'visualGuide') final  String subject;
 final  String caption;
 final  bool? mergeHeader;
 final  bool? captionTop;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of ContentCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VisualCardCopyWith<VisualCard> get copyWith => _$VisualCardCopyWithImpl<VisualCard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VisualCardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VisualCard&&(identical(other.label, label) || other.label == label)&&(identical(other.title, title) || other.title == title)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.mergeHeader, mergeHeader) || other.mergeHeader == mergeHeader)&&(identical(other.captionTop, captionTop) || other.captionTop == captionTop));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,title,subject,caption,mergeHeader,captionTop);

@override
String toString() {
  return 'ContentCard.visual(label: $label, title: $title, subject: $subject, caption: $caption, mergeHeader: $mergeHeader, captionTop: $captionTop)';
}


}

/// @nodoc
abstract mixin class $VisualCardCopyWith<$Res> implements $ContentCardCopyWith<$Res> {
  factory $VisualCardCopyWith(VisualCard value, $Res Function(VisualCard) _then) = _$VisualCardCopyWithImpl;
@useResult
$Res call({
 String label, String title,@JsonKey(name: 'visualGuide') String subject, String caption, bool? mergeHeader, bool? captionTop
});




}
/// @nodoc
class _$VisualCardCopyWithImpl<$Res>
    implements $VisualCardCopyWith<$Res> {
  _$VisualCardCopyWithImpl(this._self, this._then);

  final VisualCard _self;
  final $Res Function(VisualCard) _then;

/// Create a copy of ContentCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? label = null,Object? title = null,Object? subject = null,Object? caption = null,Object? mergeHeader = freezed,Object? captionTop = freezed,}) {
  return _then(VisualCard(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,caption: null == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String,mergeHeader: freezed == mergeHeader ? _self.mergeHeader : mergeHeader // ignore: cast_nullable_to_non_nullable
as bool?,captionTop: freezed == captionTop ? _self.captionTop : captionTop // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

/// @nodoc
@JsonSerializable()

class PracticalCard implements ContentCard {
  const PracticalCard({required this.tag, required this.title, required final  List<String> paragraphs, required this.note, final  String? $type}): _paragraphs = paragraphs,$type = $type ?? 'practical';
  factory PracticalCard.fromJson(Map<String, dynamic> json) => _$PracticalCardFromJson(json);

 final  String tag;
 final  String title;
 final  List<String> _paragraphs;
 List<String> get paragraphs {
  if (_paragraphs is EqualUnmodifiableListView) return _paragraphs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_paragraphs);
}

 final  String note;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of ContentCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PracticalCardCopyWith<PracticalCard> get copyWith => _$PracticalCardCopyWithImpl<PracticalCard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PracticalCardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PracticalCard&&(identical(other.tag, tag) || other.tag == tag)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._paragraphs, _paragraphs)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tag,title,const DeepCollectionEquality().hash(_paragraphs),note);

@override
String toString() {
  return 'ContentCard.practical(tag: $tag, title: $title, paragraphs: $paragraphs, note: $note)';
}


}

/// @nodoc
abstract mixin class $PracticalCardCopyWith<$Res> implements $ContentCardCopyWith<$Res> {
  factory $PracticalCardCopyWith(PracticalCard value, $Res Function(PracticalCard) _then) = _$PracticalCardCopyWithImpl;
@useResult
$Res call({
 String tag, String title, List<String> paragraphs, String note
});




}
/// @nodoc
class _$PracticalCardCopyWithImpl<$Res>
    implements $PracticalCardCopyWith<$Res> {
  _$PracticalCardCopyWithImpl(this._self, this._then);

  final PracticalCard _self;
  final $Res Function(PracticalCard) _then;

/// Create a copy of ContentCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? tag = null,Object? title = null,Object? paragraphs = null,Object? note = null,}) {
  return _then(PracticalCard(
tag: null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,paragraphs: null == paragraphs ? _self._paragraphs : paragraphs // ignore: cast_nullable_to_non_nullable
as List<String>,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class McqCard implements ContentCard, Gradable {
  const McqCard({required this.prompt, required final  List<Choice> choices, @JsonKey(name: 'explain') required this.explanation, final  String? $type}): _choices = choices,$type = $type ?? 'mcq';
  factory McqCard.fromJson(Map<String, dynamic> json) => _$McqCardFromJson(json);

 final  String prompt;
 final  List<Choice> _choices;
 List<Choice> get choices {
  if (_choices is EqualUnmodifiableListView) return _choices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_choices);
}

@JsonKey(name: 'explain') final  String explanation;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of ContentCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$McqCardCopyWith<McqCard> get copyWith => _$McqCardCopyWithImpl<McqCard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$McqCardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is McqCard&&(identical(other.prompt, prompt) || other.prompt == prompt)&&const DeepCollectionEquality().equals(other._choices, _choices)&&(identical(other.explanation, explanation) || other.explanation == explanation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,prompt,const DeepCollectionEquality().hash(_choices),explanation);

@override
String toString() {
  return 'ContentCard.mcq(prompt: $prompt, choices: $choices, explanation: $explanation)';
}


}

/// @nodoc
abstract mixin class $McqCardCopyWith<$Res> implements $ContentCardCopyWith<$Res> {
  factory $McqCardCopyWith(McqCard value, $Res Function(McqCard) _then) = _$McqCardCopyWithImpl;
@useResult
$Res call({
 String prompt, List<Choice> choices,@JsonKey(name: 'explain') String explanation
});




}
/// @nodoc
class _$McqCardCopyWithImpl<$Res>
    implements $McqCardCopyWith<$Res> {
  _$McqCardCopyWithImpl(this._self, this._then);

  final McqCard _self;
  final $Res Function(McqCard) _then;

/// Create a copy of ContentCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? prompt = null,Object? choices = null,Object? explanation = null,}) {
  return _then(McqCard(
prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String,choices: null == choices ? _self._choices : choices // ignore: cast_nullable_to_non_nullable
as List<Choice>,explanation: null == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class MultiCard implements ContentCard, Gradable {
  const MultiCard({required this.prompt, required final  List<Choice> choices, @JsonKey(name: 'explain') required this.explanation, final  String? $type}): _choices = choices,$type = $type ?? 'multi';
  factory MultiCard.fromJson(Map<String, dynamic> json) => _$MultiCardFromJson(json);

 final  String prompt;
 final  List<Choice> _choices;
 List<Choice> get choices {
  if (_choices is EqualUnmodifiableListView) return _choices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_choices);
}

@JsonKey(name: 'explain') final  String explanation;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of ContentCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MultiCardCopyWith<MultiCard> get copyWith => _$MultiCardCopyWithImpl<MultiCard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MultiCardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MultiCard&&(identical(other.prompt, prompt) || other.prompt == prompt)&&const DeepCollectionEquality().equals(other._choices, _choices)&&(identical(other.explanation, explanation) || other.explanation == explanation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,prompt,const DeepCollectionEquality().hash(_choices),explanation);

@override
String toString() {
  return 'ContentCard.multi(prompt: $prompt, choices: $choices, explanation: $explanation)';
}


}

/// @nodoc
abstract mixin class $MultiCardCopyWith<$Res> implements $ContentCardCopyWith<$Res> {
  factory $MultiCardCopyWith(MultiCard value, $Res Function(MultiCard) _then) = _$MultiCardCopyWithImpl;
@useResult
$Res call({
 String prompt, List<Choice> choices,@JsonKey(name: 'explain') String explanation
});




}
/// @nodoc
class _$MultiCardCopyWithImpl<$Res>
    implements $MultiCardCopyWith<$Res> {
  _$MultiCardCopyWithImpl(this._self, this._then);

  final MultiCard _self;
  final $Res Function(MultiCard) _then;

/// Create a copy of ContentCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? prompt = null,Object? choices = null,Object? explanation = null,}) {
  return _then(MultiCard(
prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String,choices: null == choices ? _self._choices : choices // ignore: cast_nullable_to_non_nullable
as List<Choice>,explanation: null == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class RecallCard implements ContentCard, Gradable {
  const RecallCard({required this.label, required this.question, required final  List<Choice> choices, @JsonKey(name: 'explain') required this.explanation, @JsonKey(name: 'line') required this.takeaway, final  String? $type}): _choices = choices,$type = $type ?? 'recall';
  factory RecallCard.fromJson(Map<String, dynamic> json) => _$RecallCardFromJson(json);

 final  String label;
 final  String question;
 final  List<Choice> _choices;
 List<Choice> get choices {
  if (_choices is EqualUnmodifiableListView) return _choices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_choices);
}

@JsonKey(name: 'explain') final  String explanation;
@JsonKey(name: 'line') final  String takeaway;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of ContentCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecallCardCopyWith<RecallCard> get copyWith => _$RecallCardCopyWithImpl<RecallCard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecallCardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecallCard&&(identical(other.label, label) || other.label == label)&&(identical(other.question, question) || other.question == question)&&const DeepCollectionEquality().equals(other._choices, _choices)&&(identical(other.explanation, explanation) || other.explanation == explanation)&&(identical(other.takeaway, takeaway) || other.takeaway == takeaway));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,question,const DeepCollectionEquality().hash(_choices),explanation,takeaway);

@override
String toString() {
  return 'ContentCard.recall(label: $label, question: $question, choices: $choices, explanation: $explanation, takeaway: $takeaway)';
}


}

/// @nodoc
abstract mixin class $RecallCardCopyWith<$Res> implements $ContentCardCopyWith<$Res> {
  factory $RecallCardCopyWith(RecallCard value, $Res Function(RecallCard) _then) = _$RecallCardCopyWithImpl;
@useResult
$Res call({
 String label, String question, List<Choice> choices,@JsonKey(name: 'explain') String explanation,@JsonKey(name: 'line') String takeaway
});




}
/// @nodoc
class _$RecallCardCopyWithImpl<$Res>
    implements $RecallCardCopyWith<$Res> {
  _$RecallCardCopyWithImpl(this._self, this._then);

  final RecallCard _self;
  final $Res Function(RecallCard) _then;

/// Create a copy of ContentCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? label = null,Object? question = null,Object? choices = null,Object? explanation = null,Object? takeaway = null,}) {
  return _then(RecallCard(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,choices: null == choices ? _self._choices : choices // ignore: cast_nullable_to_non_nullable
as List<Choice>,explanation: null == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as String,takeaway: null == takeaway ? _self.takeaway : takeaway // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class DecisionCard implements ContentCard, Gradable {
  const DecisionCard({required this.label, required this.title, required this.scenario, required this.question, required final  List<DecisionOption> options, @JsonKey(name: 'right') required this.rightExplanation, @JsonKey(name: 'wrong') required this.wrongExplanation, this.note, final  String? $type}): _options = options,$type = $type ?? 'decision';
  factory DecisionCard.fromJson(Map<String, dynamic> json) => _$DecisionCardFromJson(json);

 final  String label;
 final  String title;
 final  String scenario;
 final  String question;
 final  List<DecisionOption> _options;
 List<DecisionOption> get options {
  if (_options is EqualUnmodifiableListView) return _options;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_options);
}

@JsonKey(name: 'right') final  String rightExplanation;
@JsonKey(name: 'wrong') final  String wrongExplanation;
 final  String? note;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of ContentCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DecisionCardCopyWith<DecisionCard> get copyWith => _$DecisionCardCopyWithImpl<DecisionCard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DecisionCardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DecisionCard&&(identical(other.label, label) || other.label == label)&&(identical(other.title, title) || other.title == title)&&(identical(other.scenario, scenario) || other.scenario == scenario)&&(identical(other.question, question) || other.question == question)&&const DeepCollectionEquality().equals(other._options, _options)&&(identical(other.rightExplanation, rightExplanation) || other.rightExplanation == rightExplanation)&&(identical(other.wrongExplanation, wrongExplanation) || other.wrongExplanation == wrongExplanation)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,title,scenario,question,const DeepCollectionEquality().hash(_options),rightExplanation,wrongExplanation,note);

@override
String toString() {
  return 'ContentCard.decision(label: $label, title: $title, scenario: $scenario, question: $question, options: $options, rightExplanation: $rightExplanation, wrongExplanation: $wrongExplanation, note: $note)';
}


}

/// @nodoc
abstract mixin class $DecisionCardCopyWith<$Res> implements $ContentCardCopyWith<$Res> {
  factory $DecisionCardCopyWith(DecisionCard value, $Res Function(DecisionCard) _then) = _$DecisionCardCopyWithImpl;
@useResult
$Res call({
 String label, String title, String scenario, String question, List<DecisionOption> options,@JsonKey(name: 'right') String rightExplanation,@JsonKey(name: 'wrong') String wrongExplanation, String? note
});




}
/// @nodoc
class _$DecisionCardCopyWithImpl<$Res>
    implements $DecisionCardCopyWith<$Res> {
  _$DecisionCardCopyWithImpl(this._self, this._then);

  final DecisionCard _self;
  final $Res Function(DecisionCard) _then;

/// Create a copy of ContentCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? label = null,Object? title = null,Object? scenario = null,Object? question = null,Object? options = null,Object? rightExplanation = null,Object? wrongExplanation = null,Object? note = freezed,}) {
  return _then(DecisionCard(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,scenario: null == scenario ? _self.scenario : scenario // ignore: cast_nullable_to_non_nullable
as String,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,options: null == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as List<DecisionOption>,rightExplanation: null == rightExplanation ? _self.rightExplanation : rightExplanation // ignore: cast_nullable_to_non_nullable
as String,wrongExplanation: null == wrongExplanation ? _self.wrongExplanation : wrongExplanation // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
@JsonSerializable()

class MatchCard implements ContentCard, Gradable {
  const MatchCard({required this.prompt, required final  List<MatchPair> pairs, final  String? $type}): _pairs = pairs,$type = $type ?? 'match';
  factory MatchCard.fromJson(Map<String, dynamic> json) => _$MatchCardFromJson(json);

 final  String prompt;
 final  List<MatchPair> _pairs;
 List<MatchPair> get pairs {
  if (_pairs is EqualUnmodifiableListView) return _pairs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pairs);
}


@JsonKey(name: 'kind')
final String $type;


/// Create a copy of ContentCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MatchCardCopyWith<MatchCard> get copyWith => _$MatchCardCopyWithImpl<MatchCard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MatchCardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MatchCard&&(identical(other.prompt, prompt) || other.prompt == prompt)&&const DeepCollectionEquality().equals(other._pairs, _pairs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,prompt,const DeepCollectionEquality().hash(_pairs));

@override
String toString() {
  return 'ContentCard.match(prompt: $prompt, pairs: $pairs)';
}


}

/// @nodoc
abstract mixin class $MatchCardCopyWith<$Res> implements $ContentCardCopyWith<$Res> {
  factory $MatchCardCopyWith(MatchCard value, $Res Function(MatchCard) _then) = _$MatchCardCopyWithImpl;
@useResult
$Res call({
 String prompt, List<MatchPair> pairs
});




}
/// @nodoc
class _$MatchCardCopyWithImpl<$Res>
    implements $MatchCardCopyWith<$Res> {
  _$MatchCardCopyWithImpl(this._self, this._then);

  final MatchCard _self;
  final $Res Function(MatchCard) _then;

/// Create a copy of ContentCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? prompt = null,Object? pairs = null,}) {
  return _then(MatchCard(
prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String,pairs: null == pairs ? _self._pairs : pairs // ignore: cast_nullable_to_non_nullable
as List<MatchPair>,
  ));
}


}

/// @nodoc
@JsonSerializable()

class SequenceCard implements ContentCard, Gradable {
  const SequenceCard({required this.prompt, required final  List<SequenceItem> items, final  String? $type}): _items = items,$type = $type ?? 'sequence';
  factory SequenceCard.fromJson(Map<String, dynamic> json) => _$SequenceCardFromJson(json);

 final  String prompt;
 final  List<SequenceItem> _items;
 List<SequenceItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


@JsonKey(name: 'kind')
final String $type;


/// Create a copy of ContentCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SequenceCardCopyWith<SequenceCard> get copyWith => _$SequenceCardCopyWithImpl<SequenceCard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SequenceCardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SequenceCard&&(identical(other.prompt, prompt) || other.prompt == prompt)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,prompt,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'ContentCard.sequence(prompt: $prompt, items: $items)';
}


}

/// @nodoc
abstract mixin class $SequenceCardCopyWith<$Res> implements $ContentCardCopyWith<$Res> {
  factory $SequenceCardCopyWith(SequenceCard value, $Res Function(SequenceCard) _then) = _$SequenceCardCopyWithImpl;
@useResult
$Res call({
 String prompt, List<SequenceItem> items
});




}
/// @nodoc
class _$SequenceCardCopyWithImpl<$Res>
    implements $SequenceCardCopyWith<$Res> {
  _$SequenceCardCopyWithImpl(this._self, this._then);

  final SequenceCard _self;
  final $Res Function(SequenceCard) _then;

/// Create a copy of ContentCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? prompt = null,Object? items = null,}) {
  return _then(SequenceCard(
prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<SequenceItem>,
  ));
}


}

/// @nodoc
@JsonSerializable()

class SliderCard implements ContentCard, Gradable {
  const SliderCard({required this.prompt, required this.leftLabel, required this.rightLabel, required this.target, required this.tolerance, required final  List<String> scale, required this.feedback, final  String? $type}): _scale = scale,$type = $type ?? 'slider';
  factory SliderCard.fromJson(Map<String, dynamic> json) => _$SliderCardFromJson(json);

 final  String prompt;
 final  String leftLabel;
 final  String rightLabel;
 final  double target;
 final  double tolerance;
 final  List<String> _scale;
 List<String> get scale {
  if (_scale is EqualUnmodifiableListView) return _scale;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_scale);
}

 final  String feedback;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of ContentCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SliderCardCopyWith<SliderCard> get copyWith => _$SliderCardCopyWithImpl<SliderCard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SliderCardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SliderCard&&(identical(other.prompt, prompt) || other.prompt == prompt)&&(identical(other.leftLabel, leftLabel) || other.leftLabel == leftLabel)&&(identical(other.rightLabel, rightLabel) || other.rightLabel == rightLabel)&&(identical(other.target, target) || other.target == target)&&(identical(other.tolerance, tolerance) || other.tolerance == tolerance)&&const DeepCollectionEquality().equals(other._scale, _scale)&&(identical(other.feedback, feedback) || other.feedback == feedback));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,prompt,leftLabel,rightLabel,target,tolerance,const DeepCollectionEquality().hash(_scale),feedback);

@override
String toString() {
  return 'ContentCard.slider(prompt: $prompt, leftLabel: $leftLabel, rightLabel: $rightLabel, target: $target, tolerance: $tolerance, scale: $scale, feedback: $feedback)';
}


}

/// @nodoc
abstract mixin class $SliderCardCopyWith<$Res> implements $ContentCardCopyWith<$Res> {
  factory $SliderCardCopyWith(SliderCard value, $Res Function(SliderCard) _then) = _$SliderCardCopyWithImpl;
@useResult
$Res call({
 String prompt, String leftLabel, String rightLabel, double target, double tolerance, List<String> scale, String feedback
});




}
/// @nodoc
class _$SliderCardCopyWithImpl<$Res>
    implements $SliderCardCopyWith<$Res> {
  _$SliderCardCopyWithImpl(this._self, this._then);

  final SliderCard _self;
  final $Res Function(SliderCard) _then;

/// Create a copy of ContentCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? prompt = null,Object? leftLabel = null,Object? rightLabel = null,Object? target = null,Object? tolerance = null,Object? scale = null,Object? feedback = null,}) {
  return _then(SliderCard(
prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String,leftLabel: null == leftLabel ? _self.leftLabel : leftLabel // ignore: cast_nullable_to_non_nullable
as String,rightLabel: null == rightLabel ? _self.rightLabel : rightLabel // ignore: cast_nullable_to_non_nullable
as String,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as double,tolerance: null == tolerance ? _self.tolerance : tolerance // ignore: cast_nullable_to_non_nullable
as double,scale: null == scale ? _self._scale : scale // ignore: cast_nullable_to_non_nullable
as List<String>,feedback: null == feedback ? _self.feedback : feedback // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class TastefixCard implements ContentCard, Gradable {
  const TastefixCard({required final  List<String> tags, required this.prompt, required this.scenario, required final  List<Choice> choices, @JsonKey(name: 'explain') required this.explanation, final  String? $type}): _tags = tags,_choices = choices,$type = $type ?? 'tastefix';
  factory TastefixCard.fromJson(Map<String, dynamic> json) => _$TastefixCardFromJson(json);

 final  List<String> _tags;
 List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

 final  String prompt;
 final  String scenario;
 final  List<Choice> _choices;
 List<Choice> get choices {
  if (_choices is EqualUnmodifiableListView) return _choices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_choices);
}

@JsonKey(name: 'explain') final  String explanation;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of ContentCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TastefixCardCopyWith<TastefixCard> get copyWith => _$TastefixCardCopyWithImpl<TastefixCard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TastefixCardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TastefixCard&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.prompt, prompt) || other.prompt == prompt)&&(identical(other.scenario, scenario) || other.scenario == scenario)&&const DeepCollectionEquality().equals(other._choices, _choices)&&(identical(other.explanation, explanation) || other.explanation == explanation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_tags),prompt,scenario,const DeepCollectionEquality().hash(_choices),explanation);

@override
String toString() {
  return 'ContentCard.tastefix(tags: $tags, prompt: $prompt, scenario: $scenario, choices: $choices, explanation: $explanation)';
}


}

/// @nodoc
abstract mixin class $TastefixCardCopyWith<$Res> implements $ContentCardCopyWith<$Res> {
  factory $TastefixCardCopyWith(TastefixCard value, $Res Function(TastefixCard) _then) = _$TastefixCardCopyWithImpl;
@useResult
$Res call({
 List<String> tags, String prompt, String scenario, List<Choice> choices,@JsonKey(name: 'explain') String explanation
});




}
/// @nodoc
class _$TastefixCardCopyWithImpl<$Res>
    implements $TastefixCardCopyWith<$Res> {
  _$TastefixCardCopyWithImpl(this._self, this._then);

  final TastefixCard _self;
  final $Res Function(TastefixCard) _then;

/// Create a copy of ContentCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? tags = null,Object? prompt = null,Object? scenario = null,Object? choices = null,Object? explanation = null,}) {
  return _then(TastefixCard(
tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String,scenario: null == scenario ? _self.scenario : scenario // ignore: cast_nullable_to_non_nullable
as String,choices: null == choices ? _self._choices : choices // ignore: cast_nullable_to_non_nullable
as List<Choice>,explanation: null == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class BagpickCard implements ContentCard, Gradable {
  const BagpickCard({required this.bag, required this.origin, required this.prompt, required this.bean, required final  List<String> options, required this.answer, required this.tell, required final  List<BagpickCue> cues, @JsonKey(name: 'explain') required this.explanation, final  String? $type}): _options = options,_cues = cues,$type = $type ?? 'bagpick';
  factory BagpickCard.fromJson(Map<String, dynamic> json) => _$BagpickCardFromJson(json);

 final  String bag;
 final  String origin;
 final  String prompt;
 final  BagpickBean bean;
 final  List<String> _options;
 List<String> get options {
  if (_options is EqualUnmodifiableListView) return _options;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_options);
}

 final  String answer;
 final  String tell;
 final  List<BagpickCue> _cues;
 List<BagpickCue> get cues {
  if (_cues is EqualUnmodifiableListView) return _cues;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cues);
}

@JsonKey(name: 'explain') final  String explanation;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of ContentCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BagpickCardCopyWith<BagpickCard> get copyWith => _$BagpickCardCopyWithImpl<BagpickCard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BagpickCardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BagpickCard&&(identical(other.bag, bag) || other.bag == bag)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.prompt, prompt) || other.prompt == prompt)&&(identical(other.bean, bean) || other.bean == bean)&&const DeepCollectionEquality().equals(other._options, _options)&&(identical(other.answer, answer) || other.answer == answer)&&(identical(other.tell, tell) || other.tell == tell)&&const DeepCollectionEquality().equals(other._cues, _cues)&&(identical(other.explanation, explanation) || other.explanation == explanation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bag,origin,prompt,bean,const DeepCollectionEquality().hash(_options),answer,tell,const DeepCollectionEquality().hash(_cues),explanation);

@override
String toString() {
  return 'ContentCard.bagpick(bag: $bag, origin: $origin, prompt: $prompt, bean: $bean, options: $options, answer: $answer, tell: $tell, cues: $cues, explanation: $explanation)';
}


}

/// @nodoc
abstract mixin class $BagpickCardCopyWith<$Res> implements $ContentCardCopyWith<$Res> {
  factory $BagpickCardCopyWith(BagpickCard value, $Res Function(BagpickCard) _then) = _$BagpickCardCopyWithImpl;
@useResult
$Res call({
 String bag, String origin, String prompt, BagpickBean bean, List<String> options, String answer, String tell, List<BagpickCue> cues,@JsonKey(name: 'explain') String explanation
});


$BagpickBeanCopyWith<$Res> get bean;

}
/// @nodoc
class _$BagpickCardCopyWithImpl<$Res>
    implements $BagpickCardCopyWith<$Res> {
  _$BagpickCardCopyWithImpl(this._self, this._then);

  final BagpickCard _self;
  final $Res Function(BagpickCard) _then;

/// Create a copy of ContentCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? bag = null,Object? origin = null,Object? prompt = null,Object? bean = null,Object? options = null,Object? answer = null,Object? tell = null,Object? cues = null,Object? explanation = null,}) {
  return _then(BagpickCard(
bag: null == bag ? _self.bag : bag // ignore: cast_nullable_to_non_nullable
as String,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as String,prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String,bean: null == bean ? _self.bean : bean // ignore: cast_nullable_to_non_nullable
as BagpickBean,options: null == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as List<String>,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,tell: null == tell ? _self.tell : tell // ignore: cast_nullable_to_non_nullable
as String,cues: null == cues ? _self._cues : cues // ignore: cast_nullable_to_non_nullable
as List<BagpickCue>,explanation: null == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of ContentCard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BagpickBeanCopyWith<$Res> get bean {
  
  return $BagpickBeanCopyWith<$Res>(_self.bean, (value) {
    return _then(_self.copyWith(bean: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class FlavorCard implements ContentCard, Gradable {
  const FlavorCard({required this.clue, required this.prompt, required final  List<Choice> choices, required this.answer, @JsonKey(name: 'explain') required this.explanation, final  String? $type}): _choices = choices,$type = $type ?? 'flavor';
  factory FlavorCard.fromJson(Map<String, dynamic> json) => _$FlavorCardFromJson(json);

 final  String clue;
 final  String prompt;
 final  List<Choice> _choices;
 List<Choice> get choices {
  if (_choices is EqualUnmodifiableListView) return _choices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_choices);
}

 final  int answer;
@JsonKey(name: 'explain') final  String explanation;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of ContentCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FlavorCardCopyWith<FlavorCard> get copyWith => _$FlavorCardCopyWithImpl<FlavorCard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FlavorCardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FlavorCard&&(identical(other.clue, clue) || other.clue == clue)&&(identical(other.prompt, prompt) || other.prompt == prompt)&&const DeepCollectionEquality().equals(other._choices, _choices)&&(identical(other.answer, answer) || other.answer == answer)&&(identical(other.explanation, explanation) || other.explanation == explanation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clue,prompt,const DeepCollectionEquality().hash(_choices),answer,explanation);

@override
String toString() {
  return 'ContentCard.flavor(clue: $clue, prompt: $prompt, choices: $choices, answer: $answer, explanation: $explanation)';
}


}

/// @nodoc
abstract mixin class $FlavorCardCopyWith<$Res> implements $ContentCardCopyWith<$Res> {
  factory $FlavorCardCopyWith(FlavorCard value, $Res Function(FlavorCard) _then) = _$FlavorCardCopyWithImpl;
@useResult
$Res call({
 String clue, String prompt, List<Choice> choices, int answer,@JsonKey(name: 'explain') String explanation
});




}
/// @nodoc
class _$FlavorCardCopyWithImpl<$Res>
    implements $FlavorCardCopyWith<$Res> {
  _$FlavorCardCopyWithImpl(this._self, this._then);

  final FlavorCard _self;
  final $Res Function(FlavorCard) _then;

/// Create a copy of ContentCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? clue = null,Object? prompt = null,Object? choices = null,Object? answer = null,Object? explanation = null,}) {
  return _then(FlavorCard(
clue: null == clue ? _self.clue : clue // ignore: cast_nullable_to_non_nullable
as String,prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String,choices: null == choices ? _self._choices : choices // ignore: cast_nullable_to_non_nullable
as List<Choice>,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as int,explanation: null == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class QuizCard implements ContentCard, Gradable {
  const QuizCard({required this.statement, required this.answer, @JsonKey(name: 'explain') required this.explanation, final  String? $type}): $type = $type ?? 'quiz';
  factory QuizCard.fromJson(Map<String, dynamic> json) => _$QuizCardFromJson(json);

 final  String statement;
 final  bool answer;
@JsonKey(name: 'explain') final  String explanation;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of ContentCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuizCardCopyWith<QuizCard> get copyWith => _$QuizCardCopyWithImpl<QuizCard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuizCardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuizCard&&(identical(other.statement, statement) || other.statement == statement)&&(identical(other.answer, answer) || other.answer == answer)&&(identical(other.explanation, explanation) || other.explanation == explanation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,statement,answer,explanation);

@override
String toString() {
  return 'ContentCard.quiz(statement: $statement, answer: $answer, explanation: $explanation)';
}


}

/// @nodoc
abstract mixin class $QuizCardCopyWith<$Res> implements $ContentCardCopyWith<$Res> {
  factory $QuizCardCopyWith(QuizCard value, $Res Function(QuizCard) _then) = _$QuizCardCopyWithImpl;
@useResult
$Res call({
 String statement, bool answer,@JsonKey(name: 'explain') String explanation
});




}
/// @nodoc
class _$QuizCardCopyWithImpl<$Res>
    implements $QuizCardCopyWith<$Res> {
  _$QuizCardCopyWithImpl(this._self, this._then);

  final QuizCard _self;
  final $Res Function(QuizCard) _then;

/// Create a copy of ContentCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? statement = null,Object? answer = null,Object? explanation = null,}) {
  return _then(QuizCard(
statement: null == statement ? _self.statement : statement // ignore: cast_nullable_to_non_nullable
as String,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as bool,explanation: null == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
