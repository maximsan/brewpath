// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'visual_guide.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VisualGuideUnlock {

 String get lesson;
/// Create a copy of VisualGuideUnlock
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VisualGuideUnlockCopyWith<VisualGuideUnlock> get copyWith => _$VisualGuideUnlockCopyWithImpl<VisualGuideUnlock>(this as VisualGuideUnlock, _$identity);

  /// Serializes this VisualGuideUnlock to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VisualGuideUnlock&&(identical(other.lesson, lesson) || other.lesson == lesson));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,lesson);

@override
String toString() {
  return 'VisualGuideUnlock(lesson: $lesson)';
}


}

/// @nodoc
abstract mixin class $VisualGuideUnlockCopyWith<$Res>  {
  factory $VisualGuideUnlockCopyWith(VisualGuideUnlock value, $Res Function(VisualGuideUnlock) _then) = _$VisualGuideUnlockCopyWithImpl;
@useResult
$Res call({
 String lesson
});




}
/// @nodoc
class _$VisualGuideUnlockCopyWithImpl<$Res>
    implements $VisualGuideUnlockCopyWith<$Res> {
  _$VisualGuideUnlockCopyWithImpl(this._self, this._then);

  final VisualGuideUnlock _self;
  final $Res Function(VisualGuideUnlock) _then;

/// Create a copy of VisualGuideUnlock
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lesson = null,}) {
  return _then(_self.copyWith(
lesson: null == lesson ? _self.lesson : lesson // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [VisualGuideUnlock].
extension VisualGuideUnlockPatterns on VisualGuideUnlock {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VisualGuideUnlock value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VisualGuideUnlock() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VisualGuideUnlock value)  $default,){
final _that = this;
switch (_that) {
case _VisualGuideUnlock():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VisualGuideUnlock value)?  $default,){
final _that = this;
switch (_that) {
case _VisualGuideUnlock() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String lesson)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VisualGuideUnlock() when $default != null:
return $default(_that.lesson);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String lesson)  $default,) {final _that = this;
switch (_that) {
case _VisualGuideUnlock():
return $default(_that.lesson);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String lesson)?  $default,) {final _that = this;
switch (_that) {
case _VisualGuideUnlock() when $default != null:
return $default(_that.lesson);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VisualGuideUnlock implements VisualGuideUnlock {
  const _VisualGuideUnlock({required this.lesson});
  factory _VisualGuideUnlock.fromJson(Map<String, dynamic> json) => _$VisualGuideUnlockFromJson(json);

@override final  String lesson;

/// Create a copy of VisualGuideUnlock
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VisualGuideUnlockCopyWith<_VisualGuideUnlock> get copyWith => __$VisualGuideUnlockCopyWithImpl<_VisualGuideUnlock>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VisualGuideUnlockToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VisualGuideUnlock&&(identical(other.lesson, lesson) || other.lesson == lesson));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,lesson);

@override
String toString() {
  return 'VisualGuideUnlock(lesson: $lesson)';
}


}

/// @nodoc
abstract mixin class _$VisualGuideUnlockCopyWith<$Res> implements $VisualGuideUnlockCopyWith<$Res> {
  factory _$VisualGuideUnlockCopyWith(_VisualGuideUnlock value, $Res Function(_VisualGuideUnlock) _then) = __$VisualGuideUnlockCopyWithImpl;
@override @useResult
$Res call({
 String lesson
});




}
/// @nodoc
class __$VisualGuideUnlockCopyWithImpl<$Res>
    implements _$VisualGuideUnlockCopyWith<$Res> {
  __$VisualGuideUnlockCopyWithImpl(this._self, this._then);

  final _VisualGuideUnlock _self;
  final $Res Function(_VisualGuideUnlock) _then;

/// Create a copy of VisualGuideUnlock
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lesson = null,}) {
  return _then(_VisualGuideUnlock(
lesson: null == lesson ? _self.lesson : lesson // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$VisualGuide {

 String get id;/// The subject this guide covers — `roast`, `grind`, `variety`. The value
/// a `g:` save key carries, and the axis its drawing is chosen by.
@JsonKey(name: 'visualGuide') String get subject;/// The lesson that earns it: the earliest one that teaches it, which the
/// extractor refuses to let drift.
 VisualGuideUnlock get unlock; String get label; String get title; String get summary;/// The one thing worth repeating to somebody else.
 String get fact;/// The meta table on the wire: two or three label/value pairs.
 List<List<String>> get meta;
/// Create a copy of VisualGuide
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VisualGuideCopyWith<VisualGuide> get copyWith => _$VisualGuideCopyWithImpl<VisualGuide>(this as VisualGuide, _$identity);

  /// Serializes this VisualGuide to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VisualGuide&&(identical(other.id, id) || other.id == id)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.unlock, unlock) || other.unlock == unlock)&&(identical(other.label, label) || other.label == label)&&(identical(other.title, title) || other.title == title)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.fact, fact) || other.fact == fact)&&const DeepCollectionEquality().equals(other.meta, meta));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,subject,unlock,label,title,summary,fact,const DeepCollectionEquality().hash(meta));

@override
String toString() {
  return 'VisualGuide(id: $id, subject: $subject, unlock: $unlock, label: $label, title: $title, summary: $summary, fact: $fact, meta: $meta)';
}


}

/// @nodoc
abstract mixin class $VisualGuideCopyWith<$Res>  {
  factory $VisualGuideCopyWith(VisualGuide value, $Res Function(VisualGuide) _then) = _$VisualGuideCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'visualGuide') String subject, VisualGuideUnlock unlock, String label, String title, String summary, String fact, List<List<String>> meta
});


$VisualGuideUnlockCopyWith<$Res> get unlock;

}
/// @nodoc
class _$VisualGuideCopyWithImpl<$Res>
    implements $VisualGuideCopyWith<$Res> {
  _$VisualGuideCopyWithImpl(this._self, this._then);

  final VisualGuide _self;
  final $Res Function(VisualGuide) _then;

/// Create a copy of VisualGuide
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? subject = null,Object? unlock = null,Object? label = null,Object? title = null,Object? summary = null,Object? fact = null,Object? meta = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,unlock: null == unlock ? _self.unlock : unlock // ignore: cast_nullable_to_non_nullable
as VisualGuideUnlock,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,fact: null == fact ? _self.fact : fact // ignore: cast_nullable_to_non_nullable
as String,meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as List<List<String>>,
  ));
}
/// Create a copy of VisualGuide
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VisualGuideUnlockCopyWith<$Res> get unlock {
  
  return $VisualGuideUnlockCopyWith<$Res>(_self.unlock, (value) {
    return _then(_self.copyWith(unlock: value));
  });
}
}


/// Adds pattern-matching-related methods to [VisualGuide].
extension VisualGuidePatterns on VisualGuide {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VisualGuide value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VisualGuide() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VisualGuide value)  $default,){
final _that = this;
switch (_that) {
case _VisualGuide():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VisualGuide value)?  $default,){
final _that = this;
switch (_that) {
case _VisualGuide() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'visualGuide')  String subject,  VisualGuideUnlock unlock,  String label,  String title,  String summary,  String fact,  List<List<String>> meta)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VisualGuide() when $default != null:
return $default(_that.id,_that.subject,_that.unlock,_that.label,_that.title,_that.summary,_that.fact,_that.meta);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'visualGuide')  String subject,  VisualGuideUnlock unlock,  String label,  String title,  String summary,  String fact,  List<List<String>> meta)  $default,) {final _that = this;
switch (_that) {
case _VisualGuide():
return $default(_that.id,_that.subject,_that.unlock,_that.label,_that.title,_that.summary,_that.fact,_that.meta);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'visualGuide')  String subject,  VisualGuideUnlock unlock,  String label,  String title,  String summary,  String fact,  List<List<String>> meta)?  $default,) {final _that = this;
switch (_that) {
case _VisualGuide() when $default != null:
return $default(_that.id,_that.subject,_that.unlock,_that.label,_that.title,_that.summary,_that.fact,_that.meta);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VisualGuide extends VisualGuide {
  const _VisualGuide({required this.id, @JsonKey(name: 'visualGuide') required this.subject, required this.unlock, required this.label, required this.title, required this.summary, required this.fact, final  List<List<String>> meta = const <List<String>>[]}): _meta = meta,super._();
  factory _VisualGuide.fromJson(Map<String, dynamic> json) => _$VisualGuideFromJson(json);

@override final  String id;
/// The subject this guide covers — `roast`, `grind`, `variety`. The value
/// a `g:` save key carries, and the axis its drawing is chosen by.
@override@JsonKey(name: 'visualGuide') final  String subject;
/// The lesson that earns it: the earliest one that teaches it, which the
/// extractor refuses to let drift.
@override final  VisualGuideUnlock unlock;
@override final  String label;
@override final  String title;
@override final  String summary;
/// The one thing worth repeating to somebody else.
@override final  String fact;
/// The meta table on the wire: two or three label/value pairs.
 final  List<List<String>> _meta;
/// The meta table on the wire: two or three label/value pairs.
@override@JsonKey() List<List<String>> get meta {
  if (_meta is EqualUnmodifiableListView) return _meta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_meta);
}


/// Create a copy of VisualGuide
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VisualGuideCopyWith<_VisualGuide> get copyWith => __$VisualGuideCopyWithImpl<_VisualGuide>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VisualGuideToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VisualGuide&&(identical(other.id, id) || other.id == id)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.unlock, unlock) || other.unlock == unlock)&&(identical(other.label, label) || other.label == label)&&(identical(other.title, title) || other.title == title)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.fact, fact) || other.fact == fact)&&const DeepCollectionEquality().equals(other._meta, _meta));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,subject,unlock,label,title,summary,fact,const DeepCollectionEquality().hash(_meta));

@override
String toString() {
  return 'VisualGuide(id: $id, subject: $subject, unlock: $unlock, label: $label, title: $title, summary: $summary, fact: $fact, meta: $meta)';
}


}

/// @nodoc
abstract mixin class _$VisualGuideCopyWith<$Res> implements $VisualGuideCopyWith<$Res> {
  factory _$VisualGuideCopyWith(_VisualGuide value, $Res Function(_VisualGuide) _then) = __$VisualGuideCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'visualGuide') String subject, VisualGuideUnlock unlock, String label, String title, String summary, String fact, List<List<String>> meta
});


@override $VisualGuideUnlockCopyWith<$Res> get unlock;

}
/// @nodoc
class __$VisualGuideCopyWithImpl<$Res>
    implements _$VisualGuideCopyWith<$Res> {
  __$VisualGuideCopyWithImpl(this._self, this._then);

  final _VisualGuide _self;
  final $Res Function(_VisualGuide) _then;

/// Create a copy of VisualGuide
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? subject = null,Object? unlock = null,Object? label = null,Object? title = null,Object? summary = null,Object? fact = null,Object? meta = null,}) {
  return _then(_VisualGuide(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,unlock: null == unlock ? _self.unlock : unlock // ignore: cast_nullable_to_non_nullable
as VisualGuideUnlock,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,fact: null == fact ? _self.fact : fact // ignore: cast_nullable_to_non_nullable
as String,meta: null == meta ? _self._meta : meta // ignore: cast_nullable_to_non_nullable
as List<List<String>>,
  ));
}

/// Create a copy of VisualGuide
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VisualGuideUnlockCopyWith<$Res> get unlock {
  
  return $VisualGuideUnlockCopyWith<$Res>(_self.unlock, (value) {
    return _then(_self.copyWith(unlock: value));
  });
}
}

// dart format on
