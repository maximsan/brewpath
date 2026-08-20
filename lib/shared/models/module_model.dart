import 'package:brew_path/shared/models/content/content_reward.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'module_model.freezed.dart';
part 'module_model.g.dart';

/// One lesson as its **module** lists it — id, title and the two figures the
/// module screen shows before a lesson is opened.
///
/// The full lesson, with its cards, lives in the lessons bank; this is the
/// module's own table of contents, and it is the only place the course records
/// which module owns which lesson. A lesson record carries just a display
/// label (`MODULE 1 · BEANS`), so lesson → module is a reverse lookup over
/// these entries rather than a field.
@freezed
abstract class ModuleLesson with _$ModuleLesson {
  /// Creates a [ModuleLesson].
  const factory ModuleLesson({
    required String id,
    required String title,
    required int points,
    required int time,
  }) = _ModuleLesson;

  /// Creates a [ModuleLesson] from decoded JSON.
  factory ModuleLesson.fromJson(Map<String, dynamic> json) =>
      _$ModuleLessonFromJson(json);
}

/// One of the five modules of Foundations, as the extractor emits it.
///
/// Three fields the bank carries are **deliberately absent**: the module's
/// own `locked`, each lesson's `status`, and a collectible's `earned`. All
/// three are the prototype's demo state — a snapshot of one imaginary learner
/// — not content, and reading them would hand every real learner that
/// learner's progress. Lock state derives from [n] and the learner's own
/// completions instead.
@freezed
abstract class ModuleModel with _$ModuleModel {
  /// Creates a [ModuleModel].
  const factory ModuleModel({
    required String id,

    /// The module's position in the course, 1-based. The unlock rule reads
    /// this: module *n* opens when module *n − 1* is complete.
    required int n,

    /// The eyebrow the design prints above a lesson — `MODULE 1 · BEANS`.
    required String label,

    /// The module's glyph name, resolved to an icon by `moduleIcon`.
    @JsonKey(name: 'glyph') required String iconName,
    required String title,
    required List<ModuleLesson> lessons,
    required ContentReward reward,
  }) = _ModuleModel;

  const ModuleModel._();

  /// Creates a [ModuleModel] from decoded JSON.
  factory ModuleModel.fromJson(Map<String, dynamic> json) =>
      _$ModuleModelFromJson(json);

  /// The module's lesson ids, in course order.
  List<String> get lessonIds => [for (final lesson in lessons) lesson.id];
}
