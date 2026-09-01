// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'module_summary_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Builds the [ModuleSummary] for [moduleId] by joining content (module +
/// cards) with persisted progress (collected cards).

@ProviderFor(moduleSummary)
final moduleSummaryProvider = ModuleSummaryFamily._();

/// Builds the [ModuleSummary] for [moduleId] by joining content (module +
/// cards) with persisted progress (collected cards).

final class ModuleSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<ModuleSummary>,
          ModuleSummary,
          FutureOr<ModuleSummary>
        >
    with $FutureModifier<ModuleSummary>, $FutureProvider<ModuleSummary> {
  /// Builds the [ModuleSummary] for [moduleId] by joining content (module +
  /// cards) with persisted progress (collected cards).
  ModuleSummaryProvider._({
    required ModuleSummaryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'moduleSummaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$moduleSummaryHash();

  @override
  String toString() {
    return r'moduleSummaryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ModuleSummary> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ModuleSummary> create(Ref ref) {
    final argument = this.argument as String;
    return moduleSummary(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ModuleSummaryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$moduleSummaryHash() => r'b3431f3c038e7d3dbfc1f422f3001d0ae0ca81e1';

/// Builds the [ModuleSummary] for [moduleId] by joining content (module +
/// cards) with persisted progress (collected cards).

final class ModuleSummaryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ModuleSummary>, String> {
  ModuleSummaryFamily._()
    : super(
        retry: null,
        name: r'moduleSummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Builds the [ModuleSummary] for [moduleId] by joining content (module +
  /// cards) with persisted progress (collected cards).

  ModuleSummaryProvider call(String moduleId) =>
      ModuleSummaryProvider._(argument: moduleId, from: this);

  @override
  String toString() => r'moduleSummaryProvider';
}
