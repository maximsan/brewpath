// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visual_guide_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app-wide [VisualGuideRepository].

@ProviderFor(visualGuideRepository)
final visualGuideRepositoryProvider = VisualGuideRepositoryProvider._();

/// The app-wide [VisualGuideRepository].

final class VisualGuideRepositoryProvider
    extends
        $FunctionalProvider<
          VisualGuideRepository,
          VisualGuideRepository,
          VisualGuideRepository
        >
    with $Provider<VisualGuideRepository> {
  /// The app-wide [VisualGuideRepository].
  VisualGuideRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'visualGuideRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$visualGuideRepositoryHash();

  @$internal
  @override
  $ProviderElement<VisualGuideRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VisualGuideRepository create(Ref ref) {
    return visualGuideRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VisualGuideRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VisualGuideRepository>(value),
    );
  }
}

String _$visualGuideRepositoryHash() =>
    r'fecac13da40c626103c3af404bf11a910f573b70';
