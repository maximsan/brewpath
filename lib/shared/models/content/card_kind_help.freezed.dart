// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'card_kind_help.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CardKindHelp {

 String get kind; String get title; String get blurb; List<String> get steps;
/// Create a copy of CardKindHelp
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardKindHelpCopyWith<CardKindHelp> get copyWith => _$CardKindHelpCopyWithImpl<CardKindHelp>(this as CardKindHelp, _$identity);

  /// Serializes this CardKindHelp to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardKindHelp&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.title, title) || other.title == title)&&(identical(other.blurb, blurb) || other.blurb == blurb)&&const DeepCollectionEquality().equals(other.steps, steps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,title,blurb,const DeepCollectionEquality().hash(steps));

@override
String toString() {
  return 'CardKindHelp(kind: $kind, title: $title, blurb: $blurb, steps: $steps)';
}


}

/// @nodoc
abstract mixin class $CardKindHelpCopyWith<$Res>  {
  factory $CardKindHelpCopyWith(CardKindHelp value, $Res Function(CardKindHelp) _then) = _$CardKindHelpCopyWithImpl;
@useResult
$Res call({
 String kind, String title, String blurb, List<String> steps
});




}
/// @nodoc
class _$CardKindHelpCopyWithImpl<$Res>
    implements $CardKindHelpCopyWith<$Res> {
  _$CardKindHelpCopyWithImpl(this._self, this._then);

  final CardKindHelp _self;
  final $Res Function(CardKindHelp) _then;

/// Create a copy of CardKindHelp
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? title = null,Object? blurb = null,Object? steps = null,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,blurb: null == blurb ? _self.blurb : blurb // ignore: cast_nullable_to_non_nullable
as String,steps: null == steps ? _self.steps : steps // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [CardKindHelp].
extension CardKindHelpPatterns on CardKindHelp {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardKindHelp value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardKindHelp() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardKindHelp value)  $default,){
final _that = this;
switch (_that) {
case _CardKindHelp():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardKindHelp value)?  $default,){
final _that = this;
switch (_that) {
case _CardKindHelp() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String kind,  String title,  String blurb,  List<String> steps)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardKindHelp() when $default != null:
return $default(_that.kind,_that.title,_that.blurb,_that.steps);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String kind,  String title,  String blurb,  List<String> steps)  $default,) {final _that = this;
switch (_that) {
case _CardKindHelp():
return $default(_that.kind,_that.title,_that.blurb,_that.steps);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String kind,  String title,  String blurb,  List<String> steps)?  $default,) {final _that = this;
switch (_that) {
case _CardKindHelp() when $default != null:
return $default(_that.kind,_that.title,_that.blurb,_that.steps);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CardKindHelp implements CardKindHelp {
  const _CardKindHelp({required this.kind, required this.title, required this.blurb, required final  List<String> steps}): _steps = steps;
  factory _CardKindHelp.fromJson(Map<String, dynamic> json) => _$CardKindHelpFromJson(json);

@override final  String kind;
@override final  String title;
@override final  String blurb;
 final  List<String> _steps;
@override List<String> get steps {
  if (_steps is EqualUnmodifiableListView) return _steps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_steps);
}


/// Create a copy of CardKindHelp
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardKindHelpCopyWith<_CardKindHelp> get copyWith => __$CardKindHelpCopyWithImpl<_CardKindHelp>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CardKindHelpToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardKindHelp&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.title, title) || other.title == title)&&(identical(other.blurb, blurb) || other.blurb == blurb)&&const DeepCollectionEquality().equals(other._steps, _steps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,title,blurb,const DeepCollectionEquality().hash(_steps));

@override
String toString() {
  return 'CardKindHelp(kind: $kind, title: $title, blurb: $blurb, steps: $steps)';
}


}

/// @nodoc
abstract mixin class _$CardKindHelpCopyWith<$Res> implements $CardKindHelpCopyWith<$Res> {
  factory _$CardKindHelpCopyWith(_CardKindHelp value, $Res Function(_CardKindHelp) _then) = __$CardKindHelpCopyWithImpl;
@override @useResult
$Res call({
 String kind, String title, String blurb, List<String> steps
});




}
/// @nodoc
class __$CardKindHelpCopyWithImpl<$Res>
    implements _$CardKindHelpCopyWith<$Res> {
  __$CardKindHelpCopyWithImpl(this._self, this._then);

  final _CardKindHelp _self;
  final $Res Function(_CardKindHelp) _then;

/// Create a copy of CardKindHelp
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? title = null,Object? blurb = null,Object? steps = null,}) {
  return _then(_CardKindHelp(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,blurb: null == blurb ? _self.blurb : blurb // ignore: cast_nullable_to_non_nullable
as String,steps: null == steps ? _self._steps : steps // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
