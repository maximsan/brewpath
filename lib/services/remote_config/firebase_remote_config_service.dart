import 'package:coffee_quest/services/remote_config/remote_config_keys.dart';
import 'package:coffee_quest/services/remote_config/remote_config_service.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Firebase Remote Config-backed implementation. Wired in
/// `remote_config_provider.dart` once `kUseFirebase` is enabled.
class FirebaseRemoteConfigService implements RemoteConfigService {
  /// Creates a [FirebaseRemoteConfigService] (optional custom [config]).
  FirebaseRemoteConfigService([FirebaseRemoteConfig? config])
    : _config = config ?? FirebaseRemoteConfig.instance;

  final FirebaseRemoteConfig _config;

  @override
  Future<void> fetchAndActivate() async {
    await _config.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );
    await _config.setDefaults(const {
      RemoteConfigKeys.forceUpdateMinVersion: '0.0.0',
      RemoteConfigKeys.dailyLessonGoal: 1,
      RemoteConfigKeys.enableCardAnimations: false,
    });
    await _config.fetchAndActivate();
  }

  @override
  String getString(String key) => _config.getString(key);

  @override
  bool getBool(String key) => _config.getBool(key);

  @override
  int getInt(String key) => _config.getInt(key);

  @override
  double getDouble(String key) => _config.getDouble(key);
}
