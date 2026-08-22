// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dictionary_category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DictionaryCategory {

 String get id; String get label;/// The category's illustration key. Named, not drawn, here — the grid
/// falls back to a generic mark until a drawing for it exists.
 String get glyph;/// One line saying what is inside, shown under the label on the grid.
@JsonKey(name: 'short') String get summary;
/// Create a copy of DictionaryCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DictionaryCategoryCopyWith<DictionaryCategory> get copyWith => _$DictionaryCategoryCopyWithImpl<DictionaryCategory>(this as DictionaryCategory, _$identity);

  /// Serializes this DictionaryCategory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DictionaryCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.glyph, glyph) || other.glyph == glyph)&&(identical(other.summary, summary) || other.summary == summary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,glyph,summary);

@override
String toString() {
  return 'DictionaryCategory(id: $id, label: $label, glyph: $glyph, summary: $summary)';
}


}

/// @nodoc
abstract mixin class $DictionaryCategoryCopyWith<$Res>  {
  factory $DictionaryCategoryCopyWith(DictionaryCategory value, $Res Function(DictionaryCategory) _then) = _$DictionaryCategoryCopyWithImpl;
@useResult
$Res call({
 String id, String label, String glyph,@JsonKey(name: 'short') String summary
});




}
/// @nodoc
class _$DictionaryCategoryCopyWithImpl<$Res>
    implements $DictionaryCategoryCopyWith<$Res> {
  _$DictionaryCategoryCopyWithImpl(this._self, this._then);

  final DictionaryCategory _self;
  final $Res Function(DictionaryCategory) _then;

/// Create a copy of DictionaryCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? glyph = null,Object? summary = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,glyph: null == glyph ? _self.glyph : glyph // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DictionaryCategory].
extension DictionaryCategoryPatterns on DictionaryCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DictionaryCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DictionaryCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DictionaryCategory value)  $default,){
final _that = this;
switch (_that) {
case _DictionaryCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DictionaryCategory value)?  $default,){
final _that = this;
switch (_that) {
case _DictionaryCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  String glyph, @JsonKey(name: 'short')  String summary)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DictionaryCategory() when $default != null:
return $default(_that.id,_that.label,_that.glyph,_that.summary);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  String glyph, @JsonKey(name: 'short')  String summary)  $default,) {final _that = this;
switch (_that) {
case _DictionaryCategory():
return $default(_that.id,_that.label,_that.glyph,_that.summary);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  String glyph, @JsonKey(name: 'short')  String summary)?  $default,) {final _that = this;
switch (_that) {
case _DictionaryCategory() when $default != null:
return $default(_that.id,_that.label,_that.glyph,_that.summary);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DictionaryCategory implements DictionaryCategory {
  const _DictionaryCategory({required this.id, required this.label, required this.glyph, @JsonKey(name: 'short') required this.summary});
  factory _DictionaryCategory.fromJson(Map<String, dynamic> json) => _$DictionaryCategoryFromJson(json);

@override final  String id;
@override final  String label;
/// The category's illustration key. Named, not drawn, here — the grid
/// falls back to a generic mark until a drawing for it exists.
@override final  String glyph;
/// One line saying what is inside, shown under the label on the grid.
@override@JsonKey(name: 'short') final  String summary;

/// Create a copy of DictionaryCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DictionaryCategoryCopyWith<_DictionaryCategory> get copyWith => __$DictionaryCategoryCopyWithImpl<_DictionaryCategory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DictionaryCategoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DictionaryCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.glyph, glyph) || other.glyph == glyph)&&(identical(other.summary, summary) || other.summary == summary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,glyph,summary);

@override
String toString() {
  return 'DictionaryCategory(id: $id, label: $label, glyph: $glyph, summary: $summary)';
}


}

/// @nodoc
abstract mixin class _$DictionaryCategoryCopyWith<$Res> implements $DictionaryCategoryCopyWith<$Res> {
  factory _$DictionaryCategoryCopyWith(_DictionaryCategory value, $Res Function(_DictionaryCategory) _then) = __$DictionaryCategoryCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, String glyph,@JsonKey(name: 'short') String summary
});




}
/// @nodoc
class __$DictionaryCategoryCopyWithImpl<$Res>
    implements _$DictionaryCategoryCopyWith<$Res> {
  __$DictionaryCategoryCopyWithImpl(this._self, this._then);

  final _DictionaryCategory _self;
  final $Res Function(_DictionaryCategory) _then;

/// Create a copy of DictionaryCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? glyph = null,Object? summary = null,}) {
  return _then(_DictionaryCategory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,glyph: null == glyph ? _self.glyph : glyph // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
