// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'coffee_card_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CoffeeCardModel _$CoffeeCardModelFromJson(Map<String, dynamic> json) {
  return _CoffeeCardModel.fromJson(json);
}

/// @nodoc
mixin _$CoffeeCardModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get moduleTag => throw _privateConstructorUsedError;
  String get iconName => throw _privateConstructorUsedError;
  String get lessonId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CoffeeCardModelCopyWith<CoffeeCardModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CoffeeCardModelCopyWith<$Res> {
  factory $CoffeeCardModelCopyWith(
          CoffeeCardModel value, $Res Function(CoffeeCardModel) then) =
      _$CoffeeCardModelCopyWithImpl<$Res, CoffeeCardModel>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String moduleTag,
      String iconName,
      String lessonId});
}

/// @nodoc
class _$CoffeeCardModelCopyWithImpl<$Res, $Val extends CoffeeCardModel>
    implements $CoffeeCardModelCopyWith<$Res> {
  _$CoffeeCardModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? moduleTag = null,
    Object? iconName = null,
    Object? lessonId = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      moduleTag: null == moduleTag
          ? _value.moduleTag
          : moduleTag // ignore: cast_nullable_to_non_nullable
              as String,
      iconName: null == iconName
          ? _value.iconName
          : iconName // ignore: cast_nullable_to_non_nullable
              as String,
      lessonId: null == lessonId
          ? _value.lessonId
          : lessonId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CoffeeCardModelImplCopyWith<$Res>
    implements $CoffeeCardModelCopyWith<$Res> {
  factory _$$CoffeeCardModelImplCopyWith(_$CoffeeCardModelImpl value,
          $Res Function(_$CoffeeCardModelImpl) then) =
      __$$CoffeeCardModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String moduleTag,
      String iconName,
      String lessonId});
}

/// @nodoc
class __$$CoffeeCardModelImplCopyWithImpl<$Res>
    extends _$CoffeeCardModelCopyWithImpl<$Res, _$CoffeeCardModelImpl>
    implements _$$CoffeeCardModelImplCopyWith<$Res> {
  __$$CoffeeCardModelImplCopyWithImpl(
      _$CoffeeCardModelImpl _value, $Res Function(_$CoffeeCardModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? moduleTag = null,
    Object? iconName = null,
    Object? lessonId = null,
  }) {
    return _then(_$CoffeeCardModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      moduleTag: null == moduleTag
          ? _value.moduleTag
          : moduleTag // ignore: cast_nullable_to_non_nullable
              as String,
      iconName: null == iconName
          ? _value.iconName
          : iconName // ignore: cast_nullable_to_non_nullable
              as String,
      lessonId: null == lessonId
          ? _value.lessonId
          : lessonId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CoffeeCardModelImpl implements _CoffeeCardModel {
  const _$CoffeeCardModelImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.moduleTag,
      required this.iconName,
      required this.lessonId});

  factory _$CoffeeCardModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CoffeeCardModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String moduleTag;
  @override
  final String iconName;
  @override
  final String lessonId;

  @override
  String toString() {
    return 'CoffeeCardModel(id: $id, title: $title, description: $description, moduleTag: $moduleTag, iconName: $iconName, lessonId: $lessonId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CoffeeCardModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.moduleTag, moduleTag) ||
                other.moduleTag == moduleTag) &&
            (identical(other.iconName, iconName) ||
                other.iconName == iconName) &&
            (identical(other.lessonId, lessonId) ||
                other.lessonId == lessonId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, title, description, moduleTag, iconName, lessonId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CoffeeCardModelImplCopyWith<_$CoffeeCardModelImpl> get copyWith =>
      __$$CoffeeCardModelImplCopyWithImpl<_$CoffeeCardModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CoffeeCardModelImplToJson(
      this,
    );
  }
}

abstract class _CoffeeCardModel implements CoffeeCardModel {
  const factory _CoffeeCardModel(
      {required final String id,
      required final String title,
      required final String description,
      required final String moduleTag,
      required final String iconName,
      required final String lessonId}) = _$CoffeeCardModelImpl;

  factory _CoffeeCardModel.fromJson(Map<String, dynamic> json) =
      _$CoffeeCardModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String get moduleTag;
  @override
  String get iconName;
  @override
  String get lessonId;
  @override
  @JsonKey(ignore: true)
  _$$CoffeeCardModelImplCopyWith<_$CoffeeCardModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
