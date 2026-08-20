// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'coffee_card_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CoffeeCardModel {

 String get id;/// From the source reward.
 String get title;/// From the source reward's summary.
 String get description;/// The keepsake line the reward carries under its summary.
 String get fact;/// The owning module's short name — what the Cards screen groups by.
 String get moduleTag;/// The glyph name to draw, resolved by `moduleIcon`.
 String get iconName;/// The lesson that awards this card, or null when a module does.
 String? get lessonId;/// The module that awards this card, or null when a lesson does.
 String? get moduleId;
/// Create a copy of CoffeeCardModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoffeeCardModelCopyWith<CoffeeCardModel> get copyWith => _$CoffeeCardModelCopyWithImpl<CoffeeCardModel>(this as CoffeeCardModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoffeeCardModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.fact, fact) || other.fact == fact)&&(identical(other.moduleTag, moduleTag) || other.moduleTag == moduleTag)&&(identical(other.iconName, iconName) || other.iconName == iconName)&&(identical(other.lessonId, lessonId) || other.lessonId == lessonId)&&(identical(other.moduleId, moduleId) || other.moduleId == moduleId));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,description,fact,moduleTag,iconName,lessonId,moduleId);

@override
String toString() {
  return 'CoffeeCardModel(id: $id, title: $title, description: $description, fact: $fact, moduleTag: $moduleTag, iconName: $iconName, lessonId: $lessonId, moduleId: $moduleId)';
}


}

/// @nodoc
abstract mixin class $CoffeeCardModelCopyWith<$Res>  {
  factory $CoffeeCardModelCopyWith(CoffeeCardModel value, $Res Function(CoffeeCardModel) _then) = _$CoffeeCardModelCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, String fact, String moduleTag, String iconName, String? lessonId, String? moduleId
});




}
/// @nodoc
class _$CoffeeCardModelCopyWithImpl<$Res>
    implements $CoffeeCardModelCopyWith<$Res> {
  _$CoffeeCardModelCopyWithImpl(this._self, this._then);

  final CoffeeCardModel _self;
  final $Res Function(CoffeeCardModel) _then;

/// Create a copy of CoffeeCardModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? fact = null,Object? moduleTag = null,Object? iconName = null,Object? lessonId = freezed,Object? moduleId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,fact: null == fact ? _self.fact : fact // ignore: cast_nullable_to_non_nullable
as String,moduleTag: null == moduleTag ? _self.moduleTag : moduleTag // ignore: cast_nullable_to_non_nullable
as String,iconName: null == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String,lessonId: freezed == lessonId ? _self.lessonId : lessonId // ignore: cast_nullable_to_non_nullable
as String?,moduleId: freezed == moduleId ? _self.moduleId : moduleId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CoffeeCardModel].
extension CoffeeCardModelPatterns on CoffeeCardModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoffeeCardModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoffeeCardModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoffeeCardModel value)  $default,){
final _that = this;
switch (_that) {
case _CoffeeCardModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoffeeCardModel value)?  $default,){
final _that = this;
switch (_that) {
case _CoffeeCardModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String fact,  String moduleTag,  String iconName,  String? lessonId,  String? moduleId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoffeeCardModel() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.fact,_that.moduleTag,_that.iconName,_that.lessonId,_that.moduleId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String fact,  String moduleTag,  String iconName,  String? lessonId,  String? moduleId)  $default,) {final _that = this;
switch (_that) {
case _CoffeeCardModel():
return $default(_that.id,_that.title,_that.description,_that.fact,_that.moduleTag,_that.iconName,_that.lessonId,_that.moduleId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  String fact,  String moduleTag,  String iconName,  String? lessonId,  String? moduleId)?  $default,) {final _that = this;
switch (_that) {
case _CoffeeCardModel() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.fact,_that.moduleTag,_that.iconName,_that.lessonId,_that.moduleId);case _:
  return null;

}
}

}

/// @nodoc


class _CoffeeCardModel implements CoffeeCardModel {
  const _CoffeeCardModel({required this.id, required this.title, required this.description, required this.fact, required this.moduleTag, required this.iconName, this.lessonId, this.moduleId});
  

@override final  String id;
/// From the source reward.
@override final  String title;
/// From the source reward's summary.
@override final  String description;
/// The keepsake line the reward carries under its summary.
@override final  String fact;
/// The owning module's short name — what the Cards screen groups by.
@override final  String moduleTag;
/// The glyph name to draw, resolved by `moduleIcon`.
@override final  String iconName;
/// The lesson that awards this card, or null when a module does.
@override final  String? lessonId;
/// The module that awards this card, or null when a lesson does.
@override final  String? moduleId;

/// Create a copy of CoffeeCardModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoffeeCardModelCopyWith<_CoffeeCardModel> get copyWith => __$CoffeeCardModelCopyWithImpl<_CoffeeCardModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoffeeCardModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.fact, fact) || other.fact == fact)&&(identical(other.moduleTag, moduleTag) || other.moduleTag == moduleTag)&&(identical(other.iconName, iconName) || other.iconName == iconName)&&(identical(other.lessonId, lessonId) || other.lessonId == lessonId)&&(identical(other.moduleId, moduleId) || other.moduleId == moduleId));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,description,fact,moduleTag,iconName,lessonId,moduleId);

@override
String toString() {
  return 'CoffeeCardModel(id: $id, title: $title, description: $description, fact: $fact, moduleTag: $moduleTag, iconName: $iconName, lessonId: $lessonId, moduleId: $moduleId)';
}


}

/// @nodoc
abstract mixin class _$CoffeeCardModelCopyWith<$Res> implements $CoffeeCardModelCopyWith<$Res> {
  factory _$CoffeeCardModelCopyWith(_CoffeeCardModel value, $Res Function(_CoffeeCardModel) _then) = __$CoffeeCardModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, String fact, String moduleTag, String iconName, String? lessonId, String? moduleId
});




}
/// @nodoc
class __$CoffeeCardModelCopyWithImpl<$Res>
    implements _$CoffeeCardModelCopyWith<$Res> {
  __$CoffeeCardModelCopyWithImpl(this._self, this._then);

  final _CoffeeCardModel _self;
  final $Res Function(_CoffeeCardModel) _then;

/// Create a copy of CoffeeCardModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? fact = null,Object? moduleTag = null,Object? iconName = null,Object? lessonId = freezed,Object? moduleId = freezed,}) {
  return _then(_CoffeeCardModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,fact: null == fact ? _self.fact : fact // ignore: cast_nullable_to_non_nullable
as String,moduleTag: null == moduleTag ? _self.moduleTag : moduleTag // ignore: cast_nullable_to_non_nullable
as String,iconName: null == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String,lessonId: freezed == lessonId ? _self.lessonId : lessonId // ignore: cast_nullable_to_non_nullable
as String?,moduleId: freezed == moduleId ? _self.moduleId : moduleId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
