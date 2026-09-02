// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dictionary_term.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DictionarySource {

 String get label; String? get url;
/// Create a copy of DictionarySource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DictionarySourceCopyWith<DictionarySource> get copyWith => _$DictionarySourceCopyWithImpl<DictionarySource>(this as DictionarySource, _$identity);

  /// Serializes this DictionarySource to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DictionarySource&&(identical(other.label, label) || other.label == label)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,url);

@override
String toString() {
  return 'DictionarySource(label: $label, url: $url)';
}


}

/// @nodoc
abstract mixin class $DictionarySourceCopyWith<$Res>  {
  factory $DictionarySourceCopyWith(DictionarySource value, $Res Function(DictionarySource) _then) = _$DictionarySourceCopyWithImpl;
@useResult
$Res call({
 String label, String? url
});




}
/// @nodoc
class _$DictionarySourceCopyWithImpl<$Res>
    implements $DictionarySourceCopyWith<$Res> {
  _$DictionarySourceCopyWithImpl(this._self, this._then);

  final DictionarySource _self;
  final $Res Function(DictionarySource) _then;

/// Create a copy of DictionarySource
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? url = freezed,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DictionarySource].
extension DictionarySourcePatterns on DictionarySource {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DictionarySource value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DictionarySource() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DictionarySource value)  $default,){
final _that = this;
switch (_that) {
case _DictionarySource():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DictionarySource value)?  $default,){
final _that = this;
switch (_that) {
case _DictionarySource() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  String? url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DictionarySource() when $default != null:
return $default(_that.label,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  String? url)  $default,) {final _that = this;
switch (_that) {
case _DictionarySource():
return $default(_that.label,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  String? url)?  $default,) {final _that = this;
switch (_that) {
case _DictionarySource() when $default != null:
return $default(_that.label,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DictionarySource implements DictionarySource {
  const _DictionarySource({required this.label, this.url});
  factory _DictionarySource.fromJson(Map<String, dynamic> json) => _$DictionarySourceFromJson(json);

@override final  String label;
@override final  String? url;

/// Create a copy of DictionarySource
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DictionarySourceCopyWith<_DictionarySource> get copyWith => __$DictionarySourceCopyWithImpl<_DictionarySource>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DictionarySourceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DictionarySource&&(identical(other.label, label) || other.label == label)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,url);

@override
String toString() {
  return 'DictionarySource(label: $label, url: $url)';
}


}

/// @nodoc
abstract mixin class _$DictionarySourceCopyWith<$Res> implements $DictionarySourceCopyWith<$Res> {
  factory _$DictionarySourceCopyWith(_DictionarySource value, $Res Function(_DictionarySource) _then) = __$DictionarySourceCopyWithImpl;
@override @useResult
$Res call({
 String label, String? url
});




}
/// @nodoc
class __$DictionarySourceCopyWithImpl<$Res>
    implements _$DictionarySourceCopyWith<$Res> {
  __$DictionarySourceCopyWithImpl(this._self, this._then);

  final _DictionarySource _self;
  final $Res Function(_DictionarySource) _then;

/// Create a copy of DictionarySource
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? url = freezed,}) {
  return _then(_DictionarySource(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$DictionaryCheck {

@JsonKey(name: 'q') String get question; List<Choice> get choices;/// Shown after the learner answers, so a wrong guess still teaches.
@JsonKey(name: 'explain') String get explanation;
/// Create a copy of DictionaryCheck
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DictionaryCheckCopyWith<DictionaryCheck> get copyWith => _$DictionaryCheckCopyWithImpl<DictionaryCheck>(this as DictionaryCheck, _$identity);

  /// Serializes this DictionaryCheck to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DictionaryCheck&&(identical(other.question, question) || other.question == question)&&const DeepCollectionEquality().equals(other.choices, choices)&&(identical(other.explanation, explanation) || other.explanation == explanation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,question,const DeepCollectionEquality().hash(choices),explanation);

@override
String toString() {
  return 'DictionaryCheck(question: $question, choices: $choices, explanation: $explanation)';
}


}

/// @nodoc
abstract mixin class $DictionaryCheckCopyWith<$Res>  {
  factory $DictionaryCheckCopyWith(DictionaryCheck value, $Res Function(DictionaryCheck) _then) = _$DictionaryCheckCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'q') String question, List<Choice> choices,@JsonKey(name: 'explain') String explanation
});




}
/// @nodoc
class _$DictionaryCheckCopyWithImpl<$Res>
    implements $DictionaryCheckCopyWith<$Res> {
  _$DictionaryCheckCopyWithImpl(this._self, this._then);

  final DictionaryCheck _self;
  final $Res Function(DictionaryCheck) _then;

/// Create a copy of DictionaryCheck
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? question = null,Object? choices = null,Object? explanation = null,}) {
  return _then(_self.copyWith(
question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,choices: null == choices ? _self.choices : choices // ignore: cast_nullable_to_non_nullable
as List<Choice>,explanation: null == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DictionaryCheck].
extension DictionaryCheckPatterns on DictionaryCheck {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DictionaryCheck value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DictionaryCheck() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DictionaryCheck value)  $default,){
final _that = this;
switch (_that) {
case _DictionaryCheck():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DictionaryCheck value)?  $default,){
final _that = this;
switch (_that) {
case _DictionaryCheck() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'q')  String question,  List<Choice> choices, @JsonKey(name: 'explain')  String explanation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DictionaryCheck() when $default != null:
return $default(_that.question,_that.choices,_that.explanation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'q')  String question,  List<Choice> choices, @JsonKey(name: 'explain')  String explanation)  $default,) {final _that = this;
switch (_that) {
case _DictionaryCheck():
return $default(_that.question,_that.choices,_that.explanation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'q')  String question,  List<Choice> choices, @JsonKey(name: 'explain')  String explanation)?  $default,) {final _that = this;
switch (_that) {
case _DictionaryCheck() when $default != null:
return $default(_that.question,_that.choices,_that.explanation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DictionaryCheck implements DictionaryCheck {
  const _DictionaryCheck({@JsonKey(name: 'q') required this.question, required final  List<Choice> choices, @JsonKey(name: 'explain') required this.explanation}): _choices = choices;
  factory _DictionaryCheck.fromJson(Map<String, dynamic> json) => _$DictionaryCheckFromJson(json);

@override@JsonKey(name: 'q') final  String question;
 final  List<Choice> _choices;
@override List<Choice> get choices {
  if (_choices is EqualUnmodifiableListView) return _choices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_choices);
}

/// Shown after the learner answers, so a wrong guess still teaches.
@override@JsonKey(name: 'explain') final  String explanation;

/// Create a copy of DictionaryCheck
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DictionaryCheckCopyWith<_DictionaryCheck> get copyWith => __$DictionaryCheckCopyWithImpl<_DictionaryCheck>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DictionaryCheckToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DictionaryCheck&&(identical(other.question, question) || other.question == question)&&const DeepCollectionEquality().equals(other._choices, _choices)&&(identical(other.explanation, explanation) || other.explanation == explanation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,question,const DeepCollectionEquality().hash(_choices),explanation);

@override
String toString() {
  return 'DictionaryCheck(question: $question, choices: $choices, explanation: $explanation)';
}


}

/// @nodoc
abstract mixin class _$DictionaryCheckCopyWith<$Res> implements $DictionaryCheckCopyWith<$Res> {
  factory _$DictionaryCheckCopyWith(_DictionaryCheck value, $Res Function(_DictionaryCheck) _then) = __$DictionaryCheckCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'q') String question, List<Choice> choices,@JsonKey(name: 'explain') String explanation
});




}
/// @nodoc
class __$DictionaryCheckCopyWithImpl<$Res>
    implements _$DictionaryCheckCopyWith<$Res> {
  __$DictionaryCheckCopyWithImpl(this._self, this._then);

  final _DictionaryCheck _self;
  final $Res Function(_DictionaryCheck) _then;

/// Create a copy of DictionaryCheck
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? question = null,Object? choices = null,Object? explanation = null,}) {
  return _then(_DictionaryCheck(
question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,choices: null == choices ? _self._choices : choices // ignore: cast_nullable_to_non_nullable
as List<Choice>,explanation: null == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$DictionaryTerm {

 String get id;/// The word itself, as it is displayed.
 String get term;/// The category this term belongs to. Always resolves — the extractor
/// refuses a bank whose pointer does not.
@JsonKey(name: 'cat') String get categoryId;/// The one-line answer to *what does this word mean*. Every term has one,
/// and it is what a free learner reads: the longer [deepExplanation] comes
/// with the course (`docs/decisions.md` §12).
@JsonKey(name: 'short') String get shortExplanation;/// Ids of terms worth reading next. May be empty, never absent.
@JsonKey(name: 'related') List<String> get relatedIds;/// Other names the same thing goes by, matched by search.
 List<String> get aliases;/// The lesson that teaches this term. **Absent means no lesson teaches
/// it** — the term is reference-only, and saying otherwise would promise a
/// lesson the course does not have.
@JsonKey(name: 'lesson') String? get lessonId;/// A pronunciation respelling, shipped as text.
@JsonKey(name: 'pron') String? get pronunciation;/// The longer explanation, for terms that repay one.
@JsonKey(name: 'deep') String? get deepExplanation;/// The term used in the wild, so it is recognisable next time.
 String? get example; List<DictionarySource> get sources; DictionaryCheck? get check;
/// Create a copy of DictionaryTerm
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DictionaryTermCopyWith<DictionaryTerm> get copyWith => _$DictionaryTermCopyWithImpl<DictionaryTerm>(this as DictionaryTerm, _$identity);

  /// Serializes this DictionaryTerm to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DictionaryTerm&&(identical(other.id, id) || other.id == id)&&(identical(other.term, term) || other.term == term)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.shortExplanation, shortExplanation) || other.shortExplanation == shortExplanation)&&const DeepCollectionEquality().equals(other.relatedIds, relatedIds)&&const DeepCollectionEquality().equals(other.aliases, aliases)&&(identical(other.lessonId, lessonId) || other.lessonId == lessonId)&&(identical(other.pronunciation, pronunciation) || other.pronunciation == pronunciation)&&(identical(other.deepExplanation, deepExplanation) || other.deepExplanation == deepExplanation)&&(identical(other.example, example) || other.example == example)&&const DeepCollectionEquality().equals(other.sources, sources)&&(identical(other.check, check) || other.check == check));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,term,categoryId,shortExplanation,const DeepCollectionEquality().hash(relatedIds),const DeepCollectionEquality().hash(aliases),lessonId,pronunciation,deepExplanation,example,const DeepCollectionEquality().hash(sources),check);

@override
String toString() {
  return 'DictionaryTerm(id: $id, term: $term, categoryId: $categoryId, shortExplanation: $shortExplanation, relatedIds: $relatedIds, aliases: $aliases, lessonId: $lessonId, pronunciation: $pronunciation, deepExplanation: $deepExplanation, example: $example, sources: $sources, check: $check)';
}


}

/// @nodoc
abstract mixin class $DictionaryTermCopyWith<$Res>  {
  factory $DictionaryTermCopyWith(DictionaryTerm value, $Res Function(DictionaryTerm) _then) = _$DictionaryTermCopyWithImpl;
@useResult
$Res call({
 String id, String term,@JsonKey(name: 'cat') String categoryId,@JsonKey(name: 'short') String shortExplanation,@JsonKey(name: 'related') List<String> relatedIds, List<String> aliases,@JsonKey(name: 'lesson') String? lessonId,@JsonKey(name: 'pron') String? pronunciation,@JsonKey(name: 'deep') String? deepExplanation, String? example, List<DictionarySource> sources, DictionaryCheck? check
});


$DictionaryCheckCopyWith<$Res>? get check;

}
/// @nodoc
class _$DictionaryTermCopyWithImpl<$Res>
    implements $DictionaryTermCopyWith<$Res> {
  _$DictionaryTermCopyWithImpl(this._self, this._then);

  final DictionaryTerm _self;
  final $Res Function(DictionaryTerm) _then;

/// Create a copy of DictionaryTerm
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? term = null,Object? categoryId = null,Object? shortExplanation = null,Object? relatedIds = null,Object? aliases = null,Object? lessonId = freezed,Object? pronunciation = freezed,Object? deepExplanation = freezed,Object? example = freezed,Object? sources = null,Object? check = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,term: null == term ? _self.term : term // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,shortExplanation: null == shortExplanation ? _self.shortExplanation : shortExplanation // ignore: cast_nullable_to_non_nullable
as String,relatedIds: null == relatedIds ? _self.relatedIds : relatedIds // ignore: cast_nullable_to_non_nullable
as List<String>,aliases: null == aliases ? _self.aliases : aliases // ignore: cast_nullable_to_non_nullable
as List<String>,lessonId: freezed == lessonId ? _self.lessonId : lessonId // ignore: cast_nullable_to_non_nullable
as String?,pronunciation: freezed == pronunciation ? _self.pronunciation : pronunciation // ignore: cast_nullable_to_non_nullable
as String?,deepExplanation: freezed == deepExplanation ? _self.deepExplanation : deepExplanation // ignore: cast_nullable_to_non_nullable
as String?,example: freezed == example ? _self.example : example // ignore: cast_nullable_to_non_nullable
as String?,sources: null == sources ? _self.sources : sources // ignore: cast_nullable_to_non_nullable
as List<DictionarySource>,check: freezed == check ? _self.check : check // ignore: cast_nullable_to_non_nullable
as DictionaryCheck?,
  ));
}
/// Create a copy of DictionaryTerm
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DictionaryCheckCopyWith<$Res>? get check {
    if (_self.check == null) {
    return null;
  }

  return $DictionaryCheckCopyWith<$Res>(_self.check!, (value) {
    return _then(_self.copyWith(check: value));
  });
}
}


/// Adds pattern-matching-related methods to [DictionaryTerm].
extension DictionaryTermPatterns on DictionaryTerm {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DictionaryTerm value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DictionaryTerm() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DictionaryTerm value)  $default,){
final _that = this;
switch (_that) {
case _DictionaryTerm():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DictionaryTerm value)?  $default,){
final _that = this;
switch (_that) {
case _DictionaryTerm() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String term, @JsonKey(name: 'cat')  String categoryId, @JsonKey(name: 'short')  String shortExplanation, @JsonKey(name: 'related')  List<String> relatedIds,  List<String> aliases, @JsonKey(name: 'lesson')  String? lessonId, @JsonKey(name: 'pron')  String? pronunciation, @JsonKey(name: 'deep')  String? deepExplanation,  String? example,  List<DictionarySource> sources,  DictionaryCheck? check)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DictionaryTerm() when $default != null:
return $default(_that.id,_that.term,_that.categoryId,_that.shortExplanation,_that.relatedIds,_that.aliases,_that.lessonId,_that.pronunciation,_that.deepExplanation,_that.example,_that.sources,_that.check);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String term, @JsonKey(name: 'cat')  String categoryId, @JsonKey(name: 'short')  String shortExplanation, @JsonKey(name: 'related')  List<String> relatedIds,  List<String> aliases, @JsonKey(name: 'lesson')  String? lessonId, @JsonKey(name: 'pron')  String? pronunciation, @JsonKey(name: 'deep')  String? deepExplanation,  String? example,  List<DictionarySource> sources,  DictionaryCheck? check)  $default,) {final _that = this;
switch (_that) {
case _DictionaryTerm():
return $default(_that.id,_that.term,_that.categoryId,_that.shortExplanation,_that.relatedIds,_that.aliases,_that.lessonId,_that.pronunciation,_that.deepExplanation,_that.example,_that.sources,_that.check);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String term, @JsonKey(name: 'cat')  String categoryId, @JsonKey(name: 'short')  String shortExplanation, @JsonKey(name: 'related')  List<String> relatedIds,  List<String> aliases, @JsonKey(name: 'lesson')  String? lessonId, @JsonKey(name: 'pron')  String? pronunciation, @JsonKey(name: 'deep')  String? deepExplanation,  String? example,  List<DictionarySource> sources,  DictionaryCheck? check)?  $default,) {final _that = this;
switch (_that) {
case _DictionaryTerm() when $default != null:
return $default(_that.id,_that.term,_that.categoryId,_that.shortExplanation,_that.relatedIds,_that.aliases,_that.lessonId,_that.pronunciation,_that.deepExplanation,_that.example,_that.sources,_that.check);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DictionaryTerm extends DictionaryTerm {
  const _DictionaryTerm({required this.id, required this.term, @JsonKey(name: 'cat') required this.categoryId, @JsonKey(name: 'short') required this.shortExplanation, @JsonKey(name: 'related') final  List<String> relatedIds = const <String>[], final  List<String> aliases = const <String>[], @JsonKey(name: 'lesson') this.lessonId, @JsonKey(name: 'pron') this.pronunciation, @JsonKey(name: 'deep') this.deepExplanation, this.example, final  List<DictionarySource> sources = const <DictionarySource>[], this.check}): _relatedIds = relatedIds,_aliases = aliases,_sources = sources,super._();
  factory _DictionaryTerm.fromJson(Map<String, dynamic> json) => _$DictionaryTermFromJson(json);

@override final  String id;
/// The word itself, as it is displayed.
@override final  String term;
/// The category this term belongs to. Always resolves — the extractor
/// refuses a bank whose pointer does not.
@override@JsonKey(name: 'cat') final  String categoryId;
/// The one-line answer to *what does this word mean*. Every term has one,
/// and it is what a free learner reads: the longer [deepExplanation] comes
/// with the course (`docs/decisions.md` §12).
@override@JsonKey(name: 'short') final  String shortExplanation;
/// Ids of terms worth reading next. May be empty, never absent.
 final  List<String> _relatedIds;
/// Ids of terms worth reading next. May be empty, never absent.
@override@JsonKey(name: 'related') List<String> get relatedIds {
  if (_relatedIds is EqualUnmodifiableListView) return _relatedIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_relatedIds);
}

/// Other names the same thing goes by, matched by search.
 final  List<String> _aliases;
/// Other names the same thing goes by, matched by search.
@override@JsonKey() List<String> get aliases {
  if (_aliases is EqualUnmodifiableListView) return _aliases;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_aliases);
}

/// The lesson that teaches this term. **Absent means no lesson teaches
/// it** — the term is reference-only, and saying otherwise would promise a
/// lesson the course does not have.
@override@JsonKey(name: 'lesson') final  String? lessonId;
/// A pronunciation respelling, shipped as text.
@override@JsonKey(name: 'pron') final  String? pronunciation;
/// The longer explanation, for terms that repay one.
@override@JsonKey(name: 'deep') final  String? deepExplanation;
/// The term used in the wild, so it is recognisable next time.
@override final  String? example;
 final  List<DictionarySource> _sources;
@override@JsonKey() List<DictionarySource> get sources {
  if (_sources is EqualUnmodifiableListView) return _sources;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sources);
}

@override final  DictionaryCheck? check;

/// Create a copy of DictionaryTerm
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DictionaryTermCopyWith<_DictionaryTerm> get copyWith => __$DictionaryTermCopyWithImpl<_DictionaryTerm>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DictionaryTermToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DictionaryTerm&&(identical(other.id, id) || other.id == id)&&(identical(other.term, term) || other.term == term)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.shortExplanation, shortExplanation) || other.shortExplanation == shortExplanation)&&const DeepCollectionEquality().equals(other._relatedIds, _relatedIds)&&const DeepCollectionEquality().equals(other._aliases, _aliases)&&(identical(other.lessonId, lessonId) || other.lessonId == lessonId)&&(identical(other.pronunciation, pronunciation) || other.pronunciation == pronunciation)&&(identical(other.deepExplanation, deepExplanation) || other.deepExplanation == deepExplanation)&&(identical(other.example, example) || other.example == example)&&const DeepCollectionEquality().equals(other._sources, _sources)&&(identical(other.check, check) || other.check == check));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,term,categoryId,shortExplanation,const DeepCollectionEquality().hash(_relatedIds),const DeepCollectionEquality().hash(_aliases),lessonId,pronunciation,deepExplanation,example,const DeepCollectionEquality().hash(_sources),check);

@override
String toString() {
  return 'DictionaryTerm(id: $id, term: $term, categoryId: $categoryId, shortExplanation: $shortExplanation, relatedIds: $relatedIds, aliases: $aliases, lessonId: $lessonId, pronunciation: $pronunciation, deepExplanation: $deepExplanation, example: $example, sources: $sources, check: $check)';
}


}

/// @nodoc
abstract mixin class _$DictionaryTermCopyWith<$Res> implements $DictionaryTermCopyWith<$Res> {
  factory _$DictionaryTermCopyWith(_DictionaryTerm value, $Res Function(_DictionaryTerm) _then) = __$DictionaryTermCopyWithImpl;
@override @useResult
$Res call({
 String id, String term,@JsonKey(name: 'cat') String categoryId,@JsonKey(name: 'short') String shortExplanation,@JsonKey(name: 'related') List<String> relatedIds, List<String> aliases,@JsonKey(name: 'lesson') String? lessonId,@JsonKey(name: 'pron') String? pronunciation,@JsonKey(name: 'deep') String? deepExplanation, String? example, List<DictionarySource> sources, DictionaryCheck? check
});


@override $DictionaryCheckCopyWith<$Res>? get check;

}
/// @nodoc
class __$DictionaryTermCopyWithImpl<$Res>
    implements _$DictionaryTermCopyWith<$Res> {
  __$DictionaryTermCopyWithImpl(this._self, this._then);

  final _DictionaryTerm _self;
  final $Res Function(_DictionaryTerm) _then;

/// Create a copy of DictionaryTerm
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? term = null,Object? categoryId = null,Object? shortExplanation = null,Object? relatedIds = null,Object? aliases = null,Object? lessonId = freezed,Object? pronunciation = freezed,Object? deepExplanation = freezed,Object? example = freezed,Object? sources = null,Object? check = freezed,}) {
  return _then(_DictionaryTerm(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,term: null == term ? _self.term : term // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,shortExplanation: null == shortExplanation ? _self.shortExplanation : shortExplanation // ignore: cast_nullable_to_non_nullable
as String,relatedIds: null == relatedIds ? _self._relatedIds : relatedIds // ignore: cast_nullable_to_non_nullable
as List<String>,aliases: null == aliases ? _self._aliases : aliases // ignore: cast_nullable_to_non_nullable
as List<String>,lessonId: freezed == lessonId ? _self.lessonId : lessonId // ignore: cast_nullable_to_non_nullable
as String?,pronunciation: freezed == pronunciation ? _self.pronunciation : pronunciation // ignore: cast_nullable_to_non_nullable
as String?,deepExplanation: freezed == deepExplanation ? _self.deepExplanation : deepExplanation // ignore: cast_nullable_to_non_nullable
as String?,example: freezed == example ? _self.example : example // ignore: cast_nullable_to_non_nullable
as String?,sources: null == sources ? _self._sources : sources // ignore: cast_nullable_to_non_nullable
as List<DictionarySource>,check: freezed == check ? _self.check : check // ignore: cast_nullable_to_non_nullable
as DictionaryCheck?,
  ));
}

/// Create a copy of DictionaryTerm
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DictionaryCheckCopyWith<$Res>? get check {
    if (_self.check == null) {
    return null;
  }

  return $DictionaryCheckCopyWith<$Res>(_self.check!, (value) {
    return _then(_self.copyWith(check: value));
  });
}
}

// dart format on
