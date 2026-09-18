// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'companion_line.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CompanionLine {

 String get id;/// The `CompanionReaction` this line answers, by enum name.
 String get occasion; String get text;
/// Create a copy of CompanionLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompanionLineCopyWith<CompanionLine> get copyWith => _$CompanionLineCopyWithImpl<CompanionLine>(this as CompanionLine, _$identity);

  /// Serializes this CompanionLine to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompanionLine&&(identical(other.id, id) || other.id == id)&&(identical(other.occasion, occasion) || other.occasion == occasion)&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,occasion,text);

@override
String toString() {
  return 'CompanionLine(id: $id, occasion: $occasion, text: $text)';
}


}

/// @nodoc
abstract mixin class $CompanionLineCopyWith<$Res>  {
  factory $CompanionLineCopyWith(CompanionLine value, $Res Function(CompanionLine) _then) = _$CompanionLineCopyWithImpl;
@useResult
$Res call({
 String id, String occasion, String text
});




}
/// @nodoc
class _$CompanionLineCopyWithImpl<$Res>
    implements $CompanionLineCopyWith<$Res> {
  _$CompanionLineCopyWithImpl(this._self, this._then);

  final CompanionLine _self;
  final $Res Function(CompanionLine) _then;

/// Create a copy of CompanionLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? occasion = null,Object? text = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,occasion: null == occasion ? _self.occasion : occasion // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CompanionLine].
extension CompanionLinePatterns on CompanionLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompanionLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompanionLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompanionLine value)  $default,){
final _that = this;
switch (_that) {
case _CompanionLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompanionLine value)?  $default,){
final _that = this;
switch (_that) {
case _CompanionLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String occasion,  String text)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompanionLine() when $default != null:
return $default(_that.id,_that.occasion,_that.text);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String occasion,  String text)  $default,) {final _that = this;
switch (_that) {
case _CompanionLine():
return $default(_that.id,_that.occasion,_that.text);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String occasion,  String text)?  $default,) {final _that = this;
switch (_that) {
case _CompanionLine() when $default != null:
return $default(_that.id,_that.occasion,_that.text);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CompanionLine implements CompanionLine {
  const _CompanionLine({required this.id, required this.occasion, required this.text});
  factory _CompanionLine.fromJson(Map<String, dynamic> json) => _$CompanionLineFromJson(json);

@override final  String id;
/// The `CompanionReaction` this line answers, by enum name.
@override final  String occasion;
@override final  String text;

/// Create a copy of CompanionLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompanionLineCopyWith<_CompanionLine> get copyWith => __$CompanionLineCopyWithImpl<_CompanionLine>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CompanionLineToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompanionLine&&(identical(other.id, id) || other.id == id)&&(identical(other.occasion, occasion) || other.occasion == occasion)&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,occasion,text);

@override
String toString() {
  return 'CompanionLine(id: $id, occasion: $occasion, text: $text)';
}


}

/// @nodoc
abstract mixin class _$CompanionLineCopyWith<$Res> implements $CompanionLineCopyWith<$Res> {
  factory _$CompanionLineCopyWith(_CompanionLine value, $Res Function(_CompanionLine) _then) = __$CompanionLineCopyWithImpl;
@override @useResult
$Res call({
 String id, String occasion, String text
});




}
/// @nodoc
class __$CompanionLineCopyWithImpl<$Res>
    implements _$CompanionLineCopyWith<$Res> {
  __$CompanionLineCopyWithImpl(this._self, this._then);

  final _CompanionLine _self;
  final $Res Function(_CompanionLine) _then;

/// Create a copy of CompanionLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? occasion = null,Object? text = null,}) {
  return _then(_CompanionLine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,occasion: null == occasion ? _self.occasion : occasion // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
