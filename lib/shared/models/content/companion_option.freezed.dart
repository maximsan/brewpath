// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'companion_option.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CompanionOption {

 String get id; String get label;/// Swatch colour for the picker chip, as a CSS hex string. Only the roast
/// axis carries one — a hat is shown by its drawing, not by a colour.
 String? get swatch;
/// Create a copy of CompanionOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompanionOptionCopyWith<CompanionOption> get copyWith => _$CompanionOptionCopyWithImpl<CompanionOption>(this as CompanionOption, _$identity);

  /// Serializes this CompanionOption to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompanionOption&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.swatch, swatch) || other.swatch == swatch));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,swatch);

@override
String toString() {
  return 'CompanionOption(id: $id, label: $label, swatch: $swatch)';
}


}

/// @nodoc
abstract mixin class $CompanionOptionCopyWith<$Res>  {
  factory $CompanionOptionCopyWith(CompanionOption value, $Res Function(CompanionOption) _then) = _$CompanionOptionCopyWithImpl;
@useResult
$Res call({
 String id, String label, String? swatch
});




}
/// @nodoc
class _$CompanionOptionCopyWithImpl<$Res>
    implements $CompanionOptionCopyWith<$Res> {
  _$CompanionOptionCopyWithImpl(this._self, this._then);

  final CompanionOption _self;
  final $Res Function(CompanionOption) _then;

/// Create a copy of CompanionOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? swatch = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,swatch: freezed == swatch ? _self.swatch : swatch // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CompanionOption].
extension CompanionOptionPatterns on CompanionOption {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompanionOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompanionOption() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompanionOption value)  $default,){
final _that = this;
switch (_that) {
case _CompanionOption():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompanionOption value)?  $default,){
final _that = this;
switch (_that) {
case _CompanionOption() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  String? swatch)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompanionOption() when $default != null:
return $default(_that.id,_that.label,_that.swatch);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  String? swatch)  $default,) {final _that = this;
switch (_that) {
case _CompanionOption():
return $default(_that.id,_that.label,_that.swatch);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  String? swatch)?  $default,) {final _that = this;
switch (_that) {
case _CompanionOption() when $default != null:
return $default(_that.id,_that.label,_that.swatch);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CompanionOption implements CompanionOption {
  const _CompanionOption({required this.id, required this.label, this.swatch});
  factory _CompanionOption.fromJson(Map<String, dynamic> json) => _$CompanionOptionFromJson(json);

@override final  String id;
@override final  String label;
/// Swatch colour for the picker chip, as a CSS hex string. Only the roast
/// axis carries one — a hat is shown by its drawing, not by a colour.
@override final  String? swatch;

/// Create a copy of CompanionOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompanionOptionCopyWith<_CompanionOption> get copyWith => __$CompanionOptionCopyWithImpl<_CompanionOption>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CompanionOptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompanionOption&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.swatch, swatch) || other.swatch == swatch));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,swatch);

@override
String toString() {
  return 'CompanionOption(id: $id, label: $label, swatch: $swatch)';
}


}

/// @nodoc
abstract mixin class _$CompanionOptionCopyWith<$Res> implements $CompanionOptionCopyWith<$Res> {
  factory _$CompanionOptionCopyWith(_CompanionOption value, $Res Function(_CompanionOption) _then) = __$CompanionOptionCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, String? swatch
});




}
/// @nodoc
class __$CompanionOptionCopyWithImpl<$Res>
    implements _$CompanionOptionCopyWith<$Res> {
  __$CompanionOptionCopyWithImpl(this._self, this._then);

  final _CompanionOption _self;
  final $Res Function(_CompanionOption) _then;

/// Create a copy of CompanionOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? swatch = freezed,}) {
  return _then(_CompanionOption(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,swatch: freezed == swatch ? _self.swatch : swatch // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
