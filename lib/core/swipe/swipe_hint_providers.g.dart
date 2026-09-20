// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swipe_hint_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The swipe surfaces whose gesture this learner has used.
///
/// A used gesture is what retires its hint — never a count of showings, which
/// only ever fires on the learner who has not learned it.

@ProviderFor(swipesUsed)
final swipesUsedProvider = SwipesUsedProvider._();

/// The swipe surfaces whose gesture this learner has used.
///
/// A used gesture is what retires its hint — never a count of showings, which
/// only ever fires on the learner who has not learned it.

final class SwipesUsedProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<String>>,
          Set<String>,
          FutureOr<Set<String>>
        >
    with $FutureModifier<Set<String>>, $FutureProvider<Set<String>> {
  /// The swipe surfaces whose gesture this learner has used.
  ///
  /// A used gesture is what retires its hint — never a count of showings, which
  /// only ever fires on the learner who has not learned it.
  SwipesUsedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'swipesUsedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$swipesUsedHash();

  @$internal
  @override
  $FutureProviderElement<Set<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Set<String>> create(Ref ref) {
    return swipesUsed(ref);
  }
}

String _$swipesUsedHash() => r'0341c7a699b316188e7f24d8db8c554368e84f4e';
