// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'path_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The whole course as Path draws it — every module at its density, with its
/// lessons already paired to the learner's progress.
///
/// One provider for the screen rather than a family per module: Path shows all
/// five modules at once, so a per-module fetch would be five reads of the same
/// two banks, and the "current lesson" rule has to see the course in order
/// anyway.

@ProviderFor(pathModules)
final pathModulesProvider = PathModulesProvider._();

/// The whole course as Path draws it — every module at its density, with its
/// lessons already paired to the learner's progress.
///
/// One provider for the screen rather than a family per module: Path shows all
/// five modules at once, so a per-module fetch would be five reads of the same
/// two banks, and the "current lesson" rule has to see the course in order
/// anyway.

final class PathModulesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PathModule>>,
          List<PathModule>,
          FutureOr<List<PathModule>>
        >
    with $FutureModifier<List<PathModule>>, $FutureProvider<List<PathModule>> {
  /// The whole course as Path draws it — every module at its density, with its
  /// lessons already paired to the learner's progress.
  ///
  /// One provider for the screen rather than a family per module: Path shows all
  /// five modules at once, so a per-module fetch would be five reads of the same
  /// two banks, and the "current lesson" rule has to see the course in order
  /// anyway.
  PathModulesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pathModulesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pathModulesHash();

  @$internal
  @override
  $FutureProviderElement<List<PathModule>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PathModule>> create(Ref ref) {
    return pathModules(ref);
  }
}

String _$pathModulesHash() => r'039b61a25e5de06e937a2694b3afdb96430fce96';
