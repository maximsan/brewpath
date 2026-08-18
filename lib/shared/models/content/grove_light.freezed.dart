// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'grove_light.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GroveLight {

 String get id; String get name;/// The one-line mood, e.g. `Late sun`.
 String get note;/// Swatch colour for the picker pill, as a CSS hex string.
 String get swatch;/// The filter chain applied over the plant, empty for the unfiltered
/// default. Composed with the variety's leaf tone into one treatment.
 String get filter;
/// Create a copy of GroveLight
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroveLightCopyWith<GroveLight> get copyWith => _$GroveLightCopyWithImpl<GroveLight>(this as GroveLight, _$identity);

  /// Serializes this GroveLight to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroveLight&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.note, note) || other.note == note)&&(identical(other.swatch, swatch) || other.swatch == swatch)&&(identical(other.filter, filter) || other.filter == filter));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,note,swatch,filter);

@override
String toString() {
  return 'GroveLight(id: $id, name: $name, note: $note, swatch: $swatch, filter: $filter)';
}


}

/// @nodoc
abstract mixin class $GroveLightCopyWith<$Res>  {
  factory $GroveLightCopyWith(GroveLight value, $Res Function(GroveLight) _then) = _$GroveLightCopyWithImpl;
@useResult
$Res call({
 String id, String name, String note, String swatch, String filter
});




}
/// @nodoc
class _$GroveLightCopyWithImpl<$Res>
    implements $GroveLightCopyWith<$Res> {
  _$GroveLightCopyWithImpl(this._self, this._then);

  final GroveLight _self;
  final $Res Function(GroveLight) _then;

/// Create a copy of GroveLight
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? note = null,Object? swatch = null,Object? filter = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,swatch: null == swatch ? _self.swatch : swatch // ignore: cast_nullable_to_non_nullable
as String,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GroveLight].
extension GroveLightPatterns on GroveLight {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroveLight value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroveLight() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroveLight value)  $default,){
final _that = this;
switch (_that) {
case _GroveLight():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroveLight value)?  $default,){
final _that = this;
switch (_that) {
case _GroveLight() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String note,  String swatch,  String filter)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroveLight() when $default != null:
return $default(_that.id,_that.name,_that.note,_that.swatch,_that.filter);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String note,  String swatch,  String filter)  $default,) {final _that = this;
switch (_that) {
case _GroveLight():
return $default(_that.id,_that.name,_that.note,_that.swatch,_that.filter);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String note,  String swatch,  String filter)?  $default,) {final _that = this;
switch (_that) {
case _GroveLight() when $default != null:
return $default(_that.id,_that.name,_that.note,_that.swatch,_that.filter);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GroveLight implements GroveLight {
  const _GroveLight({required this.id, required this.name, required this.note, required this.swatch, required this.filter});
  factory _GroveLight.fromJson(Map<String, dynamic> json) => _$GroveLightFromJson(json);

@override final  String id;
@override final  String name;
/// The one-line mood, e.g. `Late sun`.
@override final  String note;
/// Swatch colour for the picker pill, as a CSS hex string.
@override final  String swatch;
/// The filter chain applied over the plant, empty for the unfiltered
/// default. Composed with the variety's leaf tone into one treatment.
@override final  String filter;

/// Create a copy of GroveLight
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroveLightCopyWith<_GroveLight> get copyWith => __$GroveLightCopyWithImpl<_GroveLight>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GroveLightToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroveLight&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.note, note) || other.note == note)&&(identical(other.swatch, swatch) || other.swatch == swatch)&&(identical(other.filter, filter) || other.filter == filter));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,note,swatch,filter);

@override
String toString() {
  return 'GroveLight(id: $id, name: $name, note: $note, swatch: $swatch, filter: $filter)';
}


}

/// @nodoc
abstract mixin class _$GroveLightCopyWith<$Res> implements $GroveLightCopyWith<$Res> {
  factory _$GroveLightCopyWith(_GroveLight value, $Res Function(_GroveLight) _then) = __$GroveLightCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String note, String swatch, String filter
});




}
/// @nodoc
class __$GroveLightCopyWithImpl<$Res>
    implements _$GroveLightCopyWith<$Res> {
  __$GroveLightCopyWithImpl(this._self, this._then);

  final _GroveLight _self;
  final $Res Function(_GroveLight) _then;

/// Create a copy of GroveLight
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? note = null,Object? swatch = null,Object? filter = null,}) {
  return _then(_GroveLight(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,swatch: null == swatch ? _self.swatch : swatch // ignore: cast_nullable_to_non_nullable
as String,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
