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
mixin _$ModuleLesson {

 String get id; String get title; int get points; int get time;
/// Create a copy of ModuleLesson
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModuleLessonCopyWith<ModuleLesson> get copyWith => _$ModuleLessonCopyWithImpl<ModuleLesson>(this as ModuleLesson, _$identity);

  /// Serializes this ModuleLesson to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModuleLesson&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.points, points) || other.points == points)&&(identical(other.time, time) || other.time == time));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,points,time);

@override
String toString() {
  return 'ModuleLesson(id: $id, title: $title, points: $points, time: $time)';
}


}

/// @nodoc
abstract mixin class $ModuleLessonCopyWith<$Res>  {
  factory $ModuleLessonCopyWith(ModuleLesson value, $Res Function(ModuleLesson) _then) = _$ModuleLessonCopyWithImpl;
@useResult
$Res call({
 String id, String title, int points, int time
});




}
/// @nodoc
class _$ModuleLessonCopyWithImpl<$Res>
    implements $ModuleLessonCopyWith<$Res> {
  _$ModuleLessonCopyWithImpl(this._self, this._then);

  final ModuleLesson _self;
  final $Res Function(ModuleLesson) _then;

/// Create a copy of ModuleLesson
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? points = null,Object? time = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ModuleLesson].
extension ModuleLessonPatterns on ModuleLesson {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModuleLesson value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModuleLesson() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModuleLesson value)  $default,){
final _that = this;
switch (_that) {
case _ModuleLesson():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModuleLesson value)?  $default,){
final _that = this;
switch (_that) {
case _ModuleLesson() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  int points,  int time)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModuleLesson() when $default != null:
return $default(_that.id,_that.title,_that.points,_that.time);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  int points,  int time)  $default,) {final _that = this;
switch (_that) {
case _ModuleLesson():
return $default(_that.id,_that.title,_that.points,_that.time);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  int points,  int time)?  $default,) {final _that = this;
switch (_that) {
case _ModuleLesson() when $default != null:
return $default(_that.id,_that.title,_that.points,_that.time);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ModuleLesson implements ModuleLesson {
  const _ModuleLesson({required this.id, required this.title, required this.points, required this.time});
  factory _ModuleLesson.fromJson(Map<String, dynamic> json) => _$ModuleLessonFromJson(json);

@override final  String id;
@override final  String title;
@override final  int points;
@override final  int time;

/// Create a copy of ModuleLesson
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModuleLessonCopyWith<_ModuleLesson> get copyWith => __$ModuleLessonCopyWithImpl<_ModuleLesson>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ModuleLessonToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModuleLesson&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.points, points) || other.points == points)&&(identical(other.time, time) || other.time == time));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,points,time);

@override
String toString() {
  return 'ModuleLesson(id: $id, title: $title, points: $points, time: $time)';
}


}

/// @nodoc
abstract mixin class _$ModuleLessonCopyWith<$Res> implements $ModuleLessonCopyWith<$Res> {
  factory _$ModuleLessonCopyWith(_ModuleLesson value, $Res Function(_ModuleLesson) _then) = __$ModuleLessonCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, int points, int time
});




}
/// @nodoc
class __$ModuleLessonCopyWithImpl<$Res>
    implements _$ModuleLessonCopyWith<$Res> {
  __$ModuleLessonCopyWithImpl(this._self, this._then);

  final _ModuleLesson _self;
  final $Res Function(_ModuleLesson) _then;

/// Create a copy of ModuleLesson
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? points = null,Object? time = null,}) {
  return _then(_ModuleLesson(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ModuleModel {

 String get id;/// The module's position in the course, 1-based. The unlock rule reads
/// this: module *n* opens when module *n − 1* is complete.
 int get n;/// The eyebrow the design prints above a lesson — `MODULE 1 · BEANS`.
 String get label;/// The module's glyph name, resolved to an icon by `moduleIcon`.
@JsonKey(name: 'glyph') String get iconName; String get title; List<ModuleLesson> get lessons; ContentReward get reward;/// The module's picture, by the path the bank names — the same path the
/// design loads, so the file is bundled under that name verbatim. Null for
/// a module the design has not illustrated.
 String? get art;/// Where the picture is anchored when a frame crops it: CSS
/// `object-position`, as in `50% 42%`. Read by `alignmentFromObjectPosition`.
 String? get artPos;
/// Create a copy of ModuleModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModuleModelCopyWith<ModuleModel> get copyWith => _$ModuleModelCopyWithImpl<ModuleModel>(this as ModuleModel, _$identity);

  /// Serializes this ModuleModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModuleModel&&(identical(other.id, id) || other.id == id)&&(identical(other.n, n) || other.n == n)&&(identical(other.label, label) || other.label == label)&&(identical(other.iconName, iconName) || other.iconName == iconName)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.lessons, lessons)&&(identical(other.reward, reward) || other.reward == reward)&&(identical(other.art, art) || other.art == art)&&(identical(other.artPos, artPos) || other.artPos == artPos));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,n,label,iconName,title,const DeepCollectionEquality().hash(lessons),reward,art,artPos);

@override
String toString() {
  return 'ModuleModel(id: $id, n: $n, label: $label, iconName: $iconName, title: $title, lessons: $lessons, reward: $reward, art: $art, artPos: $artPos)';
}


}

/// @nodoc
abstract mixin class $ModuleModelCopyWith<$Res>  {
  factory $ModuleModelCopyWith(ModuleModel value, $Res Function(ModuleModel) _then) = _$ModuleModelCopyWithImpl;
@useResult
$Res call({
 String id, int n, String label,@JsonKey(name: 'glyph') String iconName, String title, List<ModuleLesson> lessons, ContentReward reward, String? art, String? artPos
});


$ContentRewardCopyWith<$Res> get reward;

}
/// @nodoc
class _$ModuleModelCopyWithImpl<$Res>
    implements $ModuleModelCopyWith<$Res> {
  _$ModuleModelCopyWithImpl(this._self, this._then);

  final ModuleModel _self;
  final $Res Function(ModuleModel) _then;

/// Create a copy of ModuleModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? n = null,Object? label = null,Object? iconName = null,Object? title = null,Object? lessons = null,Object? reward = null,Object? art = freezed,Object? artPos = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,n: null == n ? _self.n : n // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,iconName: null == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,lessons: null == lessons ? _self.lessons : lessons // ignore: cast_nullable_to_non_nullable
as List<ModuleLesson>,reward: null == reward ? _self.reward : reward // ignore: cast_nullable_to_non_nullable
as ContentReward,art: freezed == art ? _self.art : art // ignore: cast_nullable_to_non_nullable
as String?,artPos: freezed == artPos ? _self.artPos : artPos // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ModuleModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContentRewardCopyWith<$Res> get reward {
  
  return $ContentRewardCopyWith<$Res>(_self.reward, (value) {
    return _then(_self.copyWith(reward: value));
  });
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int n,  String label, @JsonKey(name: 'glyph')  String iconName,  String title,  List<ModuleLesson> lessons,  ContentReward reward,  String? art,  String? artPos)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModuleModel() when $default != null:
return $default(_that.id,_that.n,_that.label,_that.iconName,_that.title,_that.lessons,_that.reward,_that.art,_that.artPos);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int n,  String label, @JsonKey(name: 'glyph')  String iconName,  String title,  List<ModuleLesson> lessons,  ContentReward reward,  String? art,  String? artPos)  $default,) {final _that = this;
switch (_that) {
case _ModuleModel():
return $default(_that.id,_that.n,_that.label,_that.iconName,_that.title,_that.lessons,_that.reward,_that.art,_that.artPos);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int n,  String label, @JsonKey(name: 'glyph')  String iconName,  String title,  List<ModuleLesson> lessons,  ContentReward reward,  String? art,  String? artPos)?  $default,) {final _that = this;
switch (_that) {
case _ModuleModel() when $default != null:
return $default(_that.id,_that.n,_that.label,_that.iconName,_that.title,_that.lessons,_that.reward,_that.art,_that.artPos);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ModuleModel extends ModuleModel {
  const _ModuleModel({required this.id, required this.n, required this.label, @JsonKey(name: 'glyph') required this.iconName, required this.title, required final  List<ModuleLesson> lessons, required this.reward, this.art, this.artPos}): _lessons = lessons,super._();
  factory _ModuleModel.fromJson(Map<String, dynamic> json) => _$ModuleModelFromJson(json);

@override final  String id;
/// The module's position in the course, 1-based. The unlock rule reads
/// this: module *n* opens when module *n − 1* is complete.
@override final  int n;
/// The eyebrow the design prints above a lesson — `MODULE 1 · BEANS`.
@override final  String label;
/// The module's glyph name, resolved to an icon by `moduleIcon`.
@override@JsonKey(name: 'glyph') final  String iconName;
@override final  String title;
 final  List<ModuleLesson> _lessons;
@override List<ModuleLesson> get lessons {
  if (_lessons is EqualUnmodifiableListView) return _lessons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lessons);
}

@override final  ContentReward reward;
/// The module's picture, by the path the bank names — the same path the
/// design loads, so the file is bundled under that name verbatim. Null for
/// a module the design has not illustrated.
@override final  String? art;
/// Where the picture is anchored when a frame crops it: CSS
/// `object-position`, as in `50% 42%`. Read by `alignmentFromObjectPosition`.
@override final  String? artPos;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModuleModel&&(identical(other.id, id) || other.id == id)&&(identical(other.n, n) || other.n == n)&&(identical(other.label, label) || other.label == label)&&(identical(other.iconName, iconName) || other.iconName == iconName)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._lessons, _lessons)&&(identical(other.reward, reward) || other.reward == reward)&&(identical(other.art, art) || other.art == art)&&(identical(other.artPos, artPos) || other.artPos == artPos));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,n,label,iconName,title,const DeepCollectionEquality().hash(_lessons),reward,art,artPos);

@override
String toString() {
  return 'ModuleModel(id: $id, n: $n, label: $label, iconName: $iconName, title: $title, lessons: $lessons, reward: $reward, art: $art, artPos: $artPos)';
}


}

/// @nodoc
abstract mixin class _$ModuleModelCopyWith<$Res> implements $ModuleModelCopyWith<$Res> {
  factory _$ModuleModelCopyWith(_ModuleModel value, $Res Function(_ModuleModel) _then) = __$ModuleModelCopyWithImpl;
@override @useResult
$Res call({
 String id, int n, String label,@JsonKey(name: 'glyph') String iconName, String title, List<ModuleLesson> lessons, ContentReward reward, String? art, String? artPos
});


@override $ContentRewardCopyWith<$Res> get reward;

}
/// @nodoc
class __$ModuleModelCopyWithImpl<$Res>
    implements _$ModuleModelCopyWith<$Res> {
  __$ModuleModelCopyWithImpl(this._self, this._then);

  final _ModuleModel _self;
  final $Res Function(_ModuleModel) _then;

/// Create a copy of ModuleModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? n = null,Object? label = null,Object? iconName = null,Object? title = null,Object? lessons = null,Object? reward = null,Object? art = freezed,Object? artPos = freezed,}) {
  return _then(_ModuleModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,n: null == n ? _self.n : n // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,iconName: null == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,lessons: null == lessons ? _self._lessons : lessons // ignore: cast_nullable_to_non_nullable
as List<ModuleLesson>,reward: null == reward ? _self.reward : reward // ignore: cast_nullable_to_non_nullable
as ContentReward,art: freezed == art ? _self.art : art // ignore: cast_nullable_to_non_nullable
as String?,artPos: freezed == artPos ? _self.artPos : artPos // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ModuleModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContentRewardCopyWith<$Res> get reward {
  
  return $ContentRewardCopyWith<$Res>(_self.reward, (value) {
    return _then(_self.copyWith(reward: value));
  });
}
}

// dart format on
