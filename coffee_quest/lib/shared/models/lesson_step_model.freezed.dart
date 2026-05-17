// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lesson_step_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LessonStepModel _$LessonStepModelFromJson(Map<String, dynamic> json) {
  switch (json['type']) {
    case 'multiple_choice':
      return MultipleChoiceStep.fromJson(json);
    case 'drag_drop':
      return DragDropStep.fromJson(json);
    case 'slider':
      return SliderStep.fromJson(json);
    case 'tap_order':
      return TapOrderStep.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'type', 'LessonStepModel',
          'Invalid union type "${json['type']}"!');
  }
}

/// @nodoc
mixin _$LessonStepModel {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String question, List<String> options,
            int correctIndex, String explanation)
        multipleChoice,
    required TResult Function(
            String instruction, List<String> terms, List<String> definitions)
        dragDrop,
    required TResult Function(
            String instruction,
            double minValue,
            double maxValue,
            double targetMin,
            double targetMax,
            String unit,
            String explanation)
        slider,
    required TResult Function(
            String instruction, List<String> items, String explanation)
        tapOrder,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String question, List<String> options, int correctIndex,
            String explanation)?
        multipleChoice,
    TResult? Function(
            String instruction, List<String> terms, List<String> definitions)?
        dragDrop,
    TResult? Function(
            String instruction,
            double minValue,
            double maxValue,
            double targetMin,
            double targetMax,
            String unit,
            String explanation)?
        slider,
    TResult? Function(
            String instruction, List<String> items, String explanation)?
        tapOrder,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String question, List<String> options, int correctIndex,
            String explanation)?
        multipleChoice,
    TResult Function(
            String instruction, List<String> terms, List<String> definitions)?
        dragDrop,
    TResult Function(
            String instruction,
            double minValue,
            double maxValue,
            double targetMin,
            double targetMax,
            String unit,
            String explanation)?
        slider,
    TResult Function(
            String instruction, List<String> items, String explanation)?
        tapOrder,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MultipleChoiceStep value) multipleChoice,
    required TResult Function(DragDropStep value) dragDrop,
    required TResult Function(SliderStep value) slider,
    required TResult Function(TapOrderStep value) tapOrder,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MultipleChoiceStep value)? multipleChoice,
    TResult? Function(DragDropStep value)? dragDrop,
    TResult? Function(SliderStep value)? slider,
    TResult? Function(TapOrderStep value)? tapOrder,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MultipleChoiceStep value)? multipleChoice,
    TResult Function(DragDropStep value)? dragDrop,
    TResult Function(SliderStep value)? slider,
    TResult Function(TapOrderStep value)? tapOrder,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LessonStepModelCopyWith<$Res> {
  factory $LessonStepModelCopyWith(
          LessonStepModel value, $Res Function(LessonStepModel) then) =
      _$LessonStepModelCopyWithImpl<$Res, LessonStepModel>;
}

/// @nodoc
class _$LessonStepModelCopyWithImpl<$Res, $Val extends LessonStepModel>
    implements $LessonStepModelCopyWith<$Res> {
  _$LessonStepModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$MultipleChoiceStepImplCopyWith<$Res> {
  factory _$$MultipleChoiceStepImplCopyWith(_$MultipleChoiceStepImpl value,
          $Res Function(_$MultipleChoiceStepImpl) then) =
      __$$MultipleChoiceStepImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {String question,
      List<String> options,
      int correctIndex,
      String explanation});
}

/// @nodoc
class __$$MultipleChoiceStepImplCopyWithImpl<$Res>
    extends _$LessonStepModelCopyWithImpl<$Res, _$MultipleChoiceStepImpl>
    implements _$$MultipleChoiceStepImplCopyWith<$Res> {
  __$$MultipleChoiceStepImplCopyWithImpl(_$MultipleChoiceStepImpl _value,
      $Res Function(_$MultipleChoiceStepImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? question = null,
    Object? options = null,
    Object? correctIndex = null,
    Object? explanation = null,
  }) {
    return _then(_$MultipleChoiceStepImpl(
      question: null == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as String,
      options: null == options
          ? _value._options
          : options // ignore: cast_nullable_to_non_nullable
              as List<String>,
      correctIndex: null == correctIndex
          ? _value.correctIndex
          : correctIndex // ignore: cast_nullable_to_non_nullable
              as int,
      explanation: null == explanation
          ? _value.explanation
          : explanation // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MultipleChoiceStepImpl implements MultipleChoiceStep {
  const _$MultipleChoiceStepImpl(
      {required this.question,
      required final List<String> options,
      required this.correctIndex,
      required this.explanation,
      final String? $type})
      : _options = options,
        $type = $type ?? 'multiple_choice';

  factory _$MultipleChoiceStepImpl.fromJson(Map<String, dynamic> json) =>
      _$$MultipleChoiceStepImplFromJson(json);

  @override
  final String question;
  final List<String> _options;
  @override
  List<String> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

  @override
  final int correctIndex;
  @override
  final String explanation;

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'LessonStepModel.multipleChoice(question: $question, options: $options, correctIndex: $correctIndex, explanation: $explanation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MultipleChoiceStepImpl &&
            (identical(other.question, question) ||
                other.question == question) &&
            const DeepCollectionEquality().equals(other._options, _options) &&
            (identical(other.correctIndex, correctIndex) ||
                other.correctIndex == correctIndex) &&
            (identical(other.explanation, explanation) ||
                other.explanation == explanation));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, question,
      const DeepCollectionEquality().hash(_options), correctIndex, explanation);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MultipleChoiceStepImplCopyWith<_$MultipleChoiceStepImpl> get copyWith =>
      __$$MultipleChoiceStepImplCopyWithImpl<_$MultipleChoiceStepImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String question, List<String> options,
            int correctIndex, String explanation)
        multipleChoice,
    required TResult Function(
            String instruction, List<String> terms, List<String> definitions)
        dragDrop,
    required TResult Function(
            String instruction,
            double minValue,
            double maxValue,
            double targetMin,
            double targetMax,
            String unit,
            String explanation)
        slider,
    required TResult Function(
            String instruction, List<String> items, String explanation)
        tapOrder,
  }) {
    return multipleChoice(question, options, correctIndex, explanation);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String question, List<String> options, int correctIndex,
            String explanation)?
        multipleChoice,
    TResult? Function(
            String instruction, List<String> terms, List<String> definitions)?
        dragDrop,
    TResult? Function(
            String instruction,
            double minValue,
            double maxValue,
            double targetMin,
            double targetMax,
            String unit,
            String explanation)?
        slider,
    TResult? Function(
            String instruction, List<String> items, String explanation)?
        tapOrder,
  }) {
    return multipleChoice?.call(question, options, correctIndex, explanation);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String question, List<String> options, int correctIndex,
            String explanation)?
        multipleChoice,
    TResult Function(
            String instruction, List<String> terms, List<String> definitions)?
        dragDrop,
    TResult Function(
            String instruction,
            double minValue,
            double maxValue,
            double targetMin,
            double targetMax,
            String unit,
            String explanation)?
        slider,
    TResult Function(
            String instruction, List<String> items, String explanation)?
        tapOrder,
    required TResult orElse(),
  }) {
    if (multipleChoice != null) {
      return multipleChoice(question, options, correctIndex, explanation);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MultipleChoiceStep value) multipleChoice,
    required TResult Function(DragDropStep value) dragDrop,
    required TResult Function(SliderStep value) slider,
    required TResult Function(TapOrderStep value) tapOrder,
  }) {
    return multipleChoice(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MultipleChoiceStep value)? multipleChoice,
    TResult? Function(DragDropStep value)? dragDrop,
    TResult? Function(SliderStep value)? slider,
    TResult? Function(TapOrderStep value)? tapOrder,
  }) {
    return multipleChoice?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MultipleChoiceStep value)? multipleChoice,
    TResult Function(DragDropStep value)? dragDrop,
    TResult Function(SliderStep value)? slider,
    TResult Function(TapOrderStep value)? tapOrder,
    required TResult orElse(),
  }) {
    if (multipleChoice != null) {
      return multipleChoice(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$MultipleChoiceStepImplToJson(
      this,
    );
  }
}

abstract class MultipleChoiceStep implements LessonStepModel {
  const factory MultipleChoiceStep(
      {required final String question,
      required final List<String> options,
      required final int correctIndex,
      required final String explanation}) = _$MultipleChoiceStepImpl;

  factory MultipleChoiceStep.fromJson(Map<String, dynamic> json) =
      _$MultipleChoiceStepImpl.fromJson;

  String get question;
  List<String> get options;
  int get correctIndex;
  String get explanation;
  @JsonKey(ignore: true)
  _$$MultipleChoiceStepImplCopyWith<_$MultipleChoiceStepImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DragDropStepImplCopyWith<$Res> {
  factory _$$DragDropStepImplCopyWith(
          _$DragDropStepImpl value, $Res Function(_$DragDropStepImpl) then) =
      __$$DragDropStepImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String instruction, List<String> terms, List<String> definitions});
}

/// @nodoc
class __$$DragDropStepImplCopyWithImpl<$Res>
    extends _$LessonStepModelCopyWithImpl<$Res, _$DragDropStepImpl>
    implements _$$DragDropStepImplCopyWith<$Res> {
  __$$DragDropStepImplCopyWithImpl(
      _$DragDropStepImpl _value, $Res Function(_$DragDropStepImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? instruction = null,
    Object? terms = null,
    Object? definitions = null,
  }) {
    return _then(_$DragDropStepImpl(
      instruction: null == instruction
          ? _value.instruction
          : instruction // ignore: cast_nullable_to_non_nullable
              as String,
      terms: null == terms
          ? _value._terms
          : terms // ignore: cast_nullable_to_non_nullable
              as List<String>,
      definitions: null == definitions
          ? _value._definitions
          : definitions // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DragDropStepImpl implements DragDropStep {
  const _$DragDropStepImpl(
      {required this.instruction,
      required final List<String> terms,
      required final List<String> definitions,
      final String? $type})
      : _terms = terms,
        _definitions = definitions,
        $type = $type ?? 'drag_drop';

  factory _$DragDropStepImpl.fromJson(Map<String, dynamic> json) =>
      _$$DragDropStepImplFromJson(json);

  @override
  final String instruction;
  final List<String> _terms;
  @override
  List<String> get terms {
    if (_terms is EqualUnmodifiableListView) return _terms;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_terms);
  }

  final List<String> _definitions;
  @override
  List<String> get definitions {
    if (_definitions is EqualUnmodifiableListView) return _definitions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_definitions);
  }

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'LessonStepModel.dragDrop(instruction: $instruction, terms: $terms, definitions: $definitions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DragDropStepImpl &&
            (identical(other.instruction, instruction) ||
                other.instruction == instruction) &&
            const DeepCollectionEquality().equals(other._terms, _terms) &&
            const DeepCollectionEquality()
                .equals(other._definitions, _definitions));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      instruction,
      const DeepCollectionEquality().hash(_terms),
      const DeepCollectionEquality().hash(_definitions));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DragDropStepImplCopyWith<_$DragDropStepImpl> get copyWith =>
      __$$DragDropStepImplCopyWithImpl<_$DragDropStepImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String question, List<String> options,
            int correctIndex, String explanation)
        multipleChoice,
    required TResult Function(
            String instruction, List<String> terms, List<String> definitions)
        dragDrop,
    required TResult Function(
            String instruction,
            double minValue,
            double maxValue,
            double targetMin,
            double targetMax,
            String unit,
            String explanation)
        slider,
    required TResult Function(
            String instruction, List<String> items, String explanation)
        tapOrder,
  }) {
    return dragDrop(instruction, terms, definitions);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String question, List<String> options, int correctIndex,
            String explanation)?
        multipleChoice,
    TResult? Function(
            String instruction, List<String> terms, List<String> definitions)?
        dragDrop,
    TResult? Function(
            String instruction,
            double minValue,
            double maxValue,
            double targetMin,
            double targetMax,
            String unit,
            String explanation)?
        slider,
    TResult? Function(
            String instruction, List<String> items, String explanation)?
        tapOrder,
  }) {
    return dragDrop?.call(instruction, terms, definitions);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String question, List<String> options, int correctIndex,
            String explanation)?
        multipleChoice,
    TResult Function(
            String instruction, List<String> terms, List<String> definitions)?
        dragDrop,
    TResult Function(
            String instruction,
            double minValue,
            double maxValue,
            double targetMin,
            double targetMax,
            String unit,
            String explanation)?
        slider,
    TResult Function(
            String instruction, List<String> items, String explanation)?
        tapOrder,
    required TResult orElse(),
  }) {
    if (dragDrop != null) {
      return dragDrop(instruction, terms, definitions);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MultipleChoiceStep value) multipleChoice,
    required TResult Function(DragDropStep value) dragDrop,
    required TResult Function(SliderStep value) slider,
    required TResult Function(TapOrderStep value) tapOrder,
  }) {
    return dragDrop(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MultipleChoiceStep value)? multipleChoice,
    TResult? Function(DragDropStep value)? dragDrop,
    TResult? Function(SliderStep value)? slider,
    TResult? Function(TapOrderStep value)? tapOrder,
  }) {
    return dragDrop?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MultipleChoiceStep value)? multipleChoice,
    TResult Function(DragDropStep value)? dragDrop,
    TResult Function(SliderStep value)? slider,
    TResult Function(TapOrderStep value)? tapOrder,
    required TResult orElse(),
  }) {
    if (dragDrop != null) {
      return dragDrop(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$DragDropStepImplToJson(
      this,
    );
  }
}

abstract class DragDropStep implements LessonStepModel {
  const factory DragDropStep(
      {required final String instruction,
      required final List<String> terms,
      required final List<String> definitions}) = _$DragDropStepImpl;

  factory DragDropStep.fromJson(Map<String, dynamic> json) =
      _$DragDropStepImpl.fromJson;

  String get instruction;
  List<String> get terms;
  List<String> get definitions;
  @JsonKey(ignore: true)
  _$$DragDropStepImplCopyWith<_$DragDropStepImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SliderStepImplCopyWith<$Res> {
  factory _$$SliderStepImplCopyWith(
          _$SliderStepImpl value, $Res Function(_$SliderStepImpl) then) =
      __$$SliderStepImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {String instruction,
      double minValue,
      double maxValue,
      double targetMin,
      double targetMax,
      String unit,
      String explanation});
}

/// @nodoc
class __$$SliderStepImplCopyWithImpl<$Res>
    extends _$LessonStepModelCopyWithImpl<$Res, _$SliderStepImpl>
    implements _$$SliderStepImplCopyWith<$Res> {
  __$$SliderStepImplCopyWithImpl(
      _$SliderStepImpl _value, $Res Function(_$SliderStepImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? instruction = null,
    Object? minValue = null,
    Object? maxValue = null,
    Object? targetMin = null,
    Object? targetMax = null,
    Object? unit = null,
    Object? explanation = null,
  }) {
    return _then(_$SliderStepImpl(
      instruction: null == instruction
          ? _value.instruction
          : instruction // ignore: cast_nullable_to_non_nullable
              as String,
      minValue: null == minValue
          ? _value.minValue
          : minValue // ignore: cast_nullable_to_non_nullable
              as double,
      maxValue: null == maxValue
          ? _value.maxValue
          : maxValue // ignore: cast_nullable_to_non_nullable
              as double,
      targetMin: null == targetMin
          ? _value.targetMin
          : targetMin // ignore: cast_nullable_to_non_nullable
              as double,
      targetMax: null == targetMax
          ? _value.targetMax
          : targetMax // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      explanation: null == explanation
          ? _value.explanation
          : explanation // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SliderStepImpl implements SliderStep {
  const _$SliderStepImpl(
      {required this.instruction,
      required this.minValue,
      required this.maxValue,
      required this.targetMin,
      required this.targetMax,
      required this.unit,
      required this.explanation,
      final String? $type})
      : $type = $type ?? 'slider';

  factory _$SliderStepImpl.fromJson(Map<String, dynamic> json) =>
      _$$SliderStepImplFromJson(json);

  @override
  final String instruction;
  @override
  final double minValue;
  @override
  final double maxValue;
  @override
  final double targetMin;
  @override
  final double targetMax;
  @override
  final String unit;
  @override
  final String explanation;

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'LessonStepModel.slider(instruction: $instruction, minValue: $minValue, maxValue: $maxValue, targetMin: $targetMin, targetMax: $targetMax, unit: $unit, explanation: $explanation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SliderStepImpl &&
            (identical(other.instruction, instruction) ||
                other.instruction == instruction) &&
            (identical(other.minValue, minValue) ||
                other.minValue == minValue) &&
            (identical(other.maxValue, maxValue) ||
                other.maxValue == maxValue) &&
            (identical(other.targetMin, targetMin) ||
                other.targetMin == targetMin) &&
            (identical(other.targetMax, targetMax) ||
                other.targetMax == targetMax) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.explanation, explanation) ||
                other.explanation == explanation));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, instruction, minValue, maxValue,
      targetMin, targetMax, unit, explanation);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SliderStepImplCopyWith<_$SliderStepImpl> get copyWith =>
      __$$SliderStepImplCopyWithImpl<_$SliderStepImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String question, List<String> options,
            int correctIndex, String explanation)
        multipleChoice,
    required TResult Function(
            String instruction, List<String> terms, List<String> definitions)
        dragDrop,
    required TResult Function(
            String instruction,
            double minValue,
            double maxValue,
            double targetMin,
            double targetMax,
            String unit,
            String explanation)
        slider,
    required TResult Function(
            String instruction, List<String> items, String explanation)
        tapOrder,
  }) {
    return slider(instruction, minValue, maxValue, targetMin, targetMax, unit,
        explanation);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String question, List<String> options, int correctIndex,
            String explanation)?
        multipleChoice,
    TResult? Function(
            String instruction, List<String> terms, List<String> definitions)?
        dragDrop,
    TResult? Function(
            String instruction,
            double minValue,
            double maxValue,
            double targetMin,
            double targetMax,
            String unit,
            String explanation)?
        slider,
    TResult? Function(
            String instruction, List<String> items, String explanation)?
        tapOrder,
  }) {
    return slider?.call(instruction, minValue, maxValue, targetMin, targetMax,
        unit, explanation);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String question, List<String> options, int correctIndex,
            String explanation)?
        multipleChoice,
    TResult Function(
            String instruction, List<String> terms, List<String> definitions)?
        dragDrop,
    TResult Function(
            String instruction,
            double minValue,
            double maxValue,
            double targetMin,
            double targetMax,
            String unit,
            String explanation)?
        slider,
    TResult Function(
            String instruction, List<String> items, String explanation)?
        tapOrder,
    required TResult orElse(),
  }) {
    if (slider != null) {
      return slider(instruction, minValue, maxValue, targetMin, targetMax, unit,
          explanation);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MultipleChoiceStep value) multipleChoice,
    required TResult Function(DragDropStep value) dragDrop,
    required TResult Function(SliderStep value) slider,
    required TResult Function(TapOrderStep value) tapOrder,
  }) {
    return slider(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MultipleChoiceStep value)? multipleChoice,
    TResult? Function(DragDropStep value)? dragDrop,
    TResult? Function(SliderStep value)? slider,
    TResult? Function(TapOrderStep value)? tapOrder,
  }) {
    return slider?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MultipleChoiceStep value)? multipleChoice,
    TResult Function(DragDropStep value)? dragDrop,
    TResult Function(SliderStep value)? slider,
    TResult Function(TapOrderStep value)? tapOrder,
    required TResult orElse(),
  }) {
    if (slider != null) {
      return slider(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$SliderStepImplToJson(
      this,
    );
  }
}

abstract class SliderStep implements LessonStepModel {
  const factory SliderStep(
      {required final String instruction,
      required final double minValue,
      required final double maxValue,
      required final double targetMin,
      required final double targetMax,
      required final String unit,
      required final String explanation}) = _$SliderStepImpl;

  factory SliderStep.fromJson(Map<String, dynamic> json) =
      _$SliderStepImpl.fromJson;

  String get instruction;
  double get minValue;
  double get maxValue;
  double get targetMin;
  double get targetMax;
  String get unit;
  String get explanation;
  @JsonKey(ignore: true)
  _$$SliderStepImplCopyWith<_$SliderStepImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TapOrderStepImplCopyWith<$Res> {
  factory _$$TapOrderStepImplCopyWith(
          _$TapOrderStepImpl value, $Res Function(_$TapOrderStepImpl) then) =
      __$$TapOrderStepImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String instruction, List<String> items, String explanation});
}

/// @nodoc
class __$$TapOrderStepImplCopyWithImpl<$Res>
    extends _$LessonStepModelCopyWithImpl<$Res, _$TapOrderStepImpl>
    implements _$$TapOrderStepImplCopyWith<$Res> {
  __$$TapOrderStepImplCopyWithImpl(
      _$TapOrderStepImpl _value, $Res Function(_$TapOrderStepImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? instruction = null,
    Object? items = null,
    Object? explanation = null,
  }) {
    return _then(_$TapOrderStepImpl(
      instruction: null == instruction
          ? _value.instruction
          : instruction // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<String>,
      explanation: null == explanation
          ? _value.explanation
          : explanation // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TapOrderStepImpl implements TapOrderStep {
  const _$TapOrderStepImpl(
      {required this.instruction,
      required final List<String> items,
      required this.explanation,
      final String? $type})
      : _items = items,
        $type = $type ?? 'tap_order';

  factory _$TapOrderStepImpl.fromJson(Map<String, dynamic> json) =>
      _$$TapOrderStepImplFromJson(json);

  @override
  final String instruction;
  final List<String> _items;
  @override
  List<String> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final String explanation;

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'LessonStepModel.tapOrder(instruction: $instruction, items: $items, explanation: $explanation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TapOrderStepImpl &&
            (identical(other.instruction, instruction) ||
                other.instruction == instruction) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.explanation, explanation) ||
                other.explanation == explanation));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, instruction,
      const DeepCollectionEquality().hash(_items), explanation);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TapOrderStepImplCopyWith<_$TapOrderStepImpl> get copyWith =>
      __$$TapOrderStepImplCopyWithImpl<_$TapOrderStepImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String question, List<String> options,
            int correctIndex, String explanation)
        multipleChoice,
    required TResult Function(
            String instruction, List<String> terms, List<String> definitions)
        dragDrop,
    required TResult Function(
            String instruction,
            double minValue,
            double maxValue,
            double targetMin,
            double targetMax,
            String unit,
            String explanation)
        slider,
    required TResult Function(
            String instruction, List<String> items, String explanation)
        tapOrder,
  }) {
    return tapOrder(instruction, items, explanation);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String question, List<String> options, int correctIndex,
            String explanation)?
        multipleChoice,
    TResult? Function(
            String instruction, List<String> terms, List<String> definitions)?
        dragDrop,
    TResult? Function(
            String instruction,
            double minValue,
            double maxValue,
            double targetMin,
            double targetMax,
            String unit,
            String explanation)?
        slider,
    TResult? Function(
            String instruction, List<String> items, String explanation)?
        tapOrder,
  }) {
    return tapOrder?.call(instruction, items, explanation);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String question, List<String> options, int correctIndex,
            String explanation)?
        multipleChoice,
    TResult Function(
            String instruction, List<String> terms, List<String> definitions)?
        dragDrop,
    TResult Function(
            String instruction,
            double minValue,
            double maxValue,
            double targetMin,
            double targetMax,
            String unit,
            String explanation)?
        slider,
    TResult Function(
            String instruction, List<String> items, String explanation)?
        tapOrder,
    required TResult orElse(),
  }) {
    if (tapOrder != null) {
      return tapOrder(instruction, items, explanation);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MultipleChoiceStep value) multipleChoice,
    required TResult Function(DragDropStep value) dragDrop,
    required TResult Function(SliderStep value) slider,
    required TResult Function(TapOrderStep value) tapOrder,
  }) {
    return tapOrder(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MultipleChoiceStep value)? multipleChoice,
    TResult? Function(DragDropStep value)? dragDrop,
    TResult? Function(SliderStep value)? slider,
    TResult? Function(TapOrderStep value)? tapOrder,
  }) {
    return tapOrder?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MultipleChoiceStep value)? multipleChoice,
    TResult Function(DragDropStep value)? dragDrop,
    TResult Function(SliderStep value)? slider,
    TResult Function(TapOrderStep value)? tapOrder,
    required TResult orElse(),
  }) {
    if (tapOrder != null) {
      return tapOrder(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$TapOrderStepImplToJson(
      this,
    );
  }
}

abstract class TapOrderStep implements LessonStepModel {
  const factory TapOrderStep(
      {required final String instruction,
      required final List<String> items,
      required final String explanation}) = _$TapOrderStepImpl;

  factory TapOrderStep.fromJson(Map<String, dynamic> json) =
      _$TapOrderStepImpl.fromJson;

  String get instruction;
  List<String> get items;
  String get explanation;
  @JsonKey(ignore: true)
  _$$TapOrderStepImplCopyWith<_$TapOrderStepImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
