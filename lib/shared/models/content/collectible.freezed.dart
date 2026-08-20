// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'collectible.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CollectibleUnlock {

@JsonKey(name: 'lesson') String? get lessonId;@JsonKey(name: 'module') String? get moduleId;
/// Create a copy of CollectibleUnlock
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CollectibleUnlockCopyWith<CollectibleUnlock> get copyWith => _$CollectibleUnlockCopyWithImpl<CollectibleUnlock>(this as CollectibleUnlock, _$identity);

  /// Serializes this CollectibleUnlock to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CollectibleUnlock&&(identical(other.lessonId, lessonId) || other.lessonId == lessonId)&&(identical(other.moduleId, moduleId) || other.moduleId == moduleId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,lessonId,moduleId);

@override
String toString() {
  return 'CollectibleUnlock(lessonId: $lessonId, moduleId: $moduleId)';
}


}

/// @nodoc
abstract mixin class $CollectibleUnlockCopyWith<$Res>  {
  factory $CollectibleUnlockCopyWith(CollectibleUnlock value, $Res Function(CollectibleUnlock) _then) = _$CollectibleUnlockCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'lesson') String? lessonId,@JsonKey(name: 'module') String? moduleId
});




}
/// @nodoc
class _$CollectibleUnlockCopyWithImpl<$Res>
    implements $CollectibleUnlockCopyWith<$Res> {
  _$CollectibleUnlockCopyWithImpl(this._self, this._then);

  final CollectibleUnlock _self;
  final $Res Function(CollectibleUnlock) _then;

/// Create a copy of CollectibleUnlock
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lessonId = freezed,Object? moduleId = freezed,}) {
  return _then(_self.copyWith(
lessonId: freezed == lessonId ? _self.lessonId : lessonId // ignore: cast_nullable_to_non_nullable
as String?,moduleId: freezed == moduleId ? _self.moduleId : moduleId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CollectibleUnlock].
extension CollectibleUnlockPatterns on CollectibleUnlock {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CollectibleUnlock value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CollectibleUnlock() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CollectibleUnlock value)  $default,){
final _that = this;
switch (_that) {
case _CollectibleUnlock():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CollectibleUnlock value)?  $default,){
final _that = this;
switch (_that) {
case _CollectibleUnlock() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'lesson')  String? lessonId, @JsonKey(name: 'module')  String? moduleId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CollectibleUnlock() when $default != null:
return $default(_that.lessonId,_that.moduleId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'lesson')  String? lessonId, @JsonKey(name: 'module')  String? moduleId)  $default,) {final _that = this;
switch (_that) {
case _CollectibleUnlock():
return $default(_that.lessonId,_that.moduleId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'lesson')  String? lessonId, @JsonKey(name: 'module')  String? moduleId)?  $default,) {final _that = this;
switch (_that) {
case _CollectibleUnlock() when $default != null:
return $default(_that.lessonId,_that.moduleId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CollectibleUnlock extends CollectibleUnlock {
  const _CollectibleUnlock({@JsonKey(name: 'lesson') this.lessonId, @JsonKey(name: 'module') this.moduleId}): super._();
  factory _CollectibleUnlock.fromJson(Map<String, dynamic> json) => _$CollectibleUnlockFromJson(json);

@override@JsonKey(name: 'lesson') final  String? lessonId;
@override@JsonKey(name: 'module') final  String? moduleId;

/// Create a copy of CollectibleUnlock
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CollectibleUnlockCopyWith<_CollectibleUnlock> get copyWith => __$CollectibleUnlockCopyWithImpl<_CollectibleUnlock>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CollectibleUnlockToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CollectibleUnlock&&(identical(other.lessonId, lessonId) || other.lessonId == lessonId)&&(identical(other.moduleId, moduleId) || other.moduleId == moduleId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,lessonId,moduleId);

@override
String toString() {
  return 'CollectibleUnlock(lessonId: $lessonId, moduleId: $moduleId)';
}


}

/// @nodoc
abstract mixin class _$CollectibleUnlockCopyWith<$Res> implements $CollectibleUnlockCopyWith<$Res> {
  factory _$CollectibleUnlockCopyWith(_CollectibleUnlock value, $Res Function(_CollectibleUnlock) _then) = __$CollectibleUnlockCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'lesson') String? lessonId,@JsonKey(name: 'module') String? moduleId
});




}
/// @nodoc
class __$CollectibleUnlockCopyWithImpl<$Res>
    implements _$CollectibleUnlockCopyWith<$Res> {
  __$CollectibleUnlockCopyWithImpl(this._self, this._then);

  final _CollectibleUnlock _self;
  final $Res Function(_CollectibleUnlock) _then;

/// Create a copy of CollectibleUnlock
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lessonId = freezed,Object? moduleId = freezed,}) {
  return _then(_CollectibleUnlock(
lessonId: freezed == lessonId ? _self.lessonId : lessonId // ignore: cast_nullable_to_non_nullable
as String?,moduleId: freezed == moduleId ? _self.moduleId : moduleId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Collectible {

 String get id; CollectibleUnlock get unlock;/// The card's own illustration key. Unique per collectible, so it names a
/// specific drawing rather than a family, and the app falls back to the
/// owning module's glyph until those drawings exist.
 String get kind;
/// Create a copy of Collectible
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CollectibleCopyWith<Collectible> get copyWith => _$CollectibleCopyWithImpl<Collectible>(this as Collectible, _$identity);

  /// Serializes this Collectible to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Collectible&&(identical(other.id, id) || other.id == id)&&(identical(other.unlock, unlock) || other.unlock == unlock)&&(identical(other.kind, kind) || other.kind == kind));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,unlock,kind);

@override
String toString() {
  return 'Collectible(id: $id, unlock: $unlock, kind: $kind)';
}


}

/// @nodoc
abstract mixin class $CollectibleCopyWith<$Res>  {
  factory $CollectibleCopyWith(Collectible value, $Res Function(Collectible) _then) = _$CollectibleCopyWithImpl;
@useResult
$Res call({
 String id, CollectibleUnlock unlock, String kind
});


$CollectibleUnlockCopyWith<$Res> get unlock;

}
/// @nodoc
class _$CollectibleCopyWithImpl<$Res>
    implements $CollectibleCopyWith<$Res> {
  _$CollectibleCopyWithImpl(this._self, this._then);

  final Collectible _self;
  final $Res Function(Collectible) _then;

/// Create a copy of Collectible
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? unlock = null,Object? kind = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,unlock: null == unlock ? _self.unlock : unlock // ignore: cast_nullable_to_non_nullable
as CollectibleUnlock,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of Collectible
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CollectibleUnlockCopyWith<$Res> get unlock {
  
  return $CollectibleUnlockCopyWith<$Res>(_self.unlock, (value) {
    return _then(_self.copyWith(unlock: value));
  });
}
}


/// Adds pattern-matching-related methods to [Collectible].
extension CollectiblePatterns on Collectible {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Collectible value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Collectible() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Collectible value)  $default,){
final _that = this;
switch (_that) {
case _Collectible():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Collectible value)?  $default,){
final _that = this;
switch (_that) {
case _Collectible() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  CollectibleUnlock unlock,  String kind)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Collectible() when $default != null:
return $default(_that.id,_that.unlock,_that.kind);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  CollectibleUnlock unlock,  String kind)  $default,) {final _that = this;
switch (_that) {
case _Collectible():
return $default(_that.id,_that.unlock,_that.kind);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  CollectibleUnlock unlock,  String kind)?  $default,) {final _that = this;
switch (_that) {
case _Collectible() when $default != null:
return $default(_that.id,_that.unlock,_that.kind);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Collectible implements Collectible {
  const _Collectible({required this.id, required this.unlock, required this.kind});
  factory _Collectible.fromJson(Map<String, dynamic> json) => _$CollectibleFromJson(json);

@override final  String id;
@override final  CollectibleUnlock unlock;
/// The card's own illustration key. Unique per collectible, so it names a
/// specific drawing rather than a family, and the app falls back to the
/// owning module's glyph until those drawings exist.
@override final  String kind;

/// Create a copy of Collectible
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CollectibleCopyWith<_Collectible> get copyWith => __$CollectibleCopyWithImpl<_Collectible>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CollectibleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Collectible&&(identical(other.id, id) || other.id == id)&&(identical(other.unlock, unlock) || other.unlock == unlock)&&(identical(other.kind, kind) || other.kind == kind));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,unlock,kind);

@override
String toString() {
  return 'Collectible(id: $id, unlock: $unlock, kind: $kind)';
}


}

/// @nodoc
abstract mixin class _$CollectibleCopyWith<$Res> implements $CollectibleCopyWith<$Res> {
  factory _$CollectibleCopyWith(_Collectible value, $Res Function(_Collectible) _then) = __$CollectibleCopyWithImpl;
@override @useResult
$Res call({
 String id, CollectibleUnlock unlock, String kind
});


@override $CollectibleUnlockCopyWith<$Res> get unlock;

}
/// @nodoc
class __$CollectibleCopyWithImpl<$Res>
    implements _$CollectibleCopyWith<$Res> {
  __$CollectibleCopyWithImpl(this._self, this._then);

  final _Collectible _self;
  final $Res Function(_Collectible) _then;

/// Create a copy of Collectible
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? unlock = null,Object? kind = null,}) {
  return _then(_Collectible(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,unlock: null == unlock ? _self.unlock : unlock // ignore: cast_nullable_to_non_nullable
as CollectibleUnlock,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of Collectible
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CollectibleUnlockCopyWith<$Res> get unlock {
  
  return $CollectibleUnlockCopyWith<$Res>(_self.unlock, (value) {
    return _then(_self.copyWith(unlock: value));
  });
}
}

// dart format on
