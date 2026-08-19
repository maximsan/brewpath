import 'package:flutter/foundation.dart';

/// A logged reaction to a brew challenge.
///
/// The reaction is stored as its **text**, never as an index into the
/// challenge's option list. The design has already rewritten every reaction
/// string once (`Tasted the difference` → `Preferred 1:15`), and a stored index
/// silently changes meaning across such a rewrite where a stored string either
/// still matches or visibly does not.
@immutable
class ChallengeReaction {
  /// Creates a [ChallengeReaction].
  const ChallengeReaction({required this.reaction, required this.at});

  /// Builds one from its JSON form.
  factory ChallengeReaction.fromJson(Map<String, dynamic> json) =>
      ChallengeReaction(
        reaction: json['reaction'] as String? ?? '',
        at: json['at'] as int? ?? 0,
      );

  /// The chosen reaction's text.
  final String reaction;

  /// Day the reaction was logged, as days since the Unix epoch.
  final int at;

  /// This reaction's JSON form.
  Map<String, dynamic> toJson() => {'reaction': reaction, 'at': at};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChallengeReaction &&
          other.reaction == reaction &&
          other.at == at;

  @override
  int get hashCode => Object.hash(reaction, at);

  @override
  String toString() => 'ChallengeReaction($reaction @ $at)';
}

/// The single brew challenge currently in play, if any.
@immutable
class ActiveChallenge {
  /// Creates an [ActiveChallenge].
  const ActiveChallenge({required this.id, required this.startedAt});

  /// Builds one from its JSON form.
  factory ActiveChallenge.fromJson(Map<String, dynamic> json) =>
      ActiveChallenge(
        id: json['id'] as String? ?? '',
        startedAt: json['startedAt'] as int? ?? 0,
      );

  /// The challenge's content id.
  final String id;

  /// Milliseconds since epoch. The 48-hour window is elapsed wall-clock rather
  /// than a calendar boundary, so this is a moment and not a day number.
  final int startedAt;

  /// This challenge's JSON form.
  Map<String, dynamic> toJson() => {'id': id, 'startedAt': startedAt};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActiveChallenge &&
          other.id == id &&
          other.startedAt == startedAt;

  @override
  int get hashCode => Object.hash(id, startedAt);

  @override
  String toString() => 'ActiveChallenge($id @ $startedAt)';
}

/// The learner's grove: which coffee species is planted, and the light it
/// stands in.
///
/// Two axes rather than five fixed skins, so the plant reinforces the course
/// (`m1l2` teaches Arabica vs Robusta) instead of decorating around it. The
/// split from a single `tree` field is the snapshot's worked example of a
/// migration, and both halves are last-writer-wins — the first non-monotonic
/// fields on the snapshot.
@immutable
class Grove {
  /// Creates a [Grove].
  const Grove({required this.variety, required this.light});

  /// Builds one from its JSON form.
  factory Grove.fromJson(Map<String, dynamic> json) => Grove(
    variety: json['variety'] as String? ?? defaultVariety,
    light: json['light'] as String? ?? defaultLight,
  );

  /// The species a new grove starts with.
  static const defaultVariety = 'arabica';

  /// The light a new grove starts in.
  static const defaultLight = 'daylight';

  /// A grove nobody has customised.
  static const initial = Grove(variety: defaultVariety, light: defaultLight);

  /// `arabica` · `robusta` · `liberica`.
  final String variety;

  /// `daylight` · `goldenhour` · `moonlit` · `frost`.
  ///
  /// The generated grove bank is these ids' authority. This comment once named
  /// `goldenHour` and `firstFrost`, which never shipped on either side.
  final String light;

  /// This grove's JSON form.
  Map<String, dynamic> toJson() => {'variety': variety, 'light': light};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Grove && other.variety == variety && other.light == light;

  @override
  int get hashCode => Object.hash(variety, light);

  @override
  String toString() => 'Grove($variety, $light)';
}

/// How the learner has dressed Roasty.
///
/// Four independent axes. Account-scoped: kept by Reset because it is something
/// the learner chose rather than something they did, and cleared only by
/// Delete.
@immutable
class CompanionConfig {
  /// Creates a [CompanionConfig].
  const CompanionConfig({
    required this.roast,
    required this.hat,
    required this.gear,
    required this.sprout,
  });

  /// Builds one from its JSON form.
  factory CompanionConfig.fromJson(Map<String, dynamic> json) =>
      CompanionConfig(
        roast: json['roast'] as String? ?? 'medium',
        hat: json['hat'] as String? ?? 'none',
        gear: json['gear'] as String? ?? 'none',
        sprout: json['sprout'] as String? ?? 'leaf',
      );

  /// A companion nobody has customised.
  static const initial = CompanionConfig(
    roast: 'medium',
    hat: 'none',
    gear: 'none',
    sprout: 'leaf',
  );

  /// Roast level, threaded through the body painter rather than overlaid.
  final String roast;

  /// Headwear, drawn above the sprout it occludes.
  final String hat;

  /// Glasses, scarf and friends.
  final String gear;

  /// What grows from the crown.
  final String sprout;

  /// This config's JSON form.
  Map<String, dynamic> toJson() => {
    'roast': roast,
    'hat': hat,
    'gear': gear,
    'sprout': sprout,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompanionConfig &&
          other.roast == roast &&
          other.hat == hat &&
          other.gear == gear &&
          other.sprout == sprout;

  @override
  int get hashCode => Object.hash(roast, hat, gear, sprout);

  @override
  String toString() => 'CompanionConfig($roast, $hat, $gear, $sprout)';
}
