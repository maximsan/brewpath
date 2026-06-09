import 'package:coffee_quest/shared/models/lesson_step_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'lesson_model.freezed.dart';
part 'lesson_model.g.dart';

@freezed
abstract class LessonModel with _$LessonModel {
  const factory LessonModel({
    required String id,
    required String moduleId,
    required String title,
    required String summary,
    required int xpReward,
    required List<LessonStepModel> steps, String? cardId,
  }) = _LessonModel;

  factory LessonModel.fromJson(Map<String, dynamic> json) =>
      _$LessonModelFromJson(json);
}
