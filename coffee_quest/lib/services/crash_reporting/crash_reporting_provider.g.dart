// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crash_reporting_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the active [CrashReportingService] — No-Op until Firebase is on.

@ProviderFor(crashReportingService)
final crashReportingServiceProvider = CrashReportingServiceProvider._();

/// Provides the active [CrashReportingService] — No-Op until Firebase is on.

final class CrashReportingServiceProvider
    extends
        $FunctionalProvider<
          CrashReportingService,
          CrashReportingService,
          CrashReportingService
        >
    with $Provider<CrashReportingService> {
  /// Provides the active [CrashReportingService] — No-Op until Firebase is on.
  CrashReportingServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'crashReportingServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$crashReportingServiceHash();

  @$internal
  @override
  $ProviderElement<CrashReportingService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CrashReportingService create(Ref ref) {
    return crashReportingService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CrashReportingService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CrashReportingService>(value),
    );
  }
}

String _$crashReportingServiceHash() =>
    r'cc548b37f448786384e8970b2bfae1c16677e439';
