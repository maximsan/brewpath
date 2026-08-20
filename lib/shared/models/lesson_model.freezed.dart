// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lesson_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LessonModel {

 String get id;/// The module that owns this lesson.
///
/// **Injected by the content layer, not authored.** A lesson record carries
/// only [moduleLabel], a display string; ownership lives in the modules
/// bank's own lesson list, so the repository resolves it once on load
/// rather than every reader parsing an id out of a label.
 String get moduleId;/// The eyebrow the design prints above the lesson — `MODULE 1 · BEANS`.
 String get moduleLabel; String get title;/// What finishing this lesson pays, the first time only. Flat and
/// authored — never derived from how many cards the lesson happens to run.
 int get points;/// The lesson's own estimate, in minutes.
 int get time; List<ContentCard> get cards; ContentReward get reward;
/// Create a copy of LessonModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LessonModelCopyWith<LessonModel> get copyWith => _$LessonModelCopyWithImpl<LessonModel>(this as LessonModel, _$identity);

  /// Serializes this LessonModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LessonModel&&(identical(other.id, id) || other.id == id)&&(identical(other.moduleId, moduleId) || other.moduleId == moduleId)&&(identical(other.moduleLabel, moduleLabel) || other.moduleLabel == moduleLabel)&&(identical(other.title, title) || other.title == title)&&(identical(other.points, points) || other.points == points)&&(identical(other.time, time) || other.time == time)&&const DeepCollectionEquality().equals(other.cards, cards)&&(identical(other.reward, reward) || other.reward == reward));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,moduleId,moduleLabel,title,points,time,const DeepCollectionEquality().hash(cards),reward);

@override
String toString() {
  return 'LessonModel(id: $id, moduleId: $moduleId, moduleLabel: $moduleLabel, title: $title, points: $points, time: $time, cards: $cards, reward: $reward)';
}


}

/// @nodoc
abstract mixin class $LessonModelCopyWith<$Res>  {
  factory $LessonModelCopyWith(LessonModel value, $Res Function(LessonModel) _then) = _$LessonModelCopyWithImpl;
@useResult
$Res call({
 String id, String moduleId, String moduleLabel, String title, int points, int time, List<ContentCard> cards, ContentReward reward
});


$ContentRewardCopyWith<$Res> get reward;

}
/// @nodoc
class _$LessonModelCopyWithImpl<$Res>
    implements $LessonModelCopyWith<$Res> {
  _$LessonModelCopyWithImpl(this._self, this._then);

  final LessonModel _self;
  final $Res Function(LessonModel) _then;

/// Create a copy of LessonModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? moduleId = null,Object? moduleLabel = null,Object? title = null,Object? points = null,Object? time = null,Object? cards = null,Object? reward = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,moduleId: null == moduleId ? _self.moduleId : moduleId // ignore: cast_nullable_to_non_nullable
as String,moduleLabel: null == moduleLabel ? _self.moduleLabel : moduleLabel // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as int,cards: null == cards ? _self.cards : cards // ignore: cast_nullable_to_non_nullable
as List<ContentCard>,reward: null == reward ? _self.reward : reward // ignore: cast_nullable_to_non_nullable
as ContentReward,
  ));
}
/// Create a copy of LessonModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContentRewardCopyWith<$Res> get reward {
  
  return $ContentRewardCopyWith<$Res>(_self.reward, (value) {
    return _then(_self.copyWith(reward: value));
  });
}
}


/// Adds pattern-matching-related methods to [LessonModel].
extension LessonModelPatterns on LessonModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LessonModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LessonModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LessonModel value)  $default,){
final _that = this;
switch (_that) {
case _LessonModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LessonModel value)?  $default,){
final _that = this;
switch (_that) {
case _LessonModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String moduleId,  String moduleLabel,  String title,  int points,  int time,  List<ContentCard> cards,  ContentReward reward)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LessonModel() when $default != null:
return $default(_that.id,_that.moduleId,_that.moduleLabel,_that.title,_that.points,_that.time,_that.cards,_that.reward);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String moduleId,  String moduleLabel,  String title,  int points,  int time,  List<ContentCard> cards,  ContentReward reward)  $default,) {final _that = this;
switch (_that) {
case _LessonModel():
return $default(_that.id,_that.moduleId,_that.moduleLabel,_that.title,_that.points,_that.time,_that.cards,_that.reward);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String moduleId,  String moduleLabel,  String title,  int points,  int time,  List<ContentCard> cards,  ContentReward reward)?  $default,) {final _that = this;
switch (_that) {
case _LessonModel() when $default != null:
return $default(_that.id,_that.moduleId,_that.moduleLabel,_that.title,_that.points,_that.time,_that.cards,_that.reward);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LessonModel implements LessonModel {
  const _LessonModel({required this.id, required this.moduleId, required this.moduleLabel, required this.title, required this.points, required this.time, required final  List<ContentCard> cards, required this.reward}): _cards = cards;
  factory _LessonModel.fromJson(Map<String, dynamic> json) => _$LessonModelFromJson(json);

@override final  String id;
/// The module that owns this lesson.
///
/// **Injected by the content layer, not authored.** A lesson record carries
/// only [moduleLabel], a display string; ownership lives in the modules
/// bank's own lesson list, so the repository resolves it once on load
/// rather than every reader parsing an id out of a label.
@override final  String moduleId;
/// The eyebrow the design prints above the lesson — `MODULE 1 · BEANS`.
@override final  String moduleLabel;
@override final  String title;
/// What finishing this lesson pays, the first time only. Flat and
/// authored — never derived from how many cards the lesson happens to run.
@override final  int points;
/// The lesson's own estimate, in minutes.
@override final  int time;
 final  List<ContentCard> _cards;
@override List<ContentCard> get cards {
  if (_cards is EqualUnmodifiableListView) return _cards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cards);
}

@override final  ContentReward reward;

/// Create a copy of LessonModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LessonModelCopyWith<_LessonModel> get copyWith => __$LessonModelCopyWithImpl<_LessonModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LessonModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LessonModel&&(identical(other.id, id) || other.id == id)&&(identical(other.moduleId, moduleId) || other.moduleId == moduleId)&&(identical(other.moduleLabel, moduleLabel) || other.moduleLabel == moduleLabel)&&(identical(other.title, title) || other.title == title)&&(identical(other.points, points) || other.points == points)&&(identical(other.time, time) || other.time == time)&&const DeepCollectionEquality().equals(other._cards, _cards)&&(identical(other.reward, reward) || other.reward == reward));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,moduleId,moduleLabel,title,points,time,const DeepCollectionEquality().hash(_cards),reward);

@override
String toString() {
  return 'LessonModel(id: $id, moduleId: $moduleId, moduleLabel: $moduleLabel, title: $title, points: $points, time: $time, cards: $cards, reward: $reward)';
}


}

/// @nodoc
abstract mixin class _$LessonModelCopyWith<$Res> implements $LessonModelCopyWith<$Res> {
  factory _$LessonModelCopyWith(_LessonModel value, $Res Function(_LessonModel) _then) = __$LessonModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String moduleId, String moduleLabel, String title, int points, int time, List<ContentCard> cards, ContentReward reward
});


@override $ContentRewardCopyWith<$Res> get reward;

}
/// @nodoc
class __$LessonModelCopyWithImpl<$Res>
    implements _$LessonModelCopyWith<$Res> {
  __$LessonModelCopyWithImpl(this._self, this._then);

  final _LessonModel _self;
  final $Res Function(_LessonModel) _then;

/// Create a copy of LessonModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? moduleId = null,Object? moduleLabel = null,Object? title = null,Object? points = null,Object? time = null,Object? cards = null,Object? reward = null,}) {
  return _then(_LessonModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,moduleId: null == moduleId ? _self.moduleId : moduleId // ignore: cast_nullable_to_non_nullable
as String,moduleLabel: null == moduleLabel ? _self.moduleLabel : moduleLabel // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as int,cards: null == cards ? _self._cards : cards // ignore: cast_nullable_to_non_nullable
as List<ContentCard>,reward: null == reward ? _self.reward : reward // ignore: cast_nullable_to_non_nullable
as ContentReward,
  ));
}

/// Create a copy of LessonModel
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
