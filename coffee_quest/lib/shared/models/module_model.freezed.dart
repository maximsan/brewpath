// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'module_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ModuleModel {

 String get id; String get title; String get description; String get iconName; List<String> get lessonIds; String? get unlockRequirement;
/// Create a copy of ModuleModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModuleModelCopyWith<ModuleModel> get copyWith => _$ModuleModelCopyWithImpl<ModuleModel>(this as ModuleModel, _$identity);

  /// Serializes this ModuleModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModuleModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.iconName, iconName) || other.iconName == iconName)&&const DeepCollectionEquality().equals(other.lessonIds, lessonIds)&&(identical(other.unlockRequirement, unlockRequirement) || other.unlockRequirement == unlockRequirement));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,iconName,const DeepCollectionEquality().hash(lessonIds),unlockRequirement);

@override
String toString() {
  return 'ModuleModel(id: $id, title: $title, description: $description, iconName: $iconName, lessonIds: $lessonIds, unlockRequirement: $unlockRequirement)';
}


}

/// @nodoc
abstract mixin class $ModuleModelCopyWith<$Res>  {
  factory $ModuleModelCopyWith(ModuleModel value, $Res Function(ModuleModel) _then) = _$ModuleModelCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, String iconName, List<String> lessonIds, String? unlockRequirement
});




}
/// @nodoc
class _$ModuleModelCopyWithImpl<$Res>
    implements $ModuleModelCopyWith<$Res> {
  _$ModuleModelCopyWithImpl(this._self, this._then);

  final ModuleModel _self;
  final $Res Function(ModuleModel) _then;

/// Create a copy of ModuleModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? iconName = null,Object? lessonIds = null,Object? unlockRequirement = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,iconName: null == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String,lessonIds: null == lessonIds ? _self.lessonIds : lessonIds // ignore: cast_nullable_to_non_nullable
as List<String>,unlockRequirement: freezed == unlockRequirement ? _self.unlockRequirement : unlockRequirement // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ModuleModel].
extension ModuleModelPatterns on ModuleModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModuleModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModuleModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModuleModel value)  $default,){
final _that = this;
switch (_that) {
case _ModuleModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModuleModel value)?  $default,){
final _that = this;
switch (_that) {
case _ModuleModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String iconName,  List<String> lessonIds,  String? unlockRequirement)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModuleModel() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.iconName,_that.lessonIds,_that.unlockRequirement);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String iconName,  List<String> lessonIds,  String? unlockRequirement)  $default,) {final _that = this;
switch (_that) {
case _ModuleModel():
return $default(_that.id,_that.title,_that.description,_that.iconName,_that.lessonIds,_that.unlockRequirement);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  String iconName,  List<String> lessonIds,  String? unlockRequirement)?  $default,) {final _that = this;
switch (_that) {
case _ModuleModel() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.iconName,_that.lessonIds,_that.unlockRequirement);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ModuleModel implements ModuleModel {
  const _ModuleModel({required this.id, required this.title, required this.description, required this.iconName, required final  List<String> lessonIds, this.unlockRequirement}): _lessonIds = lessonIds;
  factory _ModuleModel.fromJson(Map<String, dynamic> json) => _$ModuleModelFromJson(json);

@override final  String id;
@override final  String title;
@override final  String description;
@override final  String iconName;
 final  List<String> _lessonIds;
@override List<String> get lessonIds {
  if (_lessonIds is EqualUnmodifiableListView) return _lessonIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lessonIds);
}

@override final  String? unlockRequirement;

/// Create a copy of ModuleModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModuleModelCopyWith<_ModuleModel> get copyWith => __$ModuleModelCopyWithImpl<_ModuleModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ModuleModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModuleModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.iconName, iconName) || other.iconName == iconName)&&const DeepCollectionEquality().equals(other._lessonIds, _lessonIds)&&(identical(other.unlockRequirement, unlockRequirement) || other.unlockRequirement == unlockRequirement));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,iconName,const DeepCollectionEquality().hash(_lessonIds),unlockRequirement);

@override
String toString() {
  return 'ModuleModel(id: $id, title: $title, description: $description, iconName: $iconName, lessonIds: $lessonIds, unlockRequirement: $unlockRequirement)';
}


}

/// @nodoc
abstract mixin class _$ModuleModelCopyWith<$Res> implements $ModuleModelCopyWith<$Res> {
  factory _$ModuleModelCopyWith(_ModuleModel value, $Res Function(_ModuleModel) _then) = __$ModuleModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, String iconName, List<String> lessonIds, String? unlockRequirement
});




}
/// @nodoc
class __$ModuleModelCopyWithImpl<$Res>
    implements _$ModuleModelCopyWith<$Res> {
  __$ModuleModelCopyWithImpl(this._self, this._then);

  final _ModuleModel _self;
  final $Res Function(_ModuleModel) _then;

/// Create a copy of ModuleModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? iconName = null,Object? lessonIds = null,Object? unlockRequirement = freezed,}) {
  return _then(_ModuleModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,iconName: null == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String,lessonIds: null == lessonIds ? _self._lessonIds : lessonIds // ignore: cast_nullable_to_non_nullable
as List<String>,unlockRequirement: freezed == unlockRequirement ? _self.unlockRequirement : unlockRequirement // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
