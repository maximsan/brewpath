// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visual_guide_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The Reference section's contents for this learner.
///
/// It watches completed lessons, so finishing the lesson that teaches a guide
/// fills the section in while the learner is still holding the phone — the
/// reward lands without a restart, and a reset locks it again for free.

@ProviderFor(visualGuideShelfFor)
final visualGuideShelfForProvider = VisualGuideShelfForProvider._();

/// The Reference section's contents for this learner.
///
/// It watches completed lessons, so finishing the lesson that teaches a guide
/// fills the section in while the learner is still holding the phone — the
/// reward lands without a restart, and a reset locks it again for free.

final class VisualGuideShelfForProvider
    extends
        $FunctionalProvider<
          AsyncValue<VisualGuideShelf>,
          VisualGuideShelf,
          FutureOr<VisualGuideShelf>
        >
    with $FutureModifier<VisualGuideShelf>, $FutureProvider<VisualGuideShelf> {
  /// The Reference section's contents for this learner.
  ///
  /// It watches completed lessons, so finishing the lesson that teaches a guide
  /// fills the section in while the learner is still holding the phone — the
  /// reward lands without a restart, and a reset locks it again for free.
  VisualGuideShelfForProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'visualGuideShelfForProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$visualGuideShelfForHash();

  @$internal
  @override
  $FutureProviderElement<VisualGuideShelf> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<VisualGuideShelf> create(Ref ref) {
    return visualGuideShelfFor(ref);
  }
}

String _$visualGuideShelfForHash() =>
    r'2dee6d1e6042e6099b48be5cefff18d269bbea2d';
