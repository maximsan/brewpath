import 'package:brew_path/services/remote_config/noop_remote_config_service.dart';
import 'package:brew_path/services/remote_config/remote_config_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Activation: import + return FirebaseRemoteConfigService() once kUseFirebase
// is true (see lib/core/config/firebase_flags.dart).
// import 'package:brew_path/services/remote_config/firebase_remote_config_service.dart';

part 'remote_config_provider.g.dart';

/// Provides the active [RemoteConfigService] — No-Op until Firebase is on.
@riverpod
RemoteConfigService remoteConfigService(Ref ref) =>
    const NoOpRemoteConfigService();
// To activate Firebase: => FirebaseRemoteConfigService();
