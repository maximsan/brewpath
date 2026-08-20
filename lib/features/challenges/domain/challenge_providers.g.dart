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

String _$activeChallengeHash() => r'3ba853c312826500e6f1193a6f69c6e3cfe28b8d';

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

String _$savedChallengesHash() => r'13fce43c195c1b64a2087698f563c5c5a66959d8';

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
    r'752d8e6a56ef38fec222a25ae0a6bc8438b3e347';

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
