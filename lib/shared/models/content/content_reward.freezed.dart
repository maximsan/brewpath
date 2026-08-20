// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'content_reward.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ContentReward {

 String get title; String get summary; String get fact;/// Label/value rows, as authored by a lesson reward. Empty on a module.
 List<List<String>> get meta;/// The mark a module reward carries instead of [meta]. Null on a lesson.
 String? get badge;
/// Create a copy of ContentReward
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContentRewardCopyWith<ContentReward> get copyWith => _$ContentRewardCopyWithImpl<ContentReward>(this as ContentReward, _$identity);

  /// Serializes this ContentReward to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContentReward&&(identical(other.title, title) || other.title == title)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.fact, fact) || other.fact == fact)&&const DeepCollectionEquality().equals(other.meta, meta)&&(identical(other.badge, badge) || other.badge == badge));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,summary,fact,const DeepCollectionEquality().hash(meta),badge);

@override
String toString() {
  return 'ContentReward(title: $title, summary: $summary, fact: $fact, meta: $meta, badge: $badge)';
}


}

/// @nodoc
abstract mixin class $ContentRewardCopyWith<$Res>  {
  factory $ContentRewardCopyWith(ContentReward value, $Res Function(ContentReward) _then) = _$ContentRewardCopyWithImpl;
@useResult
$Res call({
 String title, String summary, String fact, List<List<String>> meta, String? badge
});




}
/// @nodoc
class _$ContentRewardCopyWithImpl<$Res>
    implements $ContentRewardCopyWith<$Res> {
  _$ContentRewardCopyWithImpl(this._self, this._then);

  final ContentReward _self;
  final $Res Function(ContentReward) _then;

/// Create a copy of ContentReward
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? summary = null,Object? fact = null,Object? meta = null,Object? badge = freezed,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,fact: null == fact ? _self.fact : fact // ignore: cast_nullable_to_non_nullable
as String,meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as List<List<String>>,badge: freezed == badge ? _self.badge : badge // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ContentReward].
extension ContentRewardPatterns on ContentReward {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContentReward value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContentReward() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContentReward value)  $default,){
final _that = this;
switch (_that) {
case _ContentReward():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContentReward value)?  $default,){
final _that = this;
switch (_that) {
case _ContentReward() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String summary,  String fact,  List<List<String>> meta,  String? badge)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContentReward() when $default != null:
return $default(_that.title,_that.summary,_that.fact,_that.meta,_that.badge);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String summary,  String fact,  List<List<String>> meta,  String? badge)  $default,) {final _that = this;
switch (_that) {
case _ContentReward():
return $default(_that.title,_that.summary,_that.fact,_that.meta,_that.badge);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String summary,  String fact,  List<List<String>> meta,  String? badge)?  $default,) {final _that = this;
switch (_that) {
case _ContentReward() when $default != null:
return $default(_that.title,_that.summary,_that.fact,_that.meta,_that.badge);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContentReward implements ContentReward {
  const _ContentReward({required this.title, required this.summary, required this.fact, final  List<List<String>> meta = const <List<String>>[], this.badge}): _meta = meta;
  factory _ContentReward.fromJson(Map<String, dynamic> json) => _$ContentRewardFromJson(json);

@override final  String title;
@override final  String summary;
@override final  String fact;
/// Label/value rows, as authored by a lesson reward. Empty on a module.
 final  List<List<String>> _meta;
/// Label/value rows, as authored by a lesson reward. Empty on a module.
@override@JsonKey() List<List<String>> get meta {
  if (_meta is EqualUnmodifiableListView) return _meta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_meta);
}

/// The mark a module reward carries instead of [meta]. Null on a lesson.
@override final  String? badge;

/// Create a copy of ContentReward
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContentRewardCopyWith<_ContentReward> get copyWith => __$ContentRewardCopyWithImpl<_ContentReward>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContentRewardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContentReward&&(identical(other.title, title) || other.title == title)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.fact, fact) || other.fact == fact)&&const DeepCollectionEquality().equals(other._meta, _meta)&&(identical(other.badge, badge) || other.badge == badge));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,summary,fact,const DeepCollectionEquality().hash(_meta),badge);

@override
String toString() {
  return 'ContentReward(title: $title, summary: $summary, fact: $fact, meta: $meta, badge: $badge)';
}


}

/// @nodoc
abstract mixin class _$ContentRewardCopyWith<$Res> implements $ContentRewardCopyWith<$Res> {
  factory _$ContentRewardCopyWith(_ContentReward value, $Res Function(_ContentReward) _then) = __$ContentRewardCopyWithImpl;
@override @useResult
$Res call({
 String title, String summary, String fact, List<List<String>> meta, String? badge
});




}
/// @nodoc
class __$ContentRewardCopyWithImpl<$Res>
    implements _$ContentRewardCopyWith<$Res> {
  __$ContentRewardCopyWithImpl(this._self, this._then);

  final _ContentReward _self;
  final $Res Function(_ContentReward) _then;

/// Create a copy of ContentReward
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? summary = null,Object? fact = null,Object? meta = null,Object? badge = freezed,}) {
  return _then(_ContentReward(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,fact: null == fact ? _self.fact : fact // ignore: cast_nullable_to_non_nullable
as String,meta: null == meta ? _self._meta : meta // ignore: cast_nullable_to_non_nullable
as List<List<String>>,badge: freezed == badge ? _self.badge : badge // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
