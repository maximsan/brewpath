import 'package:freezed_annotation/freezed_annotation.dart';

part 'lesson_step_model.freezed.dart';
part 'lesson_step_model.g.dart';

/// Sealed union of all mini-game step types.
///
/// The `type` key in JSON maps snake_case values to each variant:
/// `"multiple_choice"`, `"drag_drop"`, `"slider"`, `"tap_order"`.
@Freezed(unionKey: 'type', unionValueCase: FreezedUnionCase.snake)
sealed class LessonStepModel with _$LessonStepModel {
  const factory LessonStepModel.multipleChoice({
    required String question,
    required List<String> options,
    required int correctIndex,
    required String explanation,
  }) = MultipleChoiceStep;

  const factory LessonStepModel.dragDrop({
    required String instruction,
    required List<String> terms,
    required List<String> definitions,
  }) = DragDropStep;

  const factory LessonStepModel.slider({
    required String instruction,
    required double minValue,
    required double maxValue,
    required double targetMin,
    required double targetMax,
    required String unit,
    required String explanation,
  }) = SliderStep;

  const factory LessonStepModel.tapOrder({
    required String instruction,
    required List<String> items,
    required String explanation,
  }) = TapOrderStep;

  factory LessonStepModel.fromJson(Map<String, dynamic> json) =>
      _$LessonStepModelFromJson(json);
}
