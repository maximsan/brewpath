// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The twelve Coffee Challenges.

@ProviderFor(challengeBank)
final challengeBankProvider = ChallengeBankProvider._();

/// The twelve Coffee Challenges.

final class ChallengeBankProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BrewChallenge>>,
          List<BrewChallenge>,
          FutureOr<List<BrewChallenge>>
        >
    with
        $FutureModifier<List<BrewChallenge>>,
        $FutureProvider<List<BrewChallenge>> {
  /// The twelve Coffee Challenges.
  ChallengeBankProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'challengeBankProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$challengeBankHash();

  @$internal
  @override
  $FutureProviderElement<List<BrewChallenge>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BrewChallenge>> create(Ref ref) {
    return challengeBank(ref);
  }
}

String _$challengeBankHash() => r'fbb392899351d081551ecc5d59a8cdec80d62602';

/// The challenge Today should show, or null when nothing is in play.
///
/// A lapsed window stops showing here and stores nothing — clearing the pair
/// and parking the challenge is the expiry path's write, not a read's side
/// effect.

@ProviderFor(activeChallenge)
final activeChallengeProvider = ActiveChallengeProvider._();

/// The challenge Today should show, or null when nothing is in play.
///
/// A lapsed window stops showing here and stores nothing — clearing the pair
/// and parking the challenge is the expiry path's write, not a read's side
/// effect.

final class ActiveChallengeProvider
    extends
        $FunctionalProvider<
          AsyncValue<BrewChallenge?>,
          BrewChallenge?,
          FutureOr<BrewChallenge?>
        >
    with $FutureModifier<BrewChallenge?>, $FutureProvider<BrewChallenge?> {
  /// The challenge Today should show, or null when nothing is in play.
  ///
  /// A lapsed window stops showing here and stores nothing — clearing the pair
  /// and parking the challenge is the expiry path's write, not a read's side
  /// effect.
  ActiveChallengeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeChallengeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeChallengeHash();

  @$internal
  @override
  $FutureProviderElement<BrewChallenge?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BrewChallenge?> create(Ref ref) {
    return activeChallenge(ref);
  }
}

String _$activeChallengeHash() => r'968d319c259fe1f4dff36725e5da71cb5d39d36d';

/// Every challenge the learner has logged at least once.

@ProviderFor(completedChallenges)
final completedChallengesProvider = CompletedChallengesProvider._();

/// Every challenge the learner has logged at least once.

final class CompletedChallengesProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<String>>,
          Set<String>,
          FutureOr<Set<String>>
        >
    with $FutureModifier<Set<String>>, $FutureProvider<Set<String>> {
  /// Every challenge the learner has logged at least once.
  CompletedChallengesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'completedChallengesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$completedChallengesHash();

  @$internal
  @override
  $FutureProviderElement<Set<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Set<String>> create(Ref ref) {
    return completedChallenges(ref);
  }
}

String _$completedChallengesHash() =>
    r'2467e35ae3c7023fe8fee777732928b15c86483a';

/// The challenge [lessonId] carries, **only while it is still an offer**.
///
/// Null covers all three ways there is nothing to offer: the lesson carries no
/// challenge, the learner started it, or they finished it. Resolved as one
/// question because the reward list needs one answer — a row that rendered
/// itself empty would still take a hairline from the row above it.

@ProviderFor(lessonChallengeOffer)
final lessonChallengeOfferProvider = LessonChallengeOfferFamily._();

/// The challenge [lessonId] carries, **only while it is still an offer**.
///
/// Null covers all three ways there is nothing to offer: the lesson carries no
/// challenge, the learner started it, or they finished it. Resolved as one
/// question because the reward list needs one answer — a row that rendered
/// itself empty would still take a hairline from the row above it.

final class LessonChallengeOfferProvider
    extends
        $FunctionalProvider<
          AsyncValue<BrewChallenge?>,
          BrewChallenge?,
          FutureOr<BrewChallenge?>
        >
    with $FutureModifier<BrewChallenge?>, $FutureProvider<BrewChallenge?> {
  /// The challenge [lessonId] carries, **only while it is still an offer**.
  ///
  /// Null covers all three ways there is nothing to offer: the lesson carries no
  /// challenge, the learner started it, or they finished it. Resolved as one
  /// question because the reward list needs one answer — a row that rendered
  /// itself empty would still take a hairline from the row above it.
  LessonChallengeOfferProvider._({
    required LessonChallengeOfferFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'lessonChallengeOfferProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$lessonChallengeOfferHash();

  @override
  String toString() {
    return r'lessonChallengeOfferProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<BrewChallenge?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BrewChallenge?> create(Ref ref) {
    final argument = this.argument as String;
    return lessonChallengeOffer(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LessonChallengeOfferProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lessonChallengeOfferHash() =>
    r'04fbbc5c2797498471b324408fc2915e7267bbeb';

/// The challenge [lessonId] carries, **only while it is still an offer**.
///
/// Null covers all three ways there is nothing to offer: the lesson carries no
/// challenge, the learner started it, or they finished it. Resolved as one
/// question because the reward list needs one answer — a row that rendered
/// itself empty would still take a hairline from the row above it.

final class LessonChallengeOfferFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<BrewChallenge?>, String> {
  LessonChallengeOfferFamily._()
    : super(
        retry: null,
        name: r'lessonChallengeOfferProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The challenge [lessonId] carries, **only while it is still an offer**.
  ///
  /// Null covers all three ways there is nothing to offer: the lesson carries no
  /// challenge, the learner started it, or they finished it. Resolved as one
  /// question because the reward list needs one answer — a row that rendered
  /// itself empty would still take a hairline from the row above it.

  LessonChallengeOfferProvider call(String lessonId) =>
      LessonChallengeOfferProvider._(argument: lessonId, from: this);

  @override
  String toString() => r'lessonChallengeOfferProvider';
}

/// What [cardId]'s challenge is doing, as a tile shows it.
///
/// Three states, not two: no challenge, one waiting to be brewed, or one
/// already brewed — the tile draws the last two differently. **Every unbrewed
/// challenge is an offer**, not only the one in play (the design's
/// `challengeOpen`), so a learner sees every card that still owes a brew.

@ProviderFor(cardChallengeState)
final cardChallengeStateProvider = CardChallengeStateFamily._();

/// What [cardId]'s challenge is doing, as a tile shows it.
///
/// Three states, not two: no challenge, one waiting to be brewed, or one
/// already brewed — the tile draws the last two differently. **Every unbrewed
/// challenge is an offer**, not only the one in play (the design's
/// `challengeOpen`), so a learner sees every card that still owes a brew.

final class CardChallengeStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<CardChallengeState>,
          CardChallengeState,
          FutureOr<CardChallengeState>
        >
    with
        $FutureModifier<CardChallengeState>,
        $FutureProvider<CardChallengeState> {
  /// What [cardId]'s challenge is doing, as a tile shows it.
  ///
  /// Three states, not two: no challenge, one waiting to be brewed, or one
  /// already brewed — the tile draws the last two differently. **Every unbrewed
  /// challenge is an offer**, not only the one in play (the design's
  /// `challengeOpen`), so a learner sees every card that still owes a brew.
  CardChallengeStateProvider._({
    required CardChallengeStateFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'cardChallengeStateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cardChallengeStateHash();

  @override
  String toString() {
    return r'cardChallengeStateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CardChallengeState> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CardChallengeState> create(Ref ref) {
    final argument = this.argument as String;
    return cardChallengeState(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CardChallengeStateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cardChallengeStateHash() =>
    r'b15e1791a5e19aaad2ab493d993acb01b86643ac';

/// What [cardId]'s challenge is doing, as a tile shows it.
///
/// Three states, not two: no challenge, one waiting to be brewed, or one
/// already brewed — the tile draws the last two differently. **Every unbrewed
/// challenge is an offer**, not only the one in play (the design's
/// `challengeOpen`), so a learner sees every card that still owes a brew.

final class CardChallengeStateFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CardChallengeState>, String> {
  CardChallengeStateFamily._()
    : super(
        retry: null,
        name: r'cardChallengeStateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// What [cardId]'s challenge is doing, as a tile shows it.
  ///
  /// Three states, not two: no challenge, one waiting to be brewed, or one
  /// already brewed — the tile draws the last two differently. **Every unbrewed
  /// challenge is an offer**, not only the one in play (the design's
  /// `challengeOpen`), so a learner sees every card that still owes a brew.

  CardChallengeStateProvider call(String cardId) =>
      CardChallengeStateProvider._(argument: cardId, from: this);

  @override
  String toString() => r'cardChallengeStateProvider';
}

/// Whether the challenge on [cardId] has been brewed.
///
/// The card's sheet asks this twice over — for the seal on its header and the
/// stamp at its foot — so the three reads behind the answer live here rather
/// than in either widget. A card with no challenge, or a bank still loading,
/// answers *not tried*.

@ProviderFor(cardChallengeTried)
final cardChallengeTriedProvider = CardChallengeTriedFamily._();

/// Whether the challenge on [cardId] has been brewed.
///
/// The card's sheet asks this twice over — for the seal on its header and the
/// stamp at its foot — so the three reads behind the answer live here rather
/// than in either widget. A card with no challenge, or a bank still loading,
/// answers *not tried*.

final class CardChallengeTriedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether the challenge on [cardId] has been brewed.
  ///
  /// The card's sheet asks this twice over — for the seal on its header and the
  /// stamp at its foot — so the three reads behind the answer live here rather
  /// than in either widget. A card with no challenge, or a bank still loading,
  /// answers *not tried*.
  CardChallengeTriedProvider._({
    required CardChallengeTriedFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'cardChallengeTriedProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cardChallengeTriedHash();

  @override
  String toString() {
    return r'cardChallengeTriedProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as String;
    return cardChallengeTried(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CardChallengeTriedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cardChallengeTriedHash() =>
    r'23d83be54362d989d4a73c393deeb50f39d70977';

/// Whether the challenge on [cardId] has been brewed.
///
/// The card's sheet asks this twice over — for the seal on its header and the
/// stamp at its foot — so the three reads behind the answer live here rather
/// than in either widget. A card with no challenge, or a bank still loading,
/// answers *not tried*.

final class CardChallengeTriedFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  CardChallengeTriedFamily._()
    : super(
        retry: null,
        name: r'cardChallengeTriedProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether the challenge on [cardId] has been brewed.
  ///
  /// The card's sheet asks this twice over — for the seal on its header and the
  /// stamp at its foot — so the three reads behind the answer live here rather
  /// than in either widget. A card with no challenge, or a bank still loading,
  /// answers *not tried*.

  CardChallengeTriedProvider call(String cardId) =>
      CardChallengeTriedProvider._(argument: cardId, from: this);

  @override
  String toString() => r'cardChallengeTriedProvider';
}

/// The challenges waiting in the saved queue, in bank order.
///
/// Excludes whatever is in play and anything already logged, and drops any
/// challenge whose lesson the learner has not reached — a queue advertising
/// work locked behind content is worse than an empty one.

@ProviderFor(savedChallenges)
final savedChallengesProvider = SavedChallengesProvider._();

/// The challenges waiting in the saved queue, in bank order.
///
/// Excludes whatever is in play and anything already logged, and drops any
/// challenge whose lesson the learner has not reached — a queue advertising
/// work locked behind content is worse than an empty one.

final class SavedChallengesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BrewChallenge>>,
          List<BrewChallenge>,
          FutureOr<List<BrewChallenge>>
        >
    with
        $FutureModifier<List<BrewChallenge>>,
        $FutureProvider<List<BrewChallenge>> {
  /// The challenges waiting in the saved queue, in bank order.
  ///
  /// Excludes whatever is in play and anything already logged, and drops any
  /// challenge whose lesson the learner has not reached — a queue advertising
  /// work locked behind content is worse than an empty one.
  SavedChallengesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedChallengesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedChallengesHash();

  @$internal
  @override
  $FutureProviderElement<List<BrewChallenge>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BrewChallenge>> create(Ref ref) {
    return savedChallenges(ref);
  }
}

String _$savedChallengesHash() => r'c7e22a00253c744c25847e4be64ac7bcc87eb292';

/// The capstone [moduleId] offers, or null when it has none or is unearned.

@ProviderFor(moduleChallengeOffer)
final moduleChallengeOfferProvider = ModuleChallengeOfferFamily._();

/// The capstone [moduleId] offers, or null when it has none or is unearned.

final class ModuleChallengeOfferProvider
    extends
        $FunctionalProvider<
          AsyncValue<BrewChallenge?>,
          BrewChallenge?,
          FutureOr<BrewChallenge?>
        >
    with $FutureModifier<BrewChallenge?>, $FutureProvider<BrewChallenge?> {
  /// The capstone [moduleId] offers, or null when it has none or is unearned.
  ModuleChallengeOfferProvider._({
    required ModuleChallengeOfferFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'moduleChallengeOfferProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$moduleChallengeOfferHash();

  @override
  String toString() {
    return r'moduleChallengeOfferProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<BrewChallenge?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BrewChallenge?> create(Ref ref) {
    final argument = this.argument as String;
    return moduleChallengeOffer(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ModuleChallengeOfferProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$moduleChallengeOfferHash() =>
    r'e90b9819e00b7c4879d97ab7ac2608ce648820ad';

/// The capstone [moduleId] offers, or null when it has none or is unearned.

final class ModuleChallengeOfferFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<BrewChallenge?>, String> {
  ModuleChallengeOfferFamily._()
    : super(
        retry: null,
        name: r'moduleChallengeOfferProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The capstone [moduleId] offers, or null when it has none or is unearned.

  ModuleChallengeOfferProvider call(String moduleId) =>
      ModuleChallengeOfferProvider._(argument: moduleId, from: this);

  @override
  String toString() => r'moduleChallengeOfferProvider';
}

/// The capstone [moduleId] is offering **right now**, or null.
///
/// Live is the design's `offerLive`: neither in play nor already brewed. A
/// saved challenge is still live; parking it was the learner saying *not yet*.
/// Eligibility is not re-derived here — [moduleChallengeOfferProvider] owns
/// the gate (#143), and this only narrows what that gate returns.

@ProviderFor(liveModuleChallengeOffer)
final liveModuleChallengeOfferProvider = LiveModuleChallengeOfferFamily._();

/// The capstone [moduleId] is offering **right now**, or null.
///
/// Live is the design's `offerLive`: neither in play nor already brewed. A
/// saved challenge is still live; parking it was the learner saying *not yet*.
/// Eligibility is not re-derived here — [moduleChallengeOfferProvider] owns
/// the gate (#143), and this only narrows what that gate returns.

final class LiveModuleChallengeOfferProvider
    extends
        $FunctionalProvider<
          AsyncValue<BrewChallenge?>,
          BrewChallenge?,
          FutureOr<BrewChallenge?>
        >
    with $FutureModifier<BrewChallenge?>, $FutureProvider<BrewChallenge?> {
  /// The capstone [moduleId] is offering **right now**, or null.
  ///
  /// Live is the design's `offerLive`: neither in play nor already brewed. A
  /// saved challenge is still live; parking it was the learner saying *not yet*.
  /// Eligibility is not re-derived here — [moduleChallengeOfferProvider] owns
  /// the gate (#143), and this only narrows what that gate returns.
  LiveModuleChallengeOfferProvider._({
    required LiveModuleChallengeOfferFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'liveModuleChallengeOfferProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$liveModuleChallengeOfferHash();

  @override
  String toString() {
    return r'liveModuleChallengeOfferProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<BrewChallenge?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BrewChallenge?> create(Ref ref) {
    final argument = this.argument as String;
    return liveModuleChallengeOffer(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LiveModuleChallengeOfferProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$liveModuleChallengeOfferHash() =>
    r'05124d63d971b993ad0dd57e1a9731e20db28bba';

/// The capstone [moduleId] is offering **right now**, or null.
///
/// Live is the design's `offerLive`: neither in play nor already brewed. A
/// saved challenge is still live; parking it was the learner saying *not yet*.
/// Eligibility is not re-derived here — [moduleChallengeOfferProvider] owns
/// the gate (#143), and this only narrows what that gate returns.

final class LiveModuleChallengeOfferFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<BrewChallenge?>, String> {
  LiveModuleChallengeOfferFamily._()
    : super(
        retry: null,
        name: r'liveModuleChallengeOfferProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The capstone [moduleId] is offering **right now**, or null.
  ///
  /// Live is the design's `offerLive`: neither in play nor already brewed. A
  /// saved challenge is still live; parking it was the learner saying *not yet*.
  /// Eligibility is not re-derived here — [moduleChallengeOfferProvider] owns
  /// the gate (#143), and this only narrows what that gate returns.

  LiveModuleChallengeOfferProvider call(String moduleId) =>
      LiveModuleChallengeOfferProvider._(argument: moduleId, from: this);

  @override
  String toString() => r'liveModuleChallengeOfferProvider';
}
