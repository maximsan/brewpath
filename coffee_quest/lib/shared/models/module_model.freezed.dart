// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'module_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ModuleModel _$ModuleModelFromJson(Map<String, dynamic> json) {
  return _ModuleModel.fromJson(json);
}

/// @nodoc
mixin _$ModuleModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get iconName => throw _privateConstructorUsedError;
  List<String> get lessonIds => throw _privateConstructorUsedError;
  String? get unlockRequirement => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ModuleModelCopyWith<ModuleModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModuleModelCopyWith<$Res> {
  factory $ModuleModelCopyWith(
          ModuleModel value, $Res Function(ModuleModel) then) =
      _$ModuleModelCopyWithImpl<$Res, ModuleModel>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String iconName,
      List<String> lessonIds,
      String? unlockRequirement});
}

/// @nodoc
class _$ModuleModelCopyWithImpl<$Res, $Val extends ModuleModel>
    implements $ModuleModelCopyWith<$Res> {
  _$ModuleModelCopyWithImpl(this._value, this._then);

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
    Object? iconName = null,
    Object? lessonIds = null,
    Object? unlockRequirement = freezed,
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
      iconName: null == iconName
          ? _value.iconName
          : iconName // ignore: cast_nullable_to_non_nullable
              as String,
      lessonIds: null == lessonIds
          ? _value.lessonIds
          : lessonIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      unlockRequirement: freezed == unlockRequirement
          ? _value.unlockRequirement
          : unlockRequirement // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ModuleModelImplCopyWith<$Res>
    implements $ModuleModelCopyWith<$Res> {
  factory _$$ModuleModelImplCopyWith(
          _$ModuleModelImpl value, $Res Function(_$ModuleModelImpl) then) =
      __$$ModuleModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String iconName,
      List<String> lessonIds,
      String? unlockRequirement});
}

/// @nodoc
class __$$ModuleModelImplCopyWithImpl<$Res>
    extends _$ModuleModelCopyWithImpl<$Res, _$ModuleModelImpl>
    implements _$$ModuleModelImplCopyWith<$Res> {
  __$$ModuleModelImplCopyWithImpl(
      _$ModuleModelImpl _value, $Res Function(_$ModuleModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? iconName = null,
    Object? lessonIds = null,
    Object? unlockRequirement = freezed,
  }) {
    return _then(_$ModuleModelImpl(
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
      iconName: null == iconName
          ? _value.iconName
          : iconName // ignore: cast_nullable_to_non_nullable
              as String,
      lessonIds: null == lessonIds
          ? _value._lessonIds
          : lessonIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      unlockRequirement: freezed == unlockRequirement
          ? _value.unlockRequirement
          : unlockRequirement // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ModuleModelImpl implements _ModuleModel {
  const _$ModuleModelImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.iconName,
      required final List<String> lessonIds,
      this.unlockRequirement})
      : _lessonIds = lessonIds;

  factory _$ModuleModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ModuleModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String iconName;
  final List<String> _lessonIds;
  @override
  List<String> get lessonIds {
    if (_lessonIds is EqualUnmodifiableListView) return _lessonIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lessonIds);
  }

  @override
  final String? unlockRequirement;

  @override
  String toString() {
    return 'ModuleModel(id: $id, title: $title, description: $description, iconName: $iconName, lessonIds: $lessonIds, unlockRequirement: $unlockRequirement)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModuleModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.iconName, iconName) ||
                other.iconName == iconName) &&
            const DeepCollectionEquality()
                .equals(other._lessonIds, _lessonIds) &&
            (identical(other.unlockRequirement, unlockRequirement) ||
                other.unlockRequirement == unlockRequirement));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, description, iconName,
      const DeepCollectionEquality().hash(_lessonIds), unlockRequirement);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ModuleModelImplCopyWith<_$ModuleModelImpl> get copyWith =>
      __$$ModuleModelImplCopyWithImpl<_$ModuleModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ModuleModelImplToJson(
      this,
    );
  }
}

abstract class _ModuleModel implements ModuleModel {
  const factory _ModuleModel(
      {required final String id,
      required final String title,
      required final String description,
      required final String iconName,
      required final List<String> lessonIds,
      final String? unlockRequirement}) = _$ModuleModelImpl;

  factory _ModuleModel.fromJson(Map<String, dynamic> json) =
      _$ModuleModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String get iconName;
  @override
  List<String> get lessonIds;
  @override
  String? get unlockRequirement;
  @override
  @JsonKey(ignore: true)
  _$$ModuleModelImplCopyWith<_$ModuleModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
