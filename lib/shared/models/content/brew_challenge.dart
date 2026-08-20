import 'package:freezed_annotation/freezed_annotation.dart';

part 'brew_challenge.freezed.dart';
part 'brew_challenge.g.dart';

/// Which surface a Coffee Challenge hangs off.
///
/// An enum rather than the bank's bare string, so a third kind cannot slip
/// past a switch that thought it had handled them all.
enum ChallengeScope {
  /// A module capstone, earned by finishing every lesson in its module.
  @JsonValue('module')
  module,

  /// A single lesson's challenge, earned by finishing that lesson.
  @JsonValue('lesson')
  lesson,
}

/// One of the twelve Coffee Challenges, as the extractor emits it.
///
/// The one thing in BrewPath that asks the learner to go and make coffee. The
/// record is content, not progress: what a learner has done with it lives in
/// the snapshot.
@freezed
abstract class BrewChallenge with _$BrewChallenge {
  /// Creates a [BrewChallenge].
  const factory BrewChallenge({
    required String id,
    @JsonKey(name: 'type') required ChallengeScope scope,

    /// The module this belongs to — its own, for a capstone; its lesson's, for
    /// a lesson challenge.
    required String moduleId,

    /// The collectible this challenge is stamped onto.
    required String cardId,
    required String title,

    /// What to actually go and brew.
    required String instruction,

    /// When and how long, as one authored string: `'Next brews · 5 min'`.
    required String effort,

    /// The question the log sheet asks — `'WHICH CUP WON?'`.
    required String prompt,

    /// The outcomes the learner can report. **Eleven records carry three and
    /// one carries two**, so nothing may assume a count.
    required List<String> reactions,

    /// The lesson this challenge belongs to, or null on a capstone.
    ///
    /// **Authored, never parsed out of [id].** `bc-m4l3` looks like it names a
    /// lesson, but lessons have been inserted mid-module before, and an id
    /// read as a pointer would then resolve to whatever now sits in that slot.
    String? lessonId,
  }) = _BrewChallenge;

  /// Creates a [BrewChallenge] from decoded JSON.
  factory BrewChallenge.fromJson(Map<String, dynamic> json) =>
      _$BrewChallengeFromJson(json);
}
