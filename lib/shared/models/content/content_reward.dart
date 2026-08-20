import 'package:freezed_annotation/freezed_annotation.dart';

part 'content_reward.freezed.dart';
part 'content_reward.g.dart';

/// The words a lesson or a module pays out when it is first finished.
///
/// **One reward, one text.** The collectibles bank carries no words at all —
/// only an id, a kind and the pointer to whatever unlocks it — so a card's
/// title, summary and fact are read from the reward of the lesson or module
/// that awards it. Storing them twice is what the content pipeline exists to
/// avoid, and a duplicated string is one edit away from disagreeing with
/// itself.
///
/// Lessons and modules author the same four fields under two names for the
/// last one: a lesson carries [meta] (label/value rows shown on the card), a
/// module carries [badge] (a single mark). Both are optional here rather than
/// modelled as two types, because every reader wants the same three strings
/// and differs only in the trailing ornament.
@freezed
abstract class ContentReward with _$ContentReward {
  /// Creates a [ContentReward].
  const factory ContentReward({
    required String title,
    required String summary,
    required String fact,

    /// Label/value rows, as authored by a lesson reward. Empty on a module.
    @Default(<List<String>>[]) List<List<String>> meta,

    /// The mark a module reward carries instead of [meta]. Null on a lesson.
    String? badge,
  }) = _ContentReward;

  /// Creates a [ContentReward] from decoded JSON.
  factory ContentReward.fromJson(Map<String, dynamic> json) =>
      _$ContentRewardFromJson(json);
}
