import 'package:brew_path/shared/models/lesson_step_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'lesson_model.freezed.dart';
part 'lesson_model.g.dart';

/// Content model for a single lesson (an ordered list of steps).
@freezed
abstract class LessonModel with _$LessonModel {
  /// Creates a [LessonModel].
  const factory LessonModel({
    required String id,
    required String moduleId,
    required String title,
    required String summary,
    required int xpReward,
    required List<LessonStepModel> steps,
    String? cardId,
  }) = _LessonModel;

  /// Creates a [LessonModel] from decoded JSON.
  factory LessonModel.fromJson(Map<String, dynamic> json) =>
      _$LessonModelFromJson(json);
}
