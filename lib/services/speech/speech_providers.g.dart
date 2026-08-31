// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'speech_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's voice.
///
/// Overridden with `NoOpSpeechService` in tests, so nothing reaches a platform
/// channel that `flutter_tester` does not register.

@ProviderFor(speechService)
final speechServiceProvider = SpeechServiceProvider._();

/// The app's voice.
///
/// Overridden with `NoOpSpeechService` in tests, so nothing reaches a platform
/// channel that `flutter_tester` does not register.

final class SpeechServiceProvider
    extends $FunctionalProvider<SpeechService, SpeechService, SpeechService>
    with $Provider<SpeechService> {
  /// The app's voice.
  ///
  /// Overridden with `NoOpSpeechService` in tests, so nothing reaches a platform
  /// channel that `flutter_tester` does not register.
  SpeechServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'speechServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$speechServiceHash();

  @$internal
  @override
  $ProviderElement<SpeechService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SpeechService create(Ref ref) {
    return speechService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SpeechService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SpeechService>(value),
    );
  }
}

String _$speechServiceHash() => r'8e768e48661eafdb82a71e2d96736d078456b24d';

/// Whether this device can speak the content's language.
///
/// Asked once and cached, because the answer is a property of the device and
/// its installed voices, not of the term being read.

@ProviderFor(canSpeakContentLanguage)
final canSpeakContentLanguageProvider = CanSpeakContentLanguageProvider._();

/// Whether this device can speak the content's language.
///
/// Asked once and cached, because the answer is a property of the device and
/// its installed voices, not of the term being read.

final class CanSpeakContentLanguageProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether this device can speak the content's language.
  ///
  /// Asked once and cached, because the answer is a property of the device and
  /// its installed voices, not of the term being read.
  CanSpeakContentLanguageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'canSpeakContentLanguageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$canSpeakContentLanguageHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return canSpeakContentLanguage(ref);
  }
}

String _$canSpeakContentLanguageHash() =>
    r'85ca0b64b93705e6269e34d6ccc88b7050d34cef';
