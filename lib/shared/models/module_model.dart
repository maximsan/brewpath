import 'package:freezed_annotation/freezed_annotation.dart';

part 'module_model.freezed.dart';
part 'module_model.g.dart';

/// Content model for a learning module (a named group of lessons).
@freezed
abstract class ModuleModel with _$ModuleModel {
  /// Creates a [ModuleModel].
  const factory ModuleModel({
    required String id,
    required String title,
    required String description,
    required String iconName,
    required List<String> lessonIds,
    String? unlockRequirement,
  }) = _ModuleModel;

  /// Creates a [ModuleModel] from decoded JSON.
  factory ModuleModel.fromJson(Map<String, dynamic> json) =>
      _$ModuleModelFromJson(json);
}
