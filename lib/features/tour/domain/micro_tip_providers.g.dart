// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'micro_tip_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The ids of every micro-tip this learner has already been shown.
///
/// Read off the device-local settings row, beside `tourSeen` and under its rule
/// (#342): a tip having been shown is not progress, so it survives Reset and
/// goes with Delete Account.

@ProviderFor(microTipsSeen)
final microTipsSeenProvider = MicroTipsSeenProvider._();

/// The ids of every micro-tip this learner has already been shown.
///
/// Read off the device-local settings row, beside `tourSeen` and under its rule
/// (#342): a tip having been shown is not progress, so it survives Reset and
/// goes with Delete Account.

final class MicroTipsSeenProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<String>>,
          Set<String>,
          FutureOr<Set<String>>
        >
    with $FutureModifier<Set<String>>, $FutureProvider<Set<String>> {
  /// The ids of every micro-tip this learner has already been shown.
  ///
  /// Read off the device-local settings row, beside `tourSeen` and under its rule
  /// (#342): a tip having been shown is not progress, so it survives Reset and
  /// goes with Delete Account.
  MicroTipsSeenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'microTipsSeenProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$microTipsSeenHash();

  @$internal
  @override
  $FutureProviderElement<Set<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Set<String>> create(Ref ref) {
    return microTipsSeen(ref);
  }
}

String _$microTipsSeenHash() => r'90069e6920b5537d5967615cf0bfd10ef65f6085';

/// Whether a save has landed since the app opened.
///
/// A *rise* in the shelf, never its size: the tip answers the action the
/// learner just took, and someone who already keeps a dozen things is not told
/// what saving does every time they launch. A removal moves the same set the
/// other way and arms nothing.
///
/// Kept alive because it is the session's memory of an event. Letting it be
/// disposed and rebuilt would forget a save the moment nothing happened to be
/// watching, which is exactly the gap the flag exists to bridge.

@ProviderFor(SaveMadeThisSession)
final saveMadeThisSessionProvider = SaveMadeThisSessionProvider._();

/// Whether a save has landed since the app opened.
///
/// A *rise* in the shelf, never its size: the tip answers the action the
/// learner just took, and someone who already keeps a dozen things is not told
/// what saving does every time they launch. A removal moves the same set the
/// other way and arms nothing.
///
/// Kept alive because it is the session's memory of an event. Letting it be
/// disposed and rebuilt would forget a save the moment nothing happened to be
/// watching, which is exactly the gap the flag exists to bridge.
final class SaveMadeThisSessionProvider
    extends $NotifierProvider<SaveMadeThisSession, bool> {
  /// Whether a save has landed since the app opened.
  ///
  /// A *rise* in the shelf, never its size: the tip answers the action the
  /// learner just took, and someone who already keeps a dozen things is not told
  /// what saving does every time they launch. A removal moves the same set the
  /// other way and arms nothing.
  ///
  /// Kept alive because it is the session's memory of an event. Letting it be
  /// disposed and rebuilt would forget a save the moment nothing happened to be
  /// watching, which is exactly the gap the flag exists to bridge.
  SaveMadeThisSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saveMadeThisSessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveMadeThisSessionHash();

  @$internal
  @override
  SaveMadeThisSession create() => SaveMadeThisSession();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$saveMadeThisSessionHash() =>
    r'caf8b2d7c05a3256d0364078e22b152b959c0636';

/// Whether a save has landed since the app opened.
///
/// A *rise* in the shelf, never its size: the tip answers the action the
/// learner just took, and someone who already keeps a dozen things is not told
/// what saving does every time they launch. A removal moves the same set the
/// other way and arms nothing.
///
/// Kept alive because it is the session's memory of an event. Letting it be
/// disposed and rebuilt would forget a save the moment nothing happened to be
/// watching, which is exactly the gap the flag exists to bridge.

abstract class _$SaveMadeThisSession extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Whether a lesson has been finished since the app opened — the beat the tree
/// tip follows.
///
/// The same shape, and kept alive for the same reason: the learner lands back
/// on the Learn tab a screen or two after the ending that grew the tree, and
/// the flag has to survive the trip.

@ProviderFor(LessonFinishedThisSession)
final lessonFinishedThisSessionProvider = LessonFinishedThisSessionProvider._();

/// Whether a lesson has been finished since the app opened — the beat the tree
/// tip follows.
///
/// The same shape, and kept alive for the same reason: the learner lands back
/// on the Learn tab a screen or two after the ending that grew the tree, and
/// the flag has to survive the trip.
final class LessonFinishedThisSessionProvider
    extends $NotifierProvider<LessonFinishedThisSession, bool> {
  /// Whether a lesson has been finished since the app opened — the beat the tree
  /// tip follows.
  ///
  /// The same shape, and kept alive for the same reason: the learner lands back
  /// on the Learn tab a screen or two after the ending that grew the tree, and
  /// the flag has to survive the trip.
  LessonFinishedThisSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lessonFinishedThisSessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lessonFinishedThisSessionHash();

  @$internal
  @override
  LessonFinishedThisSession create() => LessonFinishedThisSession();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$lessonFinishedThisSessionHash() =>
    r'd1d681d0e0c978e0626f412c741b84d5ed336139';

/// Whether a lesson has been finished since the app opened — the beat the tree
/// tip follows.
///
/// The same shape, and kept alive for the same reason: the learner lands back
/// on the Learn tab a screen or two after the ending that grew the tree, and
/// the flag has to survive the trip.

abstract class _$LessonFinishedThisSession extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
