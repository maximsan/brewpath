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
mixin _$VisualGuideNote {

 String get term; String get detail;
/// Create a copy of VisualGuideNote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VisualGuideNoteCopyWith<VisualGuideNote> get copyWith => _$VisualGuideNoteCopyWithImpl<VisualGuideNote>(this as VisualGuideNote, _$identity);

  /// Serializes this VisualGuideNote to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VisualGuideNote&&(identical(other.term, term) || other.term == term)&&(identical(other.detail, detail) || other.detail == detail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,term,detail);

@override
String toString() {
  return 'VisualGuideNote(term: $term, detail: $detail)';
}


}

/// @nodoc
abstract mixin class $VisualGuideNoteCopyWith<$Res>  {
  factory $VisualGuideNoteCopyWith(VisualGuideNote value, $Res Function(VisualGuideNote) _then) = _$VisualGuideNoteCopyWithImpl;
@useResult
$Res call({
 String term, String detail
});




}
/// @nodoc
class _$VisualGuideNoteCopyWithImpl<$Res>
    implements $VisualGuideNoteCopyWith<$Res> {
  _$VisualGuideNoteCopyWithImpl(this._self, this._then);

  final VisualGuideNote _self;
  final $Res Function(VisualGuideNote) _then;

/// Create a copy of VisualGuideNote
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? term = null,Object? detail = null,}) {
  return _then(_self.copyWith(
term: null == term ? _self.term : term // ignore: cast_nullable_to_non_nullable
as String,detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [VisualGuideNote].
extension VisualGuideNotePatterns on VisualGuideNote {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VisualGuideNote value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VisualGuideNote() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VisualGuideNote value)  $default,){
final _that = this;
switch (_that) {
case _VisualGuideNote():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VisualGuideNote value)?  $default,){
final _that = this;
switch (_that) {
case _VisualGuideNote() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String term,  String detail)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VisualGuideNote() when $default != null:
return $default(_that.term,_that.detail);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String term,  String detail)  $default,) {final _that = this;
switch (_that) {
case _VisualGuideNote():
return $default(_that.term,_that.detail);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String term,  String detail)?  $default,) {final _that = this;
switch (_that) {
case _VisualGuideNote() when $default != null:
return $default(_that.term,_that.detail);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VisualGuideNote implements VisualGuideNote {
  const _VisualGuideNote({required this.term, required this.detail});
  factory _VisualGuideNote.fromJson(Map<String, dynamic> json) => _$VisualGuideNoteFromJson(json);

@override final  String term;
@override final  String detail;

/// Create a copy of VisualGuideNote
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VisualGuideNoteCopyWith<_VisualGuideNote> get copyWith => __$VisualGuideNoteCopyWithImpl<_VisualGuideNote>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VisualGuideNoteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VisualGuideNote&&(identical(other.term, term) || other.term == term)&&(identical(other.detail, detail) || other.detail == detail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,term,detail);

@override
String toString() {
  return 'VisualGuideNote(term: $term, detail: $detail)';
}


}

/// @nodoc
abstract mixin class _$VisualGuideNoteCopyWith<$Res> implements $VisualGuideNoteCopyWith<$Res> {
  factory _$VisualGuideNoteCopyWith(_VisualGuideNote value, $Res Function(_VisualGuideNote) _then) = __$VisualGuideNoteCopyWithImpl;
@override @useResult
$Res call({
 String term, String detail
});




}
/// @nodoc
class __$VisualGuideNoteCopyWithImpl<$Res>
    implements _$VisualGuideNoteCopyWith<$Res> {
  __$VisualGuideNoteCopyWithImpl(this._self, this._then);

  final _VisualGuideNote _self;
  final $Res Function(_VisualGuideNote) _then;

/// Create a copy of VisualGuideNote
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? term = null,Object? detail = null,}) {
  return _then(_VisualGuideNote(
term: null == term ? _self.term : term // ignore: cast_nullable_to_non_nullable
as String,detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CherryLayer {

/// The layer's place, outside in, as the drawing numbers it: `01`–`06`.
/// A string because it is shown as one — a zero-padded chip on the band.
@JsonKey(name: 'n') String get number; String get name;/// The botanical name — `exocarp`, `pectin gel`, `endosperm`.
 String get latin;/// What becomes of this layer: stripped, hulled, or brewed.
 String get fate;/// The sentences shown when this layer is the selected one.
 String get note;
/// Create a copy of CherryLayer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CherryLayerCopyWith<CherryLayer> get copyWith => _$CherryLayerCopyWithImpl<CherryLayer>(this as CherryLayer, _$identity);

  /// Serializes this CherryLayer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CherryLayer&&(identical(other.number, number) || other.number == number)&&(identical(other.name, name) || other.name == name)&&(identical(other.latin, latin) || other.latin == latin)&&(identical(other.fate, fate) || other.fate == fate)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,number,name,latin,fate,note);

@override
String toString() {
  return 'CherryLayer(number: $number, name: $name, latin: $latin, fate: $fate, note: $note)';
}


}

/// @nodoc
abstract mixin class $CherryLayerCopyWith<$Res>  {
  factory $CherryLayerCopyWith(CherryLayer value, $Res Function(CherryLayer) _then) = _$CherryLayerCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'n') String number, String name, String latin, String fate, String note
});




}
/// @nodoc
class _$CherryLayerCopyWithImpl<$Res>
    implements $CherryLayerCopyWith<$Res> {
  _$CherryLayerCopyWithImpl(this._self, this._then);

  final CherryLayer _self;
  final $Res Function(CherryLayer) _then;

/// Create a copy of CherryLayer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? number = null,Object? name = null,Object? latin = null,Object? fate = null,Object? note = null,}) {
  return _then(_self.copyWith(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,latin: null == latin ? _self.latin : latin // ignore: cast_nullable_to_non_nullable
as String,fate: null == fate ? _self.fate : fate // ignore: cast_nullable_to_non_nullable
as String,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CherryLayer].
extension CherryLayerPatterns on CherryLayer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CherryLayer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CherryLayer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CherryLayer value)  $default,){
final _that = this;
switch (_that) {
case _CherryLayer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CherryLayer value)?  $default,){
final _that = this;
switch (_that) {
case _CherryLayer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'n')  String number,  String name,  String latin,  String fate,  String note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CherryLayer() when $default != null:
return $default(_that.number,_that.name,_that.latin,_that.fate,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'n')  String number,  String name,  String latin,  String fate,  String note)  $default,) {final _that = this;
switch (_that) {
case _CherryLayer():
return $default(_that.number,_that.name,_that.latin,_that.fate,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'n')  String number,  String name,  String latin,  String fate,  String note)?  $default,) {final _that = this;
switch (_that) {
case _CherryLayer() when $default != null:
return $default(_that.number,_that.name,_that.latin,_that.fate,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CherryLayer implements CherryLayer {
  const _CherryLayer({@JsonKey(name: 'n') required this.number, required this.name, required this.latin, required this.fate, required this.note});
  factory _CherryLayer.fromJson(Map<String, dynamic> json) => _$CherryLayerFromJson(json);

/// The layer's place, outside in, as the drawing numbers it: `01`–`06`.
/// A string because it is shown as one — a zero-padded chip on the band.
@override@JsonKey(name: 'n') final  String number;
@override final  String name;
/// The botanical name — `exocarp`, `pectin gel`, `endosperm`.
@override final  String latin;
/// What becomes of this layer: stripped, hulled, or brewed.
@override final  String fate;
/// The sentences shown when this layer is the selected one.
@override final  String note;

/// Create a copy of CherryLayer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CherryLayerCopyWith<_CherryLayer> get copyWith => __$CherryLayerCopyWithImpl<_CherryLayer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CherryLayerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CherryLayer&&(identical(other.number, number) || other.number == number)&&(identical(other.name, name) || other.name == name)&&(identical(other.latin, latin) || other.latin == latin)&&(identical(other.fate, fate) || other.fate == fate)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,number,name,latin,fate,note);

@override
String toString() {
  return 'CherryLayer(number: $number, name: $name, latin: $latin, fate: $fate, note: $note)';
}


}

/// @nodoc
abstract mixin class _$CherryLayerCopyWith<$Res> implements $CherryLayerCopyWith<$Res> {
  factory _$CherryLayerCopyWith(_CherryLayer value, $Res Function(_CherryLayer) _then) = __$CherryLayerCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'n') String number, String name, String latin, String fate, String note
});




}
/// @nodoc
class __$CherryLayerCopyWithImpl<$Res>
    implements _$CherryLayerCopyWith<$Res> {
  __$CherryLayerCopyWithImpl(this._self, this._then);

  final _CherryLayer _self;
  final $Res Function(_CherryLayer) _then;

/// Create a copy of CherryLayer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? number = null,Object? name = null,Object? latin = null,Object? fate = null,Object? note = null,}) {
  return _then(_CherryLayer(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,latin: null == latin ? _self.latin : latin // ignore: cast_nullable_to_non_nullable
as String,fate: null == fate ? _self.fate : fate // ignore: cast_nullable_to_non_nullable
as String,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ServingRow {

 String get name;/// The serving this figure is for — `240 ml cup`, `30 ml shot`. The half
/// of the table a guide titled *Caffeine, Per Serving* cannot do without.
@JsonKey(name: 'serve') String get serving;@JsonKey(name: 'mg') int get milligrams;
/// Create a copy of ServingRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServingRowCopyWith<ServingRow> get copyWith => _$ServingRowCopyWithImpl<ServingRow>(this as ServingRow, _$identity);

  /// Serializes this ServingRow to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServingRow&&(identical(other.name, name) || other.name == name)&&(identical(other.serving, serving) || other.serving == serving)&&(identical(other.milligrams, milligrams) || other.milligrams == milligrams));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,serving,milligrams);

@override
String toString() {
  return 'ServingRow(name: $name, serving: $serving, milligrams: $milligrams)';
}


}

/// @nodoc
abstract mixin class $ServingRowCopyWith<$Res>  {
  factory $ServingRowCopyWith(ServingRow value, $Res Function(ServingRow) _then) = _$ServingRowCopyWithImpl;
@useResult
$Res call({
 String name,@JsonKey(name: 'serve') String serving,@JsonKey(name: 'mg') int milligrams
});




}
/// @nodoc
class _$ServingRowCopyWithImpl<$Res>
    implements $ServingRowCopyWith<$Res> {
  _$ServingRowCopyWithImpl(this._self, this._then);

  final ServingRow _self;
  final $Res Function(ServingRow) _then;

/// Create a copy of ServingRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? serving = null,Object? milligrams = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,serving: null == serving ? _self.serving : serving // ignore: cast_nullable_to_non_nullable
as String,milligrams: null == milligrams ? _self.milligrams : milligrams // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ServingRow].
extension ServingRowPatterns on ServingRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServingRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServingRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServingRow value)  $default,){
final _that = this;
switch (_that) {
case _ServingRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServingRow value)?  $default,){
final _that = this;
switch (_that) {
case _ServingRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name, @JsonKey(name: 'serve')  String serving, @JsonKey(name: 'mg')  int milligrams)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServingRow() when $default != null:
return $default(_that.name,_that.serving,_that.milligrams);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name, @JsonKey(name: 'serve')  String serving, @JsonKey(name: 'mg')  int milligrams)  $default,) {final _that = this;
switch (_that) {
case _ServingRow():
return $default(_that.name,_that.serving,_that.milligrams);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name, @JsonKey(name: 'serve')  String serving, @JsonKey(name: 'mg')  int milligrams)?  $default,) {final _that = this;
switch (_that) {
case _ServingRow() when $default != null:
return $default(_that.name,_that.serving,_that.milligrams);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ServingRow implements ServingRow {
  const _ServingRow({required this.name, @JsonKey(name: 'serve') required this.serving, @JsonKey(name: 'mg') required this.milligrams});
  factory _ServingRow.fromJson(Map<String, dynamic> json) => _$ServingRowFromJson(json);

@override final  String name;
/// The serving this figure is for — `240 ml cup`, `30 ml shot`. The half
/// of the table a guide titled *Caffeine, Per Serving* cannot do without.
@override@JsonKey(name: 'serve') final  String serving;
@override@JsonKey(name: 'mg') final  int milligrams;

/// Create a copy of ServingRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServingRowCopyWith<_ServingRow> get copyWith => __$ServingRowCopyWithImpl<_ServingRow>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ServingRowToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServingRow&&(identical(other.name, name) || other.name == name)&&(identical(other.serving, serving) || other.serving == serving)&&(identical(other.milligrams, milligrams) || other.milligrams == milligrams));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,serving,milligrams);

@override
String toString() {
  return 'ServingRow(name: $name, serving: $serving, milligrams: $milligrams)';
}


}

/// @nodoc
abstract mixin class _$ServingRowCopyWith<$Res> implements $ServingRowCopyWith<$Res> {
  factory _$ServingRowCopyWith(_ServingRow value, $Res Function(_ServingRow) _then) = __$ServingRowCopyWithImpl;
@override @useResult
$Res call({
 String name,@JsonKey(name: 'serve') String serving,@JsonKey(name: 'mg') int milligrams
});




}
/// @nodoc
class __$ServingRowCopyWithImpl<$Res>
    implements _$ServingRowCopyWith<$Res> {
  __$ServingRowCopyWithImpl(this._self, this._then);

  final _ServingRow _self;
  final $Res Function(_ServingRow) _then;

/// Create a copy of ServingRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? serving = null,Object? milligrams = null,}) {
  return _then(_ServingRow(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,serving: null == serving ? _self.serving : serving // ignore: cast_nullable_to_non_nullable
as String,milligrams: null == milligrams ? _self.milligrams : milligrams // ignore: cast_nullable_to_non_nullable
as int,
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
 List<List<String>> get meta;/// What each term in the table actually means. Empty for the guides whose
/// drawing carries the explanation — anatomy's cross-section is the
/// reference, so it has no rows to gloss.
 List<VisualGuideNote> get notes;/// The cherry's six layers, outside in. Only the anatomy guide carries
/// them; every other guide's reference is the drawing itself.
 List<CherryLayer> get layers;/// The servings table, where the guide has one. Only caffeine does.
 List<ServingRow> get rows;/// The closing thought, where the guide has one: the misreading it exists
/// to head off, or the thing a learner should take away.
 String? get note;
/// Create a copy of VisualGuide
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VisualGuideCopyWith<VisualGuide> get copyWith => _$VisualGuideCopyWithImpl<VisualGuide>(this as VisualGuide, _$identity);

  /// Serializes this VisualGuide to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VisualGuide&&(identical(other.id, id) || other.id == id)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.unlock, unlock) || other.unlock == unlock)&&(identical(other.label, label) || other.label == label)&&(identical(other.title, title) || other.title == title)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.fact, fact) || other.fact == fact)&&const DeepCollectionEquality().equals(other.meta, meta)&&const DeepCollectionEquality().equals(other.notes, notes)&&const DeepCollectionEquality().equals(other.layers, layers)&&const DeepCollectionEquality().equals(other.rows, rows)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,subject,unlock,label,title,summary,fact,const DeepCollectionEquality().hash(meta),const DeepCollectionEquality().hash(notes),const DeepCollectionEquality().hash(layers),const DeepCollectionEquality().hash(rows),note);

@override
String toString() {
  return 'VisualGuide(id: $id, subject: $subject, unlock: $unlock, label: $label, title: $title, summary: $summary, fact: $fact, meta: $meta, notes: $notes, layers: $layers, rows: $rows, note: $note)';
}


}

/// @nodoc
abstract mixin class $VisualGuideCopyWith<$Res>  {
  factory $VisualGuideCopyWith(VisualGuide value, $Res Function(VisualGuide) _then) = _$VisualGuideCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'visualGuide') String subject, VisualGuideUnlock unlock, String label, String title, String summary, String fact, List<List<String>> meta, List<VisualGuideNote> notes, List<CherryLayer> layers, List<ServingRow> rows, String? note
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? subject = null,Object? unlock = null,Object? label = null,Object? title = null,Object? summary = null,Object? fact = null,Object? meta = null,Object? notes = null,Object? layers = null,Object? rows = null,Object? note = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,unlock: null == unlock ? _self.unlock : unlock // ignore: cast_nullable_to_non_nullable
as VisualGuideUnlock,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,fact: null == fact ? _self.fact : fact // ignore: cast_nullable_to_non_nullable
as String,meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as List<List<String>>,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as List<VisualGuideNote>,layers: null == layers ? _self.layers : layers // ignore: cast_nullable_to_non_nullable
as List<CherryLayer>,rows: null == rows ? _self.rows : rows // ignore: cast_nullable_to_non_nullable
as List<ServingRow>,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'visualGuide')  String subject,  VisualGuideUnlock unlock,  String label,  String title,  String summary,  String fact,  List<List<String>> meta,  List<VisualGuideNote> notes,  List<CherryLayer> layers,  List<ServingRow> rows,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VisualGuide() when $default != null:
return $default(_that.id,_that.subject,_that.unlock,_that.label,_that.title,_that.summary,_that.fact,_that.meta,_that.notes,_that.layers,_that.rows,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'visualGuide')  String subject,  VisualGuideUnlock unlock,  String label,  String title,  String summary,  String fact,  List<List<String>> meta,  List<VisualGuideNote> notes,  List<CherryLayer> layers,  List<ServingRow> rows,  String? note)  $default,) {final _that = this;
switch (_that) {
case _VisualGuide():
return $default(_that.id,_that.subject,_that.unlock,_that.label,_that.title,_that.summary,_that.fact,_that.meta,_that.notes,_that.layers,_that.rows,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'visualGuide')  String subject,  VisualGuideUnlock unlock,  String label,  String title,  String summary,  String fact,  List<List<String>> meta,  List<VisualGuideNote> notes,  List<CherryLayer> layers,  List<ServingRow> rows,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _VisualGuide() when $default != null:
return $default(_that.id,_that.subject,_that.unlock,_that.label,_that.title,_that.summary,_that.fact,_that.meta,_that.notes,_that.layers,_that.rows,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VisualGuide extends VisualGuide {
  const _VisualGuide({required this.id, @JsonKey(name: 'visualGuide') required this.subject, required this.unlock, required this.label, required this.title, required this.summary, required this.fact, final  List<List<String>> meta = const <List<String>>[], final  List<VisualGuideNote> notes = const <VisualGuideNote>[], final  List<CherryLayer> layers = const <CherryLayer>[], final  List<ServingRow> rows = const <ServingRow>[], this.note}): _meta = meta,_notes = notes,_layers = layers,_rows = rows,super._();
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

/// What each term in the table actually means. Empty for the guides whose
/// drawing carries the explanation — anatomy's cross-section is the
/// reference, so it has no rows to gloss.
 final  List<VisualGuideNote> _notes;
/// What each term in the table actually means. Empty for the guides whose
/// drawing carries the explanation — anatomy's cross-section is the
/// reference, so it has no rows to gloss.
@override@JsonKey() List<VisualGuideNote> get notes {
  if (_notes is EqualUnmodifiableListView) return _notes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_notes);
}

/// The cherry's six layers, outside in. Only the anatomy guide carries
/// them; every other guide's reference is the drawing itself.
 final  List<CherryLayer> _layers;
/// The cherry's six layers, outside in. Only the anatomy guide carries
/// them; every other guide's reference is the drawing itself.
@override@JsonKey() List<CherryLayer> get layers {
  if (_layers is EqualUnmodifiableListView) return _layers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_layers);
}

/// The servings table, where the guide has one. Only caffeine does.
 final  List<ServingRow> _rows;
/// The servings table, where the guide has one. Only caffeine does.
@override@JsonKey() List<ServingRow> get rows {
  if (_rows is EqualUnmodifiableListView) return _rows;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rows);
}

/// The closing thought, where the guide has one: the misreading it exists
/// to head off, or the thing a learner should take away.
@override final  String? note;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VisualGuide&&(identical(other.id, id) || other.id == id)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.unlock, unlock) || other.unlock == unlock)&&(identical(other.label, label) || other.label == label)&&(identical(other.title, title) || other.title == title)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.fact, fact) || other.fact == fact)&&const DeepCollectionEquality().equals(other._meta, _meta)&&const DeepCollectionEquality().equals(other._notes, _notes)&&const DeepCollectionEquality().equals(other._layers, _layers)&&const DeepCollectionEquality().equals(other._rows, _rows)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,subject,unlock,label,title,summary,fact,const DeepCollectionEquality().hash(_meta),const DeepCollectionEquality().hash(_notes),const DeepCollectionEquality().hash(_layers),const DeepCollectionEquality().hash(_rows),note);

@override
String toString() {
  return 'VisualGuide(id: $id, subject: $subject, unlock: $unlock, label: $label, title: $title, summary: $summary, fact: $fact, meta: $meta, notes: $notes, layers: $layers, rows: $rows, note: $note)';
}


}

/// @nodoc
abstract mixin class _$VisualGuideCopyWith<$Res> implements $VisualGuideCopyWith<$Res> {
  factory _$VisualGuideCopyWith(_VisualGuide value, $Res Function(_VisualGuide) _then) = __$VisualGuideCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'visualGuide') String subject, VisualGuideUnlock unlock, String label, String title, String summary, String fact, List<List<String>> meta, List<VisualGuideNote> notes, List<CherryLayer> layers, List<ServingRow> rows, String? note
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? subject = null,Object? unlock = null,Object? label = null,Object? title = null,Object? summary = null,Object? fact = null,Object? meta = null,Object? notes = null,Object? layers = null,Object? rows = null,Object? note = freezed,}) {
  return _then(_VisualGuide(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,unlock: null == unlock ? _self.unlock : unlock // ignore: cast_nullable_to_non_nullable
as VisualGuideUnlock,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,fact: null == fact ? _self.fact : fact // ignore: cast_nullable_to_non_nullable
as String,meta: null == meta ? _self._meta : meta // ignore: cast_nullable_to_non_nullable
as List<List<String>>,notes: null == notes ? _self._notes : notes // ignore: cast_nullable_to_non_nullable
as List<VisualGuideNote>,layers: null == layers ? _self._layers : layers // ignore: cast_nullable_to_non_nullable
as List<CherryLayer>,rows: null == rows ? _self._rows : rows // ignore: cast_nullable_to_non_nullable
as List<ServingRow>,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
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
