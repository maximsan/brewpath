// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The active [ReminderScheduler].
///
/// iOS is the only platform this app ships, and the only one with a scheduler
/// behind it — so everywhere else, including `flutter_tester`, gets the no-op
/// and no test has to remember to override it.

@ProviderFor(reminderScheduler)
final reminderSchedulerProvider = ReminderSchedulerProvider._();

/// The active [ReminderScheduler].
///
/// iOS is the only platform this app ships, and the only one with a scheduler
/// behind it — so everywhere else, including `flutter_tester`, gets the no-op
/// and no test has to remember to override it.

final class ReminderSchedulerProvider
    extends
        $FunctionalProvider<
          ReminderScheduler,
          ReminderScheduler,
          ReminderScheduler
        >
    with $Provider<ReminderScheduler> {
  /// The active [ReminderScheduler].
  ///
  /// iOS is the only platform this app ships, and the only one with a scheduler
  /// behind it — so everywhere else, including `flutter_tester`, gets the no-op
  /// and no test has to remember to override it.
  ReminderSchedulerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reminderSchedulerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reminderSchedulerHash();

  @$internal
  @override
  $ProviderElement<ReminderScheduler> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReminderScheduler create(Ref ref) {
    return reminderScheduler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReminderScheduler value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReminderScheduler>(value),
    );
  }
}

String _$reminderSchedulerHash() => r'c8af411770c3154b58d59633922363f2727841bc';
