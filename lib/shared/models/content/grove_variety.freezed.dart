// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'grove_variety.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GroveVariety {

 String get id; String get name;/// The binomial, e.g. `Coffea arabica`.
 String get latin;/// Share of the world's cups, as authored prose (`~60%`).
 String get share;/// What the bean gets brewed as — the same question for all three.
 String get use; String get origin;/// Growing conditions, as authored prose (`High and cool`).
 String get grows;/// The cup profile — the chooser's "Tastes like".
 String get cup;/// The plant's body plus one consequence worth remembering. Carries what
/// the spec strip cannot: what the tree actually looks like.
 String get tell;/// Anisotropic scale distinguishing this species' silhouette, or `none`
/// for the species drawn as-is. The interim treatment until bespoke art
/// lands (#87).
 String get shape;/// Leaf-tone filter chain composed under the chosen light, empty for the
/// species whose art is already the real one.
 String get leaf;/// The prototype's art-pipeline rollout note.
///
/// Emitted because the extractor renames and drops nothing, and **read by
/// nothing**: all three species ship, and a flag in the source must not be
/// able to re-defer a decided launch.
 String get drop;
/// Create a copy of GroveVariety
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroveVarietyCopyWith<GroveVariety> get copyWith => _$GroveVarietyCopyWithImpl<GroveVariety>(this as GroveVariety, _$identity);

  /// Serializes this GroveVariety to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroveVariety&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.latin, latin) || other.latin == latin)&&(identical(other.share, share) || other.share == share)&&(identical(other.use, use) || other.use == use)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.grows, grows) || other.grows == grows)&&(identical(other.cup, cup) || other.cup == cup)&&(identical(other.tell, tell) || other.tell == tell)&&(identical(other.shape, shape) || other.shape == shape)&&(identical(other.leaf, leaf) || other.leaf == leaf)&&(identical(other.drop, drop) || other.drop == drop));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,latin,share,use,origin,grows,cup,tell,shape,leaf,drop);

@override
String toString() {
  return 'GroveVariety(id: $id, name: $name, latin: $latin, share: $share, use: $use, origin: $origin, grows: $grows, cup: $cup, tell: $tell, shape: $shape, leaf: $leaf, drop: $drop)';
}


}

/// @nodoc
abstract mixin class $GroveVarietyCopyWith<$Res>  {
  factory $GroveVarietyCopyWith(GroveVariety value, $Res Function(GroveVariety) _then) = _$GroveVarietyCopyWithImpl;
@useResult
$Res call({
 String id, String name, String latin, String share, String use, String origin, String grows, String cup, String tell, String shape, String leaf, String drop
});




}
/// @nodoc
class _$GroveVarietyCopyWithImpl<$Res>
    implements $GroveVarietyCopyWith<$Res> {
  _$GroveVarietyCopyWithImpl(this._self, this._then);

  final GroveVariety _self;
  final $Res Function(GroveVariety) _then;

/// Create a copy of GroveVariety
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? latin = null,Object? share = null,Object? use = null,Object? origin = null,Object? grows = null,Object? cup = null,Object? tell = null,Object? shape = null,Object? leaf = null,Object? drop = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,latin: null == latin ? _self.latin : latin // ignore: cast_nullable_to_non_nullable
as String,share: null == share ? _self.share : share // ignore: cast_nullable_to_non_nullable
as String,use: null == use ? _self.use : use // ignore: cast_nullable_to_non_nullable
as String,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as String,grows: null == grows ? _self.grows : grows // ignore: cast_nullable_to_non_nullable
as String,cup: null == cup ? _self.cup : cup // ignore: cast_nullable_to_non_nullable
as String,tell: null == tell ? _self.tell : tell // ignore: cast_nullable_to_non_nullable
as String,shape: null == shape ? _self.shape : shape // ignore: cast_nullable_to_non_nullable
as String,leaf: null == leaf ? _self.leaf : leaf // ignore: cast_nullable_to_non_nullable
as String,drop: null == drop ? _self.drop : drop // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GroveVariety].
extension GroveVarietyPatterns on GroveVariety {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroveVariety value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroveVariety() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroveVariety value)  $default,){
final _that = this;
switch (_that) {
case _GroveVariety():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroveVariety value)?  $default,){
final _that = this;
switch (_that) {
case _GroveVariety() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String latin,  String share,  String use,  String origin,  String grows,  String cup,  String tell,  String shape,  String leaf,  String drop)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroveVariety() when $default != null:
return $default(_that.id,_that.name,_that.latin,_that.share,_that.use,_that.origin,_that.grows,_that.cup,_that.tell,_that.shape,_that.leaf,_that.drop);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String latin,  String share,  String use,  String origin,  String grows,  String cup,  String tell,  String shape,  String leaf,  String drop)  $default,) {final _that = this;
switch (_that) {
case _GroveVariety():
return $default(_that.id,_that.name,_that.latin,_that.share,_that.use,_that.origin,_that.grows,_that.cup,_that.tell,_that.shape,_that.leaf,_that.drop);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String latin,  String share,  String use,  String origin,  String grows,  String cup,  String tell,  String shape,  String leaf,  String drop)?  $default,) {final _that = this;
switch (_that) {
case _GroveVariety() when $default != null:
return $default(_that.id,_that.name,_that.latin,_that.share,_that.use,_that.origin,_that.grows,_that.cup,_that.tell,_that.shape,_that.leaf,_that.drop);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GroveVariety implements GroveVariety {
  const _GroveVariety({required this.id, required this.name, required this.latin, required this.share, required this.use, required this.origin, required this.grows, required this.cup, required this.tell, required this.shape, required this.leaf, required this.drop});
  factory _GroveVariety.fromJson(Map<String, dynamic> json) => _$GroveVarietyFromJson(json);

@override final  String id;
@override final  String name;
/// The binomial, e.g. `Coffea arabica`.
@override final  String latin;
/// Share of the world's cups, as authored prose (`~60%`).
@override final  String share;
/// What the bean gets brewed as — the same question for all three.
@override final  String use;
@override final  String origin;
/// Growing conditions, as authored prose (`High and cool`).
@override final  String grows;
/// The cup profile — the chooser's "Tastes like".
@override final  String cup;
/// The plant's body plus one consequence worth remembering. Carries what
/// the spec strip cannot: what the tree actually looks like.
@override final  String tell;
/// Anisotropic scale distinguishing this species' silhouette, or `none`
/// for the species drawn as-is. The interim treatment until bespoke art
/// lands (#87).
@override final  String shape;
/// Leaf-tone filter chain composed under the chosen light, empty for the
/// species whose art is already the real one.
@override final  String leaf;
/// The prototype's art-pipeline rollout note.
///
/// Emitted because the extractor renames and drops nothing, and **read by
/// nothing**: all three species ship, and a flag in the source must not be
/// able to re-defer a decided launch.
@override final  String drop;

/// Create a copy of GroveVariety
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroveVarietyCopyWith<_GroveVariety> get copyWith => __$GroveVarietyCopyWithImpl<_GroveVariety>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GroveVarietyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroveVariety&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.latin, latin) || other.latin == latin)&&(identical(other.share, share) || other.share == share)&&(identical(other.use, use) || other.use == use)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.grows, grows) || other.grows == grows)&&(identical(other.cup, cup) || other.cup == cup)&&(identical(other.tell, tell) || other.tell == tell)&&(identical(other.shape, shape) || other.shape == shape)&&(identical(other.leaf, leaf) || other.leaf == leaf)&&(identical(other.drop, drop) || other.drop == drop));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,latin,share,use,origin,grows,cup,tell,shape,leaf,drop);

@override
String toString() {
  return 'GroveVariety(id: $id, name: $name, latin: $latin, share: $share, use: $use, origin: $origin, grows: $grows, cup: $cup, tell: $tell, shape: $shape, leaf: $leaf, drop: $drop)';
}


}

/// @nodoc
abstract mixin class _$GroveVarietyCopyWith<$Res> implements $GroveVarietyCopyWith<$Res> {
  factory _$GroveVarietyCopyWith(_GroveVariety value, $Res Function(_GroveVariety) _then) = __$GroveVarietyCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String latin, String share, String use, String origin, String grows, String cup, String tell, String shape, String leaf, String drop
});




}
/// @nodoc
class __$GroveVarietyCopyWithImpl<$Res>
    implements _$GroveVarietyCopyWith<$Res> {
  __$GroveVarietyCopyWithImpl(this._self, this._then);

  final _GroveVariety _self;
  final $Res Function(_GroveVariety) _then;

/// Create a copy of GroveVariety
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? latin = null,Object? share = null,Object? use = null,Object? origin = null,Object? grows = null,Object? cup = null,Object? tell = null,Object? shape = null,Object? leaf = null,Object? drop = null,}) {
  return _then(_GroveVariety(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,latin: null == latin ? _self.latin : latin // ignore: cast_nullable_to_non_nullable
as String,share: null == share ? _self.share : share // ignore: cast_nullable_to_non_nullable
as String,use: null == use ? _self.use : use // ignore: cast_nullable_to_non_nullable
as String,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as String,grows: null == grows ? _self.grows : grows // ignore: cast_nullable_to_non_nullable
as String,cup: null == cup ? _self.cup : cup // ignore: cast_nullable_to_non_nullable
as String,tell: null == tell ? _self.tell : tell // ignore: cast_nullable_to_non_nullable
as String,shape: null == shape ? _self.shape : shape // ignore: cast_nullable_to_non_nullable
as String,leaf: null == leaf ? _self.leaf : leaf // ignore: cast_nullable_to_non_nullable
as String,drop: null == drop ? _self.drop : drop // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
