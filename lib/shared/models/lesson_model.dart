import 'package:brew_path/shared/models/content/content_card.dart';
import 'package:brew_path/shared/models/content/content_reward.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'lesson_model.freezed.dart';
part 'lesson_model.g.dart';

/// One lesson of Foundations: an ordered run of [ContentCard]s and the reward
/// finishing it pays.
///
/// Cards, not steps. The step model this replaced described a different course
/// in a different vocabulary; a lesson is now the cards the extractor wrote out
/// of the design, drawn by the renderers that already exist.
@freezed
abstract class LessonModel with _$LessonModel {
  /// Creates a [LessonModel].
  const factory LessonModel({
    required String id,

    /// The module that owns this lesson.
    ///
    /// **Injected by the content layer, not authored.** A lesson record carries
    /// only [moduleLabel], a display string; ownership lives in the modules
    /// bank's own lesson list, so the repository resolves it once on load
    /// rather than every reader parsing an id out of a label.
    required String moduleId,

    /// The eyebrow the design prints above the lesson — `MODULE 1 · BEANS`.
    required String moduleLabel,
    required String title,

    /// What finishing this lesson pays, the first time only. Flat and
    /// authored — never derived from how many cards the lesson happens to run.
    required int points,

    /// The lesson's own estimate, in minutes.
    required int time,
    required List<ContentCard> cards,
    required ContentReward reward,
  }) = _LessonModel;

  /// Creates a [LessonModel] from decoded JSON.
  factory LessonModel.fromJson(Map<String, dynamic> json) =>
      _$LessonModelFromJson(json);
}
