// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teaching_module.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The module teaching [lessonId], or null when the catalog names a lesson
/// the banks do not carry.
///
/// A locked game's offer pitches the module that teaches its topic, so the
/// sheet needs the module's own words rather than the game's.

@ProviderFor(teachingModule)
final teachingModuleProvider = TeachingModuleFamily._();

/// The module teaching [lessonId], or null when the catalog names a lesson
/// the banks do not carry.
///
/// A locked game's offer pitches the module that teaches its topic, so the
/// sheet needs the module's own words rather than the game's.

final class TeachingModuleProvider
    extends
        $FunctionalProvider<
          AsyncValue<ModuleModel?>,
          ModuleModel?,
          FutureOr<ModuleModel?>
        >
    with $FutureModifier<ModuleModel?>, $FutureProvider<ModuleModel?> {
  /// The module teaching [lessonId], or null when the catalog names a lesson
  /// the banks do not carry.
  ///
  /// A locked game's offer pitches the module that teaches its topic, so the
  /// sheet needs the module's own words rather than the game's.
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

String _$teachingModuleHash() => r'e8eb49cf20a21e76b5f44a4cef7233e3e0101fa5';

/// The module teaching [lessonId], or null when the catalog names a lesson
/// the banks do not carry.
///
/// A locked game's offer pitches the module that teaches its topic, so the
/// sheet needs the module's own words rather than the game's.

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

  /// The module teaching [lessonId], or null when the catalog names a lesson
  /// the banks do not carry.
  ///
  /// A locked game's offer pitches the module that teaches its topic, so the
  /// sheet needs the module's own words rather than the game's.

  TeachingModuleProvider call(String lessonId) =>
      TeachingModuleProvider._(argument: lessonId, from: this);

  @override
  String toString() => r'teachingModuleProvider';
}
