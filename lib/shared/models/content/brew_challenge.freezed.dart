// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'brew_challenge.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BrewChallenge {

 String get id;@JsonKey(name: 'type') ChallengeScope get scope;/// The module this belongs to — its own, for a capstone; its lesson's, for
/// a lesson challenge.
 String get moduleId;/// The collectible this challenge is stamped onto.
 String get cardId; String get title;/// What to actually go and brew.
 String get instruction;/// When and how long, as one authored string: `'Next brews · 5 min'`.
 String get effort;/// The question the log sheet asks — `'WHICH CUP WON?'`.
 String get prompt;/// The outcomes the learner can report. **Eleven records carry three and
/// one carries two**, so nothing may assume a count.
 List<String> get reactions;/// The lesson this challenge belongs to, or null on a capstone.
///
/// **Authored, never parsed out of [id].** `bc-m4l3` looks like it names a
/// lesson, but lessons have been inserted mid-module before, and an id
/// read as a pointer would then resolve to whatever now sits in that slot.
 String? get lessonId;
/// Create a copy of BrewChallenge
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BrewChallengeCopyWith<BrewChallenge> get copyWith => _$BrewChallengeCopyWithImpl<BrewChallenge>(this as BrewChallenge, _$identity);

  /// Serializes this BrewChallenge to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BrewChallenge&&(identical(other.id, id) || other.id == id)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.moduleId, moduleId) || other.moduleId == moduleId)&&(identical(other.cardId, cardId) || other.cardId == cardId)&&(identical(other.title, title) || other.title == title)&&(identical(other.instruction, instruction) || other.instruction == instruction)&&(identical(other.effort, effort) || other.effort == effort)&&(identical(other.prompt, prompt) || other.prompt == prompt)&&const DeepCollectionEquality().equals(other.reactions, reactions)&&(identical(other.lessonId, lessonId) || other.lessonId == lessonId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,scope,moduleId,cardId,title,instruction,effort,prompt,const DeepCollectionEquality().hash(reactions),lessonId);

@override
String toString() {
  return 'BrewChallenge(id: $id, scope: $scope, moduleId: $moduleId, cardId: $cardId, title: $title, instruction: $instruction, effort: $effort, prompt: $prompt, reactions: $reactions, lessonId: $lessonId)';
}


}

/// @nodoc
abstract mixin class $BrewChallengeCopyWith<$Res>  {
  factory $BrewChallengeCopyWith(BrewChallenge value, $Res Function(BrewChallenge) _then) = _$BrewChallengeCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'type') ChallengeScope scope, String moduleId, String cardId, String title, String instruction, String effort, String prompt, List<String> reactions, String? lessonId
});




}
/// @nodoc
class _$BrewChallengeCopyWithImpl<$Res>
    implements $BrewChallengeCopyWith<$Res> {
  _$BrewChallengeCopyWithImpl(this._self, this._then);

  final BrewChallenge _self;
  final $Res Function(BrewChallenge) _then;

/// Create a copy of BrewChallenge
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? scope = null,Object? moduleId = null,Object? cardId = null,Object? title = null,Object? instruction = null,Object? effort = null,Object? prompt = null,Object? reactions = null,Object? lessonId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as ChallengeScope,moduleId: null == moduleId ? _self.moduleId : moduleId // ignore: cast_nullable_to_non_nullable
as String,cardId: null == cardId ? _self.cardId : cardId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,instruction: null == instruction ? _self.instruction : instruction // ignore: cast_nullable_to_non_nullable
as String,effort: null == effort ? _self.effort : effort // ignore: cast_nullable_to_non_nullable
as String,prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String,reactions: null == reactions ? _self.reactions : reactions // ignore: cast_nullable_to_non_nullable
as List<String>,lessonId: freezed == lessonId ? _self.lessonId : lessonId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BrewChallenge].
extension BrewChallengePatterns on BrewChallenge {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BrewChallenge value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BrewChallenge() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BrewChallenge value)  $default,){
final _that = this;
switch (_that) {
case _BrewChallenge():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BrewChallenge value)?  $default,){
final _that = this;
switch (_that) {
case _BrewChallenge() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'type')  ChallengeScope scope,  String moduleId,  String cardId,  String title,  String instruction,  String effort,  String prompt,  List<String> reactions,  String? lessonId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BrewChallenge() when $default != null:
return $default(_that.id,_that.scope,_that.moduleId,_that.cardId,_that.title,_that.instruction,_that.effort,_that.prompt,_that.reactions,_that.lessonId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'type')  ChallengeScope scope,  String moduleId,  String cardId,  String title,  String instruction,  String effort,  String prompt,  List<String> reactions,  String? lessonId)  $default,) {final _that = this;
switch (_that) {
case _BrewChallenge():
return $default(_that.id,_that.scope,_that.moduleId,_that.cardId,_that.title,_that.instruction,_that.effort,_that.prompt,_that.reactions,_that.lessonId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'type')  ChallengeScope scope,  String moduleId,  String cardId,  String title,  String instruction,  String effort,  String prompt,  List<String> reactions,  String? lessonId)?  $default,) {final _that = this;
switch (_that) {
case _BrewChallenge() when $default != null:
return $default(_that.id,_that.scope,_that.moduleId,_that.cardId,_that.title,_that.instruction,_that.effort,_that.prompt,_that.reactions,_that.lessonId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BrewChallenge implements BrewChallenge {
  const _BrewChallenge({required this.id, @JsonKey(name: 'type') required this.scope, required this.moduleId, required this.cardId, required this.title, required this.instruction, required this.effort, required this.prompt, required final  List<String> reactions, this.lessonId}): _reactions = reactions;
  factory _BrewChallenge.fromJson(Map<String, dynamic> json) => _$BrewChallengeFromJson(json);

@override final  String id;
@override@JsonKey(name: 'type') final  ChallengeScope scope;
/// The module this belongs to — its own, for a capstone; its lesson's, for
/// a lesson challenge.
@override final  String moduleId;
/// The collectible this challenge is stamped onto.
@override final  String cardId;
@override final  String title;
/// What to actually go and brew.
@override final  String instruction;
/// When and how long, as one authored string: `'Next brews · 5 min'`.
@override final  String effort;
/// The question the log sheet asks — `'WHICH CUP WON?'`.
@override final  String prompt;
/// The outcomes the learner can report. **Eleven records carry three and
/// one carries two**, so nothing may assume a count.
 final  List<String> _reactions;
/// The outcomes the learner can report. **Eleven records carry three and
/// one carries two**, so nothing may assume a count.
@override List<String> get reactions {
  if (_reactions is EqualUnmodifiableListView) return _reactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reactions);
}

/// The lesson this challenge belongs to, or null on a capstone.
///
/// **Authored, never parsed out of [id].** `bc-m4l3` looks like it names a
/// lesson, but lessons have been inserted mid-module before, and an id
/// read as a pointer would then resolve to whatever now sits in that slot.
@override final  String? lessonId;

/// Create a copy of BrewChallenge
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BrewChallengeCopyWith<_BrewChallenge> get copyWith => __$BrewChallengeCopyWithImpl<_BrewChallenge>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BrewChallengeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BrewChallenge&&(identical(other.id, id) || other.id == id)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.moduleId, moduleId) || other.moduleId == moduleId)&&(identical(other.cardId, cardId) || other.cardId == cardId)&&(identical(other.title, title) || other.title == title)&&(identical(other.instruction, instruction) || other.instruction == instruction)&&(identical(other.effort, effort) || other.effort == effort)&&(identical(other.prompt, prompt) || other.prompt == prompt)&&const DeepCollectionEquality().equals(other._reactions, _reactions)&&(identical(other.lessonId, lessonId) || other.lessonId == lessonId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,scope,moduleId,cardId,title,instruction,effort,prompt,const DeepCollectionEquality().hash(_reactions),lessonId);

@override
String toString() {
  return 'BrewChallenge(id: $id, scope: $scope, moduleId: $moduleId, cardId: $cardId, title: $title, instruction: $instruction, effort: $effort, prompt: $prompt, reactions: $reactions, lessonId: $lessonId)';
}


}

/// @nodoc
abstract mixin class _$BrewChallengeCopyWith<$Res> implements $BrewChallengeCopyWith<$Res> {
  factory _$BrewChallengeCopyWith(_BrewChallenge value, $Res Function(_BrewChallenge) _then) = __$BrewChallengeCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'type') ChallengeScope scope, String moduleId, String cardId, String title, String instruction, String effort, String prompt, List<String> reactions, String? lessonId
});




}
/// @nodoc
class __$BrewChallengeCopyWithImpl<$Res>
    implements _$BrewChallengeCopyWith<$Res> {
  __$BrewChallengeCopyWithImpl(this._self, this._then);

  final _BrewChallenge _self;
  final $Res Function(_BrewChallenge) _then;

/// Create a copy of BrewChallenge
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? scope = null,Object? moduleId = null,Object? cardId = null,Object? title = null,Object? instruction = null,Object? effort = null,Object? prompt = null,Object? reactions = null,Object? lessonId = freezed,}) {
  return _then(_BrewChallenge(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as ChallengeScope,moduleId: null == moduleId ? _self.moduleId : moduleId // ignore: cast_nullable_to_non_nullable
as String,cardId: null == cardId ? _self.cardId : cardId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,instruction: null == instruction ? _self.instruction : instruction // ignore: cast_nullable_to_non_nullable
as String,effort: null == effort ? _self.effort : effort // ignore: cast_nullable_to_non_nullable
as String,prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String,reactions: null == reactions ? _self._reactions : reactions // ignore: cast_nullable_to_non_nullable
as List<String>,lessonId: freezed == lessonId ? _self.lessonId : lessonId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
