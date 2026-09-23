// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_refresher.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's one refresher.
///
/// Kept alive because the queue is what makes two refreshes safe; a refresher
/// that came and went would be no queue at all.

@ProviderFor(reminderRefresher)
final reminderRefresherProvider = ReminderRefresherProvider._();

/// The app's one refresher.
///
/// Kept alive because the queue is what makes two refreshes safe; a refresher
/// that came and went would be no queue at all.

final class ReminderRefresherProvider
    extends
        $FunctionalProvider<
          ReminderRefresher,
          ReminderRefresher,
          ReminderRefresher
        >
    with $Provider<ReminderRefresher> {
  /// The app's one refresher.
  ///
  /// Kept alive because the queue is what makes two refreshes safe; a refresher
  /// that came and went would be no queue at all.
  ReminderRefresherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reminderRefresherProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reminderRefresherHash();

  @$internal
  @override
  $ProviderElement<ReminderRefresher> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReminderRefresher create(Ref ref) {
    return reminderRefresher(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReminderRefresher value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReminderRefresher>(value),
    );
  }
}

String _$reminderRefresherHash() => r'841ac2b3360dc6094013b927d9148f0a232f4cf6';
