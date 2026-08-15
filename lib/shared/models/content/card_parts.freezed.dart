// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'card_parts.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Choice {

@JsonKey(name: 't') String get text;@JsonKey(name: 'correct') bool get isCorrect;
/// Create a copy of Choice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChoiceCopyWith<Choice> get copyWith => _$ChoiceCopyWithImpl<Choice>(this as Choice, _$identity);

  /// Serializes this Choice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Choice&&(identical(other.text, text) || other.text == text)&&(identical(other.isCorrect, isCorrect) || other.isCorrect == isCorrect));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,isCorrect);

@override
String toString() {
  return 'Choice(text: $text, isCorrect: $isCorrect)';
}


}

/// @nodoc
abstract mixin class $ChoiceCopyWith<$Res>  {
  factory $ChoiceCopyWith(Choice value, $Res Function(Choice) _then) = _$ChoiceCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 't') String text,@JsonKey(name: 'correct') bool isCorrect
});




}
/// @nodoc
class _$ChoiceCopyWithImpl<$Res>
    implements $ChoiceCopyWith<$Res> {
  _$ChoiceCopyWithImpl(this._self, this._then);

  final Choice _self;
  final $Res Function(Choice) _then;

/// Create a copy of Choice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? isCorrect = null,}) {
  return _then(_self.copyWith(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,isCorrect: null == isCorrect ? _self.isCorrect : isCorrect // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Choice].
extension ChoicePatterns on Choice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Choice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Choice() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Choice value)  $default,){
final _that = this;
switch (_that) {
case _Choice():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Choice value)?  $default,){
final _that = this;
switch (_that) {
case _Choice() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 't')  String text, @JsonKey(name: 'correct')  bool isCorrect)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Choice() when $default != null:
return $default(_that.text,_that.isCorrect);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 't')  String text, @JsonKey(name: 'correct')  bool isCorrect)  $default,) {final _that = this;
switch (_that) {
case _Choice():
return $default(_that.text,_that.isCorrect);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 't')  String text, @JsonKey(name: 'correct')  bool isCorrect)?  $default,) {final _that = this;
switch (_that) {
case _Choice() when $default != null:
return $default(_that.text,_that.isCorrect);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Choice implements Choice {
  const _Choice({@JsonKey(name: 't') required this.text, @JsonKey(name: 'correct') this.isCorrect = false});
  factory _Choice.fromJson(Map<String, dynamic> json) => _$ChoiceFromJson(json);

@override@JsonKey(name: 't') final  String text;
@override@JsonKey(name: 'correct') final  bool isCorrect;

/// Create a copy of Choice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChoiceCopyWith<_Choice> get copyWith => __$ChoiceCopyWithImpl<_Choice>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChoiceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Choice&&(identical(other.text, text) || other.text == text)&&(identical(other.isCorrect, isCorrect) || other.isCorrect == isCorrect));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,isCorrect);

@override
String toString() {
  return 'Choice(text: $text, isCorrect: $isCorrect)';
}


}

/// @nodoc
abstract mixin class _$ChoiceCopyWith<$Res> implements $ChoiceCopyWith<$Res> {
  factory _$ChoiceCopyWith(_Choice value, $Res Function(_Choice) _then) = __$ChoiceCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 't') String text,@JsonKey(name: 'correct') bool isCorrect
});




}
/// @nodoc
class __$ChoiceCopyWithImpl<$Res>
    implements _$ChoiceCopyWith<$Res> {
  __$ChoiceCopyWithImpl(this._self, this._then);

  final _Choice _self;
  final $Res Function(_Choice) _then;

/// Create a copy of Choice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? isCorrect = null,}) {
  return _then(_Choice(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,isCorrect: null == isCorrect ? _self.isCorrect : isCorrect // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$DecisionOption {

@JsonKey(name: 't') String get text;@JsonKey(name: 'sub') String? get subtitle;@JsonKey(name: 'correct') bool get isCorrect;
/// Create a copy of DecisionOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DecisionOptionCopyWith<DecisionOption> get copyWith => _$DecisionOptionCopyWithImpl<DecisionOption>(this as DecisionOption, _$identity);

  /// Serializes this DecisionOption to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DecisionOption&&(identical(other.text, text) || other.text == text)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.isCorrect, isCorrect) || other.isCorrect == isCorrect));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,subtitle,isCorrect);

@override
String toString() {
  return 'DecisionOption(text: $text, subtitle: $subtitle, isCorrect: $isCorrect)';
}


}

/// @nodoc
abstract mixin class $DecisionOptionCopyWith<$Res>  {
  factory $DecisionOptionCopyWith(DecisionOption value, $Res Function(DecisionOption) _then) = _$DecisionOptionCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 't') String text,@JsonKey(name: 'sub') String? subtitle,@JsonKey(name: 'correct') bool isCorrect
});




}
/// @nodoc
class _$DecisionOptionCopyWithImpl<$Res>
    implements $DecisionOptionCopyWith<$Res> {
  _$DecisionOptionCopyWithImpl(this._self, this._then);

  final DecisionOption _self;
  final $Res Function(DecisionOption) _then;

/// Create a copy of DecisionOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? subtitle = freezed,Object? isCorrect = null,}) {
  return _then(_self.copyWith(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,isCorrect: null == isCorrect ? _self.isCorrect : isCorrect // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DecisionOption].
extension DecisionOptionPatterns on DecisionOption {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DecisionOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DecisionOption() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DecisionOption value)  $default,){
final _that = this;
switch (_that) {
case _DecisionOption():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DecisionOption value)?  $default,){
final _that = this;
switch (_that) {
case _DecisionOption() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 't')  String text, @JsonKey(name: 'sub')  String? subtitle, @JsonKey(name: 'correct')  bool isCorrect)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DecisionOption() when $default != null:
return $default(_that.text,_that.subtitle,_that.isCorrect);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 't')  String text, @JsonKey(name: 'sub')  String? subtitle, @JsonKey(name: 'correct')  bool isCorrect)  $default,) {final _that = this;
switch (_that) {
case _DecisionOption():
return $default(_that.text,_that.subtitle,_that.isCorrect);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 't')  String text, @JsonKey(name: 'sub')  String? subtitle, @JsonKey(name: 'correct')  bool isCorrect)?  $default,) {final _that = this;
switch (_that) {
case _DecisionOption() when $default != null:
return $default(_that.text,_that.subtitle,_that.isCorrect);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DecisionOption implements DecisionOption {
  const _DecisionOption({@JsonKey(name: 't') required this.text, @JsonKey(name: 'sub') this.subtitle, @JsonKey(name: 'correct') this.isCorrect = false});
  factory _DecisionOption.fromJson(Map<String, dynamic> json) => _$DecisionOptionFromJson(json);

@override@JsonKey(name: 't') final  String text;
@override@JsonKey(name: 'sub') final  String? subtitle;
@override@JsonKey(name: 'correct') final  bool isCorrect;

/// Create a copy of DecisionOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DecisionOptionCopyWith<_DecisionOption> get copyWith => __$DecisionOptionCopyWithImpl<_DecisionOption>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DecisionOptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DecisionOption&&(identical(other.text, text) || other.text == text)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.isCorrect, isCorrect) || other.isCorrect == isCorrect));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,subtitle,isCorrect);

@override
String toString() {
  return 'DecisionOption(text: $text, subtitle: $subtitle, isCorrect: $isCorrect)';
}


}

/// @nodoc
abstract mixin class _$DecisionOptionCopyWith<$Res> implements $DecisionOptionCopyWith<$Res> {
  factory _$DecisionOptionCopyWith(_DecisionOption value, $Res Function(_DecisionOption) _then) = __$DecisionOptionCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 't') String text,@JsonKey(name: 'sub') String? subtitle,@JsonKey(name: 'correct') bool isCorrect
});




}
/// @nodoc
class __$DecisionOptionCopyWithImpl<$Res>
    implements _$DecisionOptionCopyWith<$Res> {
  __$DecisionOptionCopyWithImpl(this._self, this._then);

  final _DecisionOption _self;
  final $Res Function(_DecisionOption) _then;

/// Create a copy of DecisionOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? subtitle = freezed,Object? isCorrect = null,}) {
  return _then(_DecisionOption(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,isCorrect: null == isCorrect ? _self.isCorrect : isCorrect // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$MatchPair {

@JsonKey(name: 'l') String get left;@JsonKey(name: 'r') String get right;
/// Create a copy of MatchPair
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MatchPairCopyWith<MatchPair> get copyWith => _$MatchPairCopyWithImpl<MatchPair>(this as MatchPair, _$identity);

  /// Serializes this MatchPair to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MatchPair&&(identical(other.left, left) || other.left == left)&&(identical(other.right, right) || other.right == right));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,left,right);

@override
String toString() {
  return 'MatchPair(left: $left, right: $right)';
}


}

/// @nodoc
abstract mixin class $MatchPairCopyWith<$Res>  {
  factory $MatchPairCopyWith(MatchPair value, $Res Function(MatchPair) _then) = _$MatchPairCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'l') String left,@JsonKey(name: 'r') String right
});




}
/// @nodoc
class _$MatchPairCopyWithImpl<$Res>
    implements $MatchPairCopyWith<$Res> {
  _$MatchPairCopyWithImpl(this._self, this._then);

  final MatchPair _self;
  final $Res Function(MatchPair) _then;

/// Create a copy of MatchPair
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? left = null,Object? right = null,}) {
  return _then(_self.copyWith(
left: null == left ? _self.left : left // ignore: cast_nullable_to_non_nullable
as String,right: null == right ? _self.right : right // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MatchPair].
extension MatchPairPatterns on MatchPair {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MatchPair value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MatchPair() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MatchPair value)  $default,){
final _that = this;
switch (_that) {
case _MatchPair():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MatchPair value)?  $default,){
final _that = this;
switch (_that) {
case _MatchPair() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'l')  String left, @JsonKey(name: 'r')  String right)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MatchPair() when $default != null:
return $default(_that.left,_that.right);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'l')  String left, @JsonKey(name: 'r')  String right)  $default,) {final _that = this;
switch (_that) {
case _MatchPair():
return $default(_that.left,_that.right);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'l')  String left, @JsonKey(name: 'r')  String right)?  $default,) {final _that = this;
switch (_that) {
case _MatchPair() when $default != null:
return $default(_that.left,_that.right);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MatchPair implements MatchPair {
  const _MatchPair({@JsonKey(name: 'l') required this.left, @JsonKey(name: 'r') required this.right});
  factory _MatchPair.fromJson(Map<String, dynamic> json) => _$MatchPairFromJson(json);

@override@JsonKey(name: 'l') final  String left;
@override@JsonKey(name: 'r') final  String right;

/// Create a copy of MatchPair
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MatchPairCopyWith<_MatchPair> get copyWith => __$MatchPairCopyWithImpl<_MatchPair>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MatchPairToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MatchPair&&(identical(other.left, left) || other.left == left)&&(identical(other.right, right) || other.right == right));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,left,right);

@override
String toString() {
  return 'MatchPair(left: $left, right: $right)';
}


}

/// @nodoc
abstract mixin class _$MatchPairCopyWith<$Res> implements $MatchPairCopyWith<$Res> {
  factory _$MatchPairCopyWith(_MatchPair value, $Res Function(_MatchPair) _then) = __$MatchPairCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'l') String left,@JsonKey(name: 'r') String right
});




}
/// @nodoc
class __$MatchPairCopyWithImpl<$Res>
    implements _$MatchPairCopyWith<$Res> {
  __$MatchPairCopyWithImpl(this._self, this._then);

  final _MatchPair _self;
  final $Res Function(_MatchPair) _then;

/// Create a copy of MatchPair
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? left = null,Object? right = null,}) {
  return _then(_MatchPair(
left: null == left ? _self.left : left // ignore: cast_nullable_to_non_nullable
as String,right: null == right ? _self.right : right // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SequenceItem {

 String get label; int get order;
/// Create a copy of SequenceItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SequenceItemCopyWith<SequenceItem> get copyWith => _$SequenceItemCopyWithImpl<SequenceItem>(this as SequenceItem, _$identity);

  /// Serializes this SequenceItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SequenceItem&&(identical(other.label, label) || other.label == label)&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,order);

@override
String toString() {
  return 'SequenceItem(label: $label, order: $order)';
}


}

/// @nodoc
abstract mixin class $SequenceItemCopyWith<$Res>  {
  factory $SequenceItemCopyWith(SequenceItem value, $Res Function(SequenceItem) _then) = _$SequenceItemCopyWithImpl;
@useResult
$Res call({
 String label, int order
});




}
/// @nodoc
class _$SequenceItemCopyWithImpl<$Res>
    implements $SequenceItemCopyWith<$Res> {
  _$SequenceItemCopyWithImpl(this._self, this._then);

  final SequenceItem _self;
  final $Res Function(SequenceItem) _then;

/// Create a copy of SequenceItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? order = null,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SequenceItem].
extension SequenceItemPatterns on SequenceItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SequenceItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SequenceItem() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SequenceItem value)  $default,){
final _that = this;
switch (_that) {
case _SequenceItem():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SequenceItem value)?  $default,){
final _that = this;
switch (_that) {
case _SequenceItem() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  int order)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SequenceItem() when $default != null:
return $default(_that.label,_that.order);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  int order)  $default,) {final _that = this;
switch (_that) {
case _SequenceItem():
return $default(_that.label,_that.order);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  int order)?  $default,) {final _that = this;
switch (_that) {
case _SequenceItem() when $default != null:
return $default(_that.label,_that.order);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SequenceItem implements SequenceItem {
  const _SequenceItem({required this.label, required this.order});
  factory _SequenceItem.fromJson(Map<String, dynamic> json) => _$SequenceItemFromJson(json);

@override final  String label;
@override final  int order;

/// Create a copy of SequenceItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SequenceItemCopyWith<_SequenceItem> get copyWith => __$SequenceItemCopyWithImpl<_SequenceItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SequenceItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SequenceItem&&(identical(other.label, label) || other.label == label)&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,order);

@override
String toString() {
  return 'SequenceItem(label: $label, order: $order)';
}


}

/// @nodoc
abstract mixin class _$SequenceItemCopyWith<$Res> implements $SequenceItemCopyWith<$Res> {
  factory _$SequenceItemCopyWith(_SequenceItem value, $Res Function(_SequenceItem) _then) = __$SequenceItemCopyWithImpl;
@override @useResult
$Res call({
 String label, int order
});




}
/// @nodoc
class __$SequenceItemCopyWithImpl<$Res>
    implements _$SequenceItemCopyWith<$Res> {
  __$SequenceItemCopyWithImpl(this._self, this._then);

  final _SequenceItem _self;
  final $Res Function(_SequenceItem) _then;

/// Create a copy of SequenceItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? order = null,}) {
  return _then(_SequenceItem(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$BagpickBean {

 String get body; String get crease; int get mottle; bool get chaff;
/// Create a copy of BagpickBean
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BagpickBeanCopyWith<BagpickBean> get copyWith => _$BagpickBeanCopyWithImpl<BagpickBean>(this as BagpickBean, _$identity);

  /// Serializes this BagpickBean to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BagpickBean&&(identical(other.body, body) || other.body == body)&&(identical(other.crease, crease) || other.crease == crease)&&(identical(other.mottle, mottle) || other.mottle == mottle)&&(identical(other.chaff, chaff) || other.chaff == chaff));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,body,crease,mottle,chaff);

@override
String toString() {
  return 'BagpickBean(body: $body, crease: $crease, mottle: $mottle, chaff: $chaff)';
}


}

/// @nodoc
abstract mixin class $BagpickBeanCopyWith<$Res>  {
  factory $BagpickBeanCopyWith(BagpickBean value, $Res Function(BagpickBean) _then) = _$BagpickBeanCopyWithImpl;
@useResult
$Res call({
 String body, String crease, int mottle, bool chaff
});




}
/// @nodoc
class _$BagpickBeanCopyWithImpl<$Res>
    implements $BagpickBeanCopyWith<$Res> {
  _$BagpickBeanCopyWithImpl(this._self, this._then);

  final BagpickBean _self;
  final $Res Function(BagpickBean) _then;

/// Create a copy of BagpickBean
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? body = null,Object? crease = null,Object? mottle = null,Object? chaff = null,}) {
  return _then(_self.copyWith(
body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,crease: null == crease ? _self.crease : crease // ignore: cast_nullable_to_non_nullable
as String,mottle: null == mottle ? _self.mottle : mottle // ignore: cast_nullable_to_non_nullable
as int,chaff: null == chaff ? _self.chaff : chaff // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [BagpickBean].
extension BagpickBeanPatterns on BagpickBean {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BagpickBean value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BagpickBean() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BagpickBean value)  $default,){
final _that = this;
switch (_that) {
case _BagpickBean():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BagpickBean value)?  $default,){
final _that = this;
switch (_that) {
case _BagpickBean() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String body,  String crease,  int mottle,  bool chaff)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BagpickBean() when $default != null:
return $default(_that.body,_that.crease,_that.mottle,_that.chaff);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String body,  String crease,  int mottle,  bool chaff)  $default,) {final _that = this;
switch (_that) {
case _BagpickBean():
return $default(_that.body,_that.crease,_that.mottle,_that.chaff);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String body,  String crease,  int mottle,  bool chaff)?  $default,) {final _that = this;
switch (_that) {
case _BagpickBean() when $default != null:
return $default(_that.body,_that.crease,_that.mottle,_that.chaff);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BagpickBean implements BagpickBean {
  const _BagpickBean({required this.body, required this.crease, required this.mottle, required this.chaff});
  factory _BagpickBean.fromJson(Map<String, dynamic> json) => _$BagpickBeanFromJson(json);

@override final  String body;
@override final  String crease;
@override final  int mottle;
@override final  bool chaff;

/// Create a copy of BagpickBean
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BagpickBeanCopyWith<_BagpickBean> get copyWith => __$BagpickBeanCopyWithImpl<_BagpickBean>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BagpickBeanToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BagpickBean&&(identical(other.body, body) || other.body == body)&&(identical(other.crease, crease) || other.crease == crease)&&(identical(other.mottle, mottle) || other.mottle == mottle)&&(identical(other.chaff, chaff) || other.chaff == chaff));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,body,crease,mottle,chaff);

@override
String toString() {
  return 'BagpickBean(body: $body, crease: $crease, mottle: $mottle, chaff: $chaff)';
}


}

/// @nodoc
abstract mixin class _$BagpickBeanCopyWith<$Res> implements $BagpickBeanCopyWith<$Res> {
  factory _$BagpickBeanCopyWith(_BagpickBean value, $Res Function(_BagpickBean) _then) = __$BagpickBeanCopyWithImpl;
@override @useResult
$Res call({
 String body, String crease, int mottle, bool chaff
});




}
/// @nodoc
class __$BagpickBeanCopyWithImpl<$Res>
    implements _$BagpickBeanCopyWith<$Res> {
  __$BagpickBeanCopyWithImpl(this._self, this._then);

  final _BagpickBean _self;
  final $Res Function(_BagpickBean) _then;

/// Create a copy of BagpickBean
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? body = null,Object? crease = null,Object? mottle = null,Object? chaff = null,}) {
  return _then(_BagpickBean(
body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,crease: null == crease ? _self.crease : crease // ignore: cast_nullable_to_non_nullable
as String,mottle: null == mottle ? _self.mottle : mottle // ignore: cast_nullable_to_non_nullable
as int,chaff: null == chaff ? _self.chaff : chaff // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$BagpickCue {

 String get id; String get label; String get text;
/// Create a copy of BagpickCue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BagpickCueCopyWith<BagpickCue> get copyWith => _$BagpickCueCopyWithImpl<BagpickCue>(this as BagpickCue, _$identity);

  /// Serializes this BagpickCue to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BagpickCue&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,text);

@override
String toString() {
  return 'BagpickCue(id: $id, label: $label, text: $text)';
}


}

/// @nodoc
abstract mixin class $BagpickCueCopyWith<$Res>  {
  factory $BagpickCueCopyWith(BagpickCue value, $Res Function(BagpickCue) _then) = _$BagpickCueCopyWithImpl;
@useResult
$Res call({
 String id, String label, String text
});




}
/// @nodoc
class _$BagpickCueCopyWithImpl<$Res>
    implements $BagpickCueCopyWith<$Res> {
  _$BagpickCueCopyWithImpl(this._self, this._then);

  final BagpickCue _self;
  final $Res Function(BagpickCue) _then;

/// Create a copy of BagpickCue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? text = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BagpickCue].
extension BagpickCuePatterns on BagpickCue {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BagpickCue value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BagpickCue() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BagpickCue value)  $default,){
final _that = this;
switch (_that) {
case _BagpickCue():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BagpickCue value)?  $default,){
final _that = this;
switch (_that) {
case _BagpickCue() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  String text)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BagpickCue() when $default != null:
return $default(_that.id,_that.label,_that.text);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  String text)  $default,) {final _that = this;
switch (_that) {
case _BagpickCue():
return $default(_that.id,_that.label,_that.text);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  String text)?  $default,) {final _that = this;
switch (_that) {
case _BagpickCue() when $default != null:
return $default(_that.id,_that.label,_that.text);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BagpickCue implements BagpickCue {
  const _BagpickCue({required this.id, required this.label, required this.text});
  factory _BagpickCue.fromJson(Map<String, dynamic> json) => _$BagpickCueFromJson(json);

@override final  String id;
@override final  String label;
@override final  String text;

/// Create a copy of BagpickCue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BagpickCueCopyWith<_BagpickCue> get copyWith => __$BagpickCueCopyWithImpl<_BagpickCue>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BagpickCueToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BagpickCue&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,text);

@override
String toString() {
  return 'BagpickCue(id: $id, label: $label, text: $text)';
}


}

/// @nodoc
abstract mixin class _$BagpickCueCopyWith<$Res> implements $BagpickCueCopyWith<$Res> {
  factory _$BagpickCueCopyWith(_BagpickCue value, $Res Function(_BagpickCue) _then) = __$BagpickCueCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, String text
});




}
/// @nodoc
class __$BagpickCueCopyWithImpl<$Res>
    implements _$BagpickCueCopyWith<$Res> {
  __$BagpickCueCopyWithImpl(this._self, this._then);

  final _BagpickCue _self;
  final $Res Function(_BagpickCue) _then;

/// Create a copy of BagpickCue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? text = null,}) {
  return _then(_BagpickCue(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ConceptFillPart {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConceptFillPart);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ConceptFillPart()';
}


}

/// @nodoc
class $ConceptFillPartCopyWith<$Res>  {
$ConceptFillPartCopyWith(ConceptFillPart _, $Res Function(ConceptFillPart) __);
}


/// Adds pattern-matching-related methods to [ConceptFillPart].
extension ConceptFillPartPatterns on ConceptFillPart {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( FillLiteral value)?  literal,TResult Function( FillBlank value)?  blank,required TResult orElse(),}){
final _that = this;
switch (_that) {
case FillLiteral() when literal != null:
return literal(_that);case FillBlank() when blank != null:
return blank(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( FillLiteral value)  literal,required TResult Function( FillBlank value)  blank,}){
final _that = this;
switch (_that) {
case FillLiteral():
return literal(_that);case FillBlank():
return blank(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( FillLiteral value)?  literal,TResult? Function( FillBlank value)?  blank,}){
final _that = this;
switch (_that) {
case FillLiteral() when literal != null:
return literal(_that);case FillBlank() when blank != null:
return blank(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String text)?  literal,TResult Function( String answer,  List<String> options,  String label)?  blank,required TResult orElse(),}) {final _that = this;
switch (_that) {
case FillLiteral() when literal != null:
return literal(_that.text);case FillBlank() when blank != null:
return blank(_that.answer,_that.options,_that.label);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String text)  literal,required TResult Function( String answer,  List<String> options,  String label)  blank,}) {final _that = this;
switch (_that) {
case FillLiteral():
return literal(_that.text);case FillBlank():
return blank(_that.answer,_that.options,_that.label);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String text)?  literal,TResult? Function( String answer,  List<String> options,  String label)?  blank,}) {final _that = this;
switch (_that) {
case FillLiteral() when literal != null:
return literal(_that.text);case FillBlank() when blank != null:
return blank(_that.answer,_that.options,_that.label);case _:
  return null;

}
}

}

/// @nodoc


class FillLiteral implements ConceptFillPart {
  const FillLiteral(this.text);
  

 final  String text;

/// Create a copy of ConceptFillPart
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FillLiteralCopyWith<FillLiteral> get copyWith => _$FillLiteralCopyWithImpl<FillLiteral>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FillLiteral&&(identical(other.text, text) || other.text == text));
}


@override
int get hashCode => Object.hash(runtimeType,text);

@override
String toString() {
  return 'ConceptFillPart.literal(text: $text)';
}


}

/// @nodoc
abstract mixin class $FillLiteralCopyWith<$Res> implements $ConceptFillPartCopyWith<$Res> {
  factory $FillLiteralCopyWith(FillLiteral value, $Res Function(FillLiteral) _then) = _$FillLiteralCopyWithImpl;
@useResult
$Res call({
 String text
});




}
/// @nodoc
class _$FillLiteralCopyWithImpl<$Res>
    implements $FillLiteralCopyWith<$Res> {
  _$FillLiteralCopyWithImpl(this._self, this._then);

  final FillLiteral _self;
  final $Res Function(FillLiteral) _then;

/// Create a copy of ConceptFillPart
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? text = null,}) {
  return _then(FillLiteral(
null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class FillBlank implements ConceptFillPart {
  const FillBlank({required this.answer, required final  List<String> options, required this.label}): _options = options;
  

 final  String answer;
 final  List<String> _options;
 List<String> get options {
  if (_options is EqualUnmodifiableListView) return _options;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_options);
}

 final  String label;

/// Create a copy of ConceptFillPart
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FillBlankCopyWith<FillBlank> get copyWith => _$FillBlankCopyWithImpl<FillBlank>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FillBlank&&(identical(other.answer, answer) || other.answer == answer)&&const DeepCollectionEquality().equals(other._options, _options)&&(identical(other.label, label) || other.label == label));
}


@override
int get hashCode => Object.hash(runtimeType,answer,const DeepCollectionEquality().hash(_options),label);

@override
String toString() {
  return 'ConceptFillPart.blank(answer: $answer, options: $options, label: $label)';
}


}

/// @nodoc
abstract mixin class $FillBlankCopyWith<$Res> implements $ConceptFillPartCopyWith<$Res> {
  factory $FillBlankCopyWith(FillBlank value, $Res Function(FillBlank) _then) = _$FillBlankCopyWithImpl;
@useResult
$Res call({
 String answer, List<String> options, String label
});




}
/// @nodoc
class _$FillBlankCopyWithImpl<$Res>
    implements $FillBlankCopyWith<$Res> {
  _$FillBlankCopyWithImpl(this._self, this._then);

  final FillBlank _self;
  final $Res Function(FillBlank) _then;

/// Create a copy of ConceptFillPart
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? answer = null,Object? options = null,Object? label = null,}) {
  return _then(FillBlank(
answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,options: null == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as List<String>,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
