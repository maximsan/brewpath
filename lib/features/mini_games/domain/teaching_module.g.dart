// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teaching_module.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The module owning [moduleId], or null when the catalog names one the
/// modules bank does not carry.
///
/// A locked game's offer is a pitch for the module that teaches its topic, so
/// the sheet needs the module's own words rather than the game's.

@ProviderFor(teachingModule)
final teachingModuleProvider = TeachingModuleFamily._();

/// The module owning [moduleId], or null when the catalog names one the
/// modules bank does not carry.
///
/// A locked game's offer is a pitch for the module that teaches its topic, so
/// the sheet needs the module's own words rather than the game's.

final class TeachingModuleProvider
    extends
        $FunctionalProvider<
          AsyncValue<ModuleModel?>,
          ModuleModel?,
          FutureOr<ModuleModel?>
        >
    with $FutureModifier<ModuleModel?>, $FutureProvider<ModuleModel?> {
  /// The module owning [moduleId], or null when the catalog names one the
  /// modules bank does not carry.
  ///
  /// A locked game's offer is a pitch for the module that teaches its topic, so
  /// the sheet needs the module's own words rather than the game's.
  TeachingModuleProvider._({
    required TeachingModuleFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'teachingModuleProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$teachingModuleHash();

  @override
  String toString() {
    return r'teachingModuleProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ModuleModel?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ModuleModel?> create(Ref ref) {
    final argument = this.argument as String;
    return teachingModule(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TeachingModuleProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$teachingModuleHash() => r'a85a45650ff8a827f203f97384ec6ee2f97f0e02';

/// The module owning [moduleId], or null when the catalog names one the
/// modules bank does not carry.
///
/// A locked game's offer is a pitch for the module that teaches its topic, so
/// the sheet needs the module's own words rather than the game's.

final class TeachingModuleFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ModuleModel?>, String> {
  TeachingModuleFamily._()
    : super(
        retry: null,
        name: r'teachingModuleProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The module owning [moduleId], or null when the catalog names one the
  /// modules bank does not carry.
  ///
  /// A locked game's offer is a pitch for the module that teaches its topic, so
  /// the sheet needs the module's own words rather than the game's.

  TeachingModuleProvider call(String moduleId) =>
      TeachingModuleProvider._(argument: moduleId, from: this);

  @override
  String toString() => r'teachingModuleProvider';
}
