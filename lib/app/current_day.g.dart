// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_day.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's clock, handed out as a function so the caller decides *when* to
/// read it.
///
/// One seam: override this and every day and every window in the app moves
/// with it. A function rather than an instant because elapsed time and the
/// calendar day want opposite things — see [currentDayProvider] (ADR-0030).

@ProviderFor(appClock)
final appClockProvider = AppClockProvider._();

/// The app's clock, handed out as a function so the caller decides *when* to
/// read it.
///
/// One seam: override this and every day and every window in the app moves
/// with it. A function rather than an instant because elapsed time and the
/// calendar day want opposite things — see [currentDayProvider] (ADR-0030).

final class AppClockProvider
    extends
        $FunctionalProvider<
          DateTime Function(),
          DateTime Function(),
          DateTime Function()
        >
    with $Provider<DateTime Function()> {
  /// The app's clock, handed out as a function so the caller decides *when* to
  /// read it.
  ///
  /// One seam: override this and every day and every window in the app moves
  /// with it. A function rather than an instant because elapsed time and the
  /// calendar day want opposite things — see [currentDayProvider] (ADR-0030).
  AppClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appClockProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appClockHash();

  @$internal
  @override
  $ProviderElement<DateTime Function()> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DateTime Function() create(Ref ref) {
    return appClock(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime Function() value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime Function()>(value),
    );
  }
}

String _$appClockHash() => r'73ebbb27a4d882a6223d3afb8527e350a239a852';

/// The local calendar day the app is currently showing.
///
/// Read once and cached until the rollover refreshes it, so every surface
/// derived against today agrees on which day that is. A window measured in
/// elapsed hours calls [appClockProvider] per read instead: it wants the
/// moment, not the day the app settled on (ADR-0030).

@ProviderFor(currentDay)
final currentDayProvider = CurrentDayProvider._();

/// The local calendar day the app is currently showing.
///
/// Read once and cached until the rollover refreshes it, so every surface
/// derived against today agrees on which day that is. A window measured in
/// elapsed hours calls [appClockProvider] per read instead: it wants the
/// moment, not the day the app settled on (ADR-0030).

final class CurrentDayProvider
    extends $FunctionalProvider<DateTime, DateTime, DateTime>
    with $Provider<DateTime> {
  /// The local calendar day the app is currently showing.
  ///
  /// Read once and cached until the rollover refreshes it, so every surface
  /// derived against today agrees on which day that is. A window measured in
  /// elapsed hours calls [appClockProvider] per read instead: it wants the
  /// moment, not the day the app settled on (ADR-0030).
  CurrentDayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentDayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentDayHash();

  @$internal
  @override
  $ProviderElement<DateTime> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DateTime create(Ref ref) {
    return currentDay(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$currentDayHash() => r'99da67adc57e8b34cfd7e160be3e8cc3bf5e165e';
