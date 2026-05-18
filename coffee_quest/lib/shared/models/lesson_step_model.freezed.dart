// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lesson_step_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
LessonStepModel _$LessonStepModelFromJson(
  Map<String, dynamic> json
) {
        switch (json['type']) {
                  case 'multiple_choice':
          return MultipleChoiceStep.fromJson(
            json
          );
                case 'drag_drop':
          return DragDropStep.fromJson(
            json
          );
                case 'slider':
          return SliderStep.fromJson(
            json
          );
                case 'tap_order':
          return TapOrderStep.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'type',
  'LessonStepModel',
  'Invalid union type "${json['type']}"!'
);
        }
      
}

/// @nodoc
mixin _$LessonStepModel {



  /// Serializes this LessonStepModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LessonStepModel);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LessonStepModel()';
}


}

/// @nodoc
class $LessonStepModelCopyWith<$Res>  {
$LessonStepModelCopyWith(LessonStepModel _, $Res Function(LessonStepModel) __);
}


/// Adds pattern-matching-related methods to [LessonStepModel].
extension LessonStepModelPatterns on LessonStepModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( MultipleChoiceStep value)?  multipleChoice,TResult Function( DragDropStep value)?  dragDrop,TResult Function( SliderStep value)?  slider,TResult Function( TapOrderStep value)?  tapOrder,required TResult orElse(),}){
final _that = this;
switch (_that) {
case MultipleChoiceStep() when multipleChoice != null:
return multipleChoice(_that);case DragDropStep() when dragDrop != null:
return dragDrop(_that);case SliderStep() when slider != null:
return slider(_that);case TapOrderStep() when tapOrder != null:
return tapOrder(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( MultipleChoiceStep value)  multipleChoice,required TResult Function( DragDropStep value)  dragDrop,required TResult Function( SliderStep value)  slider,required TResult Function( TapOrderStep value)  tapOrder,}){
final _that = this;
switch (_that) {
case MultipleChoiceStep():
return multipleChoice(_that);case DragDropStep():
return dragDrop(_that);case SliderStep():
return slider(_that);case TapOrderStep():
return tapOrder(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( MultipleChoiceStep value)?  multipleChoice,TResult? Function( DragDropStep value)?  dragDrop,TResult? Function( SliderStep value)?  slider,TResult? Function( TapOrderStep value)?  tapOrder,}){
final _that = this;
switch (_that) {
case MultipleChoiceStep() when multipleChoice != null:
return multipleChoice(_that);case DragDropStep() when dragDrop != null:
return dragDrop(_that);case SliderStep() when slider != null:
return slider(_that);case TapOrderStep() when tapOrder != null:
return tapOrder(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String question,  List<String> options,  int correctIndex,  String explanation)?  multipleChoice,TResult Function( String instruction,  List<String> terms,  List<String> definitions)?  dragDrop,TResult Function( String instruction,  double minValue,  double maxValue,  double targetMin,  double targetMax,  String unit,  String explanation)?  slider,TResult Function( String instruction,  List<String> items,  String explanation)?  tapOrder,required TResult orElse(),}) {final _that = this;
switch (_that) {
case MultipleChoiceStep() when multipleChoice != null:
return multipleChoice(_that.question,_that.options,_that.correctIndex,_that.explanation);case DragDropStep() when dragDrop != null:
return dragDrop(_that.instruction,_that.terms,_that.definitions);case SliderStep() when slider != null:
return slider(_that.instruction,_that.minValue,_that.maxValue,_that.targetMin,_that.targetMax,_that.unit,_that.explanation);case TapOrderStep() when tapOrder != null:
return tapOrder(_that.instruction,_that.items,_that.explanation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String question,  List<String> options,  int correctIndex,  String explanation)  multipleChoice,required TResult Function( String instruction,  List<String> terms,  List<String> definitions)  dragDrop,required TResult Function( String instruction,  double minValue,  double maxValue,  double targetMin,  double targetMax,  String unit,  String explanation)  slider,required TResult Function( String instruction,  List<String> items,  String explanation)  tapOrder,}) {final _that = this;
switch (_that) {
case MultipleChoiceStep():
return multipleChoice(_that.question,_that.options,_that.correctIndex,_that.explanation);case DragDropStep():
return dragDrop(_that.instruction,_that.terms,_that.definitions);case SliderStep():
return slider(_that.instruction,_that.minValue,_that.maxValue,_that.targetMin,_that.targetMax,_that.unit,_that.explanation);case TapOrderStep():
return tapOrder(_that.instruction,_that.items,_that.explanation);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String question,  List<String> options,  int correctIndex,  String explanation)?  multipleChoice,TResult? Function( String instruction,  List<String> terms,  List<String> definitions)?  dragDrop,TResult? Function( String instruction,  double minValue,  double maxValue,  double targetMin,  double targetMax,  String unit,  String explanation)?  slider,TResult? Function( String instruction,  List<String> items,  String explanation)?  tapOrder,}) {final _that = this;
switch (_that) {
case MultipleChoiceStep() when multipleChoice != null:
return multipleChoice(_that.question,_that.options,_that.correctIndex,_that.explanation);case DragDropStep() when dragDrop != null:
return dragDrop(_that.instruction,_that.terms,_that.definitions);case SliderStep() when slider != null:
return slider(_that.instruction,_that.minValue,_that.maxValue,_that.targetMin,_that.targetMax,_that.unit,_that.explanation);case TapOrderStep() when tapOrder != null:
return tapOrder(_that.instruction,_that.items,_that.explanation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class MultipleChoiceStep implements LessonStepModel {
  const MultipleChoiceStep({required this.question, required final  List<String> options, required this.correctIndex, required this.explanation, final  String? $type}): _options = options,$type = $type ?? 'multiple_choice';
  factory MultipleChoiceStep.fromJson(Map<String, dynamic> json) => _$MultipleChoiceStepFromJson(json);

 final  String question;
 final  List<String> _options;
 List<String> get options {
  if (_options is EqualUnmodifiableListView) return _options;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_options);
}

 final  int correctIndex;
 final  String explanation;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of LessonStepModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MultipleChoiceStepCopyWith<MultipleChoiceStep> get copyWith => _$MultipleChoiceStepCopyWithImpl<MultipleChoiceStep>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MultipleChoiceStepToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MultipleChoiceStep&&(identical(other.question, question) || other.question == question)&&const DeepCollectionEquality().equals(other._options, _options)&&(identical(other.correctIndex, correctIndex) || other.correctIndex == correctIndex)&&(identical(other.explanation, explanation) || other.explanation == explanation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,question,const DeepCollectionEquality().hash(_options),correctIndex,explanation);

@override
String toString() {
  return 'LessonStepModel.multipleChoice(question: $question, options: $options, correctIndex: $correctIndex, explanation: $explanation)';
}


}

/// @nodoc
abstract mixin class $MultipleChoiceStepCopyWith<$Res> implements $LessonStepModelCopyWith<$Res> {
  factory $MultipleChoiceStepCopyWith(MultipleChoiceStep value, $Res Function(MultipleChoiceStep) _then) = _$MultipleChoiceStepCopyWithImpl;
@useResult
$Res call({
 String question, List<String> options, int correctIndex, String explanation
});




}
/// @nodoc
class _$MultipleChoiceStepCopyWithImpl<$Res>
    implements $MultipleChoiceStepCopyWith<$Res> {
  _$MultipleChoiceStepCopyWithImpl(this._self, this._then);

  final MultipleChoiceStep _self;
  final $Res Function(MultipleChoiceStep) _then;

/// Create a copy of LessonStepModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? question = null,Object? options = null,Object? correctIndex = null,Object? explanation = null,}) {
  return _then(MultipleChoiceStep(
question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,options: null == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as List<String>,correctIndex: null == correctIndex ? _self.correctIndex : correctIndex // ignore: cast_nullable_to_non_nullable
as int,explanation: null == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class DragDropStep implements LessonStepModel {
  const DragDropStep({required this.instruction, required final  List<String> terms, required final  List<String> definitions, final  String? $type}): _terms = terms,_definitions = definitions,$type = $type ?? 'drag_drop';
  factory DragDropStep.fromJson(Map<String, dynamic> json) => _$DragDropStepFromJson(json);

 final  String instruction;
 final  List<String> _terms;
 List<String> get terms {
  if (_terms is EqualUnmodifiableListView) return _terms;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_terms);
}

 final  List<String> _definitions;
 List<String> get definitions {
  if (_definitions is EqualUnmodifiableListView) return _definitions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_definitions);
}


@JsonKey(name: 'type')
final String $type;


/// Create a copy of LessonStepModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DragDropStepCopyWith<DragDropStep> get copyWith => _$DragDropStepCopyWithImpl<DragDropStep>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DragDropStepToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DragDropStep&&(identical(other.instruction, instruction) || other.instruction == instruction)&&const DeepCollectionEquality().equals(other._terms, _terms)&&const DeepCollectionEquality().equals(other._definitions, _definitions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,instruction,const DeepCollectionEquality().hash(_terms),const DeepCollectionEquality().hash(_definitions));

@override
String toString() {
  return 'LessonStepModel.dragDrop(instruction: $instruction, terms: $terms, definitions: $definitions)';
}


}

/// @nodoc
abstract mixin class $DragDropStepCopyWith<$Res> implements $LessonStepModelCopyWith<$Res> {
  factory $DragDropStepCopyWith(DragDropStep value, $Res Function(DragDropStep) _then) = _$DragDropStepCopyWithImpl;
@useResult
$Res call({
 String instruction, List<String> terms, List<String> definitions
});




}
/// @nodoc
class _$DragDropStepCopyWithImpl<$Res>
    implements $DragDropStepCopyWith<$Res> {
  _$DragDropStepCopyWithImpl(this._self, this._then);

  final DragDropStep _self;
  final $Res Function(DragDropStep) _then;

/// Create a copy of LessonStepModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? instruction = null,Object? terms = null,Object? definitions = null,}) {
  return _then(DragDropStep(
instruction: null == instruction ? _self.instruction : instruction // ignore: cast_nullable_to_non_nullable
as String,terms: null == terms ? _self._terms : terms // ignore: cast_nullable_to_non_nullable
as List<String>,definitions: null == definitions ? _self._definitions : definitions // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc
@JsonSerializable()

class SliderStep implements LessonStepModel {
  const SliderStep({required this.instruction, required this.minValue, required this.maxValue, required this.targetMin, required this.targetMax, required this.unit, required this.explanation, final  String? $type}): $type = $type ?? 'slider';
  factory SliderStep.fromJson(Map<String, dynamic> json) => _$SliderStepFromJson(json);

 final  String instruction;
 final  double minValue;
 final  double maxValue;
 final  double targetMin;
 final  double targetMax;
 final  String unit;
 final  String explanation;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of LessonStepModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SliderStepCopyWith<SliderStep> get copyWith => _$SliderStepCopyWithImpl<SliderStep>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SliderStepToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SliderStep&&(identical(other.instruction, instruction) || other.instruction == instruction)&&(identical(other.minValue, minValue) || other.minValue == minValue)&&(identical(other.maxValue, maxValue) || other.maxValue == maxValue)&&(identical(other.targetMin, targetMin) || other.targetMin == targetMin)&&(identical(other.targetMax, targetMax) || other.targetMax == targetMax)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.explanation, explanation) || other.explanation == explanation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,instruction,minValue,maxValue,targetMin,targetMax,unit,explanation);

@override
String toString() {
  return 'LessonStepModel.slider(instruction: $instruction, minValue: $minValue, maxValue: $maxValue, targetMin: $targetMin, targetMax: $targetMax, unit: $unit, explanation: $explanation)';
}


}

/// @nodoc
abstract mixin class $SliderStepCopyWith<$Res> implements $LessonStepModelCopyWith<$Res> {
  factory $SliderStepCopyWith(SliderStep value, $Res Function(SliderStep) _then) = _$SliderStepCopyWithImpl;
@useResult
$Res call({
 String instruction, double minValue, double maxValue, double targetMin, double targetMax, String unit, String explanation
});




}
/// @nodoc
class _$SliderStepCopyWithImpl<$Res>
    implements $SliderStepCopyWith<$Res> {
  _$SliderStepCopyWithImpl(this._self, this._then);

  final SliderStep _self;
  final $Res Function(SliderStep) _then;

/// Create a copy of LessonStepModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? instruction = null,Object? minValue = null,Object? maxValue = null,Object? targetMin = null,Object? targetMax = null,Object? unit = null,Object? explanation = null,}) {
  return _then(SliderStep(
instruction: null == instruction ? _self.instruction : instruction // ignore: cast_nullable_to_non_nullable
as String,minValue: null == minValue ? _self.minValue : minValue // ignore: cast_nullable_to_non_nullable
as double,maxValue: null == maxValue ? _self.maxValue : maxValue // ignore: cast_nullable_to_non_nullable
as double,targetMin: null == targetMin ? _self.targetMin : targetMin // ignore: cast_nullable_to_non_nullable
as double,targetMax: null == targetMax ? _self.targetMax : targetMax // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,explanation: null == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class TapOrderStep implements LessonStepModel {
  const TapOrderStep({required this.instruction, required final  List<String> items, required this.explanation, final  String? $type}): _items = items,$type = $type ?? 'tap_order';
  factory TapOrderStep.fromJson(Map<String, dynamic> json) => _$TapOrderStepFromJson(json);

 final  String instruction;
 final  List<String> _items;
 List<String> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

 final  String explanation;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of LessonStepModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TapOrderStepCopyWith<TapOrderStep> get copyWith => _$TapOrderStepCopyWithImpl<TapOrderStep>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TapOrderStepToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TapOrderStep&&(identical(other.instruction, instruction) || other.instruction == instruction)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.explanation, explanation) || other.explanation == explanation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,instruction,const DeepCollectionEquality().hash(_items),explanation);

@override
String toString() {
  return 'LessonStepModel.tapOrder(instruction: $instruction, items: $items, explanation: $explanation)';
}


}

/// @nodoc
abstract mixin class $TapOrderStepCopyWith<$Res> implements $LessonStepModelCopyWith<$Res> {
  factory $TapOrderStepCopyWith(TapOrderStep value, $Res Function(TapOrderStep) _then) = _$TapOrderStepCopyWithImpl;
@useResult
$Res call({
 String instruction, List<String> items, String explanation
});




}
/// @nodoc
class _$TapOrderStepCopyWithImpl<$Res>
    implements $TapOrderStepCopyWith<$Res> {
  _$TapOrderStepCopyWithImpl(this._self, this._then);

  final TapOrderStep _self;
  final $Res Function(TapOrderStep) _then;

/// Create a copy of LessonStepModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? instruction = null,Object? items = null,Object? explanation = null,}) {
  return _then(TapOrderStep(
instruction: null == instruction ? _self.instruction : instruction // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<String>,explanation: null == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
