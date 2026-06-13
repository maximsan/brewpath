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

 String get id; String get title; String get description; String get moduleTag; String get iconName; String get lessonId;
/// Create a copy of CoffeeCardModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoffeeCardModelCopyWith<CoffeeCardModel> get copyWith => _$CoffeeCardModelCopyWithImpl<CoffeeCardModel>(this as CoffeeCardModel, _$identity);

  /// Serializes this CoffeeCardModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoffeeCardModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.moduleTag, moduleTag) || other.moduleTag == moduleTag)&&(identical(other.iconName, iconName) || other.iconName == iconName)&&(identical(other.lessonId, lessonId) || other.lessonId == lessonId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,moduleTag,iconName,lessonId);

@override
String toString() {
  return 'CoffeeCardModel(id: $id, title: $title, description: $description, moduleTag: $moduleTag, iconName: $iconName, lessonId: $lessonId)';
}


}

/// @nodoc
abstract mixin class $CoffeeCardModelCopyWith<$Res>  {
  factory $CoffeeCardModelCopyWith(CoffeeCardModel value, $Res Function(CoffeeCardModel) _then) = _$CoffeeCardModelCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, String moduleTag, String iconName, String lessonId
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? moduleTag = null,Object? iconName = null,Object? lessonId = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,moduleTag: null == moduleTag ? _self.moduleTag : moduleTag // ignore: cast_nullable_to_non_nullable
as String,iconName: null == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String,lessonId: null == lessonId ? _self.lessonId : lessonId // ignore: cast_nullable_to_non_nullable
as String,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String moduleTag,  String iconName,  String lessonId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoffeeCardModel() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.moduleTag,_that.iconName,_that.lessonId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String moduleTag,  String iconName,  String lessonId)  $default,) {final _that = this;
switch (_that) {
case _CoffeeCardModel():
return $default(_that.id,_that.title,_that.description,_that.moduleTag,_that.iconName,_that.lessonId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  String moduleTag,  String iconName,  String lessonId)?  $default,) {final _that = this;
switch (_that) {
case _CoffeeCardModel() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.moduleTag,_that.iconName,_that.lessonId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CoffeeCardModel implements CoffeeCardModel {
  const _CoffeeCardModel({required this.id, required this.title, required this.description, required this.moduleTag, required this.iconName, required this.lessonId});
  factory _CoffeeCardModel.fromJson(Map<String, dynamic> json) => _$CoffeeCardModelFromJson(json);

@override final  String id;
@override final  String title;
@override final  String description;
@override final  String moduleTag;
@override final  String iconName;
@override final  String lessonId;

/// Create a copy of CoffeeCardModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoffeeCardModelCopyWith<_CoffeeCardModel> get copyWith => __$CoffeeCardModelCopyWithImpl<_CoffeeCardModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CoffeeCardModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoffeeCardModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.moduleTag, moduleTag) || other.moduleTag == moduleTag)&&(identical(other.iconName, iconName) || other.iconName == iconName)&&(identical(other.lessonId, lessonId) || other.lessonId == lessonId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,moduleTag,iconName,lessonId);

@override
String toString() {
  return 'CoffeeCardModel(id: $id, title: $title, description: $description, moduleTag: $moduleTag, iconName: $iconName, lessonId: $lessonId)';
}


}

/// @nodoc
abstract mixin class _$CoffeeCardModelCopyWith<$Res> implements $CoffeeCardModelCopyWith<$Res> {
  factory _$CoffeeCardModelCopyWith(_CoffeeCardModel value, $Res Function(_CoffeeCardModel) _then) = __$CoffeeCardModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, String moduleTag, String iconName, String lessonId
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? moduleTag = null,Object? iconName = null,Object? lessonId = null,}) {
  return _then(_CoffeeCardModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,moduleTag: null == moduleTag ? _self.moduleTag : moduleTag // ignore: cast_nullable_to_non_nullable
as String,iconName: null == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String,lessonId: null == lessonId ? _self.lessonId : lessonId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
